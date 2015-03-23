//
//  MHFileManager.h
//  MH4UDB
//
//  Created by Joe on 3/19/15.
//  Copyright (c) 2015 Null Return. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHFileManager : NSObject

+ (NSString*)bundlePathForFile:(NSString*)fileName;
+ (NSString*)pathForDirectory:(NSSearchPathDirectory)directory file:(NSString*)fileName;
+ (NSString*)documentPathForFile:(NSString*)fileName;

+ (NSString*)copyFile:(NSString*)fileName
               toPath:(NSString*)path
          doOverwrite:(BOOL)doOverwrite;
+ (NSString*)copyFile:(NSString*)fileName
          toDirectory:(NSSearchPathDirectory)directory
          doOverwrite:(BOOL)doOverwrite;
+ (NSString*)copyFile:(NSString*)fileName;
+ (NSString*)copyFile:(NSString*)fileName doOverwrite:(BOOL)doOverwrite;

@end
