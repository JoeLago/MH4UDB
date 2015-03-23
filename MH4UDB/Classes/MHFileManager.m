//
//  MHFileManager.m
//  MH4UDB
//
//  Created by Joe on 3/19/15.
//  Copyright (c) 2015 Null Return. All rights reserved.
//

#import "MHFileManager.h"

@implementation MHFileManager

+ (NSString*)bundlePathForFile:(NSString*)fileName {
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
}

+ (NSString*)pathForDirectory:(NSSearchPathDirectory)directory file:(NSString*)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:fileName];
}

+ (NSString*)documentPathForFile:(NSString*)fileName {
    return [MHFileManager pathForDirectory:NSDocumentDirectory file:fileName];
}

+ (NSString*)copyFile:(NSString*)fileName
               toPath:(NSString*)path
          doOverwrite:(BOOL)doOverwrite {
    NSString *dbPath = path;
    NSString *defaultDBPath = [MHFileManager bundlePathForFile:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileFound = [fileManager fileExistsAtPath:dbPath];
    
    if (doOverwrite || !fileFound) {
        NSError *error;
        if (fileFound) {
            [fileManager removeItemAtPath:dbPath error:&error];
        }
        
        BOOL success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        if (!success) {
            NSLog(0, @"Failed to copy file (%@) '%@'.",
                  defaultDBPath,
                  [error localizedDescription]);
        }
    }
    
    return dbPath;
}

+ (NSString*)copyFile:(NSString*)fileName
          toDirectory:(NSSearchPathDirectory)directory
          doOverwrite:(BOOL)doOverwrite {
    NSString *dbPath = [MHFileManager pathForDirectory:directory file:fileName];
    return [MHFileManager copyFile:fileName toPath:dbPath doOverwrite:doOverwrite];
}

+ (NSString*)copyFile:(NSString*)fileName doOverwrite:(BOOL)doOverwrite {
    return [MHFileManager copyFile:fileName
                       toDirectory:NSDocumentDirectory
                       doOverwrite:doOverwrite];
}

+ (NSString*)copyFile:(NSString*)fileName {
    return [self copyFile:fileName
              toDirectory:NSDocumentDirectory
              doOverwrite:FALSE];
}

@end
