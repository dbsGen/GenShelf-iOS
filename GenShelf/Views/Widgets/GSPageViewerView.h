//
//  GSPageViewerView.h
//  GenShelf
//
//  Created by Gen on 16/3/1.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GSPAGE_FILL_MODEL_CHANGE @"GSPAGE_FILL_MODEL_CHANGE"

@class GSPageViewerView;

typedef void(^GSPageViewerBlock)(GSPageViewerView *sender);

@interface GSPageViewerView : UIView {
}

@property (nonatomic, assign) BOOL fillMode;
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, readonly) UIImageView *imageView;

@property (nonatomic, assign) CGPoint translation;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, copy) GSPageViewerBlock onUpdate;

@end
