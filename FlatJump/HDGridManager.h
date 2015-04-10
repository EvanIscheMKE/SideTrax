//
//  Levels.h
//  Hexagon
//
//  Created by Evan Ische on 10/4/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSInteger NumberOfRows    = 12;
static const NSInteger NumberOfColumns = 7;

@interface HDGridManager : NSObject
@property (nonatomic, assign) NSRange range;
- (NSNumber *)coinTypeAtRow:(NSInteger)row column:(NSInteger)column;
- (void)loadGridFromRangeWithCallback:(dispatch_block_t)completion;
- (void)clearCache;
@end

