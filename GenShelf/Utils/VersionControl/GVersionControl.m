//
//  GVersionControl.m
//  GenShelf
//
//  Created by Gen on 16/3/22.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GVersionControl.h"

@implementation GVersion {
    NSUInteger *_subVersions;
    int _subVersionCount;
}

- (instancetype)initWithString:(NSString *)versionString {
    self = [super init];
    if (self) {
        if (!versionString) {
            versionString = @"0";
        }
        _versionString = versionString;
        NSArray<NSString *> *sv = [_versionString componentsSeparatedByString:@"."];
        _subVersionCount = (int)sv.count;
        _subVersions = malloc(sizeof(NSUInteger) * _subVersionCount);
        for (int n = 0; n < _subVersionCount; n++) {
            _subVersions[n] = [[sv objectAtIndex:n] integerValue];
        }
    }
    return self;
}

- (void)dealloc {
    free(_subVersions);
}

+ (instancetype)version:(NSString *)versionString {
    GVersion *version = [[self alloc] initWithString:versionString];
    return version;
}

- (NSUInteger)subVersion:(NSUInteger)index {
    if (_subVersionCount <= index) {
        return 0;
    }else return _subVersions[index];
}

- (int)sectionCount {
    return _subVersionCount;
}

- (NSComparisonResult)compare:(GVersion *)otherVersion {
    int count = MAX(_subVersionCount, otherVersion.sectionCount);
    for (int n = 0; n < count; n++) {
        NSUInteger sl = [self subVersion:n];
        NSUInteger slo = [otherVersion subVersion:n];
        if (sl > slo) {
            return NSOrderedDescending;
        }else if (sl < slo) {
            return NSOrderedAscending;
        }
    }
    return NSOrderedSame;
}

@end

GVersionControl *__instance;

#define kAppVersion @"GAppVersion"

@interface GVersionContainer : NSObject

@property (nonatomic, readonly) GVersion *version;
@property (nonatomic, copy, readonly) GVersionBlock block;

+ (instancetype)container:(GVersion *)version :(GVersionBlock)block;
- (NSComparisonResult)compare:(GVersionContainer*)other;

@end

@implementation GVersionContainer

+ (instancetype)container:(GVersion *)version :(GVersionBlock)block {
    GVersionContainer *c = [[self alloc] init];
    if (c) {
        c->_version = version;
        c->_block = block;
    }
    return c;
}

- (NSComparisonResult)compare:(GVersionContainer *)other {
    return [_version compare:other.version];
}

@end

@implementation GVersionControl {
    NSMutableArray <GVersionContainer *> *_versions;
}

+ (instancetype)instance {
    @synchronized(self) {
        if (!__instance) {
            __instance = [[GVersionControl alloc] init];
        }
    }
    return __instance;
}

- (id)init {
    self = [super init];
    if (self) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        
        NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        _applicationVersion = [GVersion version:appVersion];
        
        NSString *currentVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kAppVersion];
        _currentVersion = [GVersion version:currentVersion];
        _versions = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addVersion:(GVersion*)version block:(GVersionBlock)block {
    [_versions addObject:[GVersionContainer container:version :block]];
}

- (void)update {
    NSArray<GVersionContainer*> *vs = [_versions sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    for (GVersionContainer *con in vs) {
        if ([con.version compare:_currentVersion] == NSOrderedDescending && [con.version compare:_applicationVersion] != NSOrderedDescending) {
            if (con.block) {
                if (!con.block(_currentVersion.versionString, _applicationVersion.versionString)) {
                    NSLog(@"Faild at %@", con.version.versionString);
                }
            }
        }
    }
    [_versions removeAllObjects];
    _currentVersion = _applicationVersion;
    [[NSUserDefaults standardUserDefaults] setObject:_currentVersion.versionString
                                              forKey:kAppVersion];
}

@end
