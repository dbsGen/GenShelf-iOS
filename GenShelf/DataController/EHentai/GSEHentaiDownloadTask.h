//
//  GSLofiDownloadTask.h
//  GenShelf
//
//  Created by Gen on 16/2/28.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSTask.h"
#import "GSModelNetBook.h"

@interface GSEHentaiDownloadTask : GSTask {
    GSModelNetBook *_item;
    NSOperationQueue *_queue;
    NSUInteger _taskCount;
}

@property (nonatomic, strong) GSTaskQueue *downloadQueue;
- (id)initWithItem:(GSModelNetBook *)item queue:(NSOperationQueue *)queue;

@end
