//
//  GCoreDataManager.m
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GCoreDataManager.h"

static GCoreDataManager *_defaultManager = NULL;

@implementation GCoreDataManager {
    NSTimer *_timer;
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (GCoreDataManager*)shareManager {
    @synchronized(self) {
        if (!_defaultManager) {
            _defaultManager = [[GCoreDataManager alloc] init];
        }
    }
    return _defaultManager;
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.ri.GenShelf" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"GenShelf" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    BOOL first = YES;
    do {
        if (_persistentStoreCoordinator != nil) {
            return _persistentStoreCoordinator;
        }
        
        // Create the coordinator and store
        
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"GenShelf.sqlite"];
//        [[NSFileManager defaultManager] removeItemAtURL:storeURL
//                                                  error:nil];
        NSError *error = nil;
        NSString *failureReason = @"There was an error creating or loading the application's saved data.";
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            // Report any error we got.
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
            dict[NSLocalizedFailureReasonErrorKey] = failureReason;
            dict[NSUnderlyingErrorKey] = error;
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            error = nil;
            if (first) {
                [[NSFileManager defaultManager] removeItemAtURL:storeURL
                                                          error:&error];
                _persistentStoreCoordinator = nil;
                continue;
            }else {
                abort();
            }
        }
    } while (false);
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    _timer = [NSTimer timerWithTimeInterval:10
                                     target:self
                                   selector:@selector(save)
                                   userInfo:NULL
                                    repeats:YES];
    return _managedObjectContext;
}

- (void)dealloc {
    if (_timer) {
        [_timer invalidate];
    }
}

- (void)save {
    if (_managedObjectContext != nil) {
        NSError *error = nil;
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSArray *)fetch:(NSString *)cls {
    return [self fetch:cls predicate:NULL];
}

- (NSArray*)fetch:(NSString*)cls predicate:(NSPredicate *)predicate {
    NSManagedObjectContext *moc = self.managedObjectContext;
    if (moc) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:cls];
        if (predicate) {
            [request setPredicate:predicate];
        }
        NSError *error = nil;
        NSArray *results = [moc executeFetchRequest:request error:&error];
        if (!results) {
            NSLog(@"Error fetching %@ objects: %@\n%@", cls, [error localizedDescription], [error userInfo]);
            return [NSArray array];
        }
        return results;
    }
    return [NSArray array];
}

@end


@implementation NSManagedObject (GCoreDataManager)

+ (NSArray *)all {
    return [[GCoreDataManager shareManager] fetch:NSStringFromClass([self class])];
}

+ (NSArray *)fetch:(NSPredicate *)predicate {
    return [[GCoreDataManager shareManager] fetch:NSStringFromClass([self class])
                                        predicate:predicate];
}

+ (instancetype)fetchOrCreate:(NSPredicate *)predicate constructor:(GConstuctorBlock)block {
    NSArray *arr = [self fetch:predicate];
    if (arr.count) {
        return arr.firstObject;
    }else {
        id co = [self create];
        if (block) {
            block(co);
        }
        return co;
    }
}

+ (instancetype)create {
    id context = [GCoreDataManager shareManager].managedObjectContext;
    return [[self alloc] initWithEntity:[NSEntityDescription entityForName:NSStringFromClass([self class])
                                                    inManagedObjectContext:context]
         insertIntoManagedObjectContext:context];
}

- (void)remove {
    [[GCoreDataManager shareManager].managedObjectContext deleteObject:self];
}

@end
