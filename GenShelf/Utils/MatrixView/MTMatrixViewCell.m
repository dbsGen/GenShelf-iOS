//
//  MTMatrixViewCell.m
//  boxList
//
//  Created by zrz on 12-3-26.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "MTMatrixViewCell.h"
#import "MTMatrixTools.h"

#define kMask   0x0000ffff

@implementation MTMatrixViewCell

@synthesize reuseIdentifier = _reuseIdentifier, indexPath = _indexPath;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:frame];
    if (self) {
        self.reuseIdentifier = reuseIdentifier;
    }
    return self;
}

@end
