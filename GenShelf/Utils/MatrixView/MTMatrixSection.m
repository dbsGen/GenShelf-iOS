//
//  MTMatrixSection.m
//  boxList
//
//  Created by zrz on 12-4-10.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "MTMatrixSection.h"

@implementation NSValue(MTMatrixSection)

- (MTMatrixSection)matrixSectionValue
{
    MTMatrixSection section;
    [self getValue:&section];
    return section;
}


+ (id)valueWithMatrixSection:(MTMatrixSection)section
{
    return [self valueWithBytes:&section 
                       objCType:@encode(MTMatrixSection)];
}

@end
