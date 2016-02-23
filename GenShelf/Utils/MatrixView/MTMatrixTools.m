//
//  MTMatrixTools.m
//  boxList
//
//  Created by zrz on 12-3-27.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "MTMatrixTools.h"
#import "MTMatrixSection.h"
NSInteger tagWithIndexPath(NSIndexPath *indexPath)
{
    return (indexPath.section << 16) | (indexPath.row + 1);
}

NSInteger tagWithRowAndSction(NSInteger row, NSInteger section)
{
    return (section << 16) | row;
}

NSIndexPath *indexPathWithTag(NSInteger tag)
{
    int row = (tag & 0x0000ffff) - 1;
    if (row == -1) {
        row = 0;
    }
    return [NSIndexPath indexPathForRow:row
                              inSection:tag >> 16];
}

BOOL rangeBetween(MTDRange drange, MTRange range)
{
    return (range.location > drange.range1.location &&
            range.location < drange.range2.location) ||
    (drange.range1.location != drange.range2.location && (
    (range.location == drange.range1.location &&
     range.length > drange.range1.length) || 
    (range.location == drange.range2.location &&
     range.length < drange.range2.length))) || 
    (drange.range1.location == drange.range2.location && 
     range.length > drange.range1.length &&
     range.length < drange.range2.length);
}

void getRangeWithSizes(NSArray *sizes, CGRect rect, MTRange *start, MTRange *end)
{
    MTRange *range = start;
    CGFloat f = rect.origin.y;
turnloop:
    for (int n = 0 , t = [sizes count]; n < t ; n++) {
        NSArray *array = [sizes objectAtIndex:n];
        int totle = [array count];
        if (totle) {
            MTSize sizeS = [[array objectAtIndex:0] MTSizeValue];
            MTSize sizeE = [[array lastObject] MTSizeValue];
            if (sizeS.offset < f &&
                sizeE.offset + sizeE.height > f) {
                //range 在这个数组里面
                range->location = n;
                if (end == range) {
                    for (int m = totle - 1 ; m > 0; m --) {
                        sizeS = [[array objectAtIndex:m] MTSizeValue];
                        if (sizeS.offset < f &&
                            sizeS.offset + sizeS.height > f) {
                            range->length = m;
                            return;
                        }
                    }
                }else {
                    for (int m = 0 ; m < totle; m ++) {
                        sizeS = [[array objectAtIndex:m] MTSizeValue];
                        if (sizeS.offset < f &&
                            sizeS.offset + sizeS.height > f) {
                            range->length = m;
                            range = end;
                            f = rect.origin.y + rect.size.height;
                            goto turnloop;
                        }
                    }
                }
            }
        }
    }
    if (start == range) {
        range = end;
        f = rect.origin.y + rect.size.height;
        goto turnloop;
    }
}

NSIndexPath *indexOfPoint(NSArray *sizes, CGPoint point, int num, CGFloat cellWidth, CGFloat cellHeight, CGFloat left)
{
    int totle = [sizes count];
    int section = totle - 1;
    for (int n = 0 , t = totle; n < t ; n++) {
        MTMatrixSection tsi = [[sizes objectAtIndex:n] matrixSectionValue];
        MTSize size;
        size.offset = tsi.offset;
        size.height = tsi.headerHeight;
        if (point.y > size.offset &&
            point.y < size.offset + size.height) {
            return nil;
        }
        if (point.y < size.offset) {
            section = n - 1;
            break;
        }
    }
    if (section >= 0) {
        MTMatrixSection tsi = [[sizes objectAtIndex:section] matrixSectionValue];
        MTSize size;
        CGFloat top = point.y - (size.offset + size.height);
        int row = ((int)(top / cellHeight)) * num + (point.x - left) / cellWidth;
        if (row < tsi.rowCount) {
            return [NSIndexPath indexPathForRow:row 
                                      inSection:section];
        }
    }
    return nil;
}

NSComparisonResult MTRangeCompare(MTRange r1, MTRange r2)
{
    if (r1.location > r2.location) {
        return 1;
    }else if (r1.location == r2.location && r1.length > r2.length) {
        return 1;
    }else if (r1.location < r2.location) {
        return -1;
    }else if (r1.location == r2.location && r1.length < r2.length) {
        return -1;
    }else {
        return 0;
    }
}

MTDRange rangeOutCompare(MTDRange range1, MTDRange range2)
{
    MTDRange drange;
    if (range2.range1.length == range2.range2.length &&
        range2.range1.location == range2.range2.location) {
        return range1;
    }
    if (rangeBetween(range1, range2.range1)) {
        drange.range1 = range1.range1;
        drange.range2 = range2.range1;
        drange.range2.length -= 1;
    }else if (rangeBetween(range1, range2.range2)) {
        drange.range1 = range2.range2;
        drange.range1.length += 1;
        drange.range2 = range1.range2;
    }else if (rangeBetween(range2, (MTRange){range1.range1.location, range1.range1.length + 1}) &&
              rangeBetween(range2, (MTRange){range1.range2.location, range1.range2.length - 1})){
        drange.range1 = (MTRange){0,0};
        drange.range2 = (MTRange){0,-1};
    }else {
        drange = range1;
    }
    return drange;
}
    
@implementation MTMatrixTools

@end

@implementation NSValue (MTValue)

+ (id)valueWithMTSize:(MTSize)size
{
    return [self valueWithCGSize:*((CGSize*)&size)];
}

- (MTSize)MTSizeValue
{
    CGSize size = [self CGSizeValue];
    return *(MTSize*)&size;
}

@end