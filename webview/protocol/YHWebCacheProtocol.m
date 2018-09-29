//
//  YHWebCacheProtocol.m
//  内存管理
//
//  Created by yh on 2018/9/28.
//  Copyright © 2018年 YH. All rights reserved.
//

#import "YHWebCacheProtocol.h"

static NSString * const URLProtocolHandledKey = @"URLProtocolHandledKey";

@interface YHWebCacheProtocol () <NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation YHWebCacheProtocol


/*
 （1）.处理返回YES，不处理返回NO
 （2）.打标签，已经处理过的不在处理
 */
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{

    NSString *urlScheme = [[request URL] scheme];
    if ([urlScheme caseInsensitiveCompare:@"http"] == NSOrderedSame || [urlScheme caseInsensitiveCompare:@"https"] == NSOrderedSame){
        if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request]) {
            return NO;
        }
        return YES;
    }
    
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

//开始加载时自动调用 ，作用大了去了，该方法里判断，有缓存时加载缓存，没缓存再去请求
- (void)startLoading
{
    
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    //request处理过的放进去
    
    NSCachedURLResponse *urlResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:[self request]];
    if (urlResponse) {
        //如果缓存存在，则使用缓存。并且开启异步线程去更新缓存
        [self.client URLProtocol:self didReceiveResponse:urlResponse.response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:urlResponse.data];
        [self.client URLProtocolDidFinishLoading:self];
        return;
    }
    
    
    [NSURLProtocol setProperty:@YES forKey:URLProtocolHandledKey inRequest:mutableReqeust];
    self.session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:mutableReqeust completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            [self.client URLProtocol:self didFailWithError:error];
        } else {
            
            NSCachedURLResponse *cachedRes = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
            [[NSURLCache sharedURLCache] storeCachedResponse:cachedRes forRequest:self.request];
            
            [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            [self.client URLProtocol:self didLoadData:urlResponse.data];
            [self.client URLProtocolDidFinishLoading:self];
        }
        
    }];
    [task resume];
}

- (void)stopLoading
{
    [self.session invalidateAndCancel];
}

//- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//}
//
//- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    [self.client URLProtocol:self didLoadData:data];
//}
//
//- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
//    [self.client URLProtocolDidFinishLoading:self];
//}
//
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//    [self.client URLProtocol:self didFailWithError:error];
//}

@end
