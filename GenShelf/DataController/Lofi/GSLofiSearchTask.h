//
//  GSSearchTask.h
//  GenShelf
//
//  Created by Gen on 16/3/15.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSRequestTask.h"

@interface GSLofiSearchTask : GSRequestTask {
    NSOperationQueue *_queue;
}

@property (nonatomic, readonly) NSString *searchKey;

- (id)initWithKey:(NSString *)key index:(NSUInteger)index queue:(NSOperationQueue *)queue;

@end
