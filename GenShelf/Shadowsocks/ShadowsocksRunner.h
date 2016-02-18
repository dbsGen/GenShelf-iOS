//
// Created by clowwindy on 14-2-27.
// Copyright (c) 2014 clowwindy. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kShadowsocksIPKey @"proxy ip"
#define kShadowsocksPortKey @"proxy port"
#define kShadowsocksPasswordKey @"proxy password"
#define kShadowsocksEncryptionKey @"proxy encryption"
#define kShadowsocksProxyModeKey @"proxy mode"
#define kShadowsocksUsePublicServer @"public server"

#define SHADOWSOCKS_BIND_ERR    @"SHADOWSOCKS_BIND_ERR"
#define SHADOWSOCKS_LISTEN_ERR  @"SHADOWSOCKS_LISTEN_ERR"
#define SHADOWSOCKS_SUCCESS     @"SHADOWSOCKS_SUCCESS"


@interface ShadowsocksRunner : NSObject

+ (BOOL)settingsAreNotComplete;
+ (BOOL)runProxy:(NSString*)port;
+ (void)cancel;
+ (void)reloadConfig;
+ (BOOL)openSSURL:(NSURL *)url;
+ (NSURL *)generateSSURL;
+ (NSString *)configForKey:(NSString *)key;
+ (void)saveConfigForKey:(NSString *)key value:(NSString *)value;
+ (void)setUsingPublicServer:(BOOL)use;
+ (BOOL)isUsingPublicServer;


@end