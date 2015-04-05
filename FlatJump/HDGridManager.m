//
//  Levels.m
//  Hexagon
//
//  Created by Evan Ische on 10/4/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDGridManager.h"

@implementation HDGridManager {
    NSString *_fileName;
    NSMutableDictionary *_levelCache;
    NSNumber *_grid[NumberOfRows][NumberOfColumns];
}

#pragma mark - Convenice Initalizer

- (instancetype)initWithFileName:(NSString *)fileName {
    if (self = [super init]) {
        _fileName = @"Base-1";
        _levelCache = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Public

- (NSNumber *)coinTypeAtRow:(NSInteger)row column:(NSInteger)column {
    return _grid[row][column];
}

#pragma mark - Private

- (void)_layoutInitialGrid:(NSDictionary *)grid {
    for (NSUInteger row = 0; row < NumberOfRows; row++) {
        NSArray *rows = [grid[@"grid"] objectAtIndex:row];
        for (NSUInteger column = 0; column < NumberOfColumns; column++) {
            NSNumber *index = [rows objectAtIndex:column];
            NSInteger tileRow = NumberOfRows - row - 1;
            _grid[tileRow][column] = index;
            NSLog(@"//GRID:%@//",index);
        }
    }
}

- (void)loadGridWithCallback:(dispatch_block_t)completion {
    
    if (_levelCache[_fileName]) {
        [self _layoutInitialGrid:_levelCache[_fileName]];
        if (completion) {
            completion();
            return;
        }
    }
    
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:_fileName ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];
    if (data == nil) {
        if (completion) {
            completion();
            return;
        }
    }
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (dictionary != nil) {
        _levelCache[_fileName] = dictionary;
        [self _layoutInitialGrid:dictionary];
    }
    
    if (completion){
        completion();
    }
}

- (void)clearCache {
    [_levelCache removeAllObjects];
}


@end
