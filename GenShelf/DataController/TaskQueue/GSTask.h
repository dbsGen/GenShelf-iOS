//
//  GSTask.h
//  GenShelf
//
//  Created by ; on 16/2/25.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GSTaskDelegate;


@interface GSTask : NSObject {
    @protected
    GSTask<GSTaskDelegate> *_parent;
}

@property (nonatomic, assign) BOOL running;
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) NSInteger retryCount;

- (void)start;
- (void)restart;
- (void)cancel;

- (void)complete;
- (void)failed:(NSError *)error;

// Need override
- (void)run;

@end

@interface GSTaskGroup : GSTask

@property (nonatomic, readonly) NSArray *tasks;
@property (nonatomic, assign) NSInteger offset;

- (void)addTask:(GSTask*)task;

@end


@protocol GSTaskDelegate

@optional
- (void)onTaskStart:(GSTask *)task;
- (void)onTaskComplete:(GSTask *)task;
- (void)onTaskFailed:(GSTask *)task error:(NSError*)error;
- (void)onTaskCancel:(GSTask *)task;
- (void)onTask:(GSTask *)task progress:(CGFloat)progress;

@end