//
//  GSLofiDataControl.m
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSLofiDataControl.h"

#define URL_HOST @"http://lofi.e-hentai.org/"

@implementation GSLofiDataControl

- (id)init {
    self = [super init];
    if (self) {
        _name = @"Lofi";
    }
    return self;
}

+ (NSURL *)mainUrl {
    return [NSURL URLWithString:URL_HOST];
}

#undef URL_HOST

@end
