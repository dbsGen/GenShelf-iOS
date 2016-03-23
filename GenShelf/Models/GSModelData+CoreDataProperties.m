//
//  GSModelData+CoreDataProperties.m
//  GenShelf
//
//  Created by Gen on 16/3/23.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GSModelData+CoreDataProperties.h"
#import "GCoreDataManager.h"

@implementation GSModelData (CoreDataProperties)

@dynamic key;
@dynamic value;

+ (NSData *)valueForKey:(NSString *)key {
    NSArray<GSModelData*> *arr = [self fetch:[NSPredicate predicateWithFormat:@"key == %@", key]];
    if (arr.count) {
        return [[arr firstObject] value];
    }
    return nil;
}

+ (void)setValue:(NSData *)value forKey:(NSString *)key {
    GSModelData * data = [self fetchOrCreate:[NSPredicate predicateWithFormat:@"key == %@", key]
                                 constructor:^(id object) {
                                     ((GSModelData*)object).key = key;
                                 }];
    data.value = value;
}

@end
