//
//  YYImageView.h
//  coreTextApp
//
//  Created by jumploo on 15-4-29.
//  Copyright (c) 2015年 zl. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol YYImageViewDelegate
@optional
@end
@interface YYImageView : UIImageView
-(void)setImage:(UIImage *)aImage url:(NSString*)aUrl rect:(CGRect)aRect;
@end
