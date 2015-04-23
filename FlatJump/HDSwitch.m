//
//  HDSwitch.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/29/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import QuartzCore;

#import "HDSwitch.h"
#import "HDAppDelegate.h"
#import "UIColor+FlatColors.h"

static const CGFloat kPadding = 5.0f;
@interface HDSwitch ()
@property (nonatomic, strong) UILabel *onLabel;
@property (nonatomic, strong) UILabel *offLabel;
@property (nonatomic, strong) UIView *slidingView;
@end

@implementation HDSwitch {
    UIColor *_onColor;
    UIColor *_offColor;
    BOOL _animating;
    BOOL _toggleValue;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame onColor:[UIColor whiteColor] offColor:[UIColor redColor]];
}

- (instancetype)initWithOnColor:(UIColor *)onColor offColor:(UIColor *)offColor {
    return [self initWithFrame:CGRectZero onColor:onColor offColor:offColor];
}

- (instancetype)initWithFrame:(CGRect)frame
                      onColor:(UIColor *)onColor
                     offColor:(UIColor *)offColor {
    if (self = [super initWithFrame:frame]) {
        
        _onColor  = onColor;
        _offColor = offColor;
        
        self.on = YES;
        self.backgroundColor = _onColor;
        self.layer.cornerRadius = 5.0f;
        
        [self _setup];
    }
    return self;
}

- (void)_setup; {
    
    CGRect slidingViewFrame = CGRectMake(CGRectGetWidth(self.bounds) - (CGRectGetWidth(self.slidingView.bounds) + kPadding),
                                         kPadding,
                                         CGRectGetWidth(self.bounds)/3,
                                         CGRectGetHeight(self.bounds) - (kPadding*2));
    
    self.slidingView = [[UIView alloc] initWithFrame:slidingViewFrame];
    self.slidingView.layer.cornerRadius = 3.0f;
    self.slidingView.userInteractionEnabled = NO;
    self.slidingView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.slidingView];
    
    CGRect onLabelFrame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds)/1.5f - kPadding, CGRectGetHeight(self.bounds));
     self.onLabel = [[UILabel alloc] initWithFrame:onLabelFrame];
    self.onLabel.text  = @"ON";
    self.onLabel.alpha = 1.0f;
    
    CGRect offLabelFrame = CGRectMake(CGRectGetWidth(self.bounds)/3.0f + kPadding, 0.0f, CGRectGetWidth(self.bounds)/1.5f - kPadding, CGRectGetHeight(self.bounds));
     self.offLabel = [[UILabel alloc] initWithFrame:offLabelFrame];
    self.offLabel.text = @"OFF";
    self.offLabel.alpha = 0.0f;
    
    for (UILabel *label in @[self.onLabel, self.offLabel]) {
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        [self addSubview:label];
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    if (!_animating) {
        self.offLabel.frame = CGRectMake(CGRectGetWidth(self.bounds)/3,
                                         0.0f,
                                         CGRectGetWidth(self.bounds)/1.5f,
                                         CGRectGetHeight(self.bounds));
        
        self.onLabel.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds)/1.5f, CGRectGetHeight(self.bounds));
        if (self.isON) {
            CGRect slidingViewFrame = CGRectMake(CGRectGetWidth(self.bounds) - (CGRectGetWidth(self.slidingView.bounds) + kPadding),
                                                 kPadding,
                                                 CGRectGetWidth(self.bounds)/3,
                                                 CGRectGetHeight(self.bounds)-(kPadding*2));
            
            self.slidingView.frame = slidingViewFrame;
        } else {
            self.slidingView.frame = CGRectMake(kPadding, kPadding, CGRectGetWidth(self.bounds)/3, CGRectGetHeight(self.bounds)-(kPadding*2));
        }
        
        for (UILabel *label in @[self.onLabel, self.offLabel]) {
            label.font = GAME_FONT_WITH_SIZE(CGRectGetHeight(self.bounds) * .5f);
        }
    }
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    BOOL wasPreviouslyOn = self.isON;
    if (self.isON) {
        [self setOn:NO animated:YES];
    } else if (!self.isON) {
        [self setOn:YES animated:YES];
    }
    
    if (wasPreviouslyOn != _toggleValue) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    return YES;
}

- (void)setOn:(BOOL)on {
    [self setOn:on animated:NO];
}

- (BOOL)isON {
    return _toggleValue;
}

- (void)setOn:(BOOL)flag animated:(BOOL)animated {
    
    _toggleValue = flag;
    if (flag) {
        [self showOnAnimated:animated];
    } else {
        [self showOffAnimated:animated];
    }
}

- (void)showOnAnimated:(BOOL)animated {
    
    dispatch_block_t animationBlock = ^{
        
        const CGFloat kOriginX = CGRectGetWidth(self.bounds) - (CGRectGetWidth(self.slidingView.bounds) + kPadding);
        CGRect slidingViewFrame = CGRectMake(kOriginX, kPadding, CGRectGetWidth(self.bounds)/3, CGRectGetHeight(self.bounds) - (kPadding*2));
        self.slidingView.frame = slidingViewFrame;
        self.backgroundColor   = _onColor;
        self.onLabel.alpha     = 1.0f;
        self.offLabel.alpha    = 0.0f;
        
    };
    
    if (!animated) {
        animationBlock();
    } else {
        _animating = YES;
        [UIView animateWithDuration:.3f animations:animationBlock completion:^(BOOL finished) {
            _animating = NO;
        }];
    }
}

- (void)showOffAnimated:(BOOL)animated {
    
    dispatch_block_t animationBlock = ^{
        CGRect slidingViewFrame = CGRectMake(kPadding, kPadding, CGRectGetWidth(self.bounds)/3, CGRectGetHeight(self.bounds) - (kPadding*2));
        self.slidingView.frame = slidingViewFrame;
        self.backgroundColor   = _offColor;
        self.onLabel.alpha     = 0.0f;
        self.offLabel.alpha    = 1.0f;
    };
    
    if (!animated) {
        animationBlock();
    } else {
        _animating = YES;
        [UIView animateWithDuration:.3f animations:animationBlock completion:^(BOOL finished) {
            _animating = NO;
        }];
    }
}

@end
