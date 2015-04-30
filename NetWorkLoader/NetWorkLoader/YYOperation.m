//
//  YYOperation.m
//  coreTextApp
//
//  Created by jumploo on 15-4-29.
//  Copyright (c) 2015年 zl. All rights reserved.
//

#import "YYOperation.h"
#import "YYFileManager.h"

@interface YYOperation()<NSURLConnectionDataDelegate>
{

    NSURLConnection* connect;
    NSString* urlStr;
    dispatch_queue_t queue;
    NSMutableURLRequest *request;
    YYProgressorBlock progressorBlock;
    NSOutputStream* outPutStream;
    NSSet *runLoopModes;
    NSUInteger totalData;
    NSMutableData *responseData;
}
@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@property (nonatomic, copy) NSURLResponse *response;
@end
@implementation YYOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

+ (void)networkRequestThreadEntryPoint:(id)__unused object {
    @autoreleasepool {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

+ (NSThread *)networkRequestThread
{
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

-(void)dealloc
{

}

-(instancetype)initUrl:(NSString*)aUrl block:(YYProgressorBlock)aYYProgressorBlock
{
    self = [super init];
    if (self)
    {
        queue = dispatch_queue_create("com.YY.url", DISPATCH_QUEUE_CONCURRENT);//DISPATCH_QUEUE_SERIAL
        [self reset];
        if (aYYProgressorBlock)
        {
            progressorBlock = [aYYProgressorBlock copy];
            
        }
        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:aUrl]];
        
        urlStr = [aUrl copy];
        runLoopModes = [NSSet setWithObject:NSRunLoopCommonModes];
        
    }
    return self;
}

-(void)createDownTask
{
    outPutStream = [NSOutputStream outputStreamToMemory];
    connect = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    for (NSString* set in runLoopModes)
    {
        [connect scheduleInRunLoop:runLoop forMode:set];
        [outPutStream scheduleInRunLoop:runLoop forMode:set];
    }
    [outPutStream open];
    [connect start];
    
}

-(void)reset
{
    self.executing = NO;
    self.finished = NO;
    progressorBlock = nil;
    urlStr = nil;
}

-(void)start
{
    @synchronized(self)
    {
        if (self.isCancelled)
        {
            self.finished = YES;
            return;
        }
        
        self.executing = YES;
        [self performSelector:@selector(createDownTask) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO modes:[runLoopModes allObjects]];
    }
}

-(void)cancel
{
    @synchronized(self)
    {
        if ([urlStr length]&&(!self.isExecuting))
        {
            [super cancel];
            [self performSelectorOnMainThread:@selector(cancelInter) withObject:[[self class]networkRequestThread ] waitUntilDone:NO modes:[runLoopModes allObjects]];
        }
       
    }
}

-(void)cancelInter
{
    NSDictionary* dic = [NSDictionary dictionaryWithObject:[request URL] forKey:NSURLErrorFailingURLErrorKey];
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:dic];
    
    if (!self.isFinished)
    {
        if (connect)
        {
            [connect cancel];
        }
        [self performSelectorInBackground:@selector(connection:didFailWithError:) withObject:error];
    }

}
- (void)setFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isConcurrent
{
    return YES;
}

- (void)connection:(NSURLConnection __unused*)connection didReceiveResponse:(NSURLResponse *)response
{
    self.response = [response copy];
    responseData = [NSMutableData dataWithCapacity:self.response.expectedContentLength];
}

- (void)connection:(NSURLConnection __unused*)connection didReceiveData:(NSData *)data
{
    NSUInteger length = [data length];
    totalData += length;
    
    if (length)
    {
        while (YES)
        {
            if ([outPutStream hasSpaceAvailable])
            {
                NSUInteger stepLength = 0;
                NSUInteger sumDataLength = 0;
                const uint8_t *buffer = (uint8_t *)[data bytes];
                while (sumDataLength < length)
                {
                    stepLength = [outPutStream write:&buffer[sumDataLength] maxLength:(length - sumDataLength)];
                    if (stepLength == -1)
                    {
                        break;
                    }
                    sumDataLength += stepLength;
                }
                goto jump;
            }
            if ([outPutStream streamError])
            {
                [connect cancel];
                self.finished = YES;
                [self performSelectorInBackground:@selector(connection:didFailWithError:) withObject:[outPutStream streamError]];
                return;
            }
        }
    }
jump:
    //进度条
    if (progressorBlock)
    {
        CGFloat progress = (CGFloat)totalData / self.response.expectedContentLength;
        NSDictionary* dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:progress] forKey:@"total"];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"progress" object:nil userInfo:dic];
        });
    }

}

- (void)connectionDidFinishLoading:(NSURLConnection __unused*)connection
{
    responseData = [outPutStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
    
    [outPutStream close];
    if (outPutStream)
    {
        outPutStream = nil;
    }
    if (responseData)
    {
        NSDictionary* dic = [NSDictionary dictionaryWithObject:responseData forKey:@"data"];
        dispatch_async(queue, ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"successData" object:nil userInfo:dic];
            [YYFileManager saveFile:urlStr data:responseData];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"hideProgress" object:nil userInfo:nil];
            });
            
        });
    }
    connect = nil;
    self.finished = YES;
    self.executing = NO;
    progressorBlock = nil;
}

- (void)connection:(NSURLConnection __unused*)connection didFailWithError:(NSError *)error
{
    [outPutStream close];
    if (outPutStream)
    {
        outPutStream = nil;
    }
    connect = nil;
    self.finished = YES;
    self.executing = NO;
    responseData = nil;
    progressorBlock = nil;
    dispatch_sync(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideProgress" object:nil userInfo:nil];
    });
}

@end
