//
//  HDLayoverView.m
//  FlatJump
//
//  Created by Evan Ische on 4/5/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDButton.h"
#import "HDHelper.h"
#import "HDAppDelegate.h"
#import "HDLayoverView.h"
#import "UIColor+FlatColors.h"
#import "HDSettingsManager.h"
#import "HDSoundManager.h"

@interface HDColoredView : UIView
@end

@implementation HDColoredView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UILabel *titleLbl = [[UILabel alloc] init];
        titleLbl.textColor = [UIColor whiteColor];
        titleLbl.font = GAME_FONT_WITH_SIZE(32.0f);
        titleLbl.textAlignment = NSTextAlignmentCenter;
        titleLbl.text = NSLocalizedString(@"setting", nil);
        [titleLbl sizeToFit];
        titleLbl.center = CGPointMake(CGRectGetMidX(self.bounds), (CGRectGetHeight(self.bounds)/5.25f)/2);
        titleLbl.frame = CGRectIntegral(titleLbl.frame);
        [self addSubview:titleLbl];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGRect stripeBox = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)/5.25f);
    UIBezierPath *stripe = [UIBezierPath bezierPathWithRect:stripeBox];
    [[UIColor flatSTBackgroundColor] setFill];
    [stripe fill];
}

@end

@interface HDLayoverView ()
@property (nonatomic, strong) HDLayoverView *retainSelf;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) HDColoredView *container;
@end

@implementation HDLayoverView

- (instancetype)init {
    if (self = [super init]) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    keyWindow.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    [keyWindow tintColorDidChange];
    
    self.retainSelf = self;
    self.frame = keyWindow.bounds;
    
    // Set up our subviews
    self.backgroundView                 = [[UIView alloc] initWithFrame:keyWindow.bounds];
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    self.backgroundView.alpha           = 0.0f;
    [self addSubview:self.backgroundView];
    
    CGRect containerBounds = CGRectMake(0.0f, 0.0f, 325.0f, 335.0f); //Hardcoded, scale according to screensize
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = containerBounds;
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:containerBounds
                                           byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight
                                                 cornerRadii:CGSizeMake(25.0f, 25.0f)].CGPath;
    
    self.container = [[HDColoredView alloc] initWithFrame:containerBounds];
    self.container.backgroundColor = [UIColor flatSTAccentColor];
    self.container.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds) + CGRectGetMidY(self.container.bounds));
    self.container.layer.mask = maskLayer;
    [self addSubview:self.container];
    
    for (NSUInteger i = 0; i < 2; i++) {
        
        const CGFloat containerSpacing = 30.0f;
        
        CGRect bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.container.bounds)/1.4f, CGRectGetHeight(self.container.bounds)/10.0f);
        
        const CGFloat startyPositon = CGRectGetHeight(self.container.bounds)/5.25f + CGRectGetMidY(bounds) + containerSpacing;
        
        CALayer *layer = [CALayer layer];
        layer.frame = bounds;
        layer.position = CGPointMake(CGRectGetMidX(self.container.bounds), startyPositon + (i * (CGRectGetHeight(bounds) + containerSpacing)));
        layer.backgroundColor = [UIColor flatSTTanColor].CGColor;
        layer.cornerRadius = CGRectGetMidY(bounds);
        [self.container.layer addSublayer:layer];
        
        CGRect toggleBounds = CGRectMake(0.0f, 0.0f, CGRectGetHeight(layer.bounds) * 1.6f, CGRectGetHeight(layer.bounds) * 1.3f);
        HDButton *toggle = [HDButton buttonWithType:UIButtonTypeCustom];
        toggle.frame = toggleBounds;
        toggle.layer.cornerRadius = CGRectGetMidY(toggleBounds);
        [toggle addTarget:self action:@selector(_toggleSettings:) forControlEvents:UIControlEventTouchUpInside];
        [toggle setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [toggle setTitle:NSLocalizedString(@"off", nil) forState:UIControlStateNormal];
        [toggle setTitle:NSLocalizedString(@"on",  nil) forState:UIControlStateSelected];
        toggle.tag = i;
        toggle.backgroundColor = [UIColor flatSTRedColor];
        toggle.titleLabel.textAlignment = NSTextAlignmentCenter;
        toggle.titleLabel.font = GAME_FONT_WITH_SIZE(CGRectGetHeight(toggle.bounds) * .4f);
        toggle.center = CGPointMake(CGRectGetMaxX(layer.frame) - CGRectGetMidX(toggle.bounds), CGRectGetMidY(layer.frame));
        [self.container addSubview:toggle];
        
        NSString *labelText = nil;
        switch (i) {
            case 0:
                toggle.selected = [[HDSettingsManager sharedManager] sound];
                labelText = NSLocalizedString(@"sound", nil);
                break;
            default:
                toggle.selected = [[HDSettingsManager sharedManager] music];
                labelText = NSLocalizedString(@"music", nil);
                break;
        }
        
        UILabel *descriptionLbl = [[UILabel alloc] init];
        descriptionLbl.textAlignment = NSTextAlignmentCenter;
        descriptionLbl.textColor = [UIColor flatMidnightBlueColor];
        descriptionLbl.font = GAME_FONT_WITH_SIZE(CGRectGetHeight(bounds) * .6f);
        descriptionLbl.text = labelText;
        [descriptionLbl sizeToFit];
        descriptionLbl.center = CGPointMake(CGRectGetMinX(layer.frame) + CGRectGetMidX(descriptionLbl.bounds) + containerSpacing,
                                            CGRectGetMidY(layer.frame));
        descriptionLbl.frame = CGRectIntegral(descriptionLbl.frame);
        [self.container addSubview:descriptionLbl];
        
        if (i == 0) {
            continue;
        }
        
        CGRect restoreBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.container.bounds)/1.4f, CGRectGetHeight(self.container.bounds)/6.0f);
        UIButton *restore = [UIButton buttonWithType:UIButtonTypeCustom];
        restore.frame = restoreBounds;
        restore.layer.cornerRadius = CGRectGetMidY(restoreBounds);
        [restore addTarget:[HDAppDelegate sharedDelegate] action:@selector(restoreIAP:) forControlEvents:UIControlEventTouchUpInside];
        [restore setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [restore setTitle:NSLocalizedString(@"restore", nil) forState:UIControlStateNormal];
        restore.backgroundColor = [UIColor flatSTEmeraldColor];
        restore.titleLabel.textAlignment = NSTextAlignmentCenter;
        restore.titleLabel.font = GAME_FONT_WITH_SIZE(CGRectGetHeight(restore.bounds) * .3f);
        restore.center = CGPointMake(CGRectGetMidX(self.container.bounds),
                                     CGRectGetMaxY(layer.frame) + CGRectGetMidY(restore.bounds) + containerSpacing);
        [self.container addSubview:restore];
    }
    self.container.transform = CGAffineTransformMakeScale(TRANSFORM_SCALE_X, TRANSFORM_SCALE_X);
}

- (void)show {
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    [CATransaction begin];{
        [CATransaction setAnimationDuration:5.0f];
        [CATransaction setCompletionBlock:^{
            [self.container.layer removeAllAnimations];
        }];
        
        // Spring effect in
        CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
        keyFrameAnimation.duration = .25f;
        keyFrameAnimation.values = @[@(CGRectGetHeight(self.bounds) + CGRectGetHeight(self.container.frame)/2),
                                     @(CGRectGetHeight(self.bounds) - CGRectGetHeight(self.container.frame)/2),
                                     @(CGRectGetHeight(self.bounds) - CGRectGetHeight(self.container.frame)/2 + 20.0f)];
        keyFrameAnimation.keyTimes = @[@0.0f, @0.7f, @1.0f];
        
        self.container.layer.position = CGPointMake(CGRectGetMidX(self.bounds), [[keyFrameAnimation.values lastObject] floatValue]);
        [self.container.layer addAnimation:keyFrameAnimation forKey:keyFrameAnimation.keyPath];
        
    }[CATransaction commit];
    
    [UIView animateWithDuration:.25f animations:^{
        self.backgroundView.alpha = 1.0f;
    }];
}

- (void)dismiss {
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [CATransaction begin];{
        [CATransaction setAnimationDuration:.03f];
        [CATransaction setCompletionBlock:^{
            [self.container.layer removeAllAnimations];
            [self removeFromSuperview];
            self.retainSelf = nil;
        }];
        
        // Spring effect out
        CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
        keyFrameAnimation.duration = .2f;
        keyFrameAnimation.values = @[@(CGRectGetHeight(self.bounds) - CGRectGetHeight(self.container.frame)/2 + 20.0f),
                                     @(CGRectGetHeight(self.bounds) - CGRectGetHeight(self.container.frame)/2),
                                     @(CGRectGetHeight(self.bounds) + CGRectGetHeight(self.container.frame)/2)];
        keyFrameAnimation.keyTimes = @[@0.0f, @0.3f, @1.0f];
        
        self.container.layer.position = CGPointMake(CGRectGetMidX(self.bounds), [[keyFrameAnimation.values lastObject] floatValue]);
        [self.container.layer addAnimation:keyFrameAnimation forKey:keyFrameAnimation.keyPath];
        
    }[CATransaction commit];
    
    [UIView animateWithDuration:.2f animations:^{
        self.backgroundView.alpha = 0.0f;
        keyWindow.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
        [keyWindow tintColorDidChange];
    }];
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!self.userInteractionEnabled) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    if (touch.view == self.backgroundView) {
        self.userInteractionEnabled = NO;
        [self dismiss];
    }
}

#pragma mark - IBA

- (IBAction)_toggleSettings:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    switch (sender.tag) {
        case 0:
            [[HDSettingsManager sharedManager] setSound:![[HDSettingsManager sharedManager] sound]];
            [[HDSoundManager sharedManager] playSound:HDMenuClicked];
            break;
        default:
            [[HDSettingsManager sharedManager] setMusic:![[HDSettingsManager sharedManager] music]];
            [[HDSoundManager sharedManager] playSound:HDMenuClicked];
            break;
    }
}

@end
