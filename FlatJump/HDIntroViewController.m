//
//  HDIntroViewController.m
//  FlatJump
//
//  Created by Evan Ische on 4/1/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import QuartzCore;

#import "HDLayoverView.h"
#import "HDShadowButton.h"
#import "HDAppDelegate.h"
#import "UIColor+FlatColors.h"
#import "HDIntroViewController.h"

@interface HDIntroViewController ()

@end

@implementation HDIntroViewController

- (void)viewDidLoad {
    [self _setup];
    [super viewDidLoad];
}

- (void)_setup {
    
    self.view.backgroundColor = [UIColor flatMidnightBlueColor];
    
    CGRect beginBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds)/1.65f, CGRectGetMidX(self.view.bounds)/2.25f);
    HDShadowButton *begin = [[HDShadowButton alloc] initWithFrame:beginBounds];
    begin.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                               CGRectGetMidY(self.view.bounds) + CGRectGetHeight(self.view.bounds)/10);
    begin.backgroundColor = [UIColor flatSTRedColor];
    begin.titleLabel.font = [UIFont fontWithName:@"GillSans" size:CGRectGetHeight(begin.bounds) * .65f];
    [begin setTitle:@"BEGIN" forState:UIControlStateNormal];
    [begin addTarget:[HDAppDelegate sharedDelegate]
              action:@selector(presentGameViewController)
    forControlEvents:UIControlEventTouchUpInside];
    
    CGRect leaderboardBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(beginBounds), CGRectGetMidX(self.view.bounds)/3.25f);
    HDShadowButton *leaderboard = [[HDShadowButton alloc] initWithFrame:leaderboardBounds];
    [leaderboard setTitle:@"LEADERBOARD" forState:UIControlStateNormal];
    leaderboard.titleLabel.font = [UIFont fontWithName:@"GillSans" size:CGRectGetHeight(leaderboard.bounds) * .45f];
    leaderboard.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                     CGRectGetMaxY(begin.frame) + CGRectGetMidY(leaderboardBounds) + 10.0f);
    leaderboard.backgroundColor = [UIColor flatPeterRiverColor];
    [leaderboard addTarget:[HDAppDelegate sharedDelegate]
                    action:@selector(presentLeaderboardViewController:)
          forControlEvents:UIControlEventTouchUpInside];
    
    for (HDShadowButton *button in @[begin, leaderboard]) {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:button];
    }
    
    const CGSize buttonSize       = CGSizeMake((CGRectGetWidth(self.view.bounds)/1.65f)/4, (CGRectGetWidth(self.view.bounds)/1.65f)/4 + 10.0f);
    const CGFloat kSeperatorWidth = ceil((CGRectGetWidth(self.view.bounds)/1.65f - buttonSize.width)/2);
    const CGFloat kOriginX        = ceil(CGRectGetMidX(self.view.bounds) - kSeperatorWidth);
    
    for (NSUInteger i = 0; i < 3; i++) {
        CGRect buttonBounds = CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height);
        HDShadowButton *button = [[HDShadowButton alloc] initWithFrame:buttonBounds];
        button.center = CGPointMake(kOriginX + (kSeperatorWidth * i), CGRectGetMaxY(leaderboard.frame) + CGRectGetMidX(buttonBounds) + 15.0f);
        [self.view addSubview:button];
        
        switch (i) {
            case 0:
                [button addTarget:self
                           action:@selector(_openSettingsMenu:)
                 forControlEvents:UIControlEventTouchUpInside];
                 button.backgroundColor = [UIColor flatSTWhiteColor];
                break;
            case 1:
                [button addTarget:self
                           action:@selector(removeAds:)
                 forControlEvents:UIControlEventTouchUpInside];
                 button.backgroundColor = [UIColor flatSTRedColor];
                break;
            case 2:
                [button addTarget:[HDAppDelegate sharedDelegate]
                           action:@selector(removeAds:)
                 forControlEvents:UIControlEventTouchUpInside];
                 button.backgroundColor = [UIColor flatSTLightBlueColor];
                break;
            default:
                break;
        }
    }
}

- (IBAction)_openSettingsMenu:(id)sender {
    HDLayoverView *layover = [[HDLayoverView alloc] init];
    [layover show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
