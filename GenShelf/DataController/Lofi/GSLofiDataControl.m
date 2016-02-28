//
//  GSLofiDataControl.m
//  GenShelf
//
//  Created by Gen on 16/2/20.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSLofiDataControl.h"
#import "GDataXMLNode.h"
#import "GSGlobals.h"
#import "NSObject+GTools.h"
#import "../GSDataDefines.h"
#import "GSLofiBookTask.h"

#define URL_HOST @"http://lofi.e-hentai.org/"
#define FILTER_STR @"?f_doujinshi=0&f_manga=0&f_artistcg=0&f_gamecg=0&f_western=0&f_non-h=1&f_imageset=0&f_cosplay=0&f_asianporn=0&f_misc=0&f_apply=Apply+Filter"

@implementation GSLofiDataControl

- (id)init {
    self = [super init];
    if (self) {
        _name = @"Lofi";
        _requestDelay = 2;
    }
    return self;
}

+ (NSURL *)mainUrl {
    return [NSURL URLWithString:[URL_HOST stringByAppendingString:FILTER_STR]];
}

- (NSArray<GSBookItem *> *)parseMain:(NSString *)html {
    NSError *error = nil;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithHTMLString:html
                                                                   error:&error];
    CheckErrorR([NSArray array])
    NSArray *divs = [doc nodesForXPath:@"//div[@class='ig']" error:&error];
    CheckErrorR([NSArray array])
    
    NSMutableArray<GSBookItem *> *res = [NSMutableArray<GSBookItem*> array];
    for (GDataXMLNode *node in divs) {
        GSBookItem *item = [[GSBookItem alloc] init];
        GDataXMLElement *imageNode = (GDataXMLElement*)[node firstNodeForXPath:@"node()//td[@class='ii']/a"
                                                                         error:&error];
        CheckErrorC
        item.pageUrl = [imageNode attributeForName:@"href"].stringValue;
        GDataXMLElement *sImageNode = (GDataXMLElement*)[imageNode firstNodeForXPath:@"img"
                                                                               error:&error];
        CheckErrorC
        item.imageUrl = [sImageNode attributeForName:@"src"].stringValue;
        
        GDataXMLElement *titleNode = (GDataXMLElement*)[node firstNodeForXPath:@"node()//table[@class='it']//a[@class='b']"
                                                                         error:&error];
        CheckErrorC
        item.title = titleNode.stringValue;
        [res addObject:item];
    }
    return res;
}

typedef void(^GSPageOver)(NSArray *pages, NSString *nextUrl);

- (GSTask *)processBook:(GSBookItem *)book {
    GSLofiBookTask *task = [self.taskQueue createTask:book.pageUrl
                                              creator:^GSTask *{
                                                  return [[GSLofiBookTask alloc] initWithItem:book queue:self.operationQueue];
                                              }];
    return task;
}

- (GSTask *)downloadBook:(GSBookItem *)book {
    return nil;
}

#undef URL_HOST

@end
