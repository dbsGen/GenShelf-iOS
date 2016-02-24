//
//  HomeData+CoreDataProperties.h
//  GenShelf
//
//  Created by Gen on 16/2/24.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "HomeData.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeData (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *page;
@property (nullable, nonatomic, retain) NSNumber *hasNext;
@property (nullable, nonatomic, retain) NSSet<Book *> *books;

@end

@interface HomeData (CoreDataGeneratedAccessors)

- (void)addBooksObject:(Book *)value;
- (void)removeBooksObject:(Book *)value;
- (void)addBooks:(NSSet<Book *> *)values;
- (void)removeBooks:(NSSet<Book *> *)values;

@end

NS_ASSUME_NONNULL_END
