//
//  YYOperation.h
//  coreTextApp
//
//  Created by jumploo on 15-4-29.
//  Copyright (c) 2015年 zl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//@protocol YYOperationDelegate
//@optional
//-(void)showProgress:(CGFloat)aProgress;
//@end
typedef void (^YYProgressorBlock)(CGFloat aProgressor);
@interface YYOperation : NSOperation

-(instancetype)initUrl:(NSString*)aUrl block:(YYProgressorBlock)aYYProgressorBlock;

@end
