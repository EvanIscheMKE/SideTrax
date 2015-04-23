//
//  Levels.m
//  Hexagon
//
//  Created by Evan Ische on 10/4/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import UIKit;
#import "HDGridManager.h"

NSString * const HDDisplayBorderKey = @"displayBorder";
NSString * const HDColumnIndexKey   = @"ColumnIndex";
NSString * const HDDirectionKey     = @"Direction";

const NSUInteger startingRow = 8;
const NSUInteger firstColumn = 0;
const NSUInteger lastColumn = 4;
@implementation HDGridManager {
    NSMutableDictionary *_rowInfo;
    NSArray *_borderColumnIndexs;
    NSInteger _previousColumnIndex;
    BOOL _firstRun;
}

- (instancetype)init {
    if (self = [super init]) {
        _firstRun = YES;
        _previousColumnIndex = 2;
        _rowInfo = [NSMutableDictionary new];
        _borderColumnIndexs = @[@(firstColumn),@(lastColumn)];
    }
    return self;
}

#pragma mark - Public

- (NSDictionary *)infoForRow:(NSInteger)row {
    return _rowInfo[@(row)];
}

- (void)loadGridFromRangeWithCallback:(dispatch_block_t)completion; {
    
    // Get a background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        //
        NSInteger currentColumnIndex = 0;
        
        //
        NSDictionary *info = nil;
        
        //
        BOOL displayBorders = YES;
        
        //
        HDArrowDirection direction = HDArrowDirectionNone;
        
        //
        NSRange range = self.range;
        for (NSUInteger row = range.location; row < range.location + range.length; row++) {
            
            // at row 4 start displaying borders
            if (row < startingRow) {
                if (row > startingRow-3) {
                    info = [self _defaultRowLayout];
                    _rowInfo[@(row)] = info;
                }
                continue;
            }
            
            if (row == startingRow) {
                currentColumnIndex = lastColumn/2.0f;
            } else if ([_borderColumnIndexs containsObject:@(_previousColumnIndex)]) {
                
                if (!displayBorders) {
                    // Cut out borders, index must be 1 or 2 opposite side
                    currentColumnIndex = [self _columnIndexFromEdgeColumn:_previousColumnIndex];
                } else {
                    // Random index Within Two
                    currentColumnIndex = [self _randomIdxFromPreviousColumnIdx:_previousColumnIndex];
                }
                
            } else {
                currentColumnIndex = [self _randomIdxFromPreviousColumnIdx:_previousColumnIndex];
            }
            
            displayBorders = YES;
            if ([_borderColumnIndexs containsObject:@(currentColumnIndex)]) {
                displayBorders = [self _rollTheDice];
                if (!displayBorders) {
                    direction = (currentColumnIndex == firstColumn) ? HDArrowDirectionLeft : HDArrowDirectionRight;
                }
            }
            
            //
            info = [self _displayBorder:displayBorders
                        openColumnIndex:currentColumnIndex
                              direction:!displayBorders ? direction : HDArrowDirectionNone];
            _rowInfo[@(row)] = info;
            
            // Set the previous to current
            _previousColumnIndex = currentColumnIndex;
            
        }
        
        // Update the range to reflect the last update
        self.range = NSMakeRange(range.location + range.length, range.length);
        
        if (completion){
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

#pragma mark - Private

- (BOOL)_rollTheDice {
    return ((arc4random() % 2 == 1) && (arc4random() % 2 == 1));
}

- (NSInteger)_columnIndexFromEdgeColumn:(NSInteger)edgeColumn {
    
    if (edgeColumn == firstColumn) {
        return [self _rollTheDice] ? lastColumn : lastColumn - 1;
    } else if (edgeColumn == lastColumn) {
        return [self _rollTheDice] ? firstColumn : firstColumn + 1;
    }
    NSAssert(false, @"Edge Column has to be 0 or 4");
    return 50;
}

- (NSUInteger)_randomIdxFromPreviousColumnIdx:(NSInteger)previousIdx {
    NSInteger currentColumnIndex = (arc4random() % NumberOfColumns);
    while ((labs(currentColumnIndex - previousIdx) > 2) || currentColumnIndex == previousIdx) {
        currentColumnIndex = (arc4random() % NumberOfColumns);
    }
    return currentColumnIndex;
}

- (NSDictionary *)_defaultRowLayout {
    return [self _displayBorder:YES openColumnIndex:0 direction:HDArrowDirectionNone];
}

- (NSDictionary *)_displayBorder:(BOOL)displayBorder
                 openColumnIndex:(NSUInteger)index
                       direction:(HDArrowDirection)direction {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[HDDisplayBorderKey]  = @(displayBorder);
    dictionary[HDColumnIndexKey]    = @(index);
    dictionary[HDDirectionKey]      = @(direction);
    
    return dictionary;
}



@end
