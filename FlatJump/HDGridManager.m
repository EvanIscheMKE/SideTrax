//
//  Levels.m
//  Hexagon
//
//  Created by Evan Ische on 10/4/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDGridManager.h"

@implementation HDGridManager {
    NSNumber *_grid[NumberOfRows][NumberOfColumns];
}

#pragma mark - Public

- (NSNumber *)coinTypeAtRow:(NSInteger)row column:(NSInteger)column {
    return _grid[row][column];
}

- (BOOL)rollTheDice {
    return (arc4random() % 2 == 1);
}

#pragma mark - Private

- (void)loadGridWithCallback:(dispatch_block_t)completion {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSInteger previousIdx = 0;
        for (NSUInteger row = 3; row < NumberOfRows; row++) {
            
            NSInteger currentIdx = 0;
            if (row > 4) {
                currentIdx = (arc4random() % 5)  + 1;
                while ((abs((int)currentIdx - (int)previousIdx) > 2)
                                                || currentIdx == previousIdx) {
                     currentIdx = (arc4random() % 5)  + 1;
                }
            } else {
                currentIdx = 3;
            }
            
            NSNumber *objectType = nil;
            for (NSUInteger column = 0; column < NumberOfColumns; column++) {
                
                if (row < 4) {
                    if (column == 0 || column == NumberOfColumns - 1) {
                        objectType = @2;
                    } else {
                        objectType = @0;
                    }
                    _grid[row][column] = objectType;
                    continue;
                }
                
                if (column == 0 || column == NumberOfColumns - 1) {
                    objectType = @2;
                } else if (column == currentIdx) {
                    objectType = @0;
                } else {
                    objectType = @1;
                }
                
                previousIdx = currentIdx;
                
                _grid[row][column] = objectType;
                if (row == NumberOfRows -1 && column == NumberOfColumns -2) {
                    if (completion){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion();
                        });
                    }
                }
            }
        }
    });
}


@end
