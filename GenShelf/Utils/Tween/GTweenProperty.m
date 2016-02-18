//
//  GTweenProperty.m
//  GTween
//
//  Created by zrz on 14-7-27.
//  Copyright (c) 2014年 zrz. All rights reserved.
//

#import "GTweenProperty.h"
#import "GTween.h"
#import "GValue.h"
#import <objc/runtime.h>

#define lerp(FROM, TO, MI) (FROM*(1-MI)+TO*MI)

// ---------------- Base Class ------------------

@implementation GTweenProperty {
    SEL         _getter,
                _setter;
    IMP         _setterIMP;
}

- (id)fromValue
{
    if ([_fromValue isKindOfClass:[GValue class]]) {
        return [_fromValue data];
    }else {
        return _fromValue;
    }
}

- (id)toValue
{
    if ([_toValue isKindOfClass:[GValue class]]) {
        return [_toValue data];
    }else {
        return _toValue;
    }
}

- (SEL)getterSEL
{
    return sel_registerName([self.name cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (SEL)setterSEL
{
    NSString *selString = [NSString stringWithFormat:@"set%@%@:", [[self.name substringToIndex:1] uppercaseString],[self.name substringFromIndex:1]];
    
    return sel_registerName([selString cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (id)initWithName:(NSString *)name from:(id)from to:(id)to
{
    self = [super init];
    if (self) {
        self.name = name;
        self.fromValue = from;
        self.toValue = to;
        _getter = [self getterSEL];
        _setter = [self setterSEL];
    }
    return  self;
}

- (void)progress:(float)p target:(id)target
{
    if (!_setterIMP) {
        Method method = class_getInstanceMethod([target class], _setter);
        _setterIMP = method_getImplementation(method);
    }
    [self progress:p target:target imp:_setterIMP selector:_setter];
}

- (void)progress:(float)p target:(id)target imp:(IMP)imp selector:(SEL)sel {}

- (void)reset
{
    if ([self.fromValue respondsToSelector:@selector(reset)]) {
        [self.fromValue reset];
    }
    if ([self.toValue respondsToSelector:@selector(reset)]) {
        [self.toValue reset];
    }
}

@end


// ------------------ Children ----------------------

@implementation GTweenFloatProperty

+ (id)property:(NSString*)name from:(CGFloat)from to:(CGFloat)to
{
    return [[self alloc] initWithName:name
                                 from:[NSNumber numberWithFloat:from]
                                   to:[NSNumber numberWithFloat:to]];
}

- (void)progress:(float)p target:(id)target imp:(IMP)imp selector:(SEL)sel
{
    float res = lerp([self.fromValue floatValue], [self.toValue floatValue], p);
    GTSetter(CGFloat, target, imp, sel, res);
}

@end


@implementation GTweenCGRectProperty
CGRect rectLerp(CGRect from, CGRect to, float m) {
    CGRect rect;
    rect.origin.x = lerp(from.origin.x, to.origin.x, m);
    rect.origin.y = lerp(from.origin.y, to.origin.y, m);
    rect.size.width = lerp(from.size.width, to.size.width, m);
    rect.size.height = lerp(from.size.height, to.size.height, m);
    return rect;
}

+ (id)property:(NSString *)name from:(CGRect)from to:(CGRect)to
{

    return [[self alloc] initWithName:name
                                 from:[NSValue valueWithCGRect:from]
                                   to:[NSValue valueWithCGRect:to]];
}

- (void)progress:(float)p target:(id)target imp:(IMP)imp selector:(SEL)sel
{
    CGRect res = rectLerp([self.fromValue CGRectValue], [self.toValue CGRectValue], p);
    GTSetter(CGRect, target, imp, sel, res);
}

@end

@implementation GTweenCGSizeProperty
CGSize sizeLerp(CGSize from, CGSize to, float m) {
    CGSize size;
    size.width = lerp(from.width, to.width, m);
    size.height = lerp(from.height, to.height, m);
    return size;
}

typedef void (*CGSIZE_SETTER_IMP)(id, SEL, CGSize);
+ (id)property:(NSString *)name from:(CGSize)from to:(CGSize)to
{
    return [[self alloc] initWithName:name
                                 from:[NSValue valueWithCGSize:from]
                                   to:[NSValue valueWithCGSize:to]];
}

- (void)progress:(float)p target:(id)target imp:(IMP)imp selector:(SEL)sel
{
    CGSize res = sizeLerp([self.fromValue CGSizeValue], [self.toValue CGSizeValue], p);
    GTSetter(CGSize, target, imp, sel, res);
}

@end
@implementation GTweenCGPointProperty
CGPoint  pointLerp(CGPoint from, CGPoint to, float m) {
    CGPoint point;
    point.x = lerp(from.x, to.x, m);
    point.y = lerp(from.y, to.y, m);
    return point;
}

typedef void (*CGPOINT_SETTER_IMP)(id, SEL, CGPoint);
+ (id)property:(NSString *)name from:(CGPoint)from to:(CGPoint)to
{
    return [[self alloc] initWithName:name
                                 from:[NSValue valueWithCGPoint:from]
                                   to:[NSValue valueWithCGPoint:to]];
}

- (void)progress:(float)p target:(id)target imp:(IMP)imp selector:(SEL)sel
{
    CGPoint res = pointLerp([self.fromValue CGPointValue],
                            [self.toValue CGPointValue],
                            p);
    GTSetter(CGPoint, target, imp, sel, res);
}

@end

@implementation GTweenCATransform3DProperty
CATransform3D transform3DLerp(CATransform3D from, CATransform3D to, float m) {
    CATransform3D trans;
    trans.m11 = lerp(from.m11, to.m11, m);
    trans.m12 = lerp(from.m12, to.m12, m);
    trans.m13 = lerp(from.m13, to.m13, m);
    trans.m14 = lerp(from.m14, to.m14, m);
    trans.m21 = lerp(from.m21, to.m21, m);
    trans.m22 = lerp(from.m22, to.m22, m);
    trans.m23 = lerp(from.m23, to.m23, m);
    trans.m24 = lerp(from.m24, to.m24, m);
    trans.m31 = lerp(from.m31, to.m31, m);
    trans.m32 = lerp(from.m32, to.m32, m);
    trans.m33 = lerp(from.m33, to.m33, m);
    trans.m34 = lerp(from.m34, to.m34, m);
    trans.m41 = lerp(from.m41, to.m41, m);
    trans.m42 = lerp(from.m42, to.m42, m);
    trans.m43 = lerp(from.m43, to.m43, m);
    trans.m44 = lerp(from.m44, to.m44, m);
    return trans;
}

+ (id)property:(NSString *)name from:(CATransform3D)from to:(CATransform3D)to
{
    return [[self alloc] initWithName:name
                                 from:[NSValue valueWithCATransform3D:from]
                                   to:[NSValue valueWithCATransform3D:to]];
}

- (void)progress:(float)p target:(id)target imp:(IMP)imp selector:(SEL)sel
{
    CATransform3D res = transform3DLerp([self.fromValue CATransform3DValue],
                                        [self.toValue CATransform3DValue],
                                        p);
    GTSetter(CATransform3D, target, imp, sel, res);
}

@end

@implementation GTweenRotationProperty

+ (id)property:(NSString *)name from:(CGFloat)from to:(CGFloat)to
{
    return [[self alloc] initWithName:name
                                 from:[NSNumber numberWithFloat:from]
                                   to:[NSNumber numberWithFloat:to]];
}

- (void)progress:(float)p target:(id)target imp:(IMP)imp selector:(SEL)sel
{
    CGFloat res = lerp([self.fromValue floatValue],
                       [self.toValue floatValue],
                       p);
    GTSetter(CATransform3D, target, imp, sel, CATransform3DMakeRotation(res, 0, 0, 1));
}

@end

typedef struct GTColor {
    CGFloat r,g,b,a;
} GTColor;
@implementation GTweenColorProperty {
    BOOL _seted;
    GTColor from, to;
}
UIColor* colorLerp(GTColor from, GTColor to, float m) {
    return [UIColor colorWithRed:lerp(from.r, to.r, m)
                           green:lerp(from.g, to.g, m)
                            blue:lerp(from.b, to.b, m)
                           alpha:lerp(from.a, to.a, m)];
}

+ (id)property:(NSString *)name from:(UIColor *)from to:(UIColor *)to
{
    return [[self alloc] initWithName:name
                                 from:from
                                   to:to];
}

- (void)progress:(float)p target:(id)target imp:(IMP)imp selector:(SEL)sel
{
    if (!_seted) {
        _seted = true;
        [self.fromValue getRed:&from.r
                         green:&from.g
                          blue:&from.b
                         alpha:&from.a];
        [self.toValue getRed:&to.r
                       green:&to.g
                        blue:&to.b
                       alpha:&to.a];
    }
    UIColor *res = colorLerp(from, to, p);
    return GTSetter(UIColor*, target, imp, sel, res);
}

@end

#undef lerp