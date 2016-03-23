//
//  GSModelData+CoreDataProperties.h
//  GenShelf
//
//  Created by Gen on 16/3/23.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "GSModelData.h"

NS_ASSUME_NONNULL_BEGIN

@interface GSModelData (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *key;
@property (nullable, nonatomic, retain) NSData *value;

+ (NSData *)valueForKey:(NSString *)key;
+ (void)setValue:(NSData *)value forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
