//
//  YYFileManager.h
//  coreTextApp
//
//  Created by jumploo on 15-4-30.
//  Copyright (c) 2015年 zl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYFileManager : NSObject
+(BOOL)isExist:(NSString*)aUrl;
+(NSData*)getFile:(NSString*)aUrl;
+(BOOL)saveFile:(NSString*)aUrl data:(NSData*)aData;
@end
