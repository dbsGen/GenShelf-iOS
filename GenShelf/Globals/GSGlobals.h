//
//  GSGlobals.h
//  GenShelf
//
//  Created by Gen on 16/2/18.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface GSGlobals : NSObject

+ (void)turnProxy:(BOOL)on;
+ (BOOL)isProxyOn;

+ (void)setCurrentPort:(NSString*)currentPort;
+ (NSString *)currentPort;

+ (void)setServerIP:(NSString*)serverIP;
+ (NSString *)serverIP;
+ (void)setServerPort:(NSString*)serverPort;
+ (NSString *)serverPort;

+ (void)setPassword:(NSString*)password;
+ (NSString*)password;
+ (void)setEncryptionType:(NSString*)encryptionType;
+ (NSString*)encryptionType;
+ (NSArray *)encryptionTypes;

+ (void)runShadowsocksThread;
+ (void)resetShadowsocks;
+ (void)reloadShadowsocksConfig;

+ (ASIHTTPRequest *)requestForURL:(NSURL *)url;

@end
