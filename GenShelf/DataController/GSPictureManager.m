//
//  GSPictureManager.m
//  GenShelf
//
//  Created by Gen on 16/2/28.
//  Copyright © 2016年 AirRaidClub. All rights reserved.
//

#import "GSPictureManager.h"
#import "GSDataDefines.h"

#define DIR_PATH    @"books"
const char *replacement = "<>/\\|:\"*?";
const int replace_leng = 9;

static NSString *_tempPath = nil;

@implementation GSPictureManager

static GSPictureManager *__defaultManager = nil;

+ (GSPictureManager *)defaultManager {
    @synchronized(self) {
        if (!__defaultManager) {
            __defaultManager = [[GSPictureManager alloc] init];
        }
    }
    return __defaultManager;
}

- (NSString*)folderPath
{
    if (!_tempPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths lastObject];
        _tempPath = [path stringByAppendingPathComponent:DIR_PATH];
    }
    return _tempPath;
}

- (void)insertPicture:(NSData *)data book:(GSBookItem *)book page:(GSPageItem *)page {
    NSString *path = [self path:book page:page];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }
    [data writeToFile:path atomically:YES];
}

- (NSString *)path:(GSBookItem *)book page:(GSPageItem *)page {
    NSString *bookFolder = [[self folderPath] stringByAppendingPathComponent:[self folderName:book]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:bookFolder
                           isDirectory:nil]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:bookFolder
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
        CheckErrorR(nil);
    }
    NSString *fileName = [NSString stringWithFormat:@"%04d.%@", (int)page.index, [page.imageUrl pathExtension]];
    return [bookFolder stringByAppendingPathComponent:fileName];
}

- (NSString *)path:(GSBookItem *)book {
    if (book) {
        return [[self folderPath] stringByAppendingPathComponent:[self folderName:book]];
    }
    return nil;
}

- (NSString *)folderName:(GSBookItem *)book {
    const char *chs = book.title.UTF8String;
    long len = strlen(chs);
    char *n_chs = malloc(sizeof(char)*(len+1));
    int count = 0;
    for (int n = 0; n < len; n++) {
        bool check = false;
        for (int m = 0; m < replace_leng; m++) {
            if (chs[n] == replacement[m] || chs[n] < 33 || chs[n] > 125) {
                check = true;
                break;
            }
        }
        if (!check) {
            n_chs[count++] = chs[n];
            if (count >= 127) {
                break;
            }
        }
    }
    NSLog(@"Len is %ld string is %s", len, n_chs);
    n_chs[count] = 0;
    NSString *path = [NSString stringWithUTF8String:n_chs];
    NSLog(@"path is %@", path);
    free(n_chs);
    return path;
}

- (void)deleteBook:(GSBookItem *)book {
    for (GSPageItem *page in book.pages) {
        [page reset];
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [self path:book];
    if ([manager fileExistsAtPath:path]) {
        NSError *error = nil;
        [manager removeItemAtPath:path
                            error:&error];
    }
    [book remove];
}

- (void)deletePage:(GSPageItem *)page {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = page.imagePath;
    if ([manager fileExistsAtPath:path]) {
        NSError *error = nil;
        [manager removeItemAtPath:path
                            error:&error];
    }
    [page reset];
}

@end
