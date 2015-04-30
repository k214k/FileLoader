//
//  YYImageLoader.m
//  coreTextApp
//
//  Created by jumploo on 15-4-29.
//  Copyright (c) 2015年 zl. All rights reserved.
//

#import "YYImageLoader.h"
#import "YYOperation.h"
@interface YYImageLoader()
{
    NSOperationQueue* operationQueue;
}
@end
@implementation YYImageLoader

+(instancetype)shareInstance
{
    static YYImageLoader *imageLoader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageLoader = [YYImageLoader new];
        imageLoader->operationQueue = [[NSOperationQueue alloc] init];
        imageLoader->operationQueue.maxConcurrentOperationCount = 1;

    });
    return imageLoader;
}

-(void)registerEvent;
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showProgress:) name:@"progress" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(successData:) name:@"successData" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideProgress:) name:@"hideProgress" object:nil];
    
}

-(void)unregisterEvent
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)showProgress:(NSNotification*)notice
{
    
}

-(void)hideProgress:(NSNotification*)notice
{
    
}

-(void)successData:(NSNotification*)notice
{
    NSData* data = [notice.userInfo objectForKey:@"data"];
    if (data)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showImage" object:nil userInfo:notice.userInfo];
    }
}

-(void)requestUrl:(NSString*)aUrl
{
    YYOperation* tmp = [[YYOperation alloc]initUrl:aUrl block:nil];
    [[YYImageLoader shareInstance]->operationQueue addOperation:tmp];
}
@end
