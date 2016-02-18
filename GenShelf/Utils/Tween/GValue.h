//
//  GValue.h
//  GTween
//
//  Created by zrz on 14-7-29.
//  Copyright (c) 2014年 zrz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GValue : NSObject

@property (nonatomic, readonly) BOOL isDynamic;
@property (nonatomic, readonly) id  target;
@property (nonatomic, readonly) NSString *property;

+ (id)valueWithTarget:(id)target property:(NSString *)property dynamic:(BOOL)dynamic;
+ (id)valueWithTarget:(id)target property:(NSString *)property;

- (id)initWithTarget:(id)target property:(NSString *)property dynamic:(BOOL)dynamic;
- (id)initWithTarget:(id)target property:(NSString *)property;

- (float)floatValue;
- (CGRect)CGRectValue;
- (CGSize)CGSizeValue;
- (CGPoint)CGPointValue;
- (CATransform3D)CATransform3DValue;

- (id)data;

- (void)reset;

@end
