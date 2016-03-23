//
//  GVersionControl.h
//  GenShelf
//
//  Created by Gen on 16/3/22.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef BOOL(^GVersionBlock)(NSString *versionPrev, NSString *versionAfter);

@interface GVersion : NSObject

@property (nonatomic, readonly) NSString *versionString;
@property (nonatomic, readonly) int sectionCount;

- (instancetype)initWithString:(NSString*)versionString;
+ (instancetype)version:(NSString*)versionString;

- (NSUInteger)subVersion:(NSUInteger)index;
- (NSComparisonResult)compare:(GVersion *)otherVersion;

@end

@interface GVersionControl : NSObject

@property (nonatomic, readonly) GVersion *applicationVersion;
@property (nonatomic, readonly) GVersion *currentVersion;

+ (instancetype)instance;

- (void)addVersion:(GVersion*)version block:(GVersionBlock)block;
- (void)update;

@end
