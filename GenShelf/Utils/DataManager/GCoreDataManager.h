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

@end

@interface NSManagedObject (GCoreDataManager)

+ (NSArray *)all;
+ (NSArray *)fetch:(NSPredicate *)predicate;

@end