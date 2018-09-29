//
//  YHCacheURLProtocol.m
//  内存管理
//
//  Created by yh on 2018/9/26.
//  Copyright © 2018年 YH. All rights reserved.
//

#import "YHCacheURLProtocol.h"

#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/SDImageCache.h>
#import "SDWebImageManager.h"
#import "SDWebImageCodersManager.h"

static NSString * const URLProtocolHandledKey = @"URLProtocolHandledKey";


@interface YHCacheURLProtocol ()

@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation YHCacheURLProtocol


/*
 （1）.处理返回YES，不处理返回NO
 （2）.打标签，已经处理过的不在处理
 */
+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSString *url = request.URL.absoluteString;
    if ([url containsString:@".jpg"] || [url containsString:@".jpeg"] || [url containsString:@".png"]) {
        
        //处理过的，放过
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
    NSString *url = self.request.URL.absoluteString;
//    NSString *path = [[SDImageCache sharedImageCache] defaultCachePathForKey:url];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIImage *image = [[SDWebImageManager sharedManager].imageCache imageFromCacheForKey:url];
       
        if (image) {
            NSData *data = [[SDWebImageCodersManager sharedInstance] encodedDataWithImage:image format:SDImageFormatUndefined];
            
            NSURLResponse *res = [[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:@"" expectedContentLength:data.length textEncodingName:@""];
            
            [self.client URLProtocol:self didLoadData:data];
            [self.client URLProtocolDidFinishLoading:self];
        } else {
            
            //request处理过的放进去
            [NSURLProtocol setProperty:@YES forKey:URLProtocolHandledKey inRequest:mutableReqeust];
            
            [[SDWebImageManager sharedManager].imageDownloader downloadImageWithURL:self.request.URL options:SDWebImageDownloaderHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                
                if (error) {
                    [self.client URLProtocol:self didFailWithError:error];
                } else {
                    [[SDWebImageManager sharedManager].imageCache storeImageDataToDisk:data forKey:url];
                    [self.client URLProtocol:self didLoadData:data];
                    [self.client URLProtocolDidFinishLoading:self];
                }
                
            }];
        }
    });
    
    
    
//     举例：直接在 startLoading 中返回测试数据：
//
//    NSData *data = [@"testData" dataUsingEncoding:NSUTF8StringEncoding];
//    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:mutableReqeust.URL
//                                                        MIMEType:@"text/plain"
//                                           expectedContentLength:data.length
//                                                textEncodingName:nil];
//    [self.client URLProtocol:self
//          didReceiveResponse:response
//          cacheStoragePolicy:NSURLCacheStorageNotAllowed];
//
//    [self.client URLProtocol:self didLoadData:data];
//    [self.client URLProtocolDidFinishLoading:self];
//
//     作者：扬仔360
//     链接：https://www.jianshu.com/p/7dbe82c89c28
//     來源：简书
//     简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。
}

- (void)stopLoading
{
//    [self.connection cancel];
//    self.connection = nil;
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
