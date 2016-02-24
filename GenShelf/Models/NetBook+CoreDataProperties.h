//
//  NetBook+CoreDataProperties.h
//  GenShelf
//
//  Created by Gen on 16/2/24.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "NetBook.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetBook (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *pageUrl;
@property (nullable, nonatomic, retain) NSString *imageUrl;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSNumber *index;

@end

NS_ASSUME_NONNULL_END
