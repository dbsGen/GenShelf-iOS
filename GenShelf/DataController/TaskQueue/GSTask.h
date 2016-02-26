//
//  GSTask.h
//  GenShelf
//
//  Created by ; on 16/2/25.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GSTask;

@protocol GSTaskDelegate

@optional
- (void)onTaskStart:(GSTask *)task;
- (void)onTaskComplete:(GSTask *)task;
- (void)onTaskFailed:(GSTask *)task error:(NSError*)error;
- (void)onTaskCancel:(GSTask *)task;
- (void)onTask:(GSTask *)task progress:(CGFloat)progress;

@end

@interface GSTaskQueue : NSObject

@property (nonatomic, readonly) NSArray<GSTask *> *tasks;

- (void)addTask:(GSTask *)task;

@end

@interface GSTask : NSObject <GSTaskDelegate> 

@property (nonatomic, readonly) NSArray<GSTask *> *subtasks;
@property (nonatomic, assign) BOOL running;
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) NSInteger retryCount;
@property (nonatomic, assign) NSInteger offset;

@property (nonatomic, assign) NSTimeInterval timeDelay;

- (void)addSubtask:(GSTask*)task;

- (void)start;
- (void)restart;
- (void)cancel;

- (void)complete;
- (void)failed:(NSError *)error;
- (void)fatalError:(NSError *)error;
- (BOOL)progressSubtask;

// Need override
- (void)reset;
- (void)run;
- (void)finalFailed:(NSError *)error;

@end