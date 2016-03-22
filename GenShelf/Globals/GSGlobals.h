//
//  GSGlobals.h
//  GenShelf
//
//  Created by Gen on 16/2/18.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "GSDataControl.h"

@interface GSGlobals : NSObject

#pragma mark - settings

+ (void)setAdult:(BOOL)adult;
+ (BOOL)isAdult;

#pragma mark - proxy

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

+ (void)registerDataControl:(GSDataControl*)dataControl;
+ (NSArray<NSString*>*)dataControlNames;
+ (GSDataControl *)getDataControl:(NSString *)name;
+ (NSString *)selectedDataControl;
+ (void)setSelectedDataControl:(NSString *)selectedNumber;
+ (GSDataControl *)dataControl;

+ (ASIHTTPRequest *)requestForURL:(NSURL *)url;

+ (GSTask *)processBook:(GSBookItem *)book;
+ (GSTask *)downloadBook:(GSBookItem *)book;

@end
