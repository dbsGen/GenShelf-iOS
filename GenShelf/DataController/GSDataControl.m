//
//  GSDataController.m
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSDataControl.h"
#import "GSGlobals.h"
#import "GCoreDataManager.h"
#import "GSDataDefines.h"
#import "GSPictureManager.h"
#import "GSModelData.h"

@implementation GSDataProperty

+ (instancetype)propertyWithName:(NSString *)name defaultValue:(id)value type:(GSDataPropertyType)type {
    return [self propertyWithName:name defaultValue:value
                             type:type data:nil];
}

+ (instancetype)propertyWithName:(NSString *)name defaultValue:(id)value type:(GSDataPropertyType)type data:(id)data {
    GSDataProperty *property = [[self alloc] init];
    if (property) {
        property->_name = name;
        property->_defaultValue = value;
        property->_type = type;
        property->_custmorData = data;
    }
    return property;
}

+ (instancetype)boolPropertyWithName:(NSString *)name defaultValue:(BOOL)value {
    return [self propertyWithName:name
                     defaultValue:[NSNumber numberWithBool:value]
                             type:GSDataPropertyTypeBOOL];
}

+ (instancetype)optionsPropertyWithName:(NSString *)name defaultValue:(NSUInteger)selected options:(NSArray<NSString*>*)options {
    GSDataProperty *property = [self propertyWithName:name
                                         defaultValue:[NSNumber numberWithInteger:selected]
                                                 type:GSDataPropertyTypeOptions];
    property.custmorData = options;
    return property;
}

@end

@interface GSDataControl ()

- (void)checkProperties;
- (void)saveProperties;
- (void)loadProperties;

@end

@implementation GSDataControl

@synthesize name = _name, requestDelay = _requestDelay, taskQueue = _taskQueue;
static NSMutableArray *_progressingBooks;

- (id)init {
    self = [super init];
    if (self) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 3;
        _saveFlag = NO;
        if (!_progressingBooks) {
            [GSDataControl loadProgressBooks];
        }
    }
    return self;
}

- (GSTaskQueue *)taskQueue {
    if (!_taskQueue) {
        _taskQueue = [[GSTaskQueue alloc] initWithSource:self.name];
    }
    return _taskQueue;
}

#define kSaveKey [NSString stringWithFormat:@"%@ Config", self.name]

- (void)saveProperties {
    if (_saveFlag) {
        _saveFlag = NO;
        if (_propertiesValues) {
            [GSModelData setValue:[NSKeyedArchiver archivedDataWithRootObject:_propertiesValues]
                           forKey:kSaveKey];
            [[GCoreDataManager shareManager] save];
        }
    }
}

- (void)loadProperties {
    NSData *data = [GSModelData valueForKey:kSaveKey];
    if (data) {
        _propertiesValues = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    if (!_propertiesValues) {
        _propertiesValues = [[NSMutableDictionary alloc] init];
    }
}
#undef kSaveKey

- (NSArray<GSDataProperty*>*)properties {
    [self checkProperties];
    return _properties;
}

- (void)makeChange {
    _saveFlag = YES;
    [self performSelector:@selector(saveProperties)
               withObject:nil
               afterDelay:0];
}

- (void)checkProperties {
    if (!_properties) {
        _properties = [[NSMutableArray alloc] init];
        _propertiesIndex = [[NSMutableDictionary alloc] init];
        [self loadProperties];
        
        [self makeProperties];
    }
}

- (void)makeProperties {}

- (GSDataProperty*)getPropertyItem:(NSString*)name {
    [self checkProperties];
    for (GSDataProperty *property in _properties) {
        if ([property.name isEqualToString:name]) {
            return property;
        }
    }
    return nil;
}

- (void)insertProperty:(GSDataProperty *)property {
    [self checkProperties];
    [_properties addObject:property];
    [_propertiesIndex setObject:property forKey:property.name];
}

- (id)getProperty:(NSString*)name {
    [self checkProperties];
    GSDataProperty *pro = [_propertiesIndex objectForKey:name];
    if (pro) {
        id value = [_propertiesValues objectForKey:name];
        if (!value) {
            value = pro.defaultValue;
        }
        return value;
    }
    return nil;
}

- (void)setProperty:(id)value withName:(NSString *)name {
    [self checkProperties];
    GSDataProperty *property = [_propertiesIndex objectForKey:name];
    if (property) {
        if (value) {
            [_propertiesValues setObject:value forKey:name];
        }else {
            [_propertiesValues removeObjectForKey:name];
        }
        _saveFlag = YES;
    }
    [self makeChange];
}

+ (void)updateProgressingBooks {
    for (NSInteger n = 0, t = _progressingBooks.count; n < t; n++) {
        GSBookItem *book = [_progressingBooks objectAtIndex:n];
        if (book.status == GSBookItemStatusPagesComplete || !book.mark) {
            [_progressingBooks removeObjectAtIndex:n];
            n --;
            t --;
        }
    }
}

+ (NSInteger)removeProgressingBook:(GSBookItem *)book {
    NSInteger index = [_progressingBooks indexOfObject:book];
    if (index >= 0) {
        [_progressingBooks removeObjectAtIndex:index];
    }
    return index;
}

+ (void)loadProgressBooks {
    if (!_progressingBooks) {
        _progressingBooks = [[NSMutableArray alloc] init];
    }
    [_progressingBooks removeAllObjects];
    NSArray<GSModelNetBook *> *books = [GSModelNetBook fetch:[NSPredicate predicateWithFormat:@"mark == YES AND status != %d", GSBookItemStatusPagesComplete]
                                                       sorts:@[[NSSortDescriptor sortDescriptorWithKey:@"downloadDate"
                                                          ascending:NO]]];
    for (GSModelNetBook *book in books) {
        [_progressingBooks addObject:[GSBookItem itemWithModel:book]];
    }
}

- (GSRequestTask *)mainRequest:(NSInteger)pageIndex {return nil;}
- (GSRequestTask *)searchRequest:(NSString *)keyword pageIndex:(NSInteger)pageIndex {return nil;}

+ (NSArray *)progressingBooks {
    return _progressingBooks;
}
- (GSTask *)processBook:(GSBookItem *)book {
    if (!book.source) {
        book.source = self.name;
    }
    return nil;
}
- (GSTask *)downloadBook:(GSBookItem *)book {
    if (book.status != GSBookItemStatusPagesComplete &&
        [_progressingBooks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pageUrl == %@", book.pageUrl]].count == 0) {
        
        [_progressingBooks addObject:book];
    }
    return nil;
}

- (void)pauseBook:(GSBookItem *)book {
    GSTask *task = [self.taskQueue task:BookDownloadIdentifier(book)];
    if (task) {
        [task cancel];
    }
    task = [self.taskQueue task:BookProcessIdentifier(book)];
    if (task) {
        [task cancel];
    }
    [book cancel];
}

- (NSInteger)deleteBook:(GSBookItem *)book {
    if ([_progressingBooks containsObject:book]) {
        NSInteger index = [_progressingBooks indexOfObject:book];
        [self pauseBook:book];
        [[GSPictureManager defaultManager] deleteBook:book];
        [_progressingBooks removeObject:book];
        return index;
    }
    [[GSPictureManager defaultManager] deleteBook:book];
    return -1;
}

@end
