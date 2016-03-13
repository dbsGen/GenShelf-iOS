//
//  GSProgressViewController.h
//  GenShelf
//
//  Created by Gen on 16/3/11.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GSProgressViewBlock)();

@interface GSProgressViewController : UIViewController

@property (nonatomic, copy) GSProgressViewBlock onClose;

@end
