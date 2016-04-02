//
//  GSLofiHomeTask.h
//  GenShelf
//
//  Created by Gen on 16/3/14.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSRequestTask.h"

@interface GSEHentaiHomeTask : GSRequestTask {
    NSOperationQueue *_queue;
}

- (id)initWithIndex:(NSUInteger)index queue:(NSOperationQueue *)queue;

@end
