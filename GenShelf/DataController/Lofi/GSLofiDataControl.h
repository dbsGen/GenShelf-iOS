//
//  GSLofiDataControl.h
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSDataControl.h"
#import "GSTask.h"

#define kGSLofiAdultKey @"Adult"
#define kGSLofiSizeKey @"Size"

@interface GSLofiDataControl : GSDataControl

@property (nonatomic, readonly) GSTaskQueue *pageTaskQueue;

@end

