//
//  GSTask.m
//  GenShelf
//
//  Created by Gen on 16/2/25.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSTask.h"
#import "NSObject+GTools.h"


@interface GSTask () {
    NSMutableArray<GSTask *> *_subtasks;
}

@property (nonatomic, weak) id parent;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, assign) NSInteger refCount;

@end

@interface GSTaskQueue () <GSTaskDelegate>

@end

@implementation GSTaskQueue {
    NSMutableArray<GSTask*> *_tasks;
    BOOL _running;
}

- (id)init {
    self = [super init];
    if (self) {
        _running = NO;
        _tasks = [[NSMutableArray<GSTask*> alloc] init];
    }
    return self;
}

- (void)_checkQueue {
    if (_tasks.count == 0) {
        _running = NO;
        return;
    }
    if (_running) {
        return;
    }
    _running = YES;
    GSTask *task = [_tasks objectAtIndex:0];
    [task start];
}

- (NSArray<GSTask*>*)tasks {
    return _tasks;
}

- (GSTask *)task:(NSString *)identifier {
    for (NSUInteger n = 0, t = _tasks.count; n < t; n ++) {
        GSTask *task = [_tasks objectAtIndex:n];
        if ([task.identifier isEqualToString:identifier]) {
            return task;
        }
    }
    return nil;
}

- (id)createTask:(NSString *)identifier creator:(GSTaskCreator)creator {
    GSTask *task = [self task:identifier];
    if (!task && creator) {
        task = creator();
        task.parent = self;
        task.refCount = 0;
        task.identifier = identifier;
        [_tasks addObject:task];
        [self _checkQueue];
    }
    return task;
}

- (BOOL)hasTask:(GSTask *)task {
    return [_tasks containsObject:task];
}

- (BOOL)hasTaskI:(NSString *)identifier {
    return [self task:identifier] != nil;
}

- (void)retainTask:(GSTask *)task {
    if ([self hasTask:task]) {
        task.refCount ++;
    }
}

- (void)retainTaskI:(NSString *)identifier {
    GSTask *task = [self task:identifier];
    if (task) {
        task.refCount ++;
    }
}

- (void)releaseTask:(GSTask *)task {
    if ([self hasTask:task]) {
        task.refCount --;
        if (task.refCount <= 0) {
            [task cancel];
        }
    }
}

- (void)releaseTaskI:(NSString *)identifier {
    GSTask *task = [self task:identifier];
    if (task) {
        task.refCount --;
        if (task.refCount <= 0) {
            [task cancel];
        }
    }
}

- (void)addTask:(GSTask *)task {
    task.parent = self;
    [_tasks addObject:task];
    [self _checkQueue];
}

- (void)onTaskComplete:(GSTask *)task {
    [_tasks removeObject:task];
    _running = NO;
    [self _checkQueue];
}

- (void)onTaskFailed:(GSTask *)task error:(NSError *)error {
    [_tasks removeObject:task];
    _running = NO;
    [self _checkQueue];
}

- (void)onTaskCancel:(GSTask *)task {
    [_tasks removeObject:task];
    _running = NO;
    [self _checkQueue];
}

@end

@implementation GSTask {
    NSInteger _tryCount;
    BOOL _willChecked;
}

- (id)init {
    self = [super init];
    if (self) {
        _running = NO;
        _tryCount = 0;
        _retryCount = 0;
        _subtasks = [[NSMutableArray<GSTask *> alloc] init];
        _offset = 0;
        _willChecked = false;
    }
    return self;
}

- (void)start {
    if (_running || _isCancel) return;
    _running = YES;
    if ([self.delegate respondsToSelector:@selector(onTaskStart:)]) {
        [self.delegate onTaskStart:self];
    }
    
    if ([_parent respondsToSelector:@selector(onTaskStart:)]) {
        [_parent onTaskStart:self];
    }
    [self run];
}

- (void)restart {
    [self reset];
    _isCancel = NO;
    _offset = 0;
    _running = YES;
    if ([self.delegate respondsToSelector:@selector(onTaskStart:)]) {
        [self.delegate onTaskStart:self];
    }
    if ([_parent respondsToSelector:@selector(onTaskStart:)]) {
        [_parent onTaskStart:self];
    }
    [self run];
}

- (void)cancel {
    _isCancel = YES;
    if (_running) {
        if (_offset < _subtasks.count) {
            [[_subtasks objectAtIndex:_offset] cancel];
        }
        _running = NO;
        if ([self.delegate respondsToSelector:@selector(onTaskCancel:)]) {
            [self.delegate onTaskCancel:self];
        }
        if ([_parent respondsToSelector:@selector(onTaskCancel:)]) {
            [_parent onTaskCancel:self];
        }
    }
}

- (void)complete {
    if (![self progressSubtask]) {
        [self _delayComplete];
    }
}

- (void)failed:(NSError *)error {
    _running = NO;
    if (_tryCount < _retryCount) {
        _tryCount ++;
        [self restart];
    }else {
        [self finalFailed:error];
        if ([self.delegate respondsToSelector:@selector(onTaskFailed:error:)]) {
            [self.delegate onTaskFailed:self error:error];
        }
        if ([_parent respondsToSelector:@selector(onTaskFailed:error:)]) {
            [_parent onTaskFailed:self error:error];
        }
        _tryCount = 0;
    }
}

- (void)fatalError:(NSError *)error {
    _running = NO;
    [self finalFailed:error];
    if ([self.delegate respondsToSelector:@selector(onTaskFailed:error:)]) {
        [self.delegate onTaskFailed:self error:error];
    }
    if ([_parent respondsToSelector:@selector(onTaskFailed:error:)]) {
        [_parent onTaskFailed:self error:error];
    }
    _tryCount = 0;
}

- (BOOL)progressSubtask {
    if (_subtasks.count) {
        [self _checkSubtasks];
        return YES;
    }
    return NO;
}

- (void)reset {}
- (void)run {}
- (void)finalFailed:(NSError *)error {}
- (void)finalComplete {}

- (void)_delayComplete {
    [self performBlock:^{
        _running = NO;
        if ([self.delegate respondsToSelector:@selector(onTaskComplete:)]) {
            [self.delegate onTaskComplete:self];
        }
        if ([_parent respondsToSelector:@selector(onTaskComplete:)]) {
            [_parent onTaskComplete:self];
        }
        _tryCount = 0;
        [self finalComplete];
    } afterDelay:_timeDelay];
}

- (void)_checkSubtasks {
    if (_offset < _subtasks.count) {
        GSTask *task = [_subtasks objectAtIndex:_offset];
        if (task.running) {
            [self failed:[NSError errorWithDomain:@"Subtask is already progressing."
                                             code:100
                                         userInfo:nil]];
        }else {
            [task start];
        }
    }else {
        [self _delayComplete];
    }
}

- (NSArray<GSTask*> *)subtasks {
    return _subtasks;
}

- (void)addSubtask:(GSTask *)task {
    task.parent = self;
    [_subtasks addObject:task];
}

- (void)cleatSubtasks {
    [_subtasks removeAllObjects];
}

- (void)onTaskCancel:(GSTask *)task {
    if (_offset < _subtasks.count && [_subtasks objectAtIndex:_offset] == task) {
        _offset ++;
        [self checkNextFrame];
    }
}

- (void)onTaskComplete:(GSTask *)task {
    if (_offset < _subtasks.count && [_subtasks objectAtIndex:_offset] == task) {
        _offset ++;
        [self checkNextFrame];
    }
}

- (void)onTaskFailed:(GSTask *)task error:(NSError *)error {
    if (_offset < _subtasks.count && [_subtasks objectAtIndex:_offset] == task) {
        [self failed:error];
    }
}

- (void)checkNextFrame {
    _willChecked = YES;
    [self performSelector:@selector(checkFrameHandle)
               withObject:nil
               afterDelay:0];
}

- (void)checkFrameHandle {
    if (_willChecked) {
        _willChecked = NO;
        [self _checkSubtasks];
    }
}

@end
