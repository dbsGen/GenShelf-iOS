//
//  GValue.m
//  GTween
//
//  Created by zrz on 14-7-29.
//  Copyright (c) 2014年 zrz. All rights reserved.
//

#import "GValue.h"
#import "GTween.h"
#import <objc/runtime.h>

@implementation GValue {
    BOOL    _first,
            _isPtr;
    id  _data;
}

@synthesize isDynamic = _dynamic;

- (id)initWithTarget:(id)target property:(NSString *)property dynamic:(BOOL)dynamic
{
    self = [super init];
    if (self) {
        _first = true;
        _target = target;
        _property = property;
        _dynamic = dynamic;
        
        NSMethodSignature *method = [target methodSignatureForSelector:sel_registerName([property cStringUsingEncoding:NSUTF8StringEncoding])];
        _isPtr = *method.methodReturnType == '@' || *method.methodReturnType == '^';
    }
    return self;
}

- (id)initWithTarget:(id)target property:(NSString *)property
{
    return [self initWithTarget:target
                       property:property
                        dynamic:YES];
}

+ (id)valueWithTarget:(id)target property:(NSString *)property dynamic:(BOOL)dynamic
{
    return [[self alloc] initWithTarget:target
                               property:property
                                dynamic:dynamic];
}

+ (id)valueWithTarget:(id)target property:(NSString *)property
{
    return [[self alloc] initWithTarget:target
                               property:property];
}

#define VALUE(TYPE, FUNCTION, DATA) \
- (TYPE)FUNCTION {\
    if (_dynamic) {\
        return GTGetter(TYPE, self.target, self.property);\
    }\
    if (!_dynamic && _first) {\
        _first = NO;\
        _data = [DATA:GTGetter(TYPE, self.target, self.property)];\
    }\
    return [_data FUNCTION];\
}

VALUE(float, floatValue, NSNumber numberWithFloat)
VALUE(CGRect, CGRectValue, NSValue valueWithCGRect)
VALUE(CGSize, CGSizeValue, NSValue valueWithCGSize)
VALUE(CGPoint, CGPointValue, NSValue valueWithCGPoint)
VALUE(CATransform3D, CATransform3DValue, NSValue valueWithCATransform3D)

- (id)data {
    if (_isPtr) {
        if (_dynamic) {
            return GTGetter(id, self.target, self.property);
        }
        if (!_dynamic && _first) {
            _data = GTGetter(id, self.target, self.property);
        }
        return _data;
    }else {
        return self;
    }
}

- (void)reset
{
    _first = true;
}

@end
