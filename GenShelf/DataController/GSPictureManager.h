//
//  GSPictureManager.h
//  GenShelf
//
//  Created by Gen on 16/2/28.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSModelNetBook.h"
#import "GSModelNetPage.h"

@interface GSPictureManager : NSObject

+ (GSPictureManager *)defaultManager;

- (NSString *)insertCachePicture:(NSData *)data source:(NSString *)source keyword:(NSString *)keyword;
- (NSString *)path:(NSString *)source keyword:(NSString *)keyword;

- (void)insertPicture:(NSData *)data book:(GSModelNetBook *)book page:(GSModelNetPage *)page;
- (NSString *)fullPath:(NSString *)path;
- (NSString *)path:(GSModelNetBook *)book page:(GSModelNetPage *)page;
- (NSString *)path:(GSModelNetBook *)book;
- (void)deleteBook:(GSModelNetBook *)book;
- (void)deletePage:(GSModelNetPage *)page;

- (void)update1_2;

@end
