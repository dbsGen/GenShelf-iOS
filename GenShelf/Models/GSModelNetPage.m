//
//  GSModelNetPage.m
//  GenShelf
//
//  Created by Gen on 16/2/25.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSModelNetPage.h"

@implementation GSModelNetPage

- (void)setPageStatus:(GSPageStatus)pageStatus {
    self.status = [NSNumber numberWithInteger:pageStatus];
}

- (GSPageStatus)pageStatus {
    return  [self.status integerValue];
}

@end
