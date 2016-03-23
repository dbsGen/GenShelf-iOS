//
//  GSLofiBookTask.m
//  GenShelf
//
//  Created by Gen on 16/2/26.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSEHentaiBookTask.h"
#import "GSGlobals.h"
#import "GDataXMLNode.h"
#include "../GSDataDefines.h"
#import "RegexKitLite.h"
#import "MTNetCacheManager.h"
#import "MTBlockOperation.h"
#import "GSPictureManager.h"
#import "MTMd5.h"

typedef void(^GSProcessStyleBlock)(NSInteger index, NSString *val);

@interface GSProcessStyleChecker : NSObject

@property (nonatomic, copy) GSProcessStyleBlock block;
@property (nonatomic, strong) NSString *name;

- (instancetype)initWithBlock:(GSProcessStyleBlock)block name:(NSString *)name;

@end

@implementation GSProcessStyleChecker

- (instancetype)initWithBlock:(GSProcessStyleBlock)block name:(NSString *)name {
    self = [super init];
    if (self) {
        _block = block;
        _name = name;
    }
    return self;
}

@end

@interface GSProcessStyle : NSObject

@property (nonatomic, readonly) NSString *string;

- (instancetype)initWithString:(NSString *)string;
- (void)addCallback:(GSProcessStyleBlock)block withName:(NSString *)name;
- (void)process;

@end

@implementation GSProcessStyle {
    NSMutableArray<GSProcessStyleChecker*> *_checkers;
}

- (instancetype)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        _string = string;
        _checkers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addCallback:(GSProcessStyleBlock)block withName:(NSString *)name {
    [_checkers addObject:[[GSProcessStyleChecker alloc] initWithBlock:block name:name]];
}

- (void)process {
    if (_string) {
        NSCharacterSet *whiteSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSArray *stylrList = [_string componentsSeparatedByString:@";"];
        for (NSString *style in stylrList) {
            const char *chs = style.UTF8String, *offset = chs;
            size_t slen = strlen(chs);
            char *keyChas = malloc(sizeof(char)*strlen(chs));
            memset(keyChas, 0, slen);
            NSString *key = nil;
            NSString *val = nil;
            int count = 0;
            while (*offset) {
                if (*offset == ':') {
                    key = [NSString stringWithUTF8String:keyChas];
                    offset ++;
                    val = [NSString stringWithUTF8String:offset];
                    break;
                }
                keyChas[count++] = *offset;
                offset++;
            }
            free(keyChas);
            
            if (key && val) {
                NSArray *chs = [_checkers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", [key stringByTrimmingCharactersInSet:whiteSet]]];
                if (chs.count) {
                    GSProcessStyleChecker *checker = [chs firstObject];
                    if (checker.block) {
                        NSArray *arr = [val componentsSeparatedByString:@" "];
                        for (NSInteger i = 0, t = arr.count; i < t; i++) {
                            checker.block(i, [[arr objectAtIndex:i] stringByTrimmingCharactersInSet:whiteSet]);
                        }
                    }
                }
            }
        }
    }
}

@end

@interface GSEHentaiPageThumTask : GSTask <ASIHTTPRequestDelegate>

@property (nonatomic, readonly) NSString *imageUrl;
@property (nonatomic, readonly) CGRect rect;
@property (nonatomic, strong) GSPageItem *item;

- (instancetype)initWithImageUrl:(NSString *)imageUrl rect:(CGRect)rect item:(GSPageItem*)item queue:(NSOperationQueue *)queue;

@end

@implementation GSEHentaiPageThumTask {
    NSOperationQueue *_queue;
    ASIHTTPRequest *_request;
}

- (instancetype)initWithImageUrl:(NSString *)imageUrl rect:(CGRect)rect item:(GSPageItem *)item queue:(NSOperationQueue *)queue {
    self = [super init];
    if (self) {
        _imageUrl = imageUrl;
        _rect = rect;
        _queue = queue;
        _item = item;
    }
    return self;
}

- (void)run {
    if (_imageUrl) {
        MTNetCacheManager *manager = [MTNetCacheManager defaultManager];
        [manager getImageWithUrl:_imageUrl block:^(id result) {
            if (result) {
                [self processImage:result];
            }else {
                _request = [GSGlobals requestForURL:[NSURL URLWithString:_imageUrl]];
                _request.delegate = self;
                [_queue addOperation:_request];
            }
        }];
    }else {
        [self failed:[NSError errorWithDomain:@"Image is null."
                                         code:131
                                     userInfo:nil]];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    if (_request == request) {
        [[MTNetCacheManager defaultManager] setData:request.responseData
                                            withUrl:_imageUrl];
        UIImage *image = [UIImage imageWithData:request.responseData];
        [self processImage:image];
        _request = nil;
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    if (_request == request) {
        _request = nil;
    }
}

- (void)reset {
    [super reset];
    [_request cancel];
    _request.delegate = nil;
    _request = nil;
}

- (void)cancel {
    [super cancel];
    if (_request) {
        _request.delegate = nil;
        [_request cancel];
        _request = nil;
    }
}

- (void)processImage:(UIImage *)image {
    MTBlockOperation *operation = [[MTBlockOperation alloc] init];
    operation.size = _rect.size;
    CGSize size = image.size;
    operation.block = ^(CGContextRef context) {
        CGContextTranslateCTM(context, 0.0f, _rect.size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextDrawImage(context, CGRectMake(-_rect.origin.x, -_rect.origin.y, size.width, size.height), image.CGImage);
    };
    operation.completeBlock = ^(UIImage *image) {
        NSData *data = UIImageJPEGRepresentation(image, 0.8);
        NSString *keyword = [NSString stringWithFormat:@"%@_%.0f_%.0f.jpg", _imageUrl.MD5String, _rect.origin.x, _rect.origin.y];
        NSString *path = [[GSPictureManager defaultManager] insertCachePicture:data
                                                                        source:self.source
                                                                       keyword:keyword];
        _item.thumUrl = path;
        [_item updateData];
        [self complete];
    };
    [_queue addOperation:operation];
}

@end

@interface GSEHentaiProcessItem : NSObject

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, assign) CGRect rect;

@end

@implementation GSEHentaiProcessItem

@end

@interface GSEHentaiProcessPagesTask : GSTask

@property (nonatomic, readonly) NSArray<GSPageItem*> *pages;

- (instancetype)initWithQueue:(NSOperationQueue *)queue;

- (void)insertPage:(GSPageItem *)page imageUrl:(NSString *)imageUrl rect:(CGRect)rect;

@end

@implementation GSEHentaiProcessPagesTask {
    NSMutableArray<GSPageItem*> *_pages;
    NSMutableArray<GSEHentaiProcessItem*> *_items;
    NSOperationQueue *_queue;
}

- (instancetype)initWithQueue:(NSOperationQueue *)queue {
    self = [super init];
    if (self) {
        _pages = [[NSMutableArray alloc] init];
        _items = [[NSMutableArray alloc] init];
        _queue = queue;
    }
    return self;
}

- (NSArray<GSPageItem*> *)pages {
    return _pages;
}

- (void)insertPage:(GSPageItem *)page imageUrl:(NSString *)imageUrl rect:(CGRect)rect {
    [_pages addObject:page];
    GSEHentaiProcessItem *item = [[GSEHentaiProcessItem alloc] init];
    item.imageUrl = imageUrl;
    item.rect = rect;
    [_items addObject:item];
}

- (void)run {
    for (NSInteger n = 0, t = _pages.count; n < t; n++) {
        GSPageItem *page = [_pages objectAtIndex:n];
        GSEHentaiProcessItem *item = [_items objectAtIndex:n];
        [self addSubtask:[[GSEHentaiPageThumTask alloc] initWithImageUrl:item.imageUrl
                                                                    rect:item.rect
                                                                    item:page
                                                                   queue:_queue]];
    }
    [self complete];
}

@end

@class GSEHentaiBookSubtask;

@interface GSEHentaiBookTask (GSLofiBookSubtask)

- (void)bookSubtask:(GSEHentaiBookSubtask *)subtask complete:(NSString *)response;

@end

@interface GSEHentaiBookSubtask : GSTask  <ASIHTTPRequestDelegate>

@property (nonatomic, assign) ASIHTTPRequest *request;
@property (nonatomic, weak) id parentDelegate;

- (id)initWithUrl:(NSURL*)url queue:(NSOperationQueue *)queue;

@end

@implementation GSEHentaiBookSubtask {
    NSURL *_url;
    NSOperationQueue *_queue;
}

- (id)initWithUrl:(NSURL *)url queue:(NSOperationQueue *)queue {
    self = [super init];
    if (self) {
        _url = url;
        _queue = queue;
        self.timeDelay = 1;
    }
    return self;
}

- (void)run {
    _request = [GSGlobals requestForURL:_url];
    _request.delegate = self;
    [_queue addOperation:_request];
}

- (void)reset {
    [super reset];
    [_request cancel];
    _request.delegate = nil;
    _request = nil;
}

- (void)cancel {
    [super cancel];
    _request.delegate = nil;
    [_request cancel];
    _request = nil;
}


- (void)requestFinished:(ASIHTTPRequest *)request {
    if (_request == request) {
        _request.delegate = nil;
        _request = nil;
        if ([self.parentDelegate respondsToSelector:@selector(bookSubtask:complete:)]) {
            [self.parentDelegate performSelector:@selector(bookSubtask:complete:)
                                      withObject:self
                                      withObject:request.responseString];
        }
        [self complete];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    if (_request == request) {
        _request.delegate = nil;
        _request = nil;
        [self failed:request.error];
    }
}

- (void)dealloc {
    if (_request) {
        _request.delegate = nil;
    }
}

@end

@interface GSEHentaiBookTask ()

@end

@implementation GSEHentaiBookTask

- (id)initWithItem:(GSBookItem *)item queue:(NSOperationQueue *)queue {
    self = [super init];
    if (self) {
        _item = item;
        _queue = queue;
    }
    return self;
}

- (void)run {
    if (_item.status >= GSBookItemStatusComplete) {
        [self complete];
    }else {
        NSURL *url = [NSURL URLWithString:_item.otherData ? _item.otherData : _item.pageUrl];
        
        if (!_item.otherData && _item.pages.count > 0) {
            [_item reset];
        }
        GSEHentaiBookSubtask *subtask = [[GSEHentaiBookSubtask alloc] initWithUrl:url
                                                                      queue:_queue];
        subtask.parentDelegate = self;
        [self addSubtask:subtask];
        [self complete];
    }
}

- (void)bookSubtask:(GSEHentaiBookSubtask *)subtask complete:(NSString *)response {
    NSString *html = response;
    NSError *error = nil;
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithHTMLString:html
                                                                   error:&error];
    CheckError
    NSArray *pNodes = [doc nodesForXPath:@"//div[@id='gdt']/div[@class='gdtm']"
                                   error:&error];
    CheckError
    NSMutableArray<GSPageItem *> *pages = [NSMutableArray<GSPageItem *> array];
    GSEHentaiProcessPagesTask *task = [[GSEHentaiProcessPagesTask alloc] initWithQueue:_queue];
    for (GDataXMLNode *pNode in pNodes) {
        GDataXMLElement *a = (GDataXMLElement*)[pNode firstNodeForXPath:@"node()/a"
                                                                  error:&error];
        CheckErrorC
        GSPageItem *page = [GSPageItem itemWithUrl:[a attributeForName:@"href"].stringValue];
        
        GDataXMLElement *div = (GDataXMLElement*)[pNode firstNodeForXPath:@"div"
                                                                    error:&error];
        NSString *styleString = [div attributeForName:@"style"].stringValue;
        GSProcessStyle *processer = [[GSProcessStyle alloc] initWithString:styleString];
        __block CGRect offsetRect;
        __block NSString *imageUrl = nil;
        [processer addCallback:^(NSInteger index, NSString *val) {
            switch (index) {
                case 1:
                    imageUrl = [val stringByMatching:@"(?<=\\()[^\\)]+"];
                    break;
                case 2:
                    offsetRect.origin.x = -[[val stringByMatching:@"[-\\d.]+"] floatValue];
                    break;
                case 3:
                    offsetRect.origin.y = -[[val stringByMatching:@"[-\\d.]+"] floatValue];
                    break;
                    
                default:
                    break;
            }
        } withName:@"background"];
        [processer addCallback:^(NSInteger index, NSString *val) {
            offsetRect.size.width = [[val stringByMatching:@"[-\\d.]+"] floatValue];
        } withName:@"width"];
        [processer addCallback:^(NSInteger index, NSString *val) {
            offsetRect.size.height = [[val stringByMatching:@"[-\\d.]+"] floatValue];
        } withName:@"height"];
        [processer process];
        if (imageUrl) {
            [pages addObject:page];
            [task insertPage:page imageUrl:imageUrl rect:offsetRect];
        }else
            NSLog(@"Image url is %@ , %@", imageUrl, NSStringFromCGRect(offsetRect));
        
    }
    [self addSubtask:task];
    
    
    GDataXMLElement *last = (GDataXMLElement*)[doc firstNodeForXPath:@"//table[@class='ptb']/tbody/tr/td[last()]"
                                                               error:&error];
    BOOL hasMore = YES;
    GDataXMLNode *attNode = [last attributeForName:@"class"];
    if (pages.count && attNode) {
        hasMore = !(attNode && [[(GDataXMLElement *)attNode stringValue] isEqualToString:@"ptdd"]);
    }else hasMore = NO;
    
    if (hasMore) {
        GDataXMLElement *aNode = (GDataXMLElement*)[last firstNodeForXPath:@"a"
                                                                 error:&error];
        CheckError
        NSString *href = [aNode attributeForName:@"href"].stringValue;
        _item.otherData = href;
        GSEHentaiBookSubtask *subtask = [[GSEHentaiBookSubtask alloc] initWithUrl:[NSURL URLWithString:href]
                                                                            queue:_queue];
        subtask.parentDelegate = self;
        [self addSubtask:subtask];
        return;
        
    }
    
    _item.otherData = nil;
    
    [_item complete];
}

- (void)cancel {
    [super cancel];
    [_item cancel];
}

- (void)reset {
    [super reset];
    [_item reset];
}

- (void)onTaskComplete:(GSTask *)task {
    [super onTaskComplete:task];
    if ([task isKindOfClass:[GSEHentaiProcessPagesTask class]]) {
        GSEHentaiProcessPagesTask *pagesTask = (GSEHentaiProcessPagesTask *)task;
        [_item loadPages:pagesTask.pages];
    }
}

@end
