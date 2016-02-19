//
//  GSideCoverView.m
//  GenShelf
//
//  Created by Gen on 16/2/19.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSideCoverView.h"

@implementation GSideCoverView {
    UITouch *_currentTouch;
    CGPoint _oldPosition;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_currentTouch == NULL) {
        NSArray<UITouch *> *ts = [[touches objectEnumerator] allObjects];
        _currentTouch = [ts objectAtIndex:0];
        _oldPosition = [_currentTouch locationInView:_currentTouch.window];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSArray<UITouch *> *ts = [[touches objectEnumerator] allObjects];
    if (_currentTouch) {
        if ([ts containsObject:_currentTouch]) {
            CGPoint p = [_currentTouch locationInView:_currentTouch.window];
            if (_moveBlock) {
                _moveBlock(CGPointMake(p.x - _oldPosition.x, p.y-_oldPosition.y));
            }
            _oldPosition = p;
        }else {
            _currentTouch = NULL;
            if (_endBlock) {
                _endBlock(CGPointZero);
            }
        }
    }else {
        _currentTouch = [ts objectAtIndex:0];
        _oldPosition = [_currentTouch locationInView:_currentTouch.window];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _currentTouch = NULL;
    if (_endBlock) {
        _endBlock(CGPointZero);
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSArray<UITouch *> *ts = [[touches objectEnumerator] allObjects];
    if (_currentTouch) {
        if ([ts containsObject:_currentTouch]) {
            _currentTouch = NULL;
            if (_endBlock) {
                _endBlock(CGPointZero);
            }
        }
    }
}

@end
