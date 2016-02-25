//
//  GSModelBook+CoreDataProperties.h
//  GenShelf
//
//  Created by Gen on 16/2/25.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GSModelBook.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSModelBook (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSNumber *index;
@property (nullable, nonatomic, retain) NSNumber *loaded;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *page_count;
@property (nullable, nonatomic, retain) NSString *path;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSOrderedSet<GSModelPage *> *pages;

@end

@interface GSModelBook (CoreDataGeneratedAccessors)

- (void)insertObject:(GSModelPage *)value inPagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPagesAtIndex:(NSUInteger)idx;
- (void)insertPages:(NSArray<GSModelPage *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPagesAtIndex:(NSUInteger)idx withObject:(GSModelPage *)value;
- (void)replacePagesAtIndexes:(NSIndexSet *)indexes withPages:(NSArray<GSModelPage *> *)values;
- (void)addPagesObject:(GSModelPage *)value;
- (void)removePagesObject:(GSModelPage *)value;
- (void)addPages:(NSOrderedSet<GSModelPage *> *)values;
- (void)removePages:(NSOrderedSet<GSModelPage *> *)values;

@end

NS_ASSUME_NONNULL_END
