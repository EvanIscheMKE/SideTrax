//
//  Levels.m
//  Hexagon
//
//  Created by Evan Ische on 10/4/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import UIKit;
#import "HDGridManager.h"

@implementation HDGridManager {
    NSMutableDictionary *_gridIndex;
    NSMutableArray *_indexes;
}

#pragma mark - Public

- (NSNumber *)coinTypeAtRow:(NSInteger)row column:(NSInteger)column {
    return _gridIndex[[NSIndexPath indexPathForRow:row inSection:column]];
}

- (void)displayRowBordersForRowAtIndex:(NSUInteger)index completion:(GridBlock)completion {
    
    if (index < 6) {
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
    
    NSNumber *previousRowIndex = [self indexOfOpenCellForRow:index - 1];
    NSNumber *currentRowIndex = [self indexOfOpenCellForRow:index];
    
    BOOL currentIndexWithinScope  = [@[@0,@4] containsObject:currentRowIndex];
    BOOL previousIndexWithinScope = [@[@0,@4] containsObject:previousRowIndex];
    
    BOOL displayBorders = NO;
    if (!currentIndexWithinScope) {
        displayBorders = YES;
    } else if (currentIndexWithinScope && previousIndexWithinScope) {
        displayBorders = YES;
    }
    
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

- (BOOL)_goodOdds {
    
    BOOL firstRoll   = (arc4random() % 2 == 1);
    BOOL secondRoll  = (arc4random() % 2 == 1);
    return (firstRoll && secondRoll);
}

- (BOOL)_badOdds {
    
    BOOL firstRoll   = [self _goodOdds];
    BOOL secondRoll  = [self _goodOdds];
    return (firstRoll && secondRoll);
}

#pragma mark - Private

- (void)loadGridFromRangeWithCallback:(dispatch_block_t)completion; {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (!_gridIndex) {
            _gridIndex = [NSMutableDictionary dictionary];
        }
        
        if (!_indexes) {
            _indexes = [NSMutableArray array];
        }
        
        BOOL cutOutTheEdges = NO;
        
        NSInteger previousIdx = _indexes ? [[_indexes lastObject] integerValue] : 3;
        for (NSUInteger row = self.range.location; row < self.range.location + self.range.length; row++) {
            
            if (row < 6) {
                continue;
            }
            
            BOOL consecutive = NO;
            
            BOOL firstCheck;
            BOOL secondCheck;
            if (_indexes.count > 2) {
                firstCheck  = [@[@0, @4] containsObject:[_indexes lastObject]];
                secondCheck = [@[@0, @4] containsObject:_indexes[[_indexes count] - 2]];
                if (firstCheck && secondCheck) {
                    consecutive = YES;
                }
            }
            
            NSInteger currentIdx = 0;
            if (previousIdx == 0 && !consecutive) {
                
                cutOutTheEdges = YES;
                if ([self _badOdds]) {
                    currentIdx = 3;
                } else {
                    currentIdx = 4;
                }
                
            } else if (previousIdx == 4 && !consecutive) {

                cutOutTheEdges = YES;
                if ([self _badOdds]) {
                    currentIdx = 1;
                } else {
                    currentIdx = 0;
                }
                
            } else {
                
                cutOutTheEdges = NO;
                if (previousIdx != 4 && previousIdx != 0) {
                    currentIdx = (arc4random() % 5);
                    while ((abs((int)currentIdx - (int)previousIdx) > 2) || currentIdx == previousIdx) {
                        currentIdx = (arc4random() % 5);
                    }
                }
                
                if (previousIdx == 4) {
                    currentIdx = [self _goodOdds] ? 2 : 3;
                }
                
                if (previousIdx == 0) {
                    currentIdx = [self _goodOdds] ? 1 : 2;
                }
            }
            
            if (row == 6) {
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
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (void)clearCache {
    _indexes = nil;
    _gridIndex = nil;
}


@end
