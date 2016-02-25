//
//  GSModelHomeData+CoreDataProperties.h
//  GenShelf
//
//  Created by Gen on 16/2/25.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GSModelHomeData.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSModelHomeData (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *hasNext;
@property (nullable, nonatomic, retain) NSNumber *page;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSOrderedSet<GSModelNetBook *> *books;

@end

@interface GSModelHomeData (CoreDataGeneratedAccessors)

- (void)insertObject:(GSModelNetBook *)value inBooksAtIndex:(NSUInteger)idx;
- (void)removeObjectFromBooksAtIndex:(NSUInteger)idx;
- (void)insertBooks:(NSArray<GSModelNetBook *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeBooksAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInBooksAtIndex:(NSUInteger)idx withObject:(GSModelNetBook *)value;
- (void)replaceBooksAtIndexes:(NSIndexSet *)indexes withBooks:(NSArray<GSModelNetBook *> *)values;
- (void)addBooksObject:(GSModelNetBook *)value;
- (void)removeBooksObject:(GSModelNetBook *)value;
- (void)addBooks:(NSOrderedSet<GSModelNetBook *> *)values;
- (void)removeBooks:(NSOrderedSet<GSModelNetBook *> *)values;

@end

NS_ASSUME_NONNULL_END
