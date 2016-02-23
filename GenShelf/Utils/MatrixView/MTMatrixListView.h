//
//  MTMatrixListView.h
//  boxList
//
//  Created by zrz on 12-3-26.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTMatrixViewCell.h"
#import "MTMatrixTools.h"

@protocol MTMatrixListDelegate;

@interface MTMatrixListView : UIScrollView 
<UIScrollViewDelegate>{
    CGFloat     _spaceWidth,
                _spaceHeight,
                _left;
    NSInteger   _transverse;
    id          m_delegate;
    MTRange     _startRange,
                _endRange;
    MTSize      _topBounds,
                _bottomBounds;
    NSIndexPath *_touchStartIndex;
    NSMutableDictionary *_cached,
                        *_showCache;
    NSMutableArray      *_sizes;
}

@property (nonatomic, assign)   CGFloat     spaceWidth,
                                            spaceHeight;
@property (nonatomic, assign)   id<MTMatrixListDelegate>    matrixDelegate;

//header setting
@property (nonatomic, assign)   CGFloat     headerHeight;

- (void)reloadData;
- (id)dequeueReusableCellWithIdentifier:(NSString*)indentify;
- (id)cellWithIndexPath:(NSIndexPath*)indexPath;
- (NSIndexPath*)indexPathWithCell:(MTMatrixViewCell*)cell;

- (void)insertCells:(NSArray*)indexPaths withAnimation:(BOOL)animation;
- (void)deleteCells:(NSArray*)indexPaths withAnimation:(BOOL)animation;
- (void)reloadCells:(NSArray*)indexPaths withAnimation:(BOOL)animation;

@end

@protocol MTMatrixListDelegate <NSObject>

@required
- (NSInteger)numberOfSectionsInMatrixView:(MTMatrixListView*)matrixView;
- (MTMatrixViewCell*)matrixView:(MTMatrixListView*)matrixView 
                cellOfIndexPath:(NSIndexPath*)indexPath;
- (NSInteger)matrixView:(MTMatrixListView*)matrixView
        numberOfSection:(NSInteger)section;

@optional
- (UIView*)matrixView:(MTMatrixListView*)matrixView 
        headerOfSection:(NSInteger)section;
- (CGFloat)matrixView:(MTMatrixListView*)matrixView
headerHeightOfSection:(NSInteger)section;
- (void)matrixView:(MTMatrixListView*)matrixView 
    touchIndexPath:(NSIndexPath*)indexPath;
//
- (void)matrixView:(MTMatrixListView *)matrixView 
     touchBeginIndexPath:(NSIndexPath *)indexPath;
- (void)matrixView:(MTMatrixListView *)matrixView 
     touchEndIndexPath:(NSIndexPath *)indexPath;
- (void)matrixView:(MTMatrixListView *)matrixView 
     scanIndexPath:(NSIndexPath *)indexPath;

@end