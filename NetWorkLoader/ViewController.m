//
//  ViewController.m
//  NetWorkLoader
//
//  Created by jumploo on 15-4-30.
//  Copyright (c) 2015年 zl. All rights reserved.
//

#import "ViewController.h"
#import "YYImageView.h"
@interface ViewController ()
@property (strong, nonatomic) IBOutlet YYImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.imageView setImage:nil url:@"http://farm6.staticflickr.com/5505/9824098016_0e28a047c2_b_d.jpg" rect:self.imageView.frame];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
