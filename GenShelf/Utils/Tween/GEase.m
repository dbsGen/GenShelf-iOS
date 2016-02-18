//
//  GEase.m
//  GTween
//
//  Created by zrz on 14-7-27.
//  Copyright (c) 2014年 zrz. All rights reserved.
//

#import "GEase.h"

@implementation GEase

- (float)ease:(float)k
{
    return [[self class] ease:k];
}

+ (float)ease:(float)k
{
    return k;
}

@end

@implementation GEaseLinear
@end

@implementation GEaseQuadraticIn

+ (float)ease:(float)k
{
    return k*k;
}

@end

@implementation GEaseQuadraticOut

+ (float)ease:(float)k
{
    return k * ( 2 - k );
}

@end

@implementation GEaseQuadraticInOut

+ (float)ease:(float)k
{
    if ( ( k *= 2 ) < 1 ) return 0.5 * k * k;
    k-=1;
    return - 0.5 * ( k * ( k - 2 ) - 1 );
}

@end

@implementation GEaseCubicIn

+ (float)ease:(float)k
{
    return k*k*k;
}

@end

@implementation GEaseCubicOut

+ (float)ease:(float)k
{
    k -=1;
    return k * k * k + 1;
}

@end

@implementation GEaseCubicInOut

+ (float)ease:(float)k
{
    if ( ( k *= 2 ) < 1 ) return 0.5 * k * k * k;
    k -= 2;
    return 0.5 * ( k * k * k + 2 );
}

@end

@implementation GEaseQuarticIn

+ (float)ease:(float)k
{
    return k * k * k * k;
}

@end

@implementation GEaseQuarticOut

+ (float)ease:(float)k
{
    k-=1;
    return 1 - ( k * k * k * k );
}

@end

@implementation GEaseQuarticInOut

+ (float)ease:(float)k
{
    if ( ( k *= 2 ) < 1) return 0.5 * k * k * k * k;
    k -= 2;
    return - 0.5 * ( k * k * k * k - 2 );
}

@end

@implementation GEaseQuinticIn

+ (float)ease:(float)k
{
    return k * k * k * k * k;
}

@end

@implementation GEaseQuinticOut

+ (float)ease:(float)k
{
    k-=1;
    return k * k * k * k * k + 1;
}

@end

@implementation GEaseQuinticInOut

+ (float)ease:(float)k
{
    if ( ( k *= 2 ) < 1 ) return 0.5 * k * k * k * k * k;
    k -= 2;
    return 0.5 * ( k * k * k * k * k + 2 );
}

@end

@implementation GEaseSinusoidalIn

+ (float)ease:(float)k
{
    return 1 - cosf( k * M_PI / 2 );
}

@end

@implementation GEaseSinusoidalOut

+ (float)ease:(float)k
{
    return sinf( k * M_PI / 2 );
}

@end

@implementation GEaseSinusoidalInOut

+ (float)ease:(float)k
{
    return 0.5 * ( 1 - cosf( M_PI * k ) );
}

@end

@implementation GEaseExponentialIn

+ (float)ease:(float)k
{
    return k == 0 ? 0 : powf( 1024, k - 1 );
}

@end

@implementation GEaseExponentialOut

+ (float)ease:(float)k
{
    return k == 1 ? 1 : 1 - powf( 2, - 10 * k );
}

@end

@implementation GEaseExponentialInOut

+ (float)ease:(float)k
{
    if ( k == 0 ) return 0;
    if ( k == 1 ) return 1;
    if ( ( k *= 2 ) < 1 ) return 0.5 * powf( 1024, k - 1 );
    return 0.5 * ( - powf( 2, - 10 * ( k - 1 ) ) + 2 );
}

@end

@implementation GEaseCircularIn

+ (float)ease:(float)k
{
    return 1 - sqrtf( 1 - k * k );
}

@end

@implementation GEaseCircularOut

+ (float)ease:(float)k
{
    k-=1;
    return sqrtf( 1 - ( k * k ) );
}

@end

@implementation GEaseCircularInOut

+ (float)ease:(float)k
{
    if ( ( k *= 2 ) < 1) return - 0.5 * ( sqrtf( 1 - k * k) - 1);
    k -= 2;
    return 0.5 * ( sqrtf( 1 - k * k) + 1);
}

@end

@implementation GEaseElasticIn

+ (float)ease:(float)k
{
    float s, a = 0.1, p = 0.4;
    if ( k == 0 ) return 0;
    if ( k == 1 ) return 1;
    if ( !a || a < 1 ) { a = 1; s = p / 4; }
    else s = p * asinf( 1 / a ) / ( 2 * M_PI );
    k -= 1;
    return - ( a * powf( 2, 10 * k ) * sinf( ( k - s ) * ( 2 * M_PI ) / p ) );
}

@end

@implementation GEaseElasticOut

+ (float)ease:(float)k
{
    float s, a = 0.1, p = 0.4;
    if ( k == 0 ) return 0;
    if ( k == 1 ) return 1;
    if ( !a || a < 1 ) { a = 1; s = p / 4; }
    else s = p * asinf( 1 / a ) / ( 2 * M_PI );
    return ( a * powf( 2, - 10 * k) * sinf( ( k - s ) * ( 2 * M_PI ) / p ) + 1 );
}

@end

@implementation GEaseElasticInOut

+ (float)ease:(float)k
{
    float s, a = 0.1, p = 0.4;
    if ( k == 0 ) return 0;
    if ( k == 1 ) return 1;
    if ( !a || a < 1 ) { a = 1; s = p / 4; }
    else s = p * asinf( 1 / a ) / ( 2 * M_PI );
    if ( ( k *= 2 ) < 1 ) return - 0.5 * ( a * powf( 2, 10 * ( k -= 1 ) ) * sinf( ( k - s ) * ( 2 * M_PI ) / p ) );
    return a * powf( 2, -10 * ( k -= 1 ) ) * sinf( ( k - s ) * ( 2 * M_PI ) / p ) * 0.5 + 1;
}

@end

@implementation GEaseBackIn

+ (float)ease:(float)k
{
    float s = 1.70158;
    return k * k * ( ( s + 1 ) * k - s );
}

@end

@implementation GEaseBackOut

+ (float)ease:(float)k
{
    float s = 1.70158;
    k-=1;
    return k * k * ( ( s + 1 ) * k + s ) + 1;
}

@end

@implementation GEaseBackInOut

+ (float)ease:(float)k
{
    float s = 1.70158 * 1.525;
    if ( ( k *= 2 ) < 1 ) return 0.5 * ( k * k * ( ( s + 1 ) * k - s ) );
    k -= 2;
    return 0.5 * ( k * k * ( ( s + 1 ) * k + s ) + 2 );
}

@end

@implementation GEaseBounceIn

+ (float)ease:(float)k
{
    return 1 - [GEaseBounceOut ease:( 1 - k )];
}

@end

@implementation GEaseBounceOut

+ (float)ease:(float)k
{
    if ( k < ( 1 / 2.75 ) ) {
        return 7.5625 * k * k;
        
    } else if ( k < ( 2 / 2.75 ) ) {
        k -= ( 1.5 / 2.75 );
        return 7.5625 * k * k + 0.75;
        
    } else if ( k < ( 2.5 / 2.75 ) ) {
        k -= ( 2.25 / 2.75 );
        return 7.5625 * k * k + 0.9375;
    } else {
        k -= ( 2.625 / 2.75 );
        return 7.5625 * k * k + 0.984375;
    }
}

@end

@implementation GEaseBounceInOut

+ (float)ease:(float)k
{
    if ( k < 0.5 ) return [GEaseBounceIn ease:k * 2] * 0.5;
    return [GEaseBounceOut ease:k * 2 - 1] * 0.5 + 0.5;
}

@end


