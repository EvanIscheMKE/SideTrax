//
//  Levels.h
//  Hexagon
//
//  Created by Evan Ische on 10/4/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSInteger NumberOfRows    = 120;
static const NSInteger NumberOfColumns = 10;

@interface HDGridManager : NSObject
- (NSNumber *)coinTypeAtRow:(NSInteger)row column:(NSInteger)column;
- (void)loadGridWithCallback:(dispatch_block_t)completion;
- (instancetype)initWithFileName:(NSString *)fileName;
@end

