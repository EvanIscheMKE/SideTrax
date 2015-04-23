//
//  Levels.h
//  Hexagon
//
//  Created by Evan Ische on 10/4/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSInteger NumberOfRows    = 500;
static const NSInteger NumberOfColumns = 5;

typedef NS_OPTIONS(NSUInteger, HDArrowDirection) {
    HDArrowDirectionLeft  = 0,
    HDArrowDirectionRight = 4,
    HDArrowDirectionNone
};

extern NSString * const HDDisplayBorderKey;
extern NSString * const HDColumnIndexKey;
extern NSString * const HDDirectionKey;

extern const NSUInteger startingRow;
@interface HDGridManager : NSObject
@property (nonatomic, assign) NSRange range;
- (NSDictionary *)infoForRow:(NSInteger)row;
- (void)loadGridFromRangeWithCallback:(dispatch_block_t)completion;
@end

