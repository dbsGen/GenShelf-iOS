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

unsigned int BKDRHash(const char *str)
{
    unsigned int seed = 131; // 31 131 1313 13131 131313 etc..
    unsigned int hash = 0;
    
    while (*str)
    {
        hash = hash * seed + (*str++);
    }
    
    return (hash & 0x7FFFFFFF);
}

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

- (NSString *)cachePath {
    return [[self folderPath] stringByAppendingPathComponent:@"caches"];
}

- (void)insertPicture:(NSData *)data book:(GSModelNetBook *)book page:(GSModelNetPage *)page {
    NSString *path = [self path:book page:page];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }
    [data writeToFile:path atomically:YES];
}

- (NSString *)fullPath:(NSString *)path {
    return [[self cachePath] stringByAppendingPathComponent:path];
}

- (NSString *)insertCachePicture:(NSData *)data source:(NSString *)source keyword:(NSString *)keyword {
    NSString *path = [self path:source keyword:keyword];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }
    [data writeToFile:path atomically:YES];
    return [source stringByAppendingPathComponent:keyword];
}

- (NSString *)path:(NSString *)source keyword:(NSString *)keyword {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *folder = [[self cachePath] stringByAppendingPathComponent:source];
    if (![fileManager fileExistsAtPath:folder]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:folder
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
        CheckErrorR(nil);
    }
    NSString *path = [folder stringByAppendingPathComponent:keyword];
    return path;
}

- (NSString *)path:(GSModelNetBook *)book page:(GSModelNetPage *)page {
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
    NSString *fileName = [NSString stringWithFormat:@"%04d.%@", (int)page.index.integerValue, [page.imageUrl pathExtension]];
    return [bookFolder stringByAppendingPathComponent:fileName];
}

- (NSString *)path:(GSModelNetBook *)book {
    if (book) {
        return [[self folderPath] stringByAppendingPathComponent:[self folderName:book]];
    }
    return nil;
}

- (NSString *)_1_2_folderName:(GSModelNetBook *)book {
    NSString *string = [NSString stringWithFormat:@"%@_%@", book.source, book.title];
    const char *chs = string.UTF8String;
    long len = strlen(chs);
    char *n_chs = malloc(sizeof(char)*(len+1));
    int count = 0;
    for (int n = 0; n < len; n++) {
        bool check = false;
        for (int m = 0; m < replace_leng; m++) {
            if (chs[n] == replacement[m]) {
                check = true;
                break;
            }
        }
        if (!check && (chs[n] >= 32 && chs[n] <= 125)) {
            n_chs[count++] = chs[n];
            if (count >= 127) {
                break;
            }
        }
    }
    n_chs[count] = 0;
    NSString *path = [NSString stringWithUTF8String:n_chs];
    free(n_chs);
    return path;
}

- (NSString *)folderName:(GSModelNetBook *)book {
    unsigned int hash = BKDRHash(book.title.UTF8String);
    NSString *string = [NSString stringWithFormat:@"{%@%d}%@", book.source, hash, book.title];
    const char *chs = string.UTF8String;
    long len = strlen(chs);
    char *n_chs = malloc(sizeof(char)*(len+1));
    int count = 0;
    for (int n = 0; n < len; n++) {
        bool check = false;
        for (int m = 0; m < replace_leng; m++) {
            if (chs[n] == replacement[m]) {
                check = true;
                break;
            }
        }
        if (!check && (chs[n] >= 32 && chs[n] <= 125)) {
            n_chs[count++] = chs[n];
            if (count >= 127) {
                break;
            }
        }
    }
    n_chs[count] = 0;
    NSString *path = [NSString stringWithUTF8String:n_chs];
    free(n_chs);
    return path;
}

- (void)deleteBook:(GSModelNetBook *)book {
    for (GSModelNetPage *page in book.pages) {
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

- (void)deletePage:(GSModelNetPage *)page {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = page.imagePath;
    if ([manager fileExistsAtPath:path]) {
        NSError *error = nil;
        [manager removeItemAtPath:path
                            error:&error];
    }
    [page reset];
}

- (void)update1_2 {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *folder = [self folderPath];
    NSDirectoryEnumerator<NSString *> *en = [manager enumeratorAtPath:folder];
    for (NSString *subPath in en) {
        NSString *lastPathComponent = [subPath lastPathComponent];
        if (![lastPathComponent isEqualToString:@"caches"] && ![lastPathComponent hasPrefix:@"Lofi_"]) {
            NSString *newPathComponent = [NSString stringWithFormat:@"Lofi_%@", lastPathComponent];
            newPathComponent = [newPathComponent substringToIndex:MIN(127, newPathComponent.length)];
            newPathComponent = [folder stringByAppendingPathComponent:newPathComponent];
            
            NSError *error;
            if ([manager fileExistsAtPath:newPathComponent]) {
                [manager removeItemAtPath:newPathComponent
                                    error:&error];
                CheckErrorC
            }
            
            [manager moveItemAtPath:[folder stringByAppendingPathComponent:subPath]
                             toPath:newPathComponent
                              error:&error];
            CheckErrorC
        }
    }
}

- (void)update1_3 {
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *folder = [self folderPath];
    
    NSArray *arr = [GSModelNetBook fetch:[NSPredicate predicateWithFormat:@"mark==YES"]
                                   sorts:@[[NSSortDescriptor sortDescriptorWithKey:@"downloadDate"
                                                                         ascending:NO]]];
    for (GSModelNetBook *book in arr) {
        NSString *oldPath = [folder stringByAppendingPathComponent:[self _1_2_folderName:book]];
        if ([manager fileExistsAtPath:oldPath]) {
            NSString *newPath = [folder stringByAppendingPathComponent:[self folderName:book]];
            NSError *error;
            if ([manager fileExistsAtPath:newPath]) {
                [manager removeItemAtPath:newPath
                                    error:&error];
                CheckErrorC
            }
            [manager moveItemAtPath:oldPath
                             toPath:newPath
                              error:&error];
            CheckErrorC
        }
    }
    
}

@end
