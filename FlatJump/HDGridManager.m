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
static const NSUInteger firstRow = 0;
static const NSUInteger lastRow = 4;
@implementation HDGridManager {
    NSMutableDictionary *_gridIndex;
    NSMutableArray *_indexes;
}

#pragma mark - Public

- (NSNumber *)coinTypeAtRow:(NSInteger)row column:(NSInteger)column {
    return _gridIndex[[NSIndexPath indexPathForRow:row inSection:column]];
}

- (void)displayRowBordersForRowAtIndex:(NSUInteger)index completion:(GridBlock)completion {
    
    // From row 0-3 just present the up arrows
    if (index < 6) {
        // Rows 3-5 present up arrows and borders, call completion block and return
        if (index > 3) {
            if (completion) {
                completion(YES,HDArrowDirectionUp);
            }
            return;
        }
        if (completion) {
            completion(NO,HDArrowDirectionUp);
        }
        return;
    }
    
    // Find the index for each open row
    NSNumber *previousRowIndex = [self indexOfOpenCellForRow:index - 1];
    NSNumber *currentRowIndex  = [self indexOfOpenCellForRow:index];
    
    // Check if the open row's index is an end index(0,4)
    BOOL currentIndexWithinScope  = [@[@0,@4] containsObject:currentRowIndex];
    BOOL previousIndexWithinScope = [@[@0,@4] containsObject:previousRowIndex];
    
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

- (BOOL)_goodOdds {
    return ((arc4random() % 2 == 1) && (arc4random() % 2 == 1));
}

- (BOOL)_badOdds {
    return ([self _goodOdds] && [self _goodOdds]);
}

- (void)loadGridFromRangeWithCallback:(dispatch_block_t)completion; {
    
    // Get a background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        
        if (!_gridIndex) {
            _gridIndex = [NSMutableDictionary dictionary];
        }
        
        if (!_indexes) {
            _indexes = [NSMutableArray array];
        }
        
        
        NSInteger previousIdx = _indexes ? [[_indexes lastObject] integerValue] : 2;
        for (NSUInteger row = self.range.location; row < self.range.location + self.range.length; row++) {
            
            if (row < startingRow) {
                continue;
            }
            
            BOOL consecutive = NO;
            
            BOOL firstCheck;
            BOOL secondCheck;
            if (_indexes.count > 2) {
                firstCheck  = [@[@(firstRow), @(lastRow)] containsObject:[_indexes lastObject]];
                secondCheck = [@[@(firstRow), @(lastRow)] containsObject:_indexes[[_indexes count] - 2]];
                if (firstCheck && secondCheck) {
                    consecutive = YES;
                }
            }
            
            NSInteger currentIdx = 0;
            if (previousIdx == firstRow && !consecutive) {
                
                if ([self _badOdds]) {
                    currentIdx = 3;
                } else {
                    currentIdx = lastRow;
                }
                
            } else if (previousIdx == lastRow && !consecutive) {

                if ([self _badOdds]) {
                    currentIdx = 1;
                } else {
                    currentIdx = firstRow;
                }
                
            } else {
                
                if (previousIdx != lastRow && previousIdx != firstRow) {
                    currentIdx = (arc4random() % NumberOfColumns);
                    while ((abs((int)currentIdx - (int)previousIdx) > 2) || currentIdx == previousIdx) {
                        currentIdx = (arc4random() % NumberOfColumns);
                    }
                }
                
                if (previousIdx == lastRow) {
                    currentIdx = [self _goodOdds] ? 2 : 3;
                }
                
                if (previousIdx == firstRow) {
                    currentIdx = [self _goodOdds] ? 1 : 2;
                }
            }
            
            if (row == startingRow) {
                currentIdx = 2;
            }
            
            NSNumber *objectType = nil;
            for (NSUInteger column = 0; column < NumberOfColumns; column++) {
                
                if (column == currentIdx) {
                    objectType = @0;
                } else {
                    objectType = @1;
                }
                
                previousIdx = currentIdx;
                
                _gridIndex[[NSIndexPath indexPathForRow:row inSection:column]] = objectType;
            }
            [_indexes addObject:@(currentIdx)];
        }
        if (completion){
            // Call completion block when back on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

@end
