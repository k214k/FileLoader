//
//  YYFileManager.m
//  coreTextApp
//
//  Created by jumploo on 15-4-30.
//  Copyright (c) 2015年 zl. All rights reserved.
//

#import "YYFileManager.h"
#import <CommonCrypto/CommonDigest.h>
static unsigned char kPNGSignatureBytes[8] = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A};
static BOOL pngFile(NSData* aData)
{
    BOOL isPng = NO;
    NSData *pngSignatureData = [NSData dataWithBytes:kPNGSignatureBytes length:8];
    if ([aData length] >= [pngSignatureData length])
    {
        if ([[aData subdataWithRange:NSMakeRange(0, [pngSignatureData length])]isEqualToData:pngSignatureData])
        {
            isPng = YES;
        }
    }
    return isPng;
}

NSString *cachedFileNameForKey(NSString *key)
{
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    return filename;
}

@implementation YYFileManager
+(NSString*)fullPath:(NSString*)aUrl
{
    NSString* path = cachedFileNameForKey(aUrl);
    NSString* fullPath = [NSString stringWithFormat:@"%@/%@",[[self class]filePath],path];
    return fullPath;
}

+(BOOL)isExist:(NSString*)aUrl
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[[self class] fullPath:aUrl]])
    {
        return YES;
    }
    return NO;
}

+(NSData*)getFile:(NSString*)aUrl
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager contentsAtPath:[[self class] fullPath:aUrl]];
}

+(BOOL)saveFile:(NSString*)aUrl data:(NSData*)aData
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager createFileAtPath:[[self class] fullPath:aUrl] contents:aData attributes:nil])
    {
        return YES;
    }
    return NO;
}

+(NSString*)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSString* lastCommponent = [aStr lastPathComponent];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/YYfile",documentsDirectory];
    if (![fileManager fileExistsAtPath:path])
    {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}
@end
