//
//  MTAlertView.h
//  SOP2p
//
//  Created by zrz on 12-6-22.
//  Copyright (c) 2012年 Sctab. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTAlertView;

@protocol MTAlertViewDelegate <NSObject>

- (void)alertView:(MTAlertView*)alertView clickedButtonAtIndex:(NSInteger)index;

@end

@interface MTAlertView : UIView

@property (nonatomic, weak)  id<MTAlertViewDelegate>  delegate;
@property (nonatomic, strong) id customerData;

- (id)initWithContent:(NSString*)content
                image:(UIImage*)image 
              buttons:(NSString*)label, ...;
- (void)show;
- (void)showInView:(UIView*)view;
- (void)miss;

@end
