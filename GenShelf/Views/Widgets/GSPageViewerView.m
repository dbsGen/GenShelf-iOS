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

@end

@implementation GSPageViewerView {
    NSInteger   _touchCount;
    CGPoint     _oldTouchPosition;
    CGFloat     _beginScale;
    BOOL _bordLeft, _bordRight, _bordTop, _bordBottom;
}

static BOOL _fillMode;

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
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(onTap:)];
        tap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tap];
        
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setFillMode:(BOOL)fillMode {
    if (_fillMode != fillMode) {
        _fillMode = fillMode;
        [[NSNotificationCenter defaultCenter] postNotificationName:GSPAGE_FILL_MODEL_CHANGE
                                                            object:[NSNumber numberWithBool:_fillMode]];
    }
}

- (BOOL)fillMode {
    return _fillMode;
}

- (void)setImagePath:(NSString *)imagePath {
    if (![_imagePath isEqualToString:imagePath]) {
        _imagePath = imagePath;
        self.image = [UIImage imageWithContentsOfFile:_imagePath];
    }else {
        [self setImage:_image];
    }
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self updateImageFrame];
    _imageView.image = image;
    [self updateTransformWithoutCallback];
}

- (void)updateImageFrame {
    if (_image) {
        CGSize originalSize = _image.size;
        CGRect bounds = self.bounds;
        CGRect frame;
        BOOL check = originalSize.height/originalSize.width > bounds.size.height/bounds.size.width;
        if (_fillMode) {
            check = !check;
        }
        if (check) {
            frame.size.height = bounds.size.height;
            frame.size.width = originalSize.width * frame.size.height / originalSize.height;
            frame.origin.y = 0;
            frame.origin.x = (bounds.size.width - frame.size.width)/2;
        }else {
            frame.size.width = bounds.size.width;
            frame.size.height = originalSize.height * frame.size.width / originalSize.width;
            frame.origin.y = (bounds.size.height - frame.size.height)/2;
            frame.origin.x = 0;
        }
        _imageView.transform = CGAffineTransformIdentity;
        _imageView.frame = frame;
    }else {
        _imageView.transform = CGAffineTransformIdentity;
        _imageView.frame = self.bounds;
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

- (void)onTap:(UITapGestureRecognizer *)tap {
    self.fillMode = !_fillMode;
    [UIView transitionWithView:_imageView
                      duration:0.24
                       options:UIViewAnimationOptionCurveEaseOut
                    animations:^{
                        [self updateImageFrame];
                        [self updateTransform];
                    } completion:nil];
}

- (void)updateTransform {
    [self updateTransformWithoutCallback];
    if (_onUpdate) {
        _onUpdate(self);
    }
}

- (void)updateTransformWithoutCallback {
    _imageView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(_scale, _scale), _translation.x, _translation.y);
    CGRect frame = _imageView.frame;
    _bordLeft = frame.origin.x > 0;
    _bordTop = frame.origin.y > 0;
    _bordRight = frame.origin.x + frame.size.width < self.bounds.size.width;
    _bordBottom = frame.origin.y + frame.size.height > self.bounds.size.height;
}

- (void)revert {
    CGRect frame = _imageView.frame, bounds = self.bounds;
    BOOL willRevert = NO;
    CGPoint trans = _translation;
    if (frame.origin.x > 0) {
        willRevert = YES;
        trans.x -= frame.origin.x/2;
        if (frame.origin.x + frame.size.width < bounds.size.width) {
            trans.x = 0;
        }
    }else if (frame.origin.x + frame.size.width < bounds.size.width) {
        willRevert = YES;
        trans.x += (bounds.size.width - (frame.origin.x + frame.size.width))/2;
    }
    if (frame.origin.y > 0) {
        willRevert = YES;
        trans.y -= frame.origin.y/2;
        if (frame.origin.y + frame.size.height < bounds.size.height) {
            trans.y = 0;
        }
    }else if (frame.origin.y + frame.size.height < bounds.size.height) {
        willRevert = YES;
        trans.y += (bounds.size.height - (frame.origin.y + frame.size.height))/2;
    }
    
    float toScale = _scale;
    if (_scale < 0.3) {
        willRevert = YES;
        toScale = 0.3;
    }else if (_scale > 3) {
        willRevert = YES;
        toScale = 3;
    }
    if (willRevert) {
        GTween *tween = [[GTween alloc] initWithTarget:self
                                              duration:0.2
                                                  ease:[GEaseCubicOut class]];
        [tween addProperty:[GTweenCGPointProperty property:@"translation"
                                                      from:_translation
                                                        to:trans]];
        [tween addProperty:[GTweenFloatProperty property:@"scale"
                                                    from:_scale
                                                      to:toScale]];
        [tween.onUpdate addBlock:^{
            [self updateTransform];
        }];
        [tween start];
    }
}

@end
