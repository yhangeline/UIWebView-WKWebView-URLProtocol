//
//  WKWebViewController.m
//  内存管理
//
//  Created by yh on 2018/9/21.
//  Copyright © 2018年 YH. All rights reserved.
//

#import "WKWebViewController.h"
#import <WebKit/WebKit.h>
#import "NSURLProtocol+WKWebVIew.h"

@interface WKWebViewController () <WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *wkWebView;

@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WKWebView";
    
    [NSURLProtocol wk_registerScheme:@"http"];
    [NSURLProtocol wk_registerScheme:@"https"];
    
    [self.view addSubview:self.wkWebView];
    
//    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    
    NSURL *url = [NSURL URLWithString:@"http://www.mafengwo.cn/"];
    [self.wkWebView loadRequest: [NSURLRequest requestWithURL:url]];
}

- (WKWebView* )wkWebView {
    if (!_wkWebView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
        config.preferences = [[WKPreferences alloc]init];
        config.allowsInlineMediaPlayback = YES;
        config.selectionGranularity = YES;
        
        //自定义配置，一般用于js调用oc方法(OC拦截URL中的数据做自定义操作)
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        config.userContentController = userContentController;

        
        //JS注入 向网页中添加自己的JS方法
        NSString *scriptString = @"\
        var array = document.getElementsByTagName('img');\
        for (var i = 0; i < array.length; i++) {\
            (function(n){\
                array[n].onclick = function(){ \
                    var url =  array[n].src; \
                    window.webkit.messageHandlers.showImage.postMessage(url); \
                }; \
            })(i); \
        } \
        ";
        
        WKUserScript *script = [[WKUserScript alloc] initWithSource:scriptString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
        [userContentController addUserScript:script];
        
        [userContentController addScriptMessageHandler:self name:@"showImage"];
        
        _wkWebView = [[WKWebView alloc]initWithFrame:self.view.bounds configuration:config];
        _wkWebView.navigationDelegate = self;
//        _wkWebView.UIDelegate = self;
        //添加此属性可触发侧滑返回上一网页与下一网页操作
        _wkWebView.allowsBackForwardNavigationGestures = YES;
        
    }
    return _wkWebView;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:@"showImage"]) {
        NSLog(@"%@",message.body);
    }
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
    [NSURLProtocol wk_unregisterScheme:@"http"];
    [NSURLProtocol wk_unregisterScheme:@"https"];
}

@end
