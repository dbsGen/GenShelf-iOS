//
//  GSLofiDefines.c
//  GenShelf
//
//  Created by Gen on 16/3/15.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#include "GSLofiDefines.h"
#include "GSLofiDataControl.h"

NSString *filterString(BOOL adult)
{
    NSString *ret = FILTER_STR;
    if (adult) {
        ret = [ret stringByReplacingOccurrencesOfString:@"{{adult}}" withString:[[[GSGlobals getDataControl:@"Lofi"] getProperty:kGSLofiAdultKey] boolValue] ? @"1":@"0"];
    }else {
        ret = [ret stringByReplacingOccurrencesOfString:@"{{adult}}" withString:@"0"];
    }
    return ret;
}