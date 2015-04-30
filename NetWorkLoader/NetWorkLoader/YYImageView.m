//
//  YYImageView.m
//  coreTextApp
//
//  Created by jumploo on 15-4-29.
//  Copyright (c) 2015年 zl. All rights reserved.
//

#import "YYImageView.h"
#import "YYFileManager.h"
#import "YYImageLoader.h"
@interface YYImageView()
{
    UIImage* placeholderImage;
    NSString* urlStr;
    CGRect imageRect;
}

@end

@implementation YYImageView
-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showImage:) name:@"showImage" object:nil];
}

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showImage:) name:@"showImage" object:nil];
    }
    return self;
}

-(void)showImage:(NSNotification*)notice
{
    __weak __typeof(self) wSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData* data = [notice.userInfo objectForKey:@"data"];
        wSelf.image = [UIImage imageWithData:data];
        [[YYImageLoader shareInstance]unregisterEvent];
    });

}

-(void)setImage:(UIImage *)aImage url:(NSString*)aUrl rect:(CGRect)aRect
{
    if (aImage)
    {
        self.image = [aImage copy];
    }
    if ([aUrl length])
    {
        urlStr = [aUrl copy];
    }
    if ([aUrl length] == 0)
    {
        return;
    }
    imageRect = aRect;
    if ([YYFileManager isExist:aUrl])
    {
        self.image = [UIImage imageWithData:[YYFileManager getFile:aUrl]];
    }
    else
    {
        [[YYImageLoader shareInstance]registerEvent];
        [[YYImageLoader shareInstance]requestUrl:aUrl];
    }
}

@end
