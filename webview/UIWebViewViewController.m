//
//  UIWebViewViewController.m
//  内存管理
//
//  Created by yh on 2018/9/20.
//  Copyright © 2018年 YH. All rights reserved.
//

#import "UIWebViewViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@protocol WebExport <JSExport>
JSExportAs
(myLog ,
 - (void)myOCLog :(NSString *)string
 );
@end

@interface UIWebViewViewController () <UIWebViewDelegate,WebExport>

@end

@implementation UIWebViewViewController
{
    UIWebView *webView;
    JSContext *context;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"UIWebView";
    webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.delegate = self;
    [self.view addSubview:webView];
    
    
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"yh" ofType:@"html"] ];
//    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
}

/*
 oc中使用ARC方式管理内存（基于引用计数），但JavaScriptCore中使用的是垃圾回收方式，其中所有的引用都是强引用，但是我们不必担心其循环引用，js的垃圾回收能够打破这些强引用，有些情况需要考虑如下
 
 1.js调起OC回调的block中获取JSConetxt容易循环引用
 
 self.jsContext[@"jsCallNative"] = ^(NSString *paramer){
     // 会引起循环引用
     JSValue *value1 =  [JSValue valueWithNewObjectInContext:
     self.jsContext];
     // 不会引起循环引用
     JSValue *value =  [JSValue valueWithNewObjectInContext:
     [JSContext currentContext]];
 };
 
 2.JavaScriptCore中所有的引用都是强引用,所以在OC中需要存储JS中的值的时候，需要注意
 
 在oc中为了打破循环引用我们采用weak的方式，不过在JavaScriptCore中我们采用内存管理辅助对象JSManagedValue的方式，它能帮助引用技术和垃圾回收这两种内存管理机制之间进行正确的转换
 
 */

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    context =  [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    
    //JS调用OC的回调方法，是在子线程，所以需要更新OC中的UI的话，需要切换到主线程
    context[@"showInput"] = ^(NSString *str){
        NSLog(@"%@ %@",str,[NSThread currentThread]);
    };
    
    
    
    context[@"native"] = self;
    
    
    //oc调用JS
//    [webView stringByEvaluatingJavaScriptFromString:@"showAlert('杨浩')"];
    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('input').value = \"hahahaha\" "];
    /*
     var btns = document.getElementByTagName('button');
     for(int i = 0; i < btns.counts)
     */
    
//    JSValue *inputValue = context[@"showAlert"];
//  
//    [inputValue callWithArguments:@[@"hahaha"]];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

//JS调用OC的回调方法，是在子线程，所以需要更新OC中的UI的话，需要切换到主线程
- (void)myOCLog :(NSString *)string
{
    NSLog(@"%@",string);
    NSLog(@"%s  %@",__func__,[NSThread currentThread]);
}


- (void)dealloc{
    NSLog(@"%s",__func__);
}
@end
