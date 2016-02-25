//
//  GSModelPage+CoreDataProperties.h
//  GenShelf
//
//  Created by Gen on 16/2/25.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GSModelPage.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSModelPage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *index;
@property (nullable, nonatomic, retain) NSNumber *loaded;
@property (nullable, nonatomic, retain) NSString *path;
@property (nullable, nonatomic, retain) NSString *thum;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) GSModelBook *book;

@end

NS_ASSUME_NONNULL_END
