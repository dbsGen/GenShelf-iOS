//
//  Book+CoreDataProperties.h
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Book.h"

NS_ASSUME_NONNULL_BEGIN

@interface Book (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSNumber *index;
@property (nullable, nonatomic, retain) NSNumber *loaded;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *page_count;
@property (nullable, nonatomic, retain) NSString *path;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSOrderedSet<NSManagedObject *> *pages;

@end

@interface Book (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inPagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPagesAtIndex:(NSUInteger)idx;
- (void)insertPages:(NSArray<NSManagedObject *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPagesAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replacePagesAtIndexes:(NSIndexSet *)indexes withPages:(NSArray<NSManagedObject *> *)values;
- (void)addPagesObject:(NSManagedObject *)value;
- (void)removePagesObject:(NSManagedObject *)value;
- (void)addPages:(NSOrderedSet<NSManagedObject *> *)values;
- (void)removePages:(NSOrderedSet<NSManagedObject *> *)values;

@end

NS_ASSUME_NONNULL_END
