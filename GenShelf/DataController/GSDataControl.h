//
//  GSDataController.h
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "GSModelNetBook.h"
#import "GSModelNetPage.h"
#import "GSTask.h"
#import "GSRequestTask.h"

typedef ASIHTTPRequest *(^GSRequestBlock)(NSURL *url);
typedef void *(^GSRequestUpdateBlock)(NSUInteger count);

typedef enum : NSUInteger {
    GSDataPropertyTypeBOOL,
    GSDataPropertyTypeString,
    GSDataPropertyTypeOptions,
} GSDataPropertyType;

@interface GSDataProperty : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) id defaultValue;
@property (nonatomic, readonly) GSDataPropertyType type;
@property (nonatomic, strong) id custmorData;

+ (instancetype)propertyWithName:(NSString *)name defaultValue:(id)value type:(GSDataPropertyType)type;
+ (instancetype)propertyWithName:(NSString *)name defaultValue:(id)value type:(GSDataPropertyType)type data:(id)data;

+ (instancetype)boolPropertyWithName:(NSString *)name defaultValue:(BOOL)value;
+ (instancetype)optionsPropertyWithName:(NSString *)name defaultValue:(NSUInteger)selected options:(NSArray<NSString*>*)options;

@end

@interface GSDataControl : NSObject {
    @protected
    NSString *_name;
    CGFloat _requestDelay;
    @private
    BOOL _saveFlag;
    NSMutableArray<GSDataProperty*> *_properties;
    NSMutableDictionary<NSString *, GSDataProperty*> *_propertiesIndex;
    NSMutableDictionary *_propertiesValues;
}

@property (nonatomic, readonly) NSArray<GSDataProperty*> *properties;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, readonly) GSTaskQueue *taskQueue;
@property (nonatomic, assign) CGFloat   requestDelay;

- (GSDataProperty*)getPropertyItem:(NSString*)name;
- (void)insertProperty:(GSDataProperty *)property;
- (id)getProperty:(NSString*)name;
- (void)setProperty:(id)value withName:(NSString *)name;
// Need override
- (void)makeProperties;

+ (void)updateProgressingBooks;
+ (NSInteger)removeProgressingBook:(GSModelNetBook *)book;
+ (NSArray*)progressingBooks;

- (GSRequestTask *)mainRequest:(NSInteger)pageIndex;
- (GSRequestTask *)searchRequest:(NSString *)keyword pageIndex:(NSInteger)pageIndex;
- (GSTask *)processBook:(GSModelNetBook *)book;
- (GSTask *)downloadBook:(GSModelNetBook *)book;
- (void)pauseBook:(GSModelNetBook *)book;
- (NSInteger)deleteBook:(GSModelNetBook *)book;

@end
