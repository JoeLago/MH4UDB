//
// The MIT License (MIT)
// 
// Copyright (c) 2015 Joe Lagomarsino
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// 

#import "FMDatabase+MHFMDBAdditions.h"

@implementation FMDatabase (MHFMDBAdditions)

- (NSArray*)dictionariesForQuery:(NSString*)query {
    return [self dictionariesForQuery:query withArgumentsInArray:nil];
}

- (NSArray*)dictionariesForQuery:(NSString*)query withArgumentsInArray:(NSArray*)array {
    FMResultSet *rs = (array == nil)
    ? [self executeQuery:query]
    : [self executeQuery:query withArgumentsInArray:array];
    
    NSMutableArray *results = [[NSMutableArray alloc] init];
    while ([rs next]) {
        NSDictionary *resultDictionary = [rs resultDictionary];
        [results addObject:resultDictionary];
    }
    
    return [[NSArray alloc] initWithArray:results];
}

@end
