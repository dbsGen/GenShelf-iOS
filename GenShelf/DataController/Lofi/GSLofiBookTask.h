//
//  GSLofiBookTask.h
//  GenShelf
//
//  Created by Gen on 16/2/26.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSTask.h"
#import "GSModelNetBook.h"

@class ASIHTTPRequest;

@interface GSLofiBookTask : GSTask {
    GSModelNetBook *_item;
    NSOperationQueue *_queue;
}

- (id)initWithItem:(GSModelNetBook *)item queue:(NSOperationQueue *)queue;

@end


@protocol GSLofiBookTaskDelegate <GSTaskDelegate>

- (void)onBookUpdate:(GSLofiBookTask *)task;

@end