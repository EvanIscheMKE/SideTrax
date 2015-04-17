//
//  Levels.m
//  Hexagon
//
//  Created by Evan Ische on 10/4/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import UIKit;
#import "HDGridManager.h"

static const NSUInteger startingRow = 6;
static const NSUInteger firstColumn = 0;
static const NSUInteger lastColumn = 4;
@implementation HDGridManager {
    NSMutableDictionary *_openColumn;
    NSMutableDictionary *_gridIndex;
    NSMutableArray *_indexes;
    NSArray *_borderColumnIndexs;
}

- (instancetype)init {
    if (self = [super init]) {
        _indexes = [NSMutableArray new];
        _gridIndex = [NSMutableDictionary new];
        _openColumn = [NSMutableDictionary new];
        _borderColumnIndexs = @[@(firstColumn),@(lastColumn)];
    }
    return self;
}

#pragma mark - Public

- (BOOL)presentBarrierForRow:(NSInteger)row column:(NSInteger)column {
    return [_gridIndex[[NSIndexPath indexPathForRow:row inSection:column]] boolValue];
}

- (void)displayRowBordersForRowAtIndex:(NSUInteger)rowIndex completion:(GridBlock)completion {
    
    // From row 0-startingRow just present the up arrows
    if (rowIndex < startingRow) {
        if (completion) {
            completion(YES,HDArrowDirectionUp);
        }
        return;
    }
    
    // Find the index for each open row
    NSNumber *previousRowIndex = _openColumn[@(rowIndex - 1)];
    NSNumber *currentRowIndex  = _openColumn[@(rowIndex)];
    
    // Check if the open row's index is an end index(0,4)
    BOOL currentIndexWithinScope  = [_borderColumnIndexs containsObject:currentRowIndex];
    BOOL previousIndexWithinScope = [_borderColumnIndexs containsObject:previousRowIndex];
    
    BOOL displayBorders = NO;
    
    // if current row is not an end index, if not, present the borders, if both of them are an end index display the borders
    if (!currentIndexWithinScope) {
        displayBorders = YES;
    } else if (currentIndexWithinScope && previousIndexWithinScope) {
        displayBorders = YES;
    }
    
    // Call completion block
    if (completion) {
        completion(displayBorders, [currentRowIndex intValue]);
    }
}

- (NSNumber *)indexOfOpenCellForRow:(NSInteger)row {
    for (NSUInteger column = 0; column < NumberOfColumns ; column++) {
        NSNumber *number = _gridIndex[[NSIndexPath indexPathForRow:row inSection:column]];
        if ([number unsignedIntegerValue] == 0) {
            return @(column);
        }
    }
    return @0;
}

#pragma mark - Private

- (BOOL)_rollTheDice {
    return ((arc4random() % 2 == 1) && (arc4random() % 2 == 1));
}

- (void)loadGridFromRangeWithCallback:(dispatch_block_t)completion; {
    
    // Get a background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        if (_indexes.count) {
            const NSUInteger length = 2;
            if (self.range.length != length) {
                self.range = NSMakeRange(self.range.location, length);
            }
        }
    
        NSUInteger previousIdx = _indexes ? [[_indexes lastObject] integerValue] : 2;
        for (NSUInteger row = self.range.location; row < self.range.location + self.range.length; row++) {
            
            if (row < startingRow) {
                continue;
            }
            
            NSUInteger openColumnIdx = 0;
            if (row == startingRow) {
                openColumnIdx = 2;
            } else {
                
                BOOL consecutiveEdgeColumns = NO;
                if (_indexes.count > 2) {
                    if ([_borderColumnIndexs containsObject:[_indexes lastObject]] &&
                        [_borderColumnIndexs containsObject:_indexes[[_indexes count] - 2]]) {
                        consecutiveEdgeColumns = YES;
                    }
                }
                
                if (previousIdx == firstColumn && !consecutiveEdgeColumns) {
                    openColumnIdx = [self _rollTheDice] ? 3 : lastColumn;
                } else if (previousIdx == lastColumn && !consecutiveEdgeColumns) {
                    openColumnIdx = [self _rollTheDice] ? 1 : firstColumn;
                } else {
                    if (previousIdx == lastColumn) {
                        openColumnIdx = [self _rollTheDice] ? 2 : 3;
                    } else if (previousIdx == firstColumn) {
                        openColumnIdx = [self _rollTheDice] ? 1 : 2;
                    } else {
                        openColumnIdx = (arc4random() % NumberOfColumns);
                        while ((abs((int)openColumnIdx - (int)previousIdx) > 2) || openColumnIdx == previousIdx) {
                            openColumnIdx = (arc4random() % NumberOfColumns);
                        }
                    }
                }
            }
            
            [_indexes addObject:@(openColumnIdx)];
            _openColumn[@(row)] = @(openColumnIdx);
            previousIdx = openColumnIdx;
        }
        
        // Call completion block when back on the main thread
        if (completion){
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

@end
