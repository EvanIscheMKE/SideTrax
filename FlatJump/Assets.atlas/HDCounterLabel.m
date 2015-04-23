//
//  HDCounterLabel.m
//  FlatJump
//
//  Created by Evan Ische on 4/20/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDCounterLabel.h"

static const NSTimeInterval defaultIntervalDuration = .03f;
@interface HDCounterLabel ()
@property (nonatomic, assign) NSInteger value;
@end

@implementation HDCounterLabel {
    NSTimeInterval _updateIntervalDuration;
    NSInteger _endValue;
}

- (void)setValue:(NSInteger)value {
    _value = value;
    self.text = [NSString stringWithFormat:@"%zd", _value];
}

- (void)_updateValueBy:(NSNumber *)increaseValue {
    
    NSInteger increaseVal = [increaseValue integerValue];
    
    self.value += increaseVal;
    
    if (increaseVal > 0) {
        if (self.value > _endValue) {
            self.value = _endValue;
            return;
        }
    } else {
        if (self.value < _endValue) {
            self.value = _endValue;
            return;
        }
    }
    
    [self performSelector:@selector(_updateValueBy:)
               withObject:increaseValue
               afterDelay:_updateIntervalDuration];
}

- (void)countTo:(NSInteger)endValue duration:(NSTimeInterval)duration {
    [self countTo:endValue from:_value duration:duration];
}

-(void)countTo:(NSInteger)endValue from:(NSInteger)fromValue duration:(NSTimeInterval)duration {
    
    if (endValue == fromValue) {
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    NSInteger count = ABS(endValue - fromValue);
    
    _updateIntervalDuration = duration/count > defaultIntervalDuration ? duration/count : defaultIntervalDuration;
    
    if (self.value != fromValue) {
        self.value = fromValue;
    }
    
    _endValue = endValue;
    
    if (endValue > fromValue) {
        [self _updateValueBy:@1];
    } else {
        [self _updateValueBy:@-1];
    }
}

@end
