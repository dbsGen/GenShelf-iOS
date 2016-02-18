//
//  GEase.h
//  GTween
//
//  Created by zrz on 14-7-27.
//  Copyright (c) 2014年 zrz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GEase : NSObject
+ (float)ease:(float)k;
- (float)ease:(float)k;
@end

@interface GEaseLinear : GEase
@end

@interface GEaseQuadraticIn : GEase
@end

@interface GEaseQuadraticOut : GEase
@end

@interface GEaseQuadraticInOut : GEase
@end

@interface GEaseCubicIn : GEase
@end

@interface GEaseCubicOut : GEase
@end

@interface GEaseCubicInOut : GEase
@end

@interface GEaseQuarticIn : GEase
@end

@interface GEaseQuarticOut : GEase
@end

@interface GEaseQuarticInOut : GEase
@end

@interface GEaseQuinticIn : GEase
@end

@interface GEaseQuinticOut : GEase
@end

@interface GEaseQuinticInOut : GEase
@end

@interface GEaseSinusoidalIn : GEase
@end

@interface GEaseSinusoidalOut : GEase
@end

@interface GEaseSinusoidalInOut : GEase
@end

@interface GEaseExponentialIn : GEase
@end

@interface GEaseExponentialOut : GEase
@end

@interface GEaseExponentialInOut : GEase
@end

@interface GEaseCircularIn : GEase
@end

@interface GEaseCircularOut : GEase
@end

@interface GEaseCircularInOut : GEase
@end

@interface GEaseElasticIn : GEase
@end

@interface GEaseElasticOut : GEase
@end

@interface GEaseElasticInOut : GEase
@end

@interface GEaseBackIn : GEase
@end

@interface GEaseBackOut : GEase
@end

@interface GEaseBackInOut : GEase
@end

@interface GEaseBounceIn : GEase
@end

@interface GEaseBounceOut : GEase
@end

@interface GEaseBounceInOut : GEase
@end
