//
//  GSPageViewerView.m
//  GenShelf
//
//  Created by Gen on 16/3/1.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSPageViewerView.h"
#import "GTween.h"

#define lerp(FROM, TO, MI) (FROM*(1-MI)+TO*MI)

@interface GTweenCGAffineTransformProperty : GTweenProperty
+ (id)property:(NSString*)name from:(CGAffineTransform)from to:(CGAffineTransform)to;
@end

@implementation GTweenCGAffineTransformProperty

CGAffineTransform transformLerp(CGAffineTransform from, CGAffineTransform to, float m) {
    CGAffineTransform trans;
    trans.a = lerp(from.a, to.a, m);
    trans.b = lerp(from.b, to.b, m);
    trans.c = lerp(from.c, to.c, m);
    trans.d = lerp(from.d, to.d, m);
    trans.tx = lerp(from.tx, to.tx, m);
    trans.ty = lerp(from.ty, to.ty, m);
    return trans;
}

+ (id)property:(NSString*)name from:(CGAffineTransform)from to:(CGAffineTransform)to
{
    return [[self alloc] initWithName:name
                                 from:[NSValue valueWithCGAffineTransform:from]
                                   to:[NSValue valueWithCGAffineTransform:to]];
}

- (void)progress:(float)p target:(id)target imp:(IMP)imp selector:(SEL)sel
{
    CGAffineTransform res = transformLerp([self.fromValue CGAffineTransformValue], [self.toValue CGAffineTransformValue], p);
    
    GTSetter(CGAffineTransform, target, imp, sel, res);
}


@end

@interface GSPageViewerView ()

@property (nonatomic, assign) CGPoint translation;

@end

@implementation GSPageViewerView {
    NSInteger   _touchCount;
    CGPoint     _oldTouchPosition;
    CGFloat     _beginScale;
    CGPoint     _translation;
    CGFloat     _scale;
    BOOL _bordLeft, _bordRight, _bordTop, _bordBottom;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageView];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(onPan:)];
        pan.minimumNumberOfTouches = 2;
        _scale = 1;
        [self addGestureRecognizer:pan];
        
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(onPinch:)];
        [self addGestureRecognizer:pinch];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    if (_image != image) {
        _image = image;
        CGSize originalSize = image.size;
        CGRect frame;
        frame.size.height = self.bounds.size.height;
        frame.size.width = originalSize.width * frame.size.height / originalSize.height;
        frame.origin.y = 0;
        frame.origin.x = (self.bounds.size.width - frame.size.width)/2;
        _imageView.image = image;
        _imageView.frame = frame;
    }
}


- (void)onPan:(UIPanGestureRecognizer *)pan {
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            [GTween cancel:self];
            _oldTouchPosition = [pan locationInView:self];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
            [self revert];
            break;
            
        default: {
            if (pan.numberOfTouches == 2) {
                CGPoint position = [pan locationInView:self];
                CGFloat offY = position.y - _oldTouchPosition.y;
                CGFloat offX = position.x - _oldTouchPosition.x;
                if (_bordTop && offY > 0) offY/=2;
                if (_bordLeft && offX > 0) offX/=2;
                _translation.x += offX;
                _translation.y += offY;
                _oldTouchPosition = position;
                [self updateTransform];
            }
        }
            break;
    }
}

- (void)onPinch:(UIPinchGestureRecognizer *)pinch {
    switch (pinch.state) {
        case UIGestureRecognizerStateBegan:
            [GTween cancel:self];
            _beginScale = _scale;
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
            [self revert];
            break;
            
        default: {
            _scale = _beginScale * pinch.scale;
            [self updateTransform];
        }
            break;
    }
}

- (void)updateTransform {
    _imageView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(_scale, _scale), _translation.x, _translation.y);
    CGRect frame = _imageView.frame;
    _bordLeft = frame.origin.x > 0;
    _bordTop = frame.origin.y > 0;
    _bordRight = frame.origin.x + frame.size.width < self.bounds.size.width;
    _bordBottom = frame.origin.y + frame.size.height > self.bounds.size.height;
}

- (void)setTranslation:(CGPoint)translation {
    _translation = translation;
    [self updateTransform];
}

- (void)revert {
    CGRect frame = _imageView.frame, bounds = self.bounds;
    BOOL willRevert = NO;
    CGPoint trans = _translation;
    if (frame.origin.x > 0) {
        willRevert = YES;
        trans.x -= frame.origin.x;
        if (frame.origin.x + frame.size.width < bounds.size.width) {
            trans.x = 0;
        }
    }else if (frame.origin.x + frame.size.width < bounds.size.width) {
        willRevert = YES;
        trans.x += bounds.size.width - (frame.origin.x + frame.size.width);
    }
    if (frame.origin.y > 0) {
        willRevert = YES;
        trans.y -= frame.origin.y;
        if (frame.origin.y + frame.size.height < bounds.size.height) {
            trans.y = 0;
        }
    }else if (frame.origin.y + frame.size.height < bounds.size.height) {
        willRevert = YES;
        trans.y += bounds.size.height - (frame.origin.y + frame.size.height);
    }
    if (willRevert) {
        GTween *tween = [[GTween alloc] initWithTarget:self
                                              duration:0.2
                                                  ease:[GEaseCubicOut class]];
        [tween addProperty:[GTweenCGPointProperty property:@"translation"
                                                      from:_translation
                                                        to:trans]];
        [tween start];
    }
}

@end
