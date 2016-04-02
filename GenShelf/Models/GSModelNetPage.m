//
//  GSModelNetPage.m
//  GenShelf
//
//  Created by Gen on 16/2/25.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSModelNetPage.h"
#import "GSPictureManager.h"
#import "GCoreDataManager.h"
#import "GSModelNetBook.h"

@implementation GSModelNetPage

- (void)setPageStatus:(GSPageStatus)pageStatus {
    self.status = [NSNumber numberWithInteger:pageStatus];
}

- (GSPageStatus)pageStatus {
    return  [self.status integerValue];
}

- (void)checkStatus {
    if (![[NSFileManager defaultManager] fileExistsAtPath:self._imagePath]) {
        self.pageStatus = GSPageStatusNotStart;
    }
}

- (NSString *)imagePath {
    if (self.pageStatus == GSPageStatusComplete) {
        return [self _imagePath];
    }
    return nil;
}

- (NSString *)_imagePath {
    return [[GSPictureManager defaultManager] path:self.book
                                              page:self];
}

- (void)requestImage {
    self.pageStatus = GSPageStatusProgressing;
    [self save];
    [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_ITEM_REQUEST_IMAGE
                                                        object:self
                                                      userInfo:@{@"src": self.imageUrl}];
}

- (void)complete {
    self.pageStatus = GSPageStatusComplete;
    [self save];
    [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_ITEM_SET_IMAGE
                                                        object:self
                                                      userInfo:@{@"src": self.imageUrl}];
    [self.book pageProgress];
}

- (void)reset {
    self.pageStatus = GSPageStatusNotStart;
    [self save];
}

- (void)awakeFromFetch {
    if (self.source == nil) {
        self.source = @"Lofi";
    }
}

@end
