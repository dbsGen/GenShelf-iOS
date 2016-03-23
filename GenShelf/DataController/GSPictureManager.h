//
//  GSPictureManager.h
//  GenShelf
//
//  Created by Gen on 16/2/28.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSBookItem.h"
#import "GSPageItem.h"

@interface GSPictureManager : NSObject

+ (GSPictureManager *)defaultManager;

- (NSString *)insertCachePicture:(NSData *)data source:(NSString *)source keyword:(NSString *)keyword;
- (NSString *)path:(NSString *)source keyword:(NSString *)keyword;

- (void)insertPicture:(NSData *)data book:(GSBookItem *)book page:(GSPageItem *)page;
- (NSString *)fullPath:(NSString *)path;
- (NSString *)path:(GSBookItem *)book page:(GSPageItem *)page;
- (NSString *)path:(GSBookItem *)book;
- (void)deleteBook:(GSBookItem *)book;
- (void)deletePage:(GSPageItem *)page;

- (void)update1_2;

@end
