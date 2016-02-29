//
//  GCoreDataManager.h
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface GCoreDataManager : NSObject

+ (GCoreDataManager*)shareManager;


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)save;

- (NSArray*)fetch:(NSString*)cls;
- (NSArray*)fetch:(NSString*)cls predicate:(NSPredicate *)predicate;
- (NSArray*)fetch:(NSString*)cls predicate:(NSPredicate *)predicate sorts:(NSArray<NSSortDescriptor*> *)sorts;

@end

@interface NSManagedObject (GCoreDataManager)

typedef void(^GConstuctorBlock)(id object);
+ (NSArray *)all;
+ (NSArray *)fetch:(NSPredicate *)predicate;
+ (NSArray *)fetch:(NSPredicate *)predicate sorts:(NSArray<NSSortDescriptor*> *)sorts;
+ (instancetype)create;
+ (instancetype)fetchOrCreate:(NSPredicate *)predicate constructor:(GConstuctorBlock)block;
- (void)remove;

@end