//
//  FZDragFlipView.m
//  Photocus
//
//  Created by zrz on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MTDragFlipView.h"
#import <QuartzCore/QuartzCore.h>

#define StateBarRect   (CGRect){0,0,320,20}
#define kAngle          (M_PI / 4)
#define GetProgress(float_pro)  (CATransform3DMakeScale(0.1*float_pro + 0.9, 0.1*float_pro + 0.9, 1))
#define kLengthLimite   20

typedef struct FZAction {
SEL action;
int count;
} FZAction;

@interface NSValue(FZAction)

+ (id)valueWithAction:(FZAction)action;
- (FZAction)actionValue;

@end

@implementation NSValue(FZAction)

+ (id)valueWithAction:(FZAction)action
{
    NSValue *value = [[self alloc] initWithBytes:&action
                                         objCType:@encode(FZAction)];
    return value;
}

- (FZAction)actionValue
{
    FZAction action;
    [self getValue:&action];
    return action;
}

@end

@interface MTDragFlipView()

- (void)retainAnimation;
- (void)releaseAnimation;

@end

@implementation MTDragFlipView

@synthesize delegate = _delegate, pageIndex = _pageIndex;
@synthesize backgroundColor = m_backgroundColor;
@synthesize topLabel = _topLabel, state = _tstate;
@synthesize bottomLabel = _bottomLabel, loadAll = _loadAll;
@synthesize animationView = _animationView, count = _count;
@synthesize dragEnable = _dragEnable;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _dragEnable = YES;
        _cachedImageViews = [[NSMutableArray alloc] init];
        
        _mainPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(panndOn:)];
        [self addGestureRecognizer:_mainPanGesture];
        
        
        _backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = [UIColor grayColor];
        _bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 30, self.bounds.size.width, 15)];
        _bottomLabel.backgroundColor = [UIColor clearColor];
        _bottomLabel.textColor = [UIColor whiteColor];
        _bottomLabel.textAlignment = UITextAlignmentCenter;
        _bottomLabel.text = @"";
        _bottomLabel.font = [UIFont boldSystemFontOfSize:15];
        _bottomLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.6];
        _bottomLabel.shadowOffset = CGSizeMake(0, 1);
        [_backgroundView addSubview:_bottomLabel];
        
        
        _topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, self.bounds.size.width, 15)];
        _topLabel.backgroundColor = [UIColor clearColor];
        _topLabel.textColor = [UIColor whiteColor];
        _topLabel.textAlignment = UITextAlignmentCenter;
        _topLabel.text = @"";
        _topLabel.font = [UIFont boldSystemFontOfSize:15];
        _topLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.6];
        _topLabel.shadowOffset = CGSizeMake(0, 1);
        [_backgroundView addSubview:_topLabel];
        
        _leftTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(clickLeft:)];
        
        m_backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
        _blackColor = [UIColor clearColor];
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 10)];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = YES;
        _scrollView.showsVerticalScrollIndicator = YES;
        _scrollView.scrollsToTop = YES;
        _scrollView.contentSize = CGSizeMake(320, 20);
        _scrollView.contentOffset = CGPointMake(0, 10);
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_scrollView];
        self.backgroundColor = [UIColor clearColor];
        
        self.animationView = [[[UIApplication sharedApplication] delegate] window];
        
        _backPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(panOnLeft:)];
        _leftPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(panOnLeft:)];
        
        _transationView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_transationView];
        _transationView.hidden = YES;
        _transationView.backgroundColor = [UIColor clearColor];
        
        _unuseViews = [[NSMutableDictionary alloc] init];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width, 0, 15, frame.size.height)];
        imageView.image = [UIImage imageNamed:@"bg_detail_panelshadow"];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
        [_transationView addSubview:imageView];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-15, 0, 15, frame.size.height)];
        imageView.image = [UIImage imageNamed:@"bg_detail_panelshadow"];
        imageView.layer.transform = CATransform3DMakeScale(-1, 1, 1);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [_transationView addSubview:imageView];
        
    }
    return self;
}

- (void)setState:(FZDragFlipState)state
{
    if (state == _tstate) {
        return;
    }
    _tstate = state;
    if (self.state == FZDragFlipStateNormal) {
        self.userInteractionEnabled = YES;
        [self resetNowView:[self imageViewWithIndex:_pageIndex]];
    }else {
        self.userInteractionEnabled = NO;
        [self resetNowViewEx:[self imageViewWithIndex:_pageIndex]];
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _bottomLabel.frame = CGRectMake(0, self.bounds.size.height - 15, self.bounds.size.width, 15);
    _transationView.frame = self.bounds;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [_backContentView removeFromSuperview];
}

- (void)nextPage:(BOOL)animation
{
    if (_pageIndex + 1 >= _count) {
        return;
    }
    CGRect rect = self.bounds;
    
    MTFlipAnimationView *nowView = [self getDragingView:_pageIndex];
    MTFlipAnimationView *upView = [self getDragingView:_pageIndex - 1];
    MTFlipAnimationView *downView = [self getDragingView:_pageIndex + 1];
    
    
    nowView.center = CGPointMake(rect.size.width / 2,
                                 rect.size.height / 2);
    upView.center = CGPointMake(rect.size.width / 2,
                                -rect.size.height / 2 - 40);
    downView.center = CGPointMake(rect.size.width / 2,
                                  rect.size.height / 2);
    if (!nowView) {
        return;
    }
    _pageIndex ++;
    if (animation) {
        _transationView.hidden = NO;
        [self retainAnimation];
        [self moveUpOut:nowView];
    }else {
        NSArray *array = self.subviews;
        for (UIView *view in array) {
            if (view != _scrollView &&
                view != _transationView) {
                [view removeFromSuperview];
            }
        }
        UIView *subView = [self getViewAtIndex:_pageIndex];
        [self insertSubview:subView
               belowSubview:_transationView];
    }
}

- (void)reloadData
{
    if (_animation) {
        return;
    }
    if (_animationCount && !self.open) {
        _willToReload = YES;
        [self resetNowViewEx:[self getDragingView:_pageIndex]];
        return;
    }
    _animationCount = 0;
    _count = [_delegate numberOfFlipViewPage:self];
    int page = _pageIndex;
    if (page >= _count) {
        page = _count - 1;
    }
    if (!self.open) {
        NSArray *array = self.subviews;
        for (UIView *view in array) {
            if (view != _scrollView &&
                view != _transationView) {
                [view removeFromSuperview];
            }
        }
        UIView *subView = [self getViewAtIndex:_pageIndex];
        [self insertSubview:subView
               belowSubview:_transationView];
    }else {
        NSArray *array = self.subviews;
        for (UIView *view in array) {
            if (view != _scrollView &&
                view != _transationView &&
                view != _backContentView &&
                view != _leftView) {
                [view removeFromSuperview];
            }
        }
        UIView *subView = [self getViewAtIndex:_pageIndex];
        [self insertSubview:subView
               belowSubview:_backContentView];
    }
    
    int totle = [_cachedImageViews count];
    for (int n = _cacheRange.location; n < totle; n++) {
        if (n < page) {
            MTFlipAnimationView *view = [self imageViewWithIndex:n];
            [view removeFromSuperview];
            [self pushViewToCache:view];
            [_cachedImageViews replaceObjectAtIndex:n withObject:[NSNull null]];
        }else {
            MTFlipAnimationView *view = [_cachedImageViews lastObject];
            if ([view isKindOfClass:[UIView class]]) {
                [view removeFromSuperview];
                [self pushViewToCache:view];
            }
            [_cachedImageViews removeObject:view];
        }
    }
    _cacheRange.location = page;
    _cacheRange.length = 0;
    _pageIndex = page;
    
    CGRect rect = self.bounds;
    UIView *view = [self getDragingView:_pageIndex];
    view.center = CGPointMake(rect.size.width / 2,
                              rect.size.height / 2);
    view = [self getDragingView:_pageIndex - 1];
    view.center = CGPointMake(rect.size.width / 2,
                              - rect.size.height / 2 - 40);
    view = [self getDragingView:_pageIndex - 2];
    view.center = CGPointMake(rect.size.width / 2,
                              - rect.size.height / 2 - 40);
    view = [self getDragingView:_pageIndex + 1];
    view.center = CGPointMake(rect.size.width / 2,
                              rect.size.height / 2);
    view = [self getDragingView:_pageIndex + 2];
    
    view.center = CGPointMake(rect.size.width / 2,
                              rect.size.height / 2);
    self.userInteractionEnabled = YES;
}

- (void)setUserInter
{
    self.userInteractionEnabled = YES;
}

#define kTimeAdd        0.1
#define kBaseDurationK  0.4
#define kBaseDurationS  0.32
#define kDistanceAdd    100
#define kBaseDistance   (self.bounds.size.height)

- (MTFlipAnimationView*)imageViewWithIndex:(NSInteger)index
{
    if (index < [_cachedImageViews count]) {
        id obj = [_cachedImageViews objectAtIndex:index];
        if (obj != [NSNull null]) {
            return obj;
        }
    }
    return nil;
}

- (void)setPageIndex:(NSInteger)pageIndex
{
    _pageIndex = pageIndex;
    [self reloadData];
}

- (void)backToTop:(BOOL)aniamted
{
    //到顶部
    if (self.open || _pageIndex == 0 || _stop) {
        return;
    }
    
    _animation = YES;
    int count = 0;
    
    if (aniamted) {
        self.userInteractionEnabled = NO;
        //清除旧的
        for (int n = _pageIndex + 1 ; n < _cacheRange.location + _cacheRange.length ; n++) {
            MTFlipAnimationView *view = [_cachedImageViews lastObject];
            if ([view isKindOfClass:[UIView class]]) {
                [self pushViewToCache:view];
                [view removeFromSuperview];
            }
            [_cachedImageViews removeObject:view];
        }
        
        NSMutableArray *aniamtionArr = [NSMutableArray array];
        int toIndex = _cacheRange.location;
        int nowCount = _pageIndex - _cacheRange.location;
        if (nowCount < 25) {
            int to = 25 - nowCount;
            toIndex = _cacheRange.location - to;
            if (toIndex < 0) {
                toIndex = 0;
            }
            for (int n = _cacheRange.location - 1 ; n >= toIndex; n--) {
                MTFlipAnimationView *view = [_delegate flipView:self dragingView:n];
                [view setAnimationPercent:-1];
                [aniamtionArr addObject:view];
                [_transationView addSubview:view];
            }
        }
        if (toIndex != 0) {
            MTFlipAnimationView *view = [_delegate flipView:self dragingView:0];
            [aniamtionArr addObject:view];
            [_transationView addSubview:view];
        }
        
        for (int n = _cacheRange.location ; n <= _pageIndex ; n++) {
            MTFlipAnimationView *view = [_cachedImageViews objectAtIndex:n];
            [view setAnimationPercent:-1];
            [aniamtionArr insertObject:view atIndex:0];
        }
        
        for (int n = 0, t = [aniamtionArr count]; n < t ; n ++) {
            MTFlipAnimationView *view = [aniamtionArr objectAtIndex:n];
            [_transationView addSubview:view];
            if (0 == n) {
                [view setAnimationPercent:0];
            }else {
                CGFloat timeAdd = kTimeAdd * count;
                [self performSelector:@selector(animationHandle:)
                           withObject:view
                           afterDelay:timeAdd];
                count ++;
            }
        }
        
        [self performSelector:@selector(setTAnimation:)
                   withObject:aniamtionArr
                   afterDelay:kBaseDurationK + count  * kTimeAdd];
        _transationView.hidden = NO;
    }else {
        //无动画,有需要再写吧
    }
    _pageIndex = 0;
}
                 
- (void)animationHandle:(MTFlipAnimationView*)view
{
    [UIView animateWithDuration:kBaseDurationK
                          delay:0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         [view setAnimationPercent:0];
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)setTAnimation:(NSMutableArray*)array
{
    self.userInteractionEnabled = YES;
    for (MTFlipAnimationView *view in array) {
        [self pushViewToCache:view];
        [view removeFromSuperview];
    }
    [_cachedImageViews removeAllObjects];
    _cacheRange.location = 0;
    _cacheRange.length = 0;
    _animation = NO;
    _transationView.hidden = YES;
    [self reloadData];
}

- (MTFlipAnimationView*)getDragingView:(NSInteger)index
{
    if (index > _cacheRange.location + _cacheRange.length || 
        index < _cacheRange.location - 1 || index >= _count ||
        index < 0) {
        return nil;
    }
    MTFlipAnimationView *view = [self imageViewWithIndex:index];
    if (!view) {
        CGRect rect = self.bounds;
        if (_cacheRange.length < kLengthLimite) {
            view = [_delegate flipView:self dragingView:index];
            if (index >= [_cachedImageViews count]) {
                [_cachedImageViews addObject:view];
                if (index == _pageIndex) {
                    [_transationView addSubview:view];
                }else 
                    [_transationView insertSubview:view atIndex:0];
                _cacheRange.length ++;
                view.center = CGPointMake(rect.size.width / 2,
                                          rect.size.height / 2);
            }else {
                [_cachedImageViews replaceObjectAtIndex:index 
                                             withObject:view];
                [_transationView addSubview:view];
                _cacheRange.location --;
                _cacheRange.length ++;
                view.center = CGPointMake(rect.size.width / 2,
                                          - rect.size.height / 2 - 40);
            }
        }else {
            if (index >= [_cachedImageViews count]) {
                MTFlipAnimationView *oldView = [self imageViewWithIndex:_cacheRange.location];
                if (oldView) {
                    [self pushViewToCache:oldView];
                    [oldView removeFromSuperview];
                    [_cachedImageViews replaceObjectAtIndex:_cacheRange.location
                                                 withObject:[NSNull null]];
                }
                view = [_delegate flipView:self dragingView:index];
                [_cachedImageViews addObject:view];
                [_transationView insertSubview:view atIndex:0];
                _cacheRange.location ++;
                view.center = CGPointMake(rect.size.width / 2,
                                          rect.size.height / 2);
            }else {
                MTFlipAnimationView *oldView = [_cachedImageViews lastObject];
                if ([oldView isKindOfClass:[UIView class]]) {
                    [self pushViewToCache:oldView];
                    [oldView removeFromSuperview];
                    [_cachedImageViews removeObject:oldView];
                }
                view = [_delegate flipView:self dragingView:index];
                [_cachedImageViews replaceObjectAtIndex:index 
                                             withObject:view];
                [_transationView addSubview:view];
                _cacheRange.location --;
                view.center = CGPointMake(rect.size.width / 2,
                                          - rect.size.height / 2 - 40);
            }
        }
    }
    return view;
}

- (UIView*)getViewAtIndex:(NSInteger)index
{
    UIView *view = [_delegate flipView:self subViewAtIndex:index];
    view.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    return view;
}


- (void)reloadCount
{
    _count = 0;
    if ([_delegate respondsToSelector:@selector(numberOfFlipViewPage:)]) {
        _count = [_delegate numberOfFlipViewPage:self];
        if (!_count) {
            _backgroundView.backgroundColor = [UIColor clearColor];
            return;
        }
    }
    
}

- (void)moveUpOut:(MTFlipAnimationView*)view
{
    [UIView transitionWithView:view
                      duration:0.4
                       options:UIViewAnimationCurveLinear
                    animations:^{
                        [view setAnimationPercent:-1];
                    } completion:^(BOOL finished) {
                        [self releaseAnimation];
                    }];
    
}


- (void)moveDownIn:(MTFlipAnimationView*)view
{
    [UIView transitionWithView:view
                      duration:0.4
                       options:UIViewAnimationCurveLinear
                    animations:^{
                        [view setAnimationPercent:0];
                    } completion:^(BOOL finished) {
                        [self releaseAnimation];
                    }];
}

- (void)resetNowView:(MTFlipAnimationView*)view
{
    if (self.state == FZDragFlipStateLoading) {
        [self resetNowViewEx:view];
        return;
    }
    CGRect rect = self.bounds;
    //_animation = YES;
    
    CGFloat hOffset = view.frame.origin.y - rect.origin.y;
    CGFloat sect = - hOffset / 3;
    [UIView animateWithDuration:0.25
                          delay:0 
                        options:UIViewAnimationCurveEaseOut
                     animations:^
     {
         [view setAnimationPercent:(sect / rect.size.height)];
     } completion:^(BOOL finished) 
     {
         if (finished) {
             [UIView animateWithDuration:0.13
                                   delay:0
                                 options:UIViewAnimationCurveEaseInOut
                              animations:^
              {
                  [view setAnimationPercent:0];
              } completion:^(BOOL finished) 
              {
                  [self releaseAnimation];
              }];
         }else {
             [self releaseAnimation];
         }
     }];
}

- (void)resetNowViewEx:(UIView *)view
{
    CGRect rect = self.bounds;
    CGPoint p;
    if (self.state == FZDragFlipStateNormal) {
        p = CGPointMake(rect.size.width / 2 + rect.origin.x,
                        rect.size.height / 2 + rect.origin.y);
    }else {
        p = CGPointMake(rect.size.width / 2 + rect.origin.x,
                        rect.size.height / 2 + rect.origin.y + 44);
    }
    [UIView transitionWithView:view
                      duration:0.4
                       options:UIViewAnimationCurveEaseOut
                    animations:^{
                        view.center = p;
                    } completion:^(BOOL finished) {
                        [self releaseAnimation];
                    }];
}


- (void)resetUpview:(UIView*)view
{
    CGRect rect = self.bounds;
    CGPoint p = (CGPoint){rect.size.width / 2 + rect.origin.x,
        -rect.size.height / 2 + rect.origin.y - 40};
    [UIView transitionWithView:view
                      duration:0.4
                       options:UIViewAnimationCurveEaseOut
                    animations:^{
                        view.center = p;
                    } completion:^(BOOL finished) {
                        [self releaseAnimation];
                    }];
}

- (void)openBackView:(UIView*)view
{
    CGRect rect2 = self.bounds;
    _animation = YES;
    [UIView transitionWithView:view
                      duration:0.23
                       options:UIViewAnimationCurveEaseOut
                    animations:^{
                        view.center = (CGPoint){20 - rect2.size.width / 2 + rect2.origin.x,
                            rect2.size.height / 2 + rect2.origin.y};
                    } completion:^(BOOL finished) {
                        _backContentView.userInteractionEnabled = YES;
                        _animation = NO;
                        [self releaseAnimation];
                        [self removeGestureRecognizer:_mainPanGesture];
                        [_transationView addGestureRecognizer:_leftPanGesture];
                        [_transationView addGestureRecognizer:_leftTapGesture];
                    }];
}

- (void)openLeftBackView:(UIView*)view
{
    CGRect rect2 = self.bounds;
    _animation = YES;
    [UIView transitionWithView:view
                      duration:0.23
                       options:UIViewAnimationCurveEaseOut
                    animations:^{
                        view.center = (CGPoint){rect2.size.width / 2 + rect2.size.width - 90,
                            rect2.size.height / 2 + rect2.origin.y};
                    } completion:^(BOOL finished) {
                        _leftView.userInteractionEnabled = YES;
                        _animation = NO;
                        [self releaseAnimation];
                        [self removeGestureRecognizer:_mainPanGesture];
                        [_transationView addGestureRecognizer:_leftPanGesture];
                        [_transationView addGestureRecognizer:_leftTapGesture];
                    }];
}

- (void)resetLeftView
{
    CGRect rect = self.animationView.bounds,
    rect2 = self.frame;
    [UIView transitionWithView:self
                      duration:0.4
                       options:UIViewAnimationCurveEaseOut
                    animations:^{
                        self.center = (CGPoint){20 - rect.size.width / 2 + rect.origin.x,
                            rect2.size.height / 2 + rect2.origin.y};
                    } completion:^(BOOL finished) {
                        _backContentView.userInteractionEnabled = YES;
                        [self releaseAnimation];
                    }];
}

- (void)closeBackView:(UIView*)view
{
    CGRect rect2 = self.bounds;
    [UIView transitionWithView:self
                      duration:0.23
                       options:UIViewAnimationCurveEaseOut
                    animations:^{
                        view.center = (CGPoint){rect2.size.width / 2 + rect2.origin.x,
                            rect2.size.height / 2 + rect2.origin.y};
                    } completion:^(BOOL finished) {
                        [self releaseAnimation];
                        if (!_animationCount) {
                            [_backContentView removeFromSuperview];
                            _backContentView = nil;
                            [_leftView removeFromSuperview];
                            _leftView = nil;
                            if ([_delegate respondsToSelector:@selector(flipView:backgroudClosed:)]) {
                                [_delegate flipView:self backgroudClosed:_pageIndex];
                            }
                            [self releaseAnimation];
                        }
                    }];
    [self addGestureRecognizer:_mainPanGesture];
    [_transationView removeGestureRecognizer:_leftPanGesture];
    [_transationView removeGestureRecognizer:_leftTapGesture];
}

static NSTimeInterval __start;

- (void)panndOn:(UIPanGestureRecognizer*)pan
{
    if (_animation == YES || _stop || !_dragEnable || _willToReload) {
        return;
    }
    int state = pan.state;
    CGPoint p = [pan locationInView:self];
    switch (state) {
        case UIGestureRecognizerStateBegan:
        {
            __start = [[NSDate date] timeIntervalSince1970];
            _tempPoint = p;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if (_state == 1) {
                CGFloat height = self.bounds.size.height / 3;
                NSTimeInterval t2 = [[NSDate date] timeIntervalSince1970];
                if (_state2 == 1) {
                    
                    if (_tempPoint.y - p.y > height ||
                        (_tempPoint.y - p.y > 20 && 
                         t2 - __start < 0.2)) {
                            _pageIndex ++;
                            if ((_tempPoint.y - p.y > 20 && 
                                 t2 - __start < 0.2)) {
                                [self moveUpOut:[self getDragingView:_pageIndex - 1]];
                            }else 
                                [self moveUpOut:[self getDragingView:_pageIndex - 1]];
                        }else {
                            [self resetNowViewEx:[self getDragingView:_pageIndex]];
                        }
                }else if (_state2 == 2) {
                    if (p.y - _tempPoint.y> height||
                        (p.y - _tempPoint.y > 20 && 
                         t2 - __start < 0.2)) {
                            _pageIndex --;
                            if (p.y - _tempPoint.y > 20 && 
                                t2 - __start < 0.2) {
                                [self moveDownIn:[self getDragingView:_pageIndex]];
                            }else 
                                [self moveDownIn:[self getDragingView:_pageIndex]];
                        }else {
                            [self resetUpview:[self getDragingView:_pageIndex - 1]];
                        }
                }else if (_state2 == 4) {
                    if ([_delegate respondsToSelector:@selector(flipView:didDragToBorder:offset:)]) {
                        [_delegate flipView:self 
                            didDragToBorder:YES 
                                     offset:(_tempPoint.y - p.y) * 2 / 5];
                    }
                    [self resetNowView:[self getDragingView:_pageIndex]];
                }else if (_state2 == 3) {
                    if ([_delegate respondsToSelector:@selector(flipView:didDragToBorder:offset:)]) {
                        [_delegate flipView:self
                            didDragToBorder:NO 
                                     offset:(p.y - _tempPoint.y) * 2 / 5];
                    }
                    [self resetNowView:[self getDragingView:_pageIndex]];
                }else {
                    [self releaseAnimation];
                }
            }else if (_state == 2){
                if (_state2 == 2) {
                    NSTimeInterval t2 = [[NSDate date] timeIntervalSince1970];
                    p = [pan locationInView:self.animationView];
                    if (_transationView.center.x < 0 ||
                        (_tempPoint.x - p.x > 20 && 
                         t2 - __start < 0.5)) {
                            [self openBackView:_transationView];
                        }else {
                            [self closeBackView:_transationView];
                        }
                }else if (_state2 == 1) {
                    NSTimeInterval t2 = [[NSDate date] timeIntervalSince1970];
                    p = [pan locationInView:self.animationView];
                    if (_transationView.center.x > 250 ||
                        (p.x - _tempPoint.x > 20 && 
                         t2 - __start < 0.5)) {
                            [self openLeftBackView:_transationView];
                        }else {
                            [self closeBackView:_transationView];
                        }
                }else {
                    [self closeBackView:_transationView];
                }
            }
            _state = 0;
            _state2 = 0;
        }
            break;
        default: {
            if (_state == 0) {
                _state = abs((int)(p.x - _tempPoint.x)) <= abs((int)(p.y - _tempPoint.y)) ? 1:2;
                if (self.open && _state == 1) {
                    _state = 0;
                    return;
                }
                _tempPoint = p;
                _transationView.hidden = NO;
                MTFlipAnimationView *oldNow = [self imageViewWithIndex:_pageIndex];
                if (oldNow) {
                    if ([_delegate respondsToSelector:@selector(flipView:reloadView:atIndex:)]) {
                        [_delegate flipView:self
                                 reloadView:oldNow
                                    atIndex:_pageIndex];
                    }
                }
                if (_state == 1) {
                    [self retainAnimation];
                    if ([_delegate respondsToSelector:@selector(flipView:startDraging:)]) {
                        [_delegate flipView:self startDraging:_pageIndex];
                    }
                    MTFlipAnimationView *nowView = [self getDragingView:_pageIndex];
                    MTFlipAnimationView *upView = [self getDragingView:_pageIndex - 1];
                    if (upView && [_delegate respondsToSelector:@selector(flipView:reloadView:atIndex:)]) {
                        [_delegate flipView:self
                                 reloadView:upView
                                    atIndex:_pageIndex - 1];
                    }
                    [self getDragingView:_pageIndex - 2];
                    [self getDragingView:_pageIndex - 3];
                    MTFlipAnimationView *downView = [self getDragingView:_pageIndex + 1];
                    if (downView && [_delegate respondsToSelector:@selector(flipView:reloadView:atIndex:)]) {
                        [_delegate flipView:self
                                 reloadView:downView
                                    atIndex:_pageIndex + 1];
                    }
                    [self getDragingView:_pageIndex + 2];
                    [self getDragingView:_pageIndex + 3];
                    
                    
                    [nowView setAnimationPercent:0];
                    [upView setAnimationPercent:-1];
                    [downView setAnimationPercent:0];
                }else {
                    //左右
                    if (self.open) {
                        return;
                    }
                    [_backgroundView removeFromSuperview];
                    _backContentView = [_delegate flipView:self 
                                             backgroudView:_pageIndex 
                                                      left:NO];
                    [_leftView removeFromSuperview];
                    _leftView = [_delegate flipView:self
                                       backgroudView:_pageIndex
                                                left:YES];
                    [self getDragingView:_pageIndex];
                    [self retainAnimation];
                    [self insertSubview:_backContentView 
                           belowSubview:_transationView];
                    
                    [self insertSubview:_leftView
                           belowSubview:_transationView];
                    _tempPoint = [pan locationInView:self.animationView];
                }
            }
            
            if (_state == 1) {
                CGRect rect = self.bounds;
                CGFloat height = rect.size.height;
                MTFlipAnimationView *nowView = [self getDragingView:_pageIndex];
                MTFlipAnimationView *upView = [self getDragingView:_pageIndex - 1];
                [self getDragingView:_pageIndex + 1];
                if (p.y > _tempPoint.y) {
                    if (_pageIndex > 0 /*&& (_state2 == 2 || _state2 == 0)*/) {
                        _state2 = 2;
                        CGFloat p2 = -1-(_tempPoint.y - p.y) / height;
                        [upView setAnimationPercent:p2];
                        [nowView setAnimationPercent:0];
                        _backgroundView.backgroundColor = _blackColor;
                        _bottomLabel.hidden = YES;
                        [_transationView insertSubview:_backgroundView
                                               atIndex:0];
                    }else if (_pageIndex <= 0 /*&& (_state2 == 4 || _state2 == 0)*/){
                        _state2 = 4;
                        CGFloat p2 = (1 - (1+(_tempPoint.y - p.y) / height)) / 2;
                        [nowView setAnimationPercent:p2];
                        
                        _backgroundView.backgroundColor = m_backgroundColor;
                        _topLabel.hidden = NO;
                        _bottomLabel.hidden = YES;
                        [_transationView insertSubview:_backgroundView
                                          belowSubview:nowView];
                    }else {
                        [upView setAnimationPercent:-1];
                        [nowView setAnimationPercent:0];
                    }
                }else if (p.y < _tempPoint.y) {
                    if (_pageIndex < _count - 1 /*&& (_state2 == 1 || _state2 == 0)*/) {
                        _state2 = 1;
                        CGFloat p2 = (p.y - _tempPoint.y) / height;
                        [upView setAnimationPercent:-1];
                        [nowView setAnimationPercent:p2];
                        
                        _backgroundView.backgroundColor = _blackColor;
                        _bottomLabel.hidden = YES;
                        [_transationView insertSubview:_backgroundView
                                               atIndex:0];
                    }else if (_pageIndex >= _count - 1 /*&& (_state2 == 3 || _state2 == 0)*/){
                        _state2 = 3;
                        CGFloat p2 = (p.y - _tempPoint.y) / height / 2;
                        [upView setAnimationPercent:-1];
                        [nowView setAnimationPercent:p2];
                        
                        _backgroundView.backgroundColor = m_backgroundColor;
                        _topLabel.hidden = YES;
                        _bottomLabel.hidden = NO;
                        [_transationView insertSubview:_backgroundView
                                          belowSubview:nowView];
                    }else {
                        [upView setAnimationPercent:-1];
                        [nowView setAnimationPercent:0];
                    }
                }
            }else {
                CGRect rect2 = self.bounds;
                p = [pan locationInView:self.animationView];
                
                if (!_state2) {
                    if (p.x > _tempPoint.x && _leftView) {
                        //右边
                        _state2 = 1;
                        [_leftView addGestureRecognizer:[[UISwipeGestureRecognizer alloc] init]];
                    }else if (p.x < _tempPoint.x && _backContentView) {
                        _state2 = 2;
                        [_backContentView addGestureRecognizer:_backPanGesture];
                    }
                }
                float x = rect2.size.width / 2 + rect2.origin.x - _tempPoint.x + p.x;
                if (_state2 == 2 && _backContentView) {
                    if (x > rect2.size.width/ 2 + rect2.origin.x) {
                        x = rect2.size.width/ 2 + rect2.origin.x;
                    }
                    if (x < 20 - rect2.size.width/ 2 + rect2.origin.x) {
                        x = 20 - rect2.size.width/ 2 + rect2.origin.x;
                    }
                    _backContentView.hidden = NO;
                    _leftView.hidden = YES;
                    _transationView.center = CGPointMake(x,
                    rect2.size.height / 2 + rect2.origin.y);
                }else if (_state2 == 1 && _leftView) {
                    if (x < rect2.size.width/ 2 + rect2.origin.x) {
                        x = rect2.size.width / 2 + rect2.origin.x;
                    }
                    if (x > rect2.size.width/ 2 + rect2.size.width - 90) {
                        x = rect2.size.width/ 2 + rect2.size.width - 90;
                    }
                    _backContentView.hidden = YES;
                    _leftView.hidden = NO;
                    _transationView.center = CGPointMake(x,
                                                         rect2.size.height / 2 + rect2.origin.y);
                }
            }
        }
            break;
    }
}

- (void)closeBackView
{
    [self closeBackView:_transationView];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([anim respondsToSelector:@selector(userObject)]) {
        id obj = [anim performSelector:@selector(userObject)];
        if ([obj isKindOfClass:[NSNumber class]]) {
            int i = [obj intValue];
            self.userInteractionEnabled = YES;
            _state = 0;
            _animation = NO;
            if (i == 11) {
                _bottomLabel.hidden = YES;
            }else if (i == 1){
                CGRect rect = self.animationView.bounds;
                self.layer.position = CGPointMake(20 - rect.size.width/ 2 + rect.origin.x,
                                                  rect.size.height / 2 + rect.origin.y);
            }else if (i == 2){
                [_backContentView removeFromSuperview]; 
                _backContentView = nil;
            }else if (i == 3) {
                _backContentView.userInteractionEnabled = YES;
            }
        }
    }
}

- (void)clickLeft:(id)sender
{
    if (!_dragEnable) {
        return;
    }
    [self retainAnimation];
    [self closeBackView:_transationView];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    NSLog(@"touched at state bar");
    if (!_animationCount) {
        [self backToTop:YES];
    }else {
        _willBackToTop = YES;
    }
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    _scrollView.contentOffset = CGPointMake(0, 10);
}

- (void)panOnLeft:(UIPanGestureRecognizer*)pan
{
    if (!_dragEnable) {
        return;
    }
    int state = pan.state;
    switch (state) {
        case UIGestureRecognizerStateBegan:
            _tempPoint = [pan locationInView:self];
            static CGPoint  tp;
            tp = _transationView.center;
            __start = [[NSDate date] timeIntervalSince1970];
            [self retainAnimation];
            _state2 = tp.x > 0 ? 1:2;
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:{
            NSTimeInterval t2 = [[NSDate date] timeIntervalSince1970];
            CGPoint p2 = [pan translationInView:self];
            if (_state2 == 2) {
                if (_transationView.center.x > 0 ||
                    (p2.x - _tempPoint.x > 20 && 
                     t2 - __start < 0.2)) {
                        [self closeBackView:_transationView];
                    }else {
                        [self openBackView:_transationView];
                    }
            }else {
                if (_transationView.center.x < self.bounds.size.width - 40 ||
                    (_tempPoint.x - p2.x > 20 && 
                     t2 - __start < 0.2)) {
                        [self closeBackView:_transationView];
                    }else {
                        [self openLeftBackView:_transationView];
                    }
            }
            _state2 = 0;
            break;
        }
        default:{
            CGPoint p2 = [pan translationInView:self];
            CGRect rect = self.bounds; 
            if (_state2 == 2) {
                p2.x = p2.x < 0 ? 0:p2.x;
            }else {
                p2.x = p2.x > 0 ? 0:p2.x;
                if (tp.x + p2.x < rect.size.width / 2) {
                    p2.x = rect.size.width / 2 - tp.x;
                }
            }
            _transationView.center = (CGPoint){tp.x + rect.origin.x + p2.x, tp.y};
        }
            break;
    }
}

- (void)openBackgroudView
{
    if (!self.open && !_animation) {
        _backContentView = [_delegate flipView:self 
                                 backgroudView:_pageIndex 
                                          left:NO];
        UIView *view = [self imageViewWithIndex:_pageIndex];
        if (view) {
            if ([_delegate respondsToSelector:@selector(flipView:reloadView:atIndex:)]) {
                [_delegate flipView:self
                         reloadView:[self imageViewWithIndex:_pageIndex]
                            atIndex:_pageIndex];
            }
        }else {
            [self getDragingView:_pageIndex];
        }
        if (!_backContentView) {
            return;
        }
        [_backContentView addGestureRecognizer:_backPanGesture];
        _backContentView.hidden = NO;
        _transationView.hidden = NO;
        [self insertSubview:_backContentView
               belowSubview:_transationView];
        [self openBackView:_transationView];
    }
}

- (void)clean
{
    int totle = [_cachedImageViews count];
    _cacheRange.location = _pageIndex;
    _cacheRange.length = 1;
    for (int n = 0; n < totle; n++) {
        if (n < _pageIndex) {
            MTFlipAnimationView *view = [_cachedImageViews objectAtIndex:n];
            if ([view isKindOfClass:[UIView class]]) {
                [view removeFromSuperview];
            }
            [_cachedImageViews replaceObjectAtIndex:n withObject:[NSNull null]];
        }else if (n > _pageIndex){
            MTFlipAnimationView *view = [_cachedImageViews lastObject];
            if ([view isKindOfClass:[UIView class]]) {
                [view removeFromSuperview];
            }
            [_cachedImageViews removeObject:view];
        }
    }
}

- (void)load
{
    _count = 0;
    _count = [_delegate numberOfFlipViewPage:self];
    if (!_count) {
        return;
    }
    if (!self.open) {
        NSArray *array = self.subviews;
        for (UIView *view in array) {
            if (view != _scrollView &&
                view != _transationView) {
                [view removeFromSuperview];
            }
        }
        UIView *subView = [self getViewAtIndex:_pageIndex];
        [self insertSubview:subView
               belowSubview:_transationView];
    }else {
        NSArray *array = self.subviews;
        for (UIView *view in array) {
            if (view != _scrollView &&
                view != _transationView &&
                view != _backContentView &&
                view != _leftView) {
                [view removeFromSuperview];
            }
        }
        UIView *subView = [self getViewAtIndex:_pageIndex];
        [self insertSubview:subView
               belowSubview:_backContentView];
    }
    UIView *view = [self getDragingView:_pageIndex];
    view = [self getDragingView:_pageIndex - 1];
    view = [self getDragingView:_pageIndex - 2];
    view = [self getDragingView:_pageIndex + 1];
    view = [self getDragingView:_pageIndex + 2];
}

- (void)load:(NSInteger)page
{
    [self load];
}

- (void)setLoadAll:(BOOL)loadAll
{
    _loadAll = loadAll;
    if (_loadAll) {
        [[_bottomLabel viewWithTag:0x999] removeFromSuperview];
        _bottomLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1];
        _bottomLabel.text = @"All items loaded";
    }else {
        UIActivityIndicatorView *actionvity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        actionvity.center = CGPointMake(_bottomLabel.bounds.size.height / 2, _backgroundView.bounds.size.width / 2 - 50);
        actionvity.tag = 0x999;
        [_bottomLabel addSubview:actionvity];
        _bottomLabel.textColor = [UIColor colorWithRed:0.7 green:0 blue:0 alpha:1];
        _bottomLabel.text = @"Loading...";
    }
}

- (void)loadByNumber:(NSNumber*)number
{
    [self load:[number intValue]];
}

- (void)retainAnimation
{
    _animationCount ++;
}

- (void)releaseAnimation
{
    _animationCount --;
    if (_animationCount < 0) {
        _animationCount = 0;
    }
    if (self.open) {
        return;
    }
    if (!_animationCount) {
        _transationView.hidden = YES;
        NSArray *array = self.subviews;
        for (UIView *view in array) {
            if (view != _scrollView &&
                view != _transationView) {
                [view removeFromSuperview];
            }
        }
        _backContentView = nil;
        _leftView = nil;
        UIView *subView = [self getViewAtIndex:_pageIndex];
        [self insertSubview:subView
               belowSubview:_transationView];
        [self getDragingView:_pageIndex - 1];
        [self getDragingView:_pageIndex + 1];
        if (_willBackToTop) {
            [self backToTop:YES];
            _willBackToTop = NO;
            _willToReload = NO;
        }else if (_willToReload) {
            [self reloadData];
            _willToReload = NO;
        }
    };
}

- (void)pushViewToCache:(MTFlipAnimationView*)view
{
    [self pushViewToCache:view isClean:YES];
}

- (void)pushViewToCache:(MTFlipAnimationView*)view isClean:(BOOL)clean
{
    if (!view) {
        return;
    }
    if (clean) {
        [view clean];
    }
    NSString *indentify = view.indentify;
    NSMutableArray *arr = [_unuseViews objectForKey:indentify];
    if (!arr) {
        arr = [NSMutableArray array];
        [_unuseViews setObject:arr forKey:indentify];
    }
    [arr addObject:view];
}

- (MTFlipAnimationView*)viewByIndentify:(NSString *)indentify
{
    NSMutableArray *arr = [_unuseViews objectForKey:indentify];
    MTFlipAnimationView *view = [arr lastObject];
    if (view) {
        [arr removeObject:view];
    }
    return view;
}

- (void)preload:(NSInteger)count
{
    if (![_delegate respondsToSelector:@selector(flipViewPrePushDragingView:)]) {
        return;
    }
    int other = count - _cacheRange.length;
    while (1) {
        int tcount = 0;
        NSEnumerator *enums = [_unuseViews keyEnumerator];
        NSString *key = [enums nextObject];
        while (key) {
            NSArray *arr = [_unuseViews objectForKey:key];
            tcount += [arr count];
            key = [enums nextObject];
        }
        if (tcount >= other) {
            break;
        }
        [self pushViewToCache:[_delegate flipViewPrePushDragingView:self]];
    }
}

- (BOOL)open
{
    return fabsf(_transationView.center.x - (self.bounds.size.width / 2)) > 2;
}

@end
