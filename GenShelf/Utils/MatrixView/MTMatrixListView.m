//
//  MTMatrixListView.m
//  boxList
//
//  Created by zrz on 12-3-26.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "MTMatrixListView.h"
#import <QuartzCore/QuartzCore.h>
#import "MTMatrixSection.h"

#define kDefaulteHeaderHeight   5

@implementation MTMatrixListView

@synthesize spaceWidth = _spaceWidth, spaceHeight = _spaceHeight, matrixDelegate = _matrixDelegate;
@synthesize headerHeight = _headerHeight;

static CATransition *__reloadTransition;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _spaceHeight = 150;
        _spaceWidth = 150;
        _startRange.location = 0;
        _startRange.length = 0;
        _endRange.location = 0;
        _endRange.length = 0;
        [super setDelegate:self];
        _sizes = [[NSMutableArray alloc] init];
        _cached = [[NSMutableDictionary alloc] init];
        if (!__reloadTransition) {
            __reloadTransition = [[CATransition alloc] init];
            __reloadTransition.type = @"fade";
        }
        self.contentSize = (CGSize){320, 480};
        _showCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self reloadData];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    if (self.superview) {
        [self reloadData];
    }
}

- (void)dealloc
{
    [_touchStartIndex   release];
    _matrixDelegate = nil;
    [_sizes     release];
    [_cached    release];
    [_showCache release];
    [super      dealloc];
}

- (void)reloadData
{
    CGRect rect = self.frame;
    _transverse = rect.size.width / _spaceWidth;
    if (!_transverse) 
        _transverse = 1;
    _left = (rect.size.width - _transverse * _spaceWidth) / 2;
    int sectionCount = [_matrixDelegate numberOfSectionsInMatrixView:self];
    [_sizes removeAllObjects];
    CGFloat top = 0;
    for (int n = 0 ; n < sectionCount; n++) {
        MTMatrixSection section;
        section.section = n;
        section.rowCount = [_matrixDelegate matrixView:self
                                       numberOfSection:n];
        float height;
        if (section.rowCount) {
            height = ((section.rowCount - 1) / _transverse + 1) * _spaceHeight;
        }else height = 0;
        if ([_matrixDelegate respondsToSelector:@selector(matrixView:headerHeightOfSection:)]) {
            section.headerHeight = [_matrixDelegate matrixView:self
                                        headerHeightOfSection:n];
        }else {
            section.headerHeight = kDefaulteHeaderHeight;
        }
        height += section.headerHeight;
        section.offset = top;
        [_sizes addObject:[NSValue valueWithMatrixSection:section]];
        top += height;
    }
    self.contentSize = (CGSize){self.bounds.size.width, top};
    _startRange.location = 0;
    _startRange.length = 0;
    _endRange.location = 0;
    _endRange.length = 0;
    _topBounds.height = 0;
    _topBounds.offset = 0;
    _bottomBounds.offset = 0;
    _bottomBounds.height = 0;
    NSArray *keys = [_showCache allKeys];
    for (NSString *key in keys) {
        [self removeSubview:key];
    }
    [self showSubviewInRect:(CGRect){self.contentOffset, self.bounds.size}];
}

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate
{
    m_delegate = delegate;
}

- (id)dequeueReusableCellWithIdentifier:(NSString*)indentify
{
    NSMutableArray *array = [_cached objectForKey:indentify];
    MTMatrixViewCell *cell = [array count] ? [array lastObject] : nil;
    if (cell) {
        [[cell retain] autorelease];
        [array removeObject:cell];
    }
    return cell;
}

#pragma mark - self method

- (void)removeSubview:(id)key
{
    if (!key) {
        return;
    }
    UIView *view = [_showCache objectForKey:key];
    if (![[self subviews] containsObject:view]) 
        return;
    if ([view isKindOfClass:[MTMatrixViewCell class]]) {
        NSString *indentify = ((MTMatrixViewCell*)view).reuseIdentifier;
        ((MTMatrixViewCell*)view).indexPath = nil;
        NSMutableArray *array = [_cached objectForKey:indentify];
        if (!array) {
            array = [NSMutableArray array];
            [_cached setObject:array
                        forKey:indentify];
        }
        [array addObject:view];
    }
    [view removeFromSuperview];
    [_showCache removeObjectForKey:key];
}

- (void)removeSubviewsInDRange:(MTDRange)drange
{
    if (drange.range1.location == drange.range2.location) {
        for (int n = drange.range1.length ; 
             n <= drange.range2.length;
             n ++) {
            id key = nil;
            if (n) 
                key = [NSIndexPath indexPathForRow:n - 1
                                         inSection:drange.range1.location];
            else key = [NSNumber numberWithInt:drange.range1.location];
            [self removeSubview:key];
        }
    }else {
        for (int n = drange.range1.length, 
             t = [[_sizes objectAtIndex:drange.range1.location] count];
             n < t; n++) {
            id key = nil;
            if (n) 
                key = [NSIndexPath indexPathForRow:n - 1
                                         inSection:drange.range1.location];
            else key = [NSNumber numberWithInt:drange.range1.location];
            [self removeSubview:key];
        }
        for (int n = drange.range1.location + 1; 
             n <= drange.range2.location - 1; n++) {
            for (int m = 0 , t = [[_sizes objectAtIndex:n] count]; 
                 m < t; m ++) {
                id key = nil;
                if (n) 
                    key = [NSIndexPath indexPathForRow:n - 1
                                             inSection:drange.range1.location];
                else key = [NSNumber numberWithInt:drange.range1.location];
                [self removeSubview:key];
            }
        }
        for (int n = 0; n <= drange.range2.length; n++) {
            id key = nil;
            if (n) 
                key = [NSIndexPath indexPathForRow:n - 1
                                         inSection:drange.range1.location];
            else key = [NSNumber numberWithInt:drange.range1.location];
            [self removeSubview:key];
        }
    }
}

- (id)cellWithIndexPath:(NSIndexPath*)indexPath
{
    if (!indexPath) {
        return nil;
    }
    return [_showCache objectForKey:indexPath];
}

#define addContent(tSection, num, tWidth)\
{\
    MTMatrixSection size = [[_sizes objectAtIndex:tSection] matrixSectionValue];\
    if (!num) {\
        if ([_matrixDelegate respondsToSelector:@selector(matrixView:headerOfSection:)]) {\
        UIView *view = [_matrixDelegate matrixView:self headerOfSection:tSection];\
        view.frame = (CGRect){0, size.offset, tWidth, size.headerHeight};\
        [_showCache setObject:view forKey:[NSNumber numberWithInt:tSection]];\
        [self addSubview:view];\
    }\
    }else {\
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:num - 1 \
        inSection:tSection];\
        MTMatrixViewCell *cell = [_matrixDelegate matrixView:self \
        cellOfIndexPath:indexPath];\
        cell.center = (CGPoint){_left + _spaceWidth / 2 +  (num - 1) % _transverse * _spaceWidth, \
            size.offset + size.headerHeight + _spaceHeight * ((num - 1) / _transverse + 0.5)};\
        cell.indexPath = [NSIndexPath indexPathForRow:num - 1 inSection:tSection];\
        [_showCache setObject:cell forKey:cell.indexPath];\
        [self insertSubview:cell atIndex:0];\
    }\
}

- (void)addSubviewInDRange:(MTDRange)drange
{
    CGFloat width = self.bounds.size.width;
    if (drange.range1.location == drange.range2.location) {
        for (int n = drange.range1.length ; 
             n <= drange.range2.length;
             n ++) {
            addContent(drange.range1.location, n, width);
        }
    }else {
        for (int n = drange.range1.length, 
             t = [[_sizes objectAtIndex:drange.range1.location] matrixSectionValue].rowCount;
             n < t; n++) {
            addContent(drange.range1.location, n, width);
        }
        for (int l = drange.range1.location + 1; 
             l <= drange.range2.location - 1; l++) {
            for (int m = 0 , t = [[_sizes objectAtIndex:l] matrixSectionValue].rowCount; 
                 m < t; m ++) {
                addContent(l, m, width);
            }
        }
        for (int n = 0; n <= drange.range2.length; n++) {
            addContent(drange.range2.location, n, width);
        }
    }
}

- (void)showSubviewInRect:(CGRect)rect
{
    float bottomf = rect.origin.y + rect.size.height;
    
    if (bottomf < _bottomBounds.offset) {
        int n, t;
        for (n = 0 , t = [_sizes count]; n < t ; n ++) {
            MTMatrixSection sSection = [[_sizes objectAtIndex:n] matrixSectionValue];
            if (bottomf < sSection.offset &&
                bottomf > 0) {
                break;
            }
        }
        
        if (n > 0) {
            n --;
            MTMatrixSection sSection = [[_sizes objectAtIndex:n] matrixSectionValue];
            MTRange bottom;
            bottom.location = sSection.section;
            CGFloat top = sSection.offset + sSection.headerHeight;
            CGFloat height = bottomf - top;
            
            if (height > 0) {
                int count = height / _spaceHeight;
                bottom.length = (count + 1) * _transverse + 1;
                _bottomBounds.offset = sSection.offset + count * _spaceHeight;
                _bottomBounds.height = _spaceHeight;
            }else if (height > -sSection.headerHeight){
                bottom.length = 0;
                _bottomBounds.offset = sSection.offset;
                _bottomBounds.height = sSection.headerHeight;
            }else goto flag1;
            MTRange range2 = bottom;
            range2.length --;
            if (range2.length < 0) {
                range2.location --;
                if (range2.location < 0) {
                    goto flag1;
                }
                range2.length = [[_sizes objectAtIndex:range2.location] matrixSectionValue].rowCount;
            }
            [self removeSubviewsInDRange:(MTDRange){bottom, _endRange}];
            _endRange = range2;
        }
    }
flag1:
    if (rect.origin.y > _topBounds.offset + _topBounds.height) {
        int n, t;
        for (n = 0 , t = [_sizes count]; n < t ; n ++) {
            MTMatrixSection sSection = [[_sizes objectAtIndex:n] matrixSectionValue];
            if (rect.origin.y < sSection.offset &&
                rect.origin.y > 0) {
                break;
            }
        }
        if (n > 0) {
            n --;
            MTMatrixSection sSection = [[_sizes objectAtIndex:n] matrixSectionValue];
            MTRange start;
            start.location = sSection.section;
            CGFloat top = sSection.offset + sSection.headerHeight;
            CGFloat height = rect.origin.y - top;
            if (height > 0) {
                int count = height / _spaceHeight;
                start.length = count * _transverse;
                _topBounds.offset = sSection.offset + count * _spaceHeight;
                _topBounds.height = _spaceHeight;
            }else if (height > -sSection.headerHeight){
                start.length = 0;
                _topBounds.offset = sSection.offset;
                _topBounds.height = sSection.headerHeight;
            }else goto flag2;
            MTRange range2 = start;
            range2.length ++;
            if (range2.length > sSection.rowCount) {
                range2.length = 0;
                range2.location += 1;
                if (range2.location >= [_sizes count]) {
                    goto flag2;
                }
            }
            [self removeSubviewsInDRange:(MTDRange){_startRange, start}];
            
            _startRange = range2;
        }
    }
    
flag2:
    if (rect.origin.y < _topBounds.offset) {
        int n, t;
        for (n = 0 , t = [_sizes count]; n < t ; n ++) {
            MTMatrixSection sSection = [[_sizes objectAtIndex:n] matrixSectionValue];
            if (rect.origin.y < sSection.offset &&
                rect.origin.y > 0) {
                break;
            }
        }
        if (n > 0) {
            n--;
            MTMatrixSection sSection = [[_sizes objectAtIndex:n] matrixSectionValue];
            MTRange start;
            start.location = sSection.section;
            CGFloat top = sSection.offset + sSection.headerHeight;
            CGFloat height = rect.origin.y - top;
            if (height > 0) {
                int count = height / _spaceHeight;
                start.length = count * _transverse + 1;
                _topBounds.offset = sSection.offset + count * _spaceHeight;
                _topBounds.height = _spaceHeight;
            }else /*if (height > -sSection.headerHeight)*/{
                start.length = 0;
                _topBounds.offset = sSection.offset;
                _topBounds.height = sSection.headerHeight;
            }//else goto flag3;
            MTRange range2 = _startRange;
            range2.length --;
            if (range2.length < 0) {
                range2.location --;
                if (range2.location < 0) {
                    goto flag3;
                }
                range2.length = [[_sizes objectAtIndex:range2.location] matrixSectionValue].rowCount;
            }
            [self addSubviewInDRange:(MTDRange){start, range2}];
            _startRange = start;
        }
    }
flag3:
    if (bottomf > _bottomBounds.offset + _bottomBounds.height) {
        int n, t;
        for (n = 0 ,  t = [_sizes count]; n < t ; n ++) {
            MTMatrixSection sSection = [[_sizes objectAtIndex:n] matrixSectionValue];
            if (bottomf < sSection.offset &&
                bottomf > 0) {
                break;
            }
        }
        if (n > 0) {
            n --;
            MTMatrixSection sSection = [[_sizes objectAtIndex:n] matrixSectionValue];
            MTRange bottom;
            bottom.location = sSection.section;
            CGFloat top = sSection.offset + sSection.headerHeight;
            CGFloat height = bottomf - top;
            //if (bottomf >= self.contentSize.height) {
                //return;
            //}else {
                int count = height / _spaceHeight;
                bottom.length = (count + 1) * _transverse;
                if (bottom.length > sSection.rowCount) 
                    bottom.length = sSection.rowCount;
                _bottomBounds.offset = sSection.offset + count * _spaceHeight;
                _bottomBounds.height = _spaceHeight;
            //}
            [self addSubviewInDRange:(MTDRange){_endRange.location, _endRange.length + 1, bottom}];
            _endRange = bottom;
        }
    }
}

- (NSIndexPath*)indexPathWithCell:(MTMatrixViewCell*)cell
{
    NSArray *views = [self subviews];
    if ([views containsObject:cell]) {
        return cell.indexPath;
    }
    return nil;
}

#pragma mark - control

- (void)insertCells:(NSArray*)indexPaths withAnimation:(BOOL)animation
{
    int totle = [_sizes count];
    int *indexes = malloc(sizeof(int) * totle);
    memset(indexes, 0, sizeof(int) * totle);
    //存放加入的位置
    NSMutableDictionary *indexAdded = [NSMutableDictionary dictionary];
    for (NSIndexPath *indexPath in indexPaths) {
        int section = indexPath.section;
        if (section < totle) {
            indexes[section] ++;
        }
        [indexAdded setObject:indexPath
                       forKey:[NSNumber numberWithBool:YES]];
    }
    CGFloat top;
    CGFloat theTop = self.contentOffset.y,
            theBottom = self.contentOffset.y +
                        self.bounds.size.height;
    MTRange nStart, nEnd;
    nStart.location = -1;
    nEnd.location = -1;
    for (int n = 0 ; n < totle; n++) {
        MTMatrixSection oldSection = [[_sizes objectAtIndex:n] matrixSectionValue];
        if (indexes[n] > 0) {
            //检查
            int rowCount = oldSection.rowCount;
            int nRow = [_matrixDelegate matrixView:self
                                   numberOfSection:n];
            NSAssert4(((nRow - rowCount) == indexes[n]), 
                      @"row added %d in section %d, but the row is %d up to %d",
                      indexes[n], n, rowCount, nRow);
            oldSection.rowCount = nRow;
        }
        CGFloat height;
        if (oldSection.rowCount) {
            height = ((oldSection.rowCount - 1) / _transverse + 1) * _spaceHeight;
        }else height = 0;
        
        height += oldSection.headerHeight;
        oldSection.offset = top;
        top += height;
        [_sizes replaceObjectAtIndex:n
                          withObject:[NSValue valueWithMatrixSection:oldSection]];
        if (nStart.location == -1 && 
            theTop < top) {
            nStart.location = n;
            
            CGFloat t = (theTop - oldSection.headerHeight - oldSection.offset);
            if (t < 0) {
                nStart.length = 0;
            }else {
                int count = (t / _spaceHeight);
                nStart.length = count * _transverse + 1;
            }
        }
        if (nEnd.location == -1 &&
            theBottom < top) {
            nEnd.location = n;
            CGFloat t = (theBottom - oldSection.headerHeight - oldSection.offset);
            if (t < 0) {
                nEnd.length = 0;
            }else {
                int count = (t / _spaceHeight);
                nEnd.length = (count + 1) * _transverse;
            }
        }
    }
    
    CGFloat width = self.bounds.size.width;
    self.contentSize = CGSizeMake(width, top);
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:_showCache];
    [_showCache removeAllObjects];
    for (int n = nStart.location ; n <= _endRange.location; n++) {
        int totle = _endRange.length + 1;
        if (n < _endRange.location) {
            totle = [[_sizes objectAtIndex:n] matrixSectionValue].rowCount;
        }
        int start = 0;
        if (n == nStart.location) {
            start = nStart.length;
        }
        int addCount = 0;
        MTMatrixSection section = [[_sizes objectAtIndex:n] matrixSectionValue];
        for (int m = start; m < totle; m++) {
            NSComparisonResult ret = MTRangeCompare((MTRange){n,m}, _startRange);
            if (ret == NSOrderedAscending) {
                //添加
                addContent(n, m, width);
            }else if (MTRangeCompare((MTRange){n,m}, nEnd) != NSOrderedDescending){
                //中间操作
                if ([indexAdded objectForKey:[NSIndexPath indexPathForRow:m - 1
                                                                inSection:n]]) {
                    //新加入的添加
                    addContent(n, m, width);
                    addCount++;
                }else {
                    if (m - addCount) {
                        NSIndexPath *index = [NSIndexPath indexPathForRow:m - addCount - 1
                                                                inSection:n];
                        MTMatrixViewCell *cell = [tempDic objectForKey:index];
                        if (cell) {
                            NSIndexPath *nIndex = [NSIndexPath indexPathForRow:m - 1
                                                                     inSection:n];
                            cell.indexPath = nIndex;
                            cell.center = (CGPoint){_left + _spaceWidth / 2 +  (m - 1) % _transverse * _spaceWidth,
                                section.offset + section.headerHeight + _spaceHeight * ((m - 1) / _transverse + 0.5)};
                            [_showCache setObject:cell forKey:nIndex];
                            [tempDic removeObjectForKey:index];
                        }else {
                            addContent(n, m, width);
                        }
                    }else {
                        //header
                        NSNumber *inNum = [NSNumber numberWithInt:n];
                        UIView *view = [tempDic objectForKey:inNum];
                        if (view) {
                            view.frame = CGRectMake(0, section.offset,
                                                    width, section.headerHeight);
                            [_showCache setObject:view forKey:inNum];
                            [tempDic removeObjectForKey:inNum];
                        }else {
                            addContent(n, m, width);
                        }
                    }
                }
            }else {
                //移除
                id key;
                if (m) 
                    key = [NSIndexPath indexPathForRow:m - 1 inSection:n];
                else 
                    key = [NSNumber numberWithInt:n];
                
                UIView *view = [tempDic objectForKey:key];
                if (![[self subviews] containsObject:view]) 
                    return;
                if ([view isKindOfClass:[MTMatrixViewCell class]]) {
                    NSString *indentify = ((MTMatrixViewCell*)view).reuseIdentifier;
                    ((MTMatrixViewCell*)view).indexPath = nil;
                    NSMutableArray *array = [_cached objectForKey:indentify];
                    if (!array) {
                        array = [NSMutableArray array];
                        [_cached setObject:array
                                    forKey:indentify];
                    }
                    [array addObject:view];
                }
                [view removeFromSuperview];
                [tempDic removeObjectForKey:key];
            }
        }
    }
    
    NSArray *allKeys = [tempDic allKeys];
    for (int n = 0 ,t = [allKeys count]; n < t ; n++) {
        id key = [allKeys objectAtIndex:n];
        UIView *view = [tempDic objectForKey:key];
        if (![[self subviews] containsObject:view]) 
            return;
        if ([view isKindOfClass:[MTMatrixViewCell class]]) {
            NSString *indentify = ((MTMatrixViewCell*)view).reuseIdentifier;
            ((MTMatrixViewCell*)view).indexPath = nil;
            NSMutableArray *array = [_cached objectForKey:indentify];
            if (!array) {
                array = [NSMutableArray array];
                [_cached setObject:array
                            forKey:indentify];
            }
            [array addObject:view];
        }
        [view removeFromSuperview];
        [tempDic removeObjectForKey:key];
    }
    
    free(indexes);
}

- (void)deleteCells:(NSArray*)indexPaths withAnimation:(BOOL)animation
{
    for (NSIndexPath *indexPath in indexPaths) {
        
    }
}

- (void)reloadCells:(NSArray*)indexPaths withAnimation:(BOOL)animation
{
    for (NSIndexPath *indexPath in indexPaths) {
        MTMatrixViewCell *cell = [self cellWithIndexPath:indexPath];
        [self removeSubview:cell];
        cell = [_matrixDelegate matrixView:self 
                           cellOfIndexPath:indexPath];
        MTMatrixSection section = [[_sizes objectAtIndex:indexPath.section] matrixSectionValue];
        int row = indexPath.row;
        cell.center = (CGPoint){_left + _spaceWidth / 2 + row % _transverse * _spaceWidth, 
            section.offset + section.headerHeight + _spaceHeight * (row / _transverse + 0.5)};
        
        [self addSubview:cell];
        if (animation) {
            [cell.layer addAnimation:__reloadTransition
                              forKey:@"cellReload"];
        }
    }
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([m_delegate respondsToSelector:@selector(scrollViewDidScroll:)])
        [m_delegate scrollViewDidScroll:scrollView];
    //移动时
    [self showSubviewInRect:(CGRect){self.contentOffset, 
        self.bounds.size}];
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if ([m_delegate respondsToSelector:@selector(scrollViewDidZoom:)])
        [m_delegate scrollViewDidZoom:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([m_delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
        [m_delegate scrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([m_delegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)])
        [m_delegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([m_delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
        [m_delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if ([m_delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)])
        [m_delegate scrollViewWillBeginDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([m_delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
        [m_delegate scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if ([m_delegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)])
        [m_delegate scrollViewDidEndScrollingAnimation:scrollView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if ([m_delegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [m_delegate viewForZoomingInScrollView:scrollView];
    }
    return nil;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    if ([m_delegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)])
        [m_delegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    if ([m_delegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)])
        return [m_delegate scrollViewShouldScrollToTop:scrollView];
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    if ([m_delegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [m_delegate scrollViewDidScrollToTop:scrollView];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    CGPoint point = [[touches anyObject] locationInView:self];
    [_touchStartIndex release];
    _touchStartIndex = [indexOfPoint(_sizes, point, _transverse, _spaceWidth, _spaceHeight, _left) retain];
    if (_touchStartIndex && [_matrixDelegate respondsToSelector:@selector(matrixView:touchBeginIndexPath:)]) {
        [_matrixDelegate matrixView:self touchBeginIndexPath:_touchStartIndex];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    CGPoint point = [[touches anyObject] locationInView:self];
    NSIndexPath *endIndexPath = indexOfPoint(_sizes, point, _transverse, _spaceWidth, _spaceHeight, _left);
    if (endIndexPath && [_matrixDelegate respondsToSelector:@selector(matrixView:touchEndIndexPath:)]) {
        [_matrixDelegate matrixView:self touchEndIndexPath:endIndexPath];
    }
    if (endIndexPath && [endIndexPath compare:_touchStartIndex] == NSOrderedSame) {
        if ([_matrixDelegate respondsToSelector:@selector(matrixView:touchIndexPath:)]) {
            [_matrixDelegate matrixView:self touchIndexPath:_touchStartIndex];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    CGPoint point = [[touches anyObject] locationInView:self];
    NSIndexPath *indexPath = indexOfPoint(_sizes, point, _transverse, _spaceWidth, _spaceHeight, _left);
    if (indexPath && [_matrixDelegate respondsToSelector:@selector(matrixView:scanIndexPath:)]) {
        [_matrixDelegate matrixView:self scanIndexPath:indexPath];
    }
}

@end
