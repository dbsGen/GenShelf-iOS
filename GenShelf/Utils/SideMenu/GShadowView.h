//
//  GShadowView.h
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    GShadowViewLR,
    GShadowViewRL,
    GShadowViewTB,
    GShadowViewBT
} GShadowViewStatus;

@interface GShadowView : UIView

@property (nonatomic, strong) NSArray<UIColor *> *colors;
@property (nonatomic, assign) GShadowViewStatus status;

@end
