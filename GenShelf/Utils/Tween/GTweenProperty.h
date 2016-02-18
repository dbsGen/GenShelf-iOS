//
//  GTweenProperty.h
//  GTween
//
//  Created by zrz on 14-7-27.
//  Copyright (c) 2014年 zrz. All rights reserved.
//

#import <Foundation/Foundation.h>

//  ----------- Base Class -----------

@interface GTweenProperty : NSObject

// NSValue or GValue is allowed.
@property (nonatomic, strong) id fromValue;
@property (nonatomic, strong) id toValue;
// Property name.
@property (nonatomic, strong) NSString *name;

- (id)initWithName:(NSString*)name from:(id)from to:(id)to;
- (void)progress:(float)p target:(id)target;

@end

@interface GTweenProperty (Overdrive)
- (void)progress:(float)p target:(id)target imp:(IMP)imp selector:(SEL)sel;
@end


//  ----------- Children -----------

@interface GTweenFloatProperty : GTweenProperty
+ (id)property:(NSString*)name from:(CGFloat)from to:(CGFloat)to;
@end

@interface GTweenCGRectProperty : GTweenProperty
+ (id)property:(NSString*)name from:(CGRect)from to:(CGRect)to;
@end

@interface GTweenCGSizeProperty : GTweenProperty
+ (id)property:(NSString*)name from:(CGSize)from to:(CGSize)to;
@end

@interface GTweenCGPointProperty : GTweenProperty
+ (id)property:(NSString*)name from:(CGPoint)from to:(CGPoint)to;
@end

@interface GTweenCATransform3DProperty : GTweenProperty
+ (id)property:(NSString*)name from:(CATransform3D)from to:(CATransform3D)to;
@end

@interface GTweenRotationProperty : GTweenProperty
+ (id)property:(NSString*)name from:(CGFloat)from to:(CGFloat)to;
@end

@interface GTweenColorProperty : GTweenProperty
+ (id)property:(NSString*)name from:(UIColor*)from to:(UIColor*)to;
@end

