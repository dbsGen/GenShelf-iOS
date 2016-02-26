//
//  FZDragFlipView.h
//  Photocus
//
//  Created by zrz on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTFlipAnimationView.h"

typedef struct _FZSRange {
    NSInteger location;
    NSInteger length;
} FZRange;

typedef enum {
    FZDragFlipStateNormal,
    FZDragFlipStateLoading
} FZDragFlipState;

@protocol MTDragFlipViewDelegate;
@class CAAnimationGroup;

@interface MTDragFlipView : UIView 
<UIScrollViewDelegate>{
    int             _state;         //0any ,1updown,2leftright
    UIView          *_backContentView;
    UIView          *_leftView;
    UIImageView     *_backgroundView;    //背景层
    UIView          *_transationView;
    NSMutableArray  *_cachedImageViews;
    FZRange         _cacheRange;
    UIColor         *_blackColor;       //消失颜色
    NSInteger       _count,
                    _animationCount,
                    _state2;    //1,up , 2,down , 3,upBut cnt prev , 4 down but cnt next
    CGPoint         _tempPoint;
    BOOL            _animation,
                    _stop,
                    _change,
                    _willBackToTop,
                    _willToReload;
    UIScrollView    *_scrollView;
    UIPanGestureRecognizer  *_backPanGesture,
                            *_mainPanGesture,
                            *_leftPanGesture;
    UITapGestureRecognizer  *_leftTapGesture;
    NSMutableDictionary     *_unuseViews;
}

@property (nonatomic, assign)   id<MTDragFlipViewDelegate>  delegate;
@property (nonatomic, assign)   NSInteger   pageIndex;
@property (nonatomic, readonly) NSInteger   count;
//背景颜色
@property (nonatomic, strong)   UIColor     *backgroundColor;
@property (nonatomic, readonly) UILabel     *bottomLabel,
                                            *topLabel;
@property (nonatomic, assign)   BOOL        loadAll, dragEnable;
@property (nonatomic, strong)   UIView      *animationView;
@property (nonatomic, assign)   FZDragFlipState state;

// is opened background view or not.
@property (nonatomic, readonly) BOOL        open;

//到顶部
- (void)backToTop:(BOOL)aniamted;
//
- (void)openBackgroudView;
- (void)closeBackView;

- (void)pushViewToCache:(MTFlipAnimationView*)view;

- (MTFlipAnimationView*)getDragingView:(NSInteger)index;
//缓存的UIImageView
- (MTFlipAnimationView*)imageViewWithIndex:(NSInteger)index;
- (MTFlipAnimationView*)viewByIndentify:(NSString*)indentify;
//把页面缓存的imageView
- (void)viewToImage:(UIView*)view atIndex:(NSInteger)index;

//重载所有页面
- (void)reloadData;

//加载更多时调用
- (void)reloadCount;

- (void)clean;
- (void)load;
- (void)load:(NSInteger)page;
//if use this methord you must implementation - (MTFlipAnimationView*)flipViewPrePushDragingView:(FZDragFlipView *)flipView
- (void)preload:(NSInteger)count;

- (void)nextPage:(BOOL)animation;

@end

@protocol MTDragFlipViewDelegate <NSObject>

@required
//返回在index的子页面
- (UIView*)flipView:(MTDragFlipView*)flipView subViewAtIndex:(NSInteger)index;
//返回再index的后台页面
- (UIView*)flipView:(MTDragFlipView*)flipView backgroudView:(NSInteger)index left:(BOOL)isLeft;

//返回一共有多少个页面
- (NSInteger)numberOfFlipViewPage:(MTDragFlipView*)flipView;

- (MTFlipAnimationView*)flipView:(MTDragFlipView*)flipView dragingView:(NSInteger)index;


@optional
- (void)flipView:(MTDragFlipView*)flipView backgroudClosed:(NSInteger)index;

- (void)flipView:(MTDragFlipView *)flipView 
 didDragToBorder:(BOOL)isUp 
          offset:(CGFloat)offset;


- (void)flipView:(MTDragFlipView *)flipView startDraging:(NSInteger)index;

- (void)flipView:(MTDragFlipView*)flipView 
      reloadView:(MTFlipAnimationView*)view
         atIndex:(NSInteger)index;

- (MTFlipAnimationView*)flipViewPrePushDragingView:(MTDragFlipView *)flipView;

@end

@interface UIView(FZDragFlipViewDelegate)

- (void)setIndentify:(NSString*)indentify;
- (NSString*)indentify;

@end