//
//  RootViewController.m
//  内存管理
//
//  Created by yh on 2018/9/28.
//  Copyright © 2018年 YH. All rights reserved.
//

#import "RootViewController.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [self.view insertSubview:img atIndex:0];
    
    [img sd_setImageWithURL:[NSURL URLWithString:@"https://vd3.bdstatic.com/mda-iiswzz76bp1vyrcq/mda-iiswzz76bp1vyrcq.jpg"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
