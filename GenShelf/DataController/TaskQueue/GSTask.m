//
//  GSTask.m
//  GenShelf
//
//  Created by Gen on 16/2/25.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSTask.h"

@implementation GSTask {
    NSInteger _tryCount;
}

- (id)init {
    self = [super init];
    if (self) {
        _running = NO;
        _tryCount = 0;
        _retryCount = 0;
    }
    return self;
}

- (void)start {
    if (_running) return;
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
    [self cancel];
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
    _running = NO;
    if ([self.delegate respondsToSelector:@selector(onTaskCancel:)]) {
        [self.delegate onTaskCancel:self];
    }
    if ([_parent respondsToSelector:@selector(onTaskCancel:)]) {
        [_parent onTaskCancel:self];
    }
}

- (void)complete {
    _running = NO;
    if ([self.delegate respondsToSelector:@selector(onTaskComplete:)]) {
        [self.delegate onTaskComplete:self];
    }
    if ([_parent respondsToSelector:@selector(onTaskComplete:)]) {
        [_parent onTaskComplete:self];
    }
}

- (void)failed:(NSError *)error {
    _running = NO;
    if (_tryCount < _retryCount) {
        _tryCount ++;
        [self restart];
    }else {
        if ([self.delegate respondsToSelector:@selector(onTaskFailed:error:)]) {
            [self.delegate onTaskFailed:self error:error];
        }
        if ([_parent respondsToSelector:@selector(onTaskFailed:error:)]) {
            [_parent onTaskFailed:self error:error];
        }
    }
}

- (void)run {}

@end

@interface GSTaskGroup () <GSTaskDelegate>

@end

@implementation GSTaskGroup {
    NSMutableArray *_tasks;
}

- (id)init {
    self = [super init];
    if (self) {
        _tasks = [[NSMutableArray alloc] init];
        _offset = 0;
    }
    return self;
}

- (NSArray *)tasks {
    return [_tasks copy];
}

- (void)_checkGroup {
    if (_offset < _tasks.count) {
        GSTask *task = [_tasks objectAtIndex:_offset];
        if (task.running) {
            [self failed:[NSError errorWithDomain:@"Sub task is already running."
                                             code:100
                                         userInfo:nil]];
        }else {
            task.delegate = self;
            [task start];
        }
    }else {
        [self complete];
    }
}

- (void)run {
    [self _checkGroup];
}

- (void)addTask:(GSTask *)task {
    task->_parent = self;
    [_tasks addObject:task];
}

- (void)onTaskComplete:(GSTask *)task {
    if (task == [_tasks objectAtIndex:_offset]) {
        _offset ++;
        [self _checkGroup];
    }
}

- (void)onTaskFailed:(GSTask *)task error:(NSError *)error {
    if (task == [_tasks objectAtIndex:_offset]) {
        [self failed:error];
    }
}

@end
