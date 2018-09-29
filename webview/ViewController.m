//
//  ViewController.m
//  内存管理
//
//  Created by yh on 2018/9/18.
//  Copyright © 2018年 YH. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "NSURLProtocol+WKWebVIew.h"

@interface ViewController () <WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@end

@implementation ViewController
{
    UIProgressView *progress;
    WKUserContentController *userContentController;
    JSContext *jscontext;
}

/*
 // 注入JavaScript与原生交互协议
 // JS 端可通过 window.webkit.messageHandlers.<name>.postMessage(<messageBody>) 发送消息
 - (void)addScriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name;
 // 移除注入的协议, 在deinit方法中调用
 - (void)removeScriptMessageHandlerForName:(NSString *)name;
 
 // 通过WKUserScript注入需要执行的JavaScript代码
 - (void)addUserScript:(WKUserScript *)userScript;
 // 移除所有注入的JavaScript代码
 - (void)removeAllUserScripts;
 

 */

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WKWebView";
//    [NSURLProtocol wk_registerScheme:@"http"];
//    [NSURLProtocol wk_registerScheme:@"https"];
    //配置环境
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc] init];
    
    
    userContentController = [[WKUserContentController alloc]init];
    //注册方法
    [userContentController addScriptMessageHandler:self name:@"sayhello"];//注册一个name为sayhello的js方法
    
    
    //注入JS代码
    NSString *javaScriptSource = @"alert(\"WKUserScript注入js\");";
    WKUserScript *script = [[WKUserScript alloc] initWithSource:javaScriptSource injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [userContentController addUserScript:script];
    
    
    
    configuration.userContentController = userContentController;

    
    WKWebView *web = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    [self.view addSubview:web];
    

    
    /* 加载服务器url的方法*/
//    NSString *url = @"https://www.baidu.com";
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"yh" ofType:@"html"] ];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0f];
    [web loadRequest:request];
    
    web.navigationDelegate = self;
    web.UIDelegate = self;
    
//    progress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 64, 414, 2)];
//    progress.progressTintColor = [UIColor greenColor];
//    progress.trackTintColor = [UIColor clearColor];
//    [self.view addSubview:progress];
//
//
//    [web addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
//    [web addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
//{
//    if ([keyPath isEqualToString:@"title"]) {
//        self.title = [change valueForKey:@"new"];
//    } else {
//        [progress setProgress:[change[@"new"] floatValue] animated:YES];
//    }
//}

#pragma mark - WKNavigationDelegate
/* 页面开始加载 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
}
/* 开始返回内容 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}
/* 页面加载完成 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    //say()是JS方法名，completionHandler是异步回调block
//    [webView evaluateJavaScript:@"showAlert()" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//            NSLog(@"result : %@",result);
//        NSLog(@"%@",[NSThread currentThread]);
//    }];

}
/* 页面加载失败 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    
}
/* 在发送请求之前，决定是否跳转 */
// 决定导航的动作，通常用于处理跨域的链接能否导航。
// WebKit对跨域进行了安全检查限制，不允许跨域，因此我们要对不能跨域的链接单独处理。
// 但是，对于Safari是允许跨域的，不用这么处理。
// 这个是决定是否Request
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    
    //不允许跳转
    //decisionHandler(WKNavigationActionPolicyCancel);
}
/* 在收到响应后，决定是否跳转 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    NSLog(@"%@",navigationResponse.response.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}


#pragma mark - WKUIDelegate
// 创建一个新的WebView
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    return [[WKWebView alloc] init];
}
// 输入框
/** 对应js的prompt方法
 webView中弹出输入框时调用, 两个按钮 和 一个输入框
 
 @param webView webView description
 @param prompt 提示信息
 @param defaultText 默认提示文本
 @param frame 可用于区分哪个窗口调用的
 @param completionHandler 输入框消失的时候调用, 回调给JS, 参数为输入的内容
 */

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    completionHandler(@"http");
}
// 确认框
/** 对应js的confirm方法
 webView中弹出选择框时调用, 两个按钮
 
 @param webView webView description
 @param message 提示信息
 @param frame 可用于区分哪个窗口调用的
 @param completionHandler 确认框消失的时候调用, 回调给JS, 参数为选择结果: YES or NO
 */
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择" message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"同意" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"不同意" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}
// 警告框
/**
 webView中弹出警告框时调用, 只能有一个按钮
 
 @param webView webView
 @param message 提示信息
 @param frame 可用于区分哪个窗口调用的
 @param completionHandler 警告框消失的时候调用, 回调给JS
 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"我知道了" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"%@",[NSThread currentThread]);
    NSLog(@"name:%@",message.name);
    NSLog(@"body:%@",message.body);
    NSLog(@"frameInfo:%@",message.frameInfo);
}


- (void)dealloc
{
    //这里需要注意，前面增加过的方法一定要remove掉。
    [userContentController removeScriptMessageHandlerForName:@"sayhello"];
}

@end
