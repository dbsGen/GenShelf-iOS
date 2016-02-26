//
//  MTBlockOperation.h
//  flipview
//
//  Created by zrz on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MTBlockOperationBlock)(CGContextRef context);
typedef void (^MTBlockOperationComplete)(UIImage *image);

@interface MTBlockOperation : NSOperation

@property (nonatomic, copy) MTBlockOperationBlock   block;
@property (nonatomic, copy) MTBlockOperationComplete    completeBlock;
@property (nonatomic, assign)   CGSize  size;

@end
