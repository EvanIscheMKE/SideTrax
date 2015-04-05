//
//  HDCompletionViewController.m
//  FlatJump
//
//  Created by Evan Ische on 4/2/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import iAd;
@import QuartzCore;

#import "HDShadowButton.h"
#import "UIColor+FlatColors.h"
#import "HDCompletionViewController.h"

@interface HDCompletionViewController ()
@property (nonatomic, strong) UIView *container;
@end

@implementation HDCompletionViewController

- (void)viewDidLoad {
    [self _setup];
    [super viewDidLoad];
}

- (void)_setup {
    
    self.canDisplayBannerAds = YES;
    self.view.backgroundColor = [UIColor flatMidnightBlueColor];
    
    CGRect containerBounds = CGRectInset(self.view.bounds, 25.0f, 150.0f);
    self.container = [[UIView alloc] initWithFrame:containerBounds];
    self.container.backgroundColor = [UIColor flatSTWhiteColor];
    self.container.layer.cornerRadius = 30.0f;
    self.container.layer.borderWidth = 1.0f;
    self.container.layer.borderColor = [UIColor clearColor].CGColor;
    self.container.layer.allowsEdgeAntialiasing = YES;
    [self.view addSubview:self.container];
    
    CGRect shapeBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.container.bounds)/3.75, CGRectGetHeight(self.container.bounds)/4.75f);
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.frame = shapeBounds;
    shape.path = [UIBezierPath bezierPathWithRoundedRect:shapeBounds
                                       byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight
                                             cornerRadii:CGSizeMake(15.f, 15.f)].CGPath;
    shape.fillColor = [UIColor flatSTLightBlueColor].CGColor;
    shape.position = CGPointMake(CGRectGetMidX(self.container.bounds), CGRectGetMidY(shape.bounds));
    [self.container.layer addSublayer:shape];
    
    CALayer *shadow = [CALayer layer];
    shadow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.1f].CGColor;
    shadow.cornerRadius = self.container.layer.cornerRadius;
    shadow.frame = self.container.bounds;
    shadow.position = CGPointMake(self.container.center.x, self.container.center.y + 13.0f);
    [self.view.layer insertSublayer:shadow below:self.container.layer];
    
    CGRect boxBounds = CGRectInset(self.container.bounds, 25.0f, 138.0f);
    CALayer *labelContainer = [CALayer layer];
    labelContainer.frame = boxBounds;
    labelContainer.backgroundColor = [UIColor flatSTTanColor].CGColor;
    labelContainer.position = CGPointMake(CGRectGetMidX(self.container.bounds), CGRectGetMidY(self.container.bounds) + 15.0f);
    labelContainer.cornerRadius = self.container.layer.cornerRadius;
    [self.container.layer addSublayer:labelContainer];
    
    CGRect shareBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.container.bounds)/1.5, CGRectGetHeight(self.container.bounds)/6.5f);
    HDShadowButton *shareButton = [[HDShadowButton alloc] initWithFrame:shareBounds];
    shareButton.center = CGPointMake(CGRectGetMidX(self.container.bounds),
                                     CGRectGetMaxY(labelContainer.frame) + CGRectGetMidY(shareButton.bounds) + 15.0f);
    shareButton.backgroundColor = [UIColor flatPeterRiverColor];
    [self.container addSubview:shareButton];
    
    CGRect homeBounds = CGRectMake(0.0f,
                                   0.0f,
                                   CGRectGetWidth(self.container.bounds)/3.15f,
                                   CGRectGetWidth(self.container.bounds)/4.75f);
    HDShadowButton *home = [[HDShadowButton alloc] initWithFrame:homeBounds];
    [home addTarget:self.navigationController action:@selector(popToRootViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    home.center = CGPointMake(CGRectGetMidX(self.view.bounds) + (CGRectGetWidth(self.container.bounds)/1.5f)/2 - CGRectGetMidX(homeBounds),
                              CGRectGetMaxY(self.container.frame));
    
    CGRect gameBounds = CGRectMake(0.0f,
                                   0.0f,
                                   CGRectGetWidth(self.container.bounds)/3.15f,
                                   CGRectGetWidth(self.container.bounds)/4.75f);
    HDShadowButton *gameCenter = [[HDShadowButton alloc] initWithFrame:gameBounds];
    gameCenter.center = CGPointMake(CGRectGetMidX(self.view.bounds) - (CGRectGetWidth(self.container.bounds)/1.5f)/2 + CGRectGetMidX(gameBounds),
                                    CGRectGetMaxY(self.container.frame));
    
    for (HDShadowButton *button in @[home, gameCenter]) {
        button.backgroundColor = [UIColor flatSTLightBlueColor];
        [self.view addSubview:button];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
