//
//  MTMatrixTools.h
//  boxList
//
//  Created by zrz on 12-3-27.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    CGFloat offset;
    CGFloat height;
}MTSize;

typedef struct {
    NSInteger location, length;
}MTRange;

typedef struct {
    MTRange range1, range2;
}MTDRange;

NSInteger tagWithIndexPath(NSIndexPath *indexPath);
NSInteger tagWithRowAndSction(NSInteger row, NSInteger section);
NSIndexPath *indexPathWithTag(NSInteger tag);

void getRangeWithSizes(NSArray *sizes, CGRect rect, MTRange *start, MTRange *end);
BOOL rangeBetween(MTDRange drange, MTRange range);
MTDRange rangeOutCompare(MTDRange range1, MTDRange range2);
NSIndexPath *indexOfPoint(NSArray *sizes, CGPoint point, int num, CGFloat cellWidth, CGFloat cellHeight, CGFloat left);

NSComparisonResult MTRangeCompare(MTRange r1, MTRange r2);

@interface MTMatrixTools : NSObject

@end

@interface NSValue(MTValue)

+ (id)valueWithMTSize:(MTSize)size;

- (MTSize)MTSizeValue;

@end