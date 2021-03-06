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
- (void)onTaskMoveCache:(GSTask *)task;
- (void)onTaskFailed:(GSTask *)task error:(NSError*)error;
- (void)onTaskCancel:(GSTask *)task;
- (void)onTask:(GSTask *)task progress:(CGFloat)progress;

@end

typedef GSTask*(^GSTaskCreator)();

@interface GSTaskQueue : NSObject

@property (nonatomic, readonly) NSArray<GSTask *> *tasks;
@property (nonatomic, strong) NSString *source;

- (instancetype)initWithSource:(NSString *)source;

- (GSTask *)task:(NSString *)identifier;
- (id)createTask:(NSString *)identifier creator:(GSTaskCreator)creator;

- (void)retainTask:(GSTask *)task;
- (void)retainTaskI:(NSString *)identifier;

- (void)releaseTask:(GSTask *)task;
- (void)releaseTaskI:(NSString *)identifier;

- (BOOL)hasTask:(GSTask *)task;
- (BOOL)hasTaskI:(NSString *)identifier;

@end

@interface GSTask : NSObject <GSTaskDelegate> {
    @private
    __weak id _parent;
}

@property (nonatomic, strong) NSString *source;
@property (nonatomic, readonly) NSArray<GSTask *> *subtasks;
@property (nonatomic, assign) BOOL running;
@property (nonatomic, readonly) BOOL isCancel;
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) NSInteger retryCount;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, assign) NSTimeInterval timeDelay;

- (void)addSubtask:(GSTask*)task;
- (void)clearSubtasks;

- (void)start;
- (void)restart;
- (void)cancel;

- (void)cache;
- (void)complete;
- (void)failed:(NSError *)error;
- (void)fatalError:(NSError *)error;
- (BOOL)progressSubtask;

// Need override
- (void)reset;
- (void)run;
- (void)finalFailed:(NSError *)error;
- (void)finalComplete;

- (void)taskRelease;
- (void)taskRetain;

@end