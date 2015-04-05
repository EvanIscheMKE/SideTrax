//
//  HDShadowButton.m
//  FlatJump
//
//  Created by Evan Ische on 4/2/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import QuartzCore;

#import "HDShadowButton.h"

@interface HDShadowButton ()
@property (nonatomic, strong) UIButton *content;
@property (nonatomic, strong) CALayer *shadow;
@end

@implementation HDShadowButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setup];
        [self addTarget:self action:@selector(_touchDown)     forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(_touchUpInside) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)_setup {
    
    CGRect contentBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)/1.15f);
    self.content = [UIButton buttonWithType:UIButtonTypeCustom];
    self.content.userInteractionEnabled = NO;
    self.content.frame = contentBounds;
    self.content.layer.cornerRadius = CGRectGetMidY(self.content.bounds)/1.5f;
    self.content.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.content.bounds));
    [self addSubview:self.content];
    
    self.shadow = [CALayer layer];
    self.shadow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.15f].CGColor;
    self.shadow.cornerRadius = self.content.layer.cornerRadius;
    self.shadow.frame = self.content.bounds;
    self.shadow.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds)-CGRectGetMidY(self.shadow.bounds));
    [self.layer insertSublayer:self.shadow below:self.content.layer];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - Private 

- (void)_touchDown {
    self.content.center = self.shadow.position;
}

- (void)_touchUpInside {
    self.content.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.content.bounds));
}

- (UILabel *)titleLabel {
    return self.content.titleLabel;
}

#pragma mark - Override Setters

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [self.content setBackgroundColor:backgroundColor];
}

- (void)setAdjustsImageWhenDisabled:(BOOL)adjustsImageWhenDisabled {
    [self.content setAdjustsImageWhenDisabled:adjustsImageWhenDisabled];
}

- (void)setAdjustsImageWhenHighlighted:(BOOL)adjustsImageWhenHighlighted {
    [self.content setAdjustsImageWhenHighlighted:adjustsImageWhenHighlighted];
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {
    [self.content setBackgroundImage:image forState:state];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    [self.content setImage:image forState:state];
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    [self.content setTitleColor:color forState:state];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
    [self.content setTitle:title forState:state];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self.content setSelected:selected];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self.content setEnabled:enabled];
}

@end
