//
//  MTMatrixSection.h
//  boxList
//
//  Created by zrz on 12-4-10.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct _matrixSection {
    int     section,
            rowCount;
    float   offset,
            headerHeight;
} MTMatrixSection;

@interface NSValue(MTMatrixSection)

- (MTMatrixSection)matrixSectionValue;

+ (id)valueWithMatrixSection:(MTMatrixSection)section;

@end