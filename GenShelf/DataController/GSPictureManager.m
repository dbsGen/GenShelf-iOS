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

- (NSString*)folderPath
{
    if (!_tempPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *path = [paths lastObject];
        _tempPath = [path stringByAppendingPathComponent:DIR_PATH];
    }
    return _tempPath;
}

- (void)insertPicture:(NSData *)data book:(GSBookItem *)book page:(GSPageItem *)page {
    NSString *path = [self path:book page:page];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager delete:path];
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
    NSString *fileName = [NSString stringWithFormat:@"%4lu.%@", (unsigned long)page.index, [page.imageUrl pathExtension]];
    return [bookFolder stringByAppendingPathComponent:fileName];
}

- (NSString *)folderName:(GSBookItem *)book {
    const char *chs = book.title.UTF8String;
    long len = MIN(strlen(chs), 127);
    char *n_chs = malloc(sizeof(char)*(len+1));
    for (int n = 0; n < len; n++) {
        bool check = false;
        for (int m = 0; m < replace_leng; m++) {
            if (chs[n] == replacement[m]) {
                check = true;
                break;
            }
        }
        n_chs[n] = check ? '_' : chs[n];
    }
    n_chs[len] = 0;
    return [NSString stringWithUTF8String:n_chs];
}

@end
