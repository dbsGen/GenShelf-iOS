//
//  GSSelectView.h
//  GenShelf
//
//  Created by Gen on 16/2/18.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GSSelectView : UIView

@property (nonatomic, readonly) UIPickerView *pickerView;
@property (nonatomic, readonly) UIToolbar    *toolBar;

- (void)show;
- (void)miss;

@end
