//
//  GSideCoverView.h
//  GenShelf
//
//  Created by Gen on 16/2/19.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^GSideCoverViewBlock)(CGPoint);
@interface GSideCoverView : UIView

@property (nonatomic, copy) GSideCoverViewBlock moveBlock;
@property (nonatomic, copy) GSideCoverViewBlock endBlock;

@end
