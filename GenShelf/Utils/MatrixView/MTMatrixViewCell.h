//
//  MTMatrixViewCell.h
//  boxList
//
//  Created by zrz on 12-3-26.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTMatrixViewCell : UIView
{
    
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, retain)   NSString    *reuseIdentifier;
@property (nonatomic, assign)   NSIndexPath *indexPath;

@end
