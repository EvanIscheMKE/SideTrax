//
//  HDLayoverView.m
//  FlatJump
//
//  Created by Evan Ische on 4/5/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDLayoverView.h"
#import "UIColor+FlatColors.h"

#define TRANSFORM_SCALE_X [UIScreen mainScreen].bounds.size.width  / 375.0f
#define TRANSFORM_SCALE_Y [UIScreen mainScreen].bounds.size.height / 667.0f

NSString * const MENU_TITLE = @"SETTINGS";
@interface HDColoredView : UIView
@end

@implementation HDColoredView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UILabel *titleLbl = [[UILabel alloc] init];
        titleLbl.textColor = [UIColor whiteColor];
        titleLbl.font = [UIFont fontWithName:@"GillSans" size:32.0f];
        titleLbl.textAlignment = NSTextAlignmentCenter;
        titleLbl.text = MENU_TITLE;
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
    [[UIColor flatSTLightBlueColor] setFill];
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
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
    self.backgroundView.alpha           = 0.0f;
    [self addSubview:self.backgroundView];
    
    CGRect containerBounds = CGRectMake(0.0f, 0.0f, 325.0f, 325.0f); //Hardcoded, scale according to screensize
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = containerBounds;
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:containerBounds
                                           byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight
                                                 cornerRadii:CGSizeMake(25.0f, 25.0f)].CGPath;
    
    self.container = [[HDColoredView alloc] initWithFrame:containerBounds];
    self.container.backgroundColor = [UIColor flatSTWhiteColor];
    self.container.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds) + CGRectGetMidY(self.container.bounds));
    self.container.layer.mask = maskLayer;
    [self addSubview:self.container];
}

- (void)show {
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    // Spring effect in
    CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    keyFrameAnimation.duration = .25f;
    keyFrameAnimation.values = @[@(CGRectGetHeight(self.bounds) + CGRectGetMidY(self.container.bounds)),
                                 @(CGRectGetHeight(self.bounds) - CGRectGetMidY(self.container.bounds)),
                                 @(CGRectGetHeight(self.bounds) - CGRectGetMidY(self.container.bounds) + 15.0f)];
    keyFrameAnimation.keyTimes = @[@0.0f, @0.7f, @1.0f];
    
    self.container.layer.position = CGPointMake(CGRectGetMidX(self.bounds), [[keyFrameAnimation.values lastObject] floatValue]);
    [self.container.layer addAnimation:keyFrameAnimation forKey:keyFrameAnimation.keyPath];
    
    [UIView animateWithDuration:keyFrameAnimation.duration animations:^{
        self.backgroundView.alpha = 1.0f;
    }];
}

- (void)dismiss {
    
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    // Spring effect out
    CAKeyframeAnimation *keyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    keyFrameAnimation.duration = .2f;
    keyFrameAnimation.values = @[@(CGRectGetHeight(self.bounds) - CGRectGetMidY(self.container.bounds) + 15.0f),
                                 @(CGRectGetHeight(self.bounds) - CGRectGetMidY(self.container.bounds)),
                                 @(CGRectGetHeight(self.bounds) + CGRectGetMidY(self.container.bounds))];
    keyFrameAnimation.keyTimes = @[@0.0f, @0.3f, @1.0f];
    
    self.container.layer.position = CGPointMake(CGRectGetMidX(self.bounds), [[keyFrameAnimation.values lastObject] floatValue]);
    [self.container.layer addAnimation:keyFrameAnimation forKey:keyFrameAnimation.keyPath];
    
    [UIView animateWithDuration:keyFrameAnimation.duration animations:^{
        self.backgroundView.alpha = 0.0f;
        keyWindow.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
        [keyWindow tintColorDidChange];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
         self.retainSelf = nil;
    }];
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    if (touch.view == self.backgroundView) {
        [self dismiss];
    }
}

@end
