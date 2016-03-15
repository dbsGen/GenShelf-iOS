//
//  GSScannerViewController.h
//  GenShelf
//
//  Created by Gen on 16/3/15.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GSScannerCallback)(NSString *result);

@interface GSScannerViewController : UIViewController

@property (nonatomic, copy) GSScannerCallback block;

@end
