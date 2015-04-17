//
//  Levels.h
//  Hexagon
//
//  Created by Evan Ische on 10/4/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSInteger NumberOfRows    = 10;
static const NSInteger NumberOfColumns = 5;

typedef NS_OPTIONS(u_int8_t, HDArrowDirection) {
    HDArrowDirectionLeft  = 0,
    HDArrowDirectionRight = 4,
    HDArrowDirectionUp    = 5,
    HDArrowDirectionNone
};

typedef void(^GridBlock)(BOOL displayBorders, HDArrowDirection direction);
@interface HDGridManager : NSObject
@property (nonatomic, assign) NSRange range;
- (BOOL)presentBarrierForRow:(NSInteger)row column:(NSInteger)column;
- (void)displayRowBordersForRowAtIndex:(NSUInteger)rowIndex completion:(GridBlock)completion;
- (void)loadGridFromRangeWithCallback:(dispatch_block_t)completion;
@end

