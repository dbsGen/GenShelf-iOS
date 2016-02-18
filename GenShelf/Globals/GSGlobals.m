//
//  GSGlobals.m
//  GenShelf
//
//  Created by Gen on 16/2/18.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSGlobals.h"
#import "ShadowsocksRunner.h"

#define kTurnProxy      @"GSGTurnProxy"
#define kCurrentPort    @"GSGCurrentPort"

#define kDefaultCurrentPort @"41080"
#define kDefaultServerIP    @"192.168.1.10"
#define kDefaultServerPort  @"8090"
#define kDefaultPassword    @""
#define kDefaultEncryptionType  @"aes-256-cfb"

static BOOL shadowsocks_running = NO;

@implementation GSGlobals

+ (void)turnProxy:(BOOL)on {
    shadowsocks_running = on;
    if (!shadowsocks_running) {
        [self resetShadowsocks];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:shadowsocks_running]
                                              forKey:kTurnProxy];
}

+ (BOOL)isProxyOn {
    NSNumber *ret = [[NSUserDefaults standardUserDefaults] objectForKey:kTurnProxy];
    if (!ret) {
        BOOL r = NO;
        [self turnProxy:r];
        return r;
    }
    return [ret boolValue];
}

+ (void)setCurrentPort:(NSString *)currentPort {
    [[NSUserDefaults standardUserDefaults] setObject:currentPort
                                              forKey:kCurrentPort];
}

+ (NSString*)currentPort {
    NSString *ret = [[NSUserDefaults standardUserDefaults] stringForKey:kCurrentPort];
    if (!ret) {
        ret = kDefaultCurrentPort;
        [self setCurrentPort:ret];
    }
    return ret;
}

+ (void)setServerIP:(NSString *)serverIP {
    [ShadowsocksRunner saveConfigForKey:kShadowsocksIPKey value:serverIP];
}

+ (NSString*)serverIP {
    NSString *ret = [ShadowsocksRunner configForKey:kShadowsocksIPKey];
    if (!ret) {
        ret = kDefaultServerIP;
        [self setServerIP:ret];
    }
    return ret;
}

+ (void)setServerPort:(NSString *)serverPort {
    [ShadowsocksRunner saveConfigForKey:kShadowsocksPortKey value:serverPort];
}

+ (NSString *)serverPort {
    NSString *ret = [ShadowsocksRunner configForKey:kShadowsocksPortKey];
    if (!ret) {
        ret = kDefaultServerPort;
        [self setServerIP:ret];
    }
    return ret;
}

+ (void)setPassword:(NSString *)password {
    [ShadowsocksRunner saveConfigForKey:kShadowsocksPasswordKey value:password];
}

+ (NSString *)password {
    NSString *ret = [ShadowsocksRunner configForKey:kShadowsocksPasswordKey];
    if (!ret) {
        ret = kDefaultPassword;
        [self setServerIP:ret];
    }
    return ret;
}

+ (void)setEncryptionType:(NSString *)encryptionType {
    [ShadowsocksRunner saveConfigForKey:kShadowsocksEncryptionKey value:encryptionType];
}

+ (NSString *)encryptionType {
    NSString *ret = [ShadowsocksRunner configForKey:kShadowsocksEncryptionKey];
    if (!ret) {
        ret = kDefaultEncryptionType;
        [self setServerIP:ret];
    }
    return ret;
}

#undef GetValue

+ (NSArray *)encryptionTypes {
    return @[@"aes-256-cfb",
             @"aes-192-cfb",
             @"aes-128-cfb",
             @"bf-cfb",
             @"camellia-128-cfb",
             @"camellia-192-cfb",
             @"camellia-256-cfb",
             @"cast5-cfb",
             @"des-cfb",
             @"idea-cfb",
             @"rc2-cfb",
             @"rc4",
             @"seed-cfb"];
}

+ (void)runShadowsocksThread {
    shadowsocks_running = [self isProxyOn];
    dispatch_queue_t proxy = dispatch_queue_create("proxy", NULL);
    dispatch_async(proxy, ^{
        [ShadowsocksRunner reloadConfig];
        while (true) {
            if (shadowsocks_running) {
                if ([ShadowsocksRunner runProxy:[GSGlobals currentPort]]) {
                    sleep(1);
                } else {
                    sleep(2);
                }
            }else {
                sleep(2);
            }
        }
    });
}

+ (void)resetShadowsocks {
    [ShadowsocksRunner cancel];
}

+ (void)reloadShadowsocksConfig {
    [ShadowsocksRunner reloadConfig];
}

@end
