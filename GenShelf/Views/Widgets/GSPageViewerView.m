//
//  GSPageViewerView.m
//  GenShelf
//
//  Created by Gen on 16/3/1.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSPageViewerView.h"

@implementation GSPageViewerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageView];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    _imageView.image = image;
}

@end
