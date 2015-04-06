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
#import "HDJumperIAdHelper.h"
#import "HDCompletionViewController.h"
#import "HDAppDelegate.h"

#define TRANSFORM_SCALE_X [UIScreen mainScreen].bounds.size.width  / 375.0f
#define TRANSFORM_SCALE_Y [UIScreen mainScreen].bounds.size.height / 667.0f

@interface HDCompletionViewController ()
@property (nonatomic, strong) UIView *container;
@end

@implementation HDCompletionViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewDidLoad {
    [self _setup];
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_removeAdsWasPurchased:)
                                                 name:IAPremoveAdsProductIdentifier
                                               object:nil];
}

- (void)_setup {
    
    self.view.backgroundColor = [UIColor flatMidnightBlueColor];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:IAPremoveAdsProductIdentifier]) {
        self.canDisplayBannerAds  = YES;
    }
    
    self.container = [self _containerWithLabels];
    self.container.transform = CGAffineTransformMakeScale(TRANSFORM_SCALE_X, TRANSFORM_SCALE_Y);
    [self.view addSubview:self.container];
    
    CALayer *shadow = [CALayer layer];
    shadow.frame = self.container.frame;
    shadow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.1f].CGColor;
    shadow.cornerRadius = self.container.layer.cornerRadius;
    shadow.position = CGPointMake(self.container.center.x, self.container.center.y + 13.0f);
    [self.view.layer insertSublayer:shadow below:self.container.layer];
    
    const CGFloat kOffsetX = (CGRectGetWidth(self.container.frame)/1.5f)/2;
    CGRect buttonBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.container.frame)/3.15f, CGRectGetWidth(self.container.frame)/4.75f);
    for (NSUInteger i = 0; i < 2; i++) {
        
        HDShadowButton *subView = [[HDShadowButton alloc] initWithFrame:buttonBounds];
        subView.backgroundColor = [UIColor flatSTLightBlueColor];
        [self.view addSubview:subView];
        
        switch (i) {
            case 0:
                [subView addTarget:self.navigationController
                         action:@selector(popToRootViewControllerAnimated:)
               forControlEvents:UIControlEventTouchUpInside];
                subView.center = CGPointMake(CGRectGetMidX(self.view.bounds) + kOffsetX - CGRectGetMidX(buttonBounds),
                                             CGRectGetMaxY(self.container.frame));
                break;
            case 1:
                [subView addTarget:[HDAppDelegate sharedDelegate]
                                action:@selector(presentLeaderboardViewController:)
                      forControlEvents:UIControlEventTouchUpInside];
                subView.center = CGPointMake(CGRectGetMidX(self.view.bounds) - kOffsetX + CGRectGetMidX(buttonBounds),
                                                 CGRectGetMaxY(self.container.frame));
                break;
            default:
                break;
        }
        
    }
}

- (void)_removeAdsWasPurchased:(NSNotification *)notification {
    
    NSString *productIdentifier = notification.object;
    if (![productIdentifier isEqualToString:IAPremoveAdsProductIdentifier]) {
        return;
    }
    self.canDisplayBannerAds = NO;
}

- (UIView *)_containerWithLabels {
    
    // Hardcode it for 375*667, scale accordingly.
    CGRect containerBounds = CGRectMake(0.0f, 0.0f, 325.0f, 367.0f);
    UIView *container = [[UIView alloc] initWithFrame:containerBounds];
    container.center = self.view.center;
    container.backgroundColor = [UIColor flatSTWhiteColor];
    container.layer.cornerRadius = 30.0f;
    container.layer.borderWidth = 1.0f;
    container.layer.borderColor = [UIColor clearColor].CGColor;
    container.layer.allowsEdgeAntialiasing = YES;
    
    CGRect shapeBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(container.bounds)/3.75f, CGRectGetHeight(container.bounds)/4.75f);
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.frame = shapeBounds;
    shape.path = [UIBezierPath bezierPathWithRoundedRect:shapeBounds
                                       byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight
                                             cornerRadii:CGSizeMake(15.f, 15.f)].CGPath;
    shape.fillColor = [UIColor flatSTLightBlueColor].CGColor;
    shape.position = CGPointMake(CGRectGetMidX(container.bounds), CGRectGetMidY(shape.bounds));
    
    CGRect boxBounds = CGRectInset(container.bounds, 25.0f, 138.0f);
    CALayer *labelContainer = [CALayer layer];
    labelContainer.frame = boxBounds;
    labelContainer.backgroundColor = [UIColor flatSTTanColor].CGColor;
    labelContainer.position = CGPointMake(CGRectGetMidX(container.bounds), CGRectGetMidY(container.bounds) + 15.0f);
    labelContainer.cornerRadius = container.layer.cornerRadius;
    
    for (CALayer *subLayer in @[shape, labelContainer]) {
        [container.layer addSublayer:subLayer];
    }
    
    UILabel *descriptionLbl = [[UILabel alloc] init];
    descriptionLbl.text = @"You just beat the best move challenge";
    descriptionLbl.textColor = [UIColor flatMidnightBlueColor];
    descriptionLbl.font = [UIFont fontWithName:@"GillSans" size:17.0f];
    [descriptionLbl sizeToFit];
    descriptionLbl.center = CGPointMake(CGRectGetMidX(container.bounds),
                                        CGRectGetMinY(labelContainer.frame) - CGRectGetMidY(descriptionLbl.bounds) - 8.0f);
    
    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.text = @"Amazing!";
    titleLbl.textColor = [UIColor flatSTRedColor];
    titleLbl.font = [UIFont fontWithName:@"GillSans" size:36.0f];
    [titleLbl sizeToFit];
    titleLbl.center = CGPointMake(CGRectGetMidX(container.bounds),
                                  CGRectGetMinY(descriptionLbl.frame) - CGRectGetMidY(titleLbl.bounds) - 3.0f);
    
    for (UILabel *lbls in @[descriptionLbl, titleLbl]) {
        lbls.frame = CGRectIntegral(lbls.frame);
        [container addSubview:lbls];
    }
    
    CGRect shareBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(container.bounds)/1.5f, CGRectGetHeight(container.bounds)/6.5f);
    HDShadowButton *shareButton = [[HDShadowButton alloc] initWithFrame:shareBounds];
    shareButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    shareButton.titleLabel.font = [UIFont fontWithName:@"GillSans" size:32.0f];
    [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareButton setTitle:@"SHARE" forState:UIControlStateNormal];
    [shareButton addTarget:[HDAppDelegate sharedDelegate]
                    action:@selector(presentActivityViewController:)
          forControlEvents:UIControlEventTouchUpInside];
    shareButton.center = CGPointMake(CGRectGetMidX(container.bounds),
                                     CGRectGetMaxY(labelContainer.frame) + CGRectGetMidY(shareButton.bounds) + 15.0f);
    shareButton.backgroundColor = [UIColor flatPeterRiverColor];
    [container addSubview:shareButton];
    
    return container;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Check for new high score
    if (YES) {
        
        CGRect topViewBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.container.frame)/2.0f, CGRectGetHeight(self.container.frame)/8.5f);
        CGPoint position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMinY(self.container.frame) + CGRectGetMidY(topViewBounds));
        UIView *topView = [[UIView alloc] initWithFrame:topViewBounds];
        topView.backgroundColor = [UIColor flatSTRedColor];
        topView.center = position;
        [self.view insertSubview:topView belowSubview:self.container];
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = topView.bounds;
        maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:topView.bounds
                                               byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight
                                                     cornerRadii:CGSizeMake(15.0f, 15.0f)].CGPath;
        topView.layer.mask = maskLayer;
        
        NSTimeInterval delay = 3.0f;
        [UIView animateWithDuration:.3f animations:^{
            CGPoint position = topView.center;
            position.y = CGRectGetMinY(self.container.frame) - CGRectGetMidY(topView.bounds);
            topView.center = position;
        } completion:^(BOOL finished) {
             [UIView animateWithDuration:.3f delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
                 topView.center = position;
             } completion:^(BOOL finished) {
                [topView removeFromSuperview];
             }];
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
