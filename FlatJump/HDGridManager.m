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
    BOOL _updating;
}

#pragma mark - Public

- (NSNumber *)coinTypeAtRow:(NSInteger)row column:(NSInteger)column {
    return _gridIndex[[NSIndexPath indexPathForRow:row inSection:column]];
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
        
        NSInteger previousIdx = _indexes ? [[_indexes lastObject] integerValue] : 0;
        for (NSUInteger row = self.range.location; row < self.range.location + self.range.length; row++) {
            
            BOOL consecutive = NO;
            
            BOOL firstCheck;
            BOOL secondCheck;
            if (_indexes.count > 2) {
                firstCheck  = [@[@1, @5] containsObject:[_indexes lastObject]];
                secondCheck = [@[@1, @5] containsObject:_indexes[[_indexes count] - 2]];
                if (firstCheck && secondCheck) {
                    consecutive = YES;
                }
            }
            
            NSInteger currentIdx = 0;
            if (previousIdx == 1 && !consecutive) {
                
                cutOutTheEdges = YES;
                if ([self _badOdds]) {
                    currentIdx = 4;
                } else {
                    currentIdx = 5;
                }
                
            } else if (previousIdx == 5 && !consecutive) {

                cutOutTheEdges = YES;
                if ([self _badOdds]) {
                    currentIdx = 2;
                } else {
                    currentIdx = 1;
                }
                
            } else {
                
                cutOutTheEdges = NO;
                if (previousIdx != 5 && previousIdx != 1) {
                    currentIdx = (arc4random() % 5)  + 1;
                    while ((abs((int)currentIdx - (int)previousIdx) > 2) || currentIdx == previousIdx) {
                        currentIdx = (arc4random() % 5)  + 1;
                    }
                }
                
                if (previousIdx == 5) {
                    currentIdx = [self _goodOdds] ? 3 : 4;
                }
                
                if (previousIdx == 1) {
                    currentIdx = [self _goodOdds] ? 2 : 3;
                }
            }
            
            if (row <= 4) {
                currentIdx = 3;
            }
            
            NSNumber *objectType = nil;
            for (NSUInteger column = 0; column < NumberOfColumns; column++) {
                
                if (row < 4) {
                    if (row >= 3) {
                        if (column == 0 || column == NumberOfColumns - 1) {
                            objectType = @2;
                        } else {
                            objectType = @0;
                        }
                        _gridIndex[[NSIndexPath indexPathForRow:row inSection:column]] = objectType;
                    } else {
                        _gridIndex[[NSIndexPath indexPathForRow:row inSection:column]] = @0;
                    }
                    continue;
                }
                
                if (column == 0 || column == NumberOfColumns - 1) {
                    objectType = cutOutTheEdges ? @0 : @2;
                } else if (column == currentIdx) {
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
