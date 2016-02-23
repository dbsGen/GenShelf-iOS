//
//  GSPageItem.h
//  GenShelf
//
//  Created by Gen on 16/2/23.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GSPageItem : NSObject

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) NSString *pageUrl;
@property (nonatomic, strong) NSString *thumUrl;
@property (nonatomic, strong) NSString *imageUrl;

@end
