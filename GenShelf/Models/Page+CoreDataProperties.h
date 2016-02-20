//
//  Page+CoreDataProperties.h
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Page.h"

NS_ASSUME_NONNULL_BEGIN

@interface Page (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *index;
@property (nullable, nonatomic, retain) NSNumber *loaded;
@property (nullable, nonatomic, retain) NSString *path;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) Book *book;

@end

NS_ASSUME_NONNULL_END
