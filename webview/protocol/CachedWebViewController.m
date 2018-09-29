//
//  CachedWebViewController.m
//  内存管理
//
//  Created by yh on 2018/9/27.
//  Copyright © 2018年 YH. All rights reserved.
//

#import "CachedWebViewController.h"

@interface CachedWebViewController ()

@end

@implementation CachedWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIDevice currentDevice].userInterfaceIdiom
    
    self.title = @"UIWebView";
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
    [self.view addSubview:webView];
    
    NSURL *url = [NSURL URLWithString:@"http://www.mafengwo.cn/"];
//    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    [webView loadRequest: [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:1]];
    
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end
