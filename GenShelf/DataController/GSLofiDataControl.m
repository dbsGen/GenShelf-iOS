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

#define CheckError if (error) {\
NSLog(@"Parse html error : %@", error);\
return;\
}

#define CheckErrorC if (error) {\
NSLog(@"Parse html error : %@", error);\
continue;\
}

#define CheckErrorR(RET) if (error) {\
NSLog(@"Parse html error : %@", error);\
return RET;\
}

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

- (void)processBook:(GSBookItem *)book {
    if (book.status != GSBookItemStatusComplete && !book.loading) {
        [book startLoading];
        [self parsePage:(book.otherData ? book.otherData : book.pageUrl) block:^(NSArray *pages, NSString *url) {
            book.otherData = url;
            [book loadPages:pages];
        } over:^(NSArray *_, NSString *url) {
            [book complete];
        } failed:^(NSArray *pages, NSString *nextUrl) {
            [book failed];
        }];
    }
}

- (void)parsePage:(NSString *)url block:(GSPageOver)block over:(GSPageOver)over failed:(GSPageOver)failed {
    ASIHTTPRequest *request = [GSGlobals requestForURL:[NSURL URLWithString:url]];
    __weak ASIHTTPRequest *_request = request;
    [request setCompletionBlock:^{
        NSString *html = _request.responseString;
        NSError *error = nil;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithHTMLString:html
                                                                       error:&error];
        CheckError
        NSArray *pNodes = [doc nodesForXPath:@"//div[@id='gh']/div[@class='gi']"
                                       error:&error];
        CheckError
        NSMutableArray<GSPageItem *> *pages = [NSMutableArray<GSPageItem *> array];
        for (GDataXMLNode *pNode in pNodes) {
            GSPageItem *page = [[GSPageItem alloc] init];
            GDataXMLElement *a = (GDataXMLElement*)[pNode firstNodeForXPath:@"a"
                                                                      error:&error];
            CheckErrorC
            page.pageUrl = [a attributeForName:@"href"].stringValue;
            GDataXMLElement *img = (GDataXMLElement*)[a firstNodeForXPath:@"img"
                                                                    error:&error];
            CheckErrorC
            page.thumUrl = [img attributeForName:@"src"].stringValue;
            [pages addObject:page];
        }
        
        NSArray *links = [doc nodesForXPath:@"//div[@id='ia']/a"
                                      error:&error];
        for (GDataXMLElement *lNode in links) {
            NSString *str = [lNode.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([str hasPrefix:@"Next"] || [str hasPrefix:@"next"]) {
                NSString *href = [lNode attributeForName:@"href"].stringValue;
                block(pages, href);
                [self performBlock:^{
                    [self parsePage:href
                              block:block
                               over:over
                             failed:failed];
                } afterDelay:_requestDelay];
                return;
            }
        }
        
        block(pages, nil);
        over(nil, nil);
    }];
    [request setFailedBlock:^{
        failed(nil, nil);
    }];
    [request startAsynchronous];
}

#undef URL_HOST

@end
