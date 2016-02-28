//
//  GSLofiDownloadTask.h
//  GenShelf
//
//  Created by Gen on 16/2/28.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSTask.h"
#import "GSBookItem.h"

@interface GSLofiDownloadTask : GSTask {
    GSBookItem *_item;
    NSOperationQueue *_queue;
}

- (id)initWithItem:(GSBookItem *)item queue:(NSOperationQueue *)queue;

@end
