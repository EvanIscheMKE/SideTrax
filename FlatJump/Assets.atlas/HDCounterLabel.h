//
//  HDCounterLabel.h
//  FlatJump
//
//  Created by Evan Ische on 4/20/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDCounterLabel : UILabel
- (void)countTo:(NSInteger)endValue duration:(NSTimeInterval)duration;
- (void)countTo:(NSInteger)endValue from:(NSInteger)fromValue duration:(NSTimeInterval)duration;
@end
