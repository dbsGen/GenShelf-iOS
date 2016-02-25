//
//  GSModelNetBook+CoreDataProperties.h
//  GenShelf
//
//  Created by Gen on 16/2/25.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GSModelNetBook.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSModelNetBook (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *imageUrl;
@property (nullable, nonatomic, retain) NSNumber *index;
@property (nullable, nonatomic, retain) NSString *pageUrl;
@property (nullable, nonatomic, retain) NSNumber *status;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *otherData;
@property (nullable, nonatomic, retain) NSOrderedSet<GSModelNetPage *> *pages;

@end

@interface GSModelNetBook (CoreDataGeneratedAccessors)

- (void)insertObject:(GSModelNetPage *)value inPagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPagesAtIndex:(NSUInteger)idx;
- (void)insertPages:(NSArray<GSModelNetPage *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPagesAtIndex:(NSUInteger)idx withObject:(GSModelNetPage *)value;
- (void)replacePagesAtIndexes:(NSIndexSet *)indexes withPages:(NSArray<GSModelNetPage *> *)values;
- (void)addPagesObject:(GSModelNetPage *)value;
- (void)removePagesObject:(GSModelNetPage *)value;
- (void)addPages:(NSOrderedSet<GSModelNetPage *> *)values;
- (void)removePages:(NSOrderedSet<GSModelNetPage *> *)values;

@end

NS_ASSUME_NONNULL_END
