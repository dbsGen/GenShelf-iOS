//
//  UIRadisImageView.m
//  GenShelf
//
//  Created by Gen on 16/2/23.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSRadisImageView.h"

@implementation GSRadisImageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self updateFrame];
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateFrame];
}

- (void)setImage:(UIImage *)image {
    if (_image != image) {
        _image = image;
        [self updateFrame];
    }
}

- (void)updateFrame {
    if (_image) {
        CGRect bounds = self.bounds;
        CGSize size = _image.size;
        CGRect imageFrame = bounds;
        CGSize newSize = size;
        if (size.height/size.width > bounds.size.height/bounds.size.width) {
            newSize.width = bounds.size.width;
            newSize.height = size.height * bounds.size.width / size.width;
            
            imageFrame.origin.x = 0;
            imageFrame.origin.y = -(newSize.height - bounds.size.height)/2;
            imageFrame.size = newSize;
        }else {
            newSize.height = bounds.size.height;
            newSize.width = size.width * bounds.size.height / size.height;
            
            imageFrame.origin.y = 0;
            imageFrame.origin.x = -(newSize.width - bounds.size.width)/2;
            imageFrame.size = newSize;
        }
        if (!_imageView) {
            _imageView = [[UIImageView alloc] initWithFrame:imageFrame];
            [self addSubview:_imageView];
        }
        _imageView.frame = imageFrame;
        _imageView.image = _image;
    }
}

- (void)setRadius:(CGFloat)radius {
    if (radius != _radius) {
        _radius = radius;
        self.layer.cornerRadius = radius;
    }
}

@end
