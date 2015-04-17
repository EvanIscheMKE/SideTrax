//
//  HDIntroViewController.m
//  FlatJump
//
//  Created by Evan Ische on 4/1/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import iAd;
@import SpriteKit;
@import QuartzCore;

#import "HDButton.h"
#import "HDHelper.h"
#import "HDLayoverView.h"
#import "HDGridManager.h"
#import "HDAppDelegate.h"
#import "HDJumperIAdHelper.h"
#import "UIColor+FlatColors.h"
#import "HDPointsManager.h"
#import "HDIntroViewController.h"
#import "HDSettingsManager.h"
#import "HDSoundManager.h"

@implementation HDIntroViewController {
    ADBannerView *_bannerView;
    UIView *_containerView;
    UILabel *_highscoreLbl;
    UILabel *_scoreLbl;
    BOOL _isBannerVisible;
    BOOL _isContainerVisible;
    BOOL _animating;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IAPHelperProductPurchasedNotification
                                                  object:nil];
}

- (void)viewDidLoad {
    [self _setup];
    [super viewDidLoad];
    
    // Register to remove ads 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_removeAdsWasPurchased:)
                                                 name:IAPremoveAdsProductIdentifier
                                               object:nil];
}

- (void)_setup {
    
    _isContainerVisible = YES;
    
    self.view.backgroundColor = [UIColor flatSTBackgroundColor];
    
    CGRect bounds = self.view.bounds;
    _containerView = [[UIView alloc] initWithFrame:bounds];
    _containerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_containerView];
    
    // Check if the user has purchased remove ads IAP, if not
    if (![[NSUserDefaults standardUserDefaults] boolForKey:IAPremoveAdsProductIdentifier]) {
        
        // prepare InterstitalAd
        [UIViewController prepareInterstitialAds];
        
        // Add BannerAds
        _bannerView = [[ADBannerView alloc] init];
        _bannerView.delegate = self;
        [self.view addSubview:_bannerView];
        
        CGPoint position = _bannerView.center;
        position.y = -CGRectGetMidY(_bannerView.bounds);
        _bannerView.center = position;
    }
    
    // Current score label
    _scoreLbl = [[UILabel alloc] init];
    _scoreLbl.textColor = [UIColor whiteColor];
    _scoreLbl.font      = GAME_FONT_WITH_SIZE(62.0f);
    _scoreLbl.text      = [NSString stringWithFormat:@"%zd",0];
    [_scoreLbl sizeToFit];
    _scoreLbl.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    
    // Current score title Label
    UILabel *scoreTitleLbl = [[UILabel alloc] init];
    scoreTitleLbl.textColor = [UIColor flatSTRedColor];
    scoreTitleLbl.font      = GAME_FONT_WITH_SIZE(28.0f);
    scoreTitleLbl.text      = NSLocalizedString(@"score", nil);
    [scoreTitleLbl sizeToFit];
    scoreTitleLbl.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMinY(_scoreLbl.frame) - (8.0f * TRANSFORM_SCALE_Y));
    
    // Highscore Label
    _highscoreLbl = [[UILabel alloc] init];
    _highscoreLbl.attributedText = [self attributedStringFromHighscore:53];
    [_highscoreLbl sizeToFit];
    _highscoreLbl.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMaxY(_scoreLbl.frame) + (8.0f * TRANSFORM_SCALE_Y));
    
    // Title Label
    UILabel *title = [[UILabel alloc] init];
    title.textColor = [UIColor flatSTEmeraldColor];
    title.font = GAME_FONT_WITH_SIZE(52.0f);
    title.text = @"SIDE TRAX";
    [title sizeToFit];
    title.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) - CGRectGetHeight(self.view.bounds)/5);
    
    // Get rid of redundant code
    for (UILabel *label in @[_scoreLbl, scoreTitleLbl, _highscoreLbl, title]) {
        label.textAlignment = NSTextAlignmentCenter;
        label.frame = CGRectIntegral(label.frame);
        [_containerView addSubview:label];
    }
    
    CGRect beginBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds)/1.8f, CGRectGetHeight(_containerView.bounds)/12.0f);
    HDButton *begin = [HDButton buttonWithType:UIButtonTypeCustom];
    [begin setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
    begin.frame = beginBounds;
    begin.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds) +  CGRectGetHeight(self.view.bounds)/5);
    begin.backgroundColor = [UIColor flatSTEmeraldColor];
    [begin addTarget:self action:@selector(_liftOff:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect reverseBounds = CGRectMake(0.0f, 0.0f, 65.0f, 65.0f);
    HDButton *reverse = [HDButton buttonWithType:UIButtonTypeCustom];
    reverse.tag = 5;
    [reverse addSoundNamed:HDMenuClicked forControlEvent:UIControlEventTouchUpInside];
    [reverse setImage:[UIImage imageNamed:@"Arrow-Out"] forState:UIControlStateNormal];
    [reverse setImage:[UIImage imageNamed:@"Arrow-In"] forState:UIControlStateSelected];
    reverse.selected = [HDSettingsManager sharedManager].reversed;
    reverse.frame = reverseBounds;
    reverse.backgroundColor = [UIColor flatSTButtonColor];
    reverse.center = CGPointMake(CGRectGetMidX(self.view.bounds)/2.5, CGRectGetMidY(self.view.bounds));
    reverse.transform = CGAffineTransformMakeRotation(-(M_PI_4/2));
    [reverse addTarget:self action:@selector(_reverseControl:) forControlEvents:UIControlEventTouchUpInside];
    
    for (HDButton *button in @[begin, reverse]) {
        button.layer.cornerRadius = CGRectGetMidY(button.bounds);
        button.adjustsImageWhenHighlighted = NO;
        button.adjustsImageWhenDisabled = NO;
        [_containerView addSubview:button];
    }
    
    // Number of buttons needed
    const NSUInteger buttonCount = 5;
    
    // Bottom button sizes, scale accordingly
    const CGSize buttonSize = CGSizeMake(ceilf(CGRectGetWidth(self.view.bounds)/8.5f), ceilf(CGRectGetWidth(self.view.bounds)/8.5f));
    
    // Spacing between Buttons
    const CGFloat padding = roundf(buttonSize.width/5);
    
    // Starting Origin X-Axis
    const CGFloat startxOrigin = ceil(CGRectGetMidX(self.view.bounds) - ((buttonSize.width + padding) * ((buttonCount -1)/2)));
    
    NSLog(@"%@",NSStringFromCGSize(buttonSize));
    
    // Loop through button count
    for (NSUInteger i = 0; i < buttonCount; i++) {
        CGRect buttonBounds = CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height);
        HDButton *button = [HDButton buttonWithType:UIButtonTypeCustom];
        [button addSoundNamed:HDMenuClicked forControlEvent:UIControlEventTouchUpInside];
        button.adjustsImageWhenHighlighted = NO;
        button.adjustsImageWhenDisabled    = NO;
        button.frame = buttonBounds;
        button.layer.cornerRadius = CGRectGetMidY(buttonBounds);
        button.center = CGPointMake(startxOrigin + ((buttonSize.width + padding) * i),
                                    CGRectGetHeight(self.view.bounds) - buttonSize.width/2 - padding);
        button.backgroundColor = [UIColor flatSTButtonColor];
        [_containerView addSubview:button];
        
        switch (i) {
            case 0:
                // Display Settings Menu
                [button setBackgroundImage:[UIImage imageNamed:@"Setting"]
                                  forState:UIControlStateNormal];
                [button addTarget:self
                           action:@selector(_openSettingsMenu:)
                 forControlEvents:UIControlEventTouchUpInside];
                break;
            case 1:
                // Puchase remove ads IAP
                button.titleLabel.font = GAME_FONT_WITH_SIZE(CGRectGetHeight(buttonBounds)/3.25f);
                button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                button.titleLabel.textAlignment = NSTextAlignmentCenter;
                [button setTitle:@"NO\nADS"
                        forState:UIControlStateNormal];
                [button setTitleColor:[UIColor flatSTRedColor]
                             forState:UIControlStateNormal];
                [button addTarget:[HDAppDelegate sharedDelegate]
                           action:@selector(removeAds:)
                 forControlEvents:UIControlEventTouchUpInside];
                break;
            case 2:
                // Present Share View Controller
                [button setBackgroundImage:[UIImage imageNamed:@"Share"]
                                  forState:UIControlStateNormal];
                [button addTarget:[HDAppDelegate sharedDelegate]
                           action:@selector(presentActivityViewController:)
                 forControlEvents:UIControlEventTouchUpInside];
                break;
            case 3:
                // Present Game Center Leaderboards
                [button setBackgroundImage:[UIImage imageNamed:@"Leaderboard"]
                                  forState:UIControlStateNormal];
                [button addTarget:[HDAppDelegate sharedDelegate]
                           action:@selector(presentLeaderboardViewController:)
                 forControlEvents:UIControlEventTouchUpInside];
                break;
            case 4:
                // Open AppStore to rate application
                [button setBackgroundImage:[UIImage imageNamed:@"Star"]
                                  forState:UIControlStateNormal];
                [button addTarget:[HDAppDelegate sharedDelegate]
                           action:@selector(rateThisApp:)
                 forControlEvents:UIControlEventTouchUpInside];
                break;
            default:
                break;
        }
    }
}

- (NSAttributedString *)attributedStringFromHighscore:(NSUInteger)highscore {
    
    NSDictionary *baseAttributes = @{ NSForegroundColorAttributeName: [UIColor flatSTRedColor],
                                                  NSFontAttributeName: GAME_FONT_WITH_SIZE(18.0f)};
    
    NSDictionary *scoreAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor],
                                                  NSFontAttributeName: GAME_FONT_WITH_SIZE(18.0f)};
    
    // Change the text portion of the label to "Flat Red", and remaining numbers white
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"BEST %tu",highscore]];
    [string addAttributes:baseAttributes  range:NSMakeRange(0, 4)];
    [string addAttributes:scoreAttributes range:NSMakeRange(4, [string length] - 4)];
    
    return string;
}

- (IBAction)_reverseControl:(HDButton *)sender {
    
    // If animations already started return
    if (_animating) {
        return;
    }
    
    // Get a refernce to the button that triggered this
    HDButton *reverse = sender;
    
    _animating = YES;
    [CATransaction begin]; {
        [CATransaction setCompletionBlock:^{
            _animating = NO;
            reverse.selected = !reverse.selected;
            [HDSettingsManager sharedManager].reversed = ![HDSettingsManager sharedManager].reversed;
        }];
        
        // Rotate 2 Radians  
        CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotation.byValue  = @(reverse.selected ? M_PI*2 : -M_PI*2);
        rotation.duration = .2f;
        [reverse.layer addAnimation:rotation forKey:rotation.keyPath];
        
    } [CATransaction commit];
}

- (IBAction)_liftOff:(id)sender {
    
    _isContainerVisible = NO;
    
    // Animate the banner off the top of the screen while animating _container to the bottom of the screen
    [UIView animateWithDuration:.200f animations:^{
        
        CGPoint position = _bannerView.center;
        position.y = -CGRectGetMidY(_bannerView.bounds);
        _bannerView.center = position;
        
        CGRect frame = _containerView.frame;
        frame.origin.y = CGRectGetHeight(self.view.bounds);
        _containerView.frame = frame;
        
    } completion:^(BOOL finished) {
        
        // Allow banner to be repositioned when delegats called
        _isBannerVisible = NO;
        
        // Turn on background music
        [[HDSoundManager sharedManager] setPlayLoop:YES];
        
        // Launch Game View Controller
        [[HDAppDelegate sharedDelegate] presentGameViewController];
    }];
    
}

- (IBAction)_openSettingsMenu:(id)sender {
    HDLayoverView *layover = [[HDLayoverView alloc] init];
    [layover show];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Update score labels to reflect past game
    _scoreLbl.text = [NSString stringWithFormat:@"%zd",[[HDPointsManager sharedManager] score]];
    _highscoreLbl.attributedText = [self attributedStringFromHighscore:[[HDPointsManager sharedManager] highScore]];
    
    for (UILabel *label in @[_scoreLbl, _highscoreLbl]) {
        [label sizeToFit];
        label.center = CGPointMake(CGRectGetMidX(_containerView.bounds), label.center.y);
        label.frame = CGRectIntegral(label.frame);
    }
}

- (BOOL)_rollTheDice {
   return (arc4random() % 2 == 1);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_isContainerVisible) {
        
        // Check if the user has purchased remove ads IAP, if not
        BOOL adsRemoved = [[NSUserDefaults standardUserDefaults] boolForKey:IAPremoveAdsProductIdentifier];
        if (!adsRemoved && [self _rollTheDice]) {
            [self requestInterstitialAdPresentation];
        }
    
        [UIView animateWithDuration:.300f animations:^{
            
            CGPoint position = _containerView.center;
            position.y = CGRectGetMidY(self.view.bounds);
            _containerView.center = position;
            
            if (_bannerView) {
                position = _bannerView.center;
                position.y = CGRectGetMidY(_bannerView.bounds);
                _bannerView.center = position;
            }
            
        } completion:^(BOOL finished) {
            _isContainerVisible = YES;
        }];
        
    }
}

#pragma mark - <ADBannerViewDelegate>

- (void)_removeAdsWasPurchased:(NSNotification *)notification {
    
    // Check if the IAP notification is the "IAPremoveAdsProductIdentifier", if not return
    NSString *productIdentifier = notification.object;
    if (![productIdentifier isEqualToString:IAPremoveAdsProductIdentifier]) {
        return;
    }
    
    // Hide the banner and remove it, $$ dolla dolla bills.
    [UIView animateWithDuration:.300f animations:^{
        CGRect bannerFrame = _bannerView.frame;
        bannerFrame.origin.y = -CGRectGetMidY(_bannerView.bounds);
        _bannerView.frame = bannerFrame;
    } completion:^(BOOL finished) {
        [_bannerView removeFromSuperview];
         _bannerView = nil;
        _isBannerVisible = NO;
    }];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    
    if (!_isBannerVisible) {
        
        // Show Banner
        [UIView animateWithDuration:.300f animations:^{
            CGPoint position = _bannerView.center;
            position.y = CGRectGetMidY(_bannerView.bounds);
            _bannerView.center = position;
        }];
        
        _isBannerVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    
    if (_isBannerVisible) {
        
        // Hide Banner
        [UIView animateWithDuration:.300f animations:^{
            CGPoint position = _bannerView.center;
            position.y = -CGRectGetMidY(_bannerView.bounds);
            _bannerView.center = position;
        }];
        
        _isBannerVisible = NO;
    }
}

@end
