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

- (void)insertPicture:(NSData *)data book:(GSBookItem *)book page:(GSPageItem *)page;
- (NSString *)path:(GSBookItem *)book page:(GSPageItem *)page;

@end
