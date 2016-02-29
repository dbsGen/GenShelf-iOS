//
//  GSModelNetPage+CoreDataProperties.h
//  GenShelf
//
//  Created by Gen on 16/2/29.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GSModelNetPage.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSModelNetPage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *imageUrl;
@property (nullable, nonatomic, retain) NSNumber *index;
@property (nullable, nonatomic, retain) NSString *pageUrl;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSString *thumUrl;
@property (nullable, nonatomic, retain) GSModelNetBook *book;

@end

NS_ASSUME_NONNULL_END
