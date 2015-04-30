//
//  YYImageLoader.h
//  coreTextApp
//
//  Created by jumploo on 15-4-29.
//  Copyright (c) 2015年 zl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYImageLoader : NSObject
+(instancetype)shareInstance;
-(void)registerEvent;
-(void)unregisterEvent;
-(void)requestUrl:(NSString*)aUrl;
@end
