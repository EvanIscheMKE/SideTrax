//
//  HDIntroViewController.m
//  FlatJump
//
//  Created by Evan Ische on 4/1/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import iAd;
@import QuartzCore;

#import "HDSwitch.h"
#import "HDButton.h"
#import "HDPageControl.h"
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
#import "UIImage+ImageAdditions.h"
#import "HDCounterLabel.h"

@implementation HDSettingsView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // Title Label
        UILabel *title = [[UILabel alloc] init];
        title.textColor = [UIColor flatSTEmeraldColor];
        title.font = GAME_FONT_WITH_SIZE(ceilf(CGRectGetHeight(self.bounds)/6));
        title.text = @"SETTINGS";
        [title sizeToFit];
        title.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(title.bounds));
        title.frame = CGRectIntegral(title.frame);
        title.shadowOffset = CGSizeMake(2.0f, 2.0f);
        title.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.1f];
        [self addSubview:title];
        
        CGRect beginBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds)/1.8f, CGRectGetHeight(self.bounds)/6.f);
        self.restoreBtn = [HDButton buttonWithType:UIButtonTypeCustom];
        self.restoreBtn.frame = beginBounds;
        self.restoreBtn.backgroundColor = [UIColor flatSTEmeraldColor];
        self.restoreBtn.layer.cornerRadius = CGRectGetMidY(self.restoreBtn.bounds);
        self.restoreBtn.adjustsImageWhenHighlighted = NO;
        self.restoreBtn.adjustsImageWhenDisabled = NO;
        self.restoreBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.restoreBtn.titleLabel.font = GAME_FONT_WITH_SIZE(CGRectGetHeight(self.restoreBtn.bounds)*.3f);
        self.restoreBtn.center = CGPointMake(CGRectGetMidX(self.bounds),
                                             CGRectGetHeight(self.bounds) - CGRectGetMidY(self.restoreBtn.bounds));
        [self.restoreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.restoreBtn setTitle:NSLocalizedString(@"restore", nil) forState:UIControlStateNormal];
        [self addSubview:self.restoreBtn];
        
       const CGFloat distace = ceilf(CGRectGetMinY(self.restoreBtn.frame) - CGRectGetMaxY(title.frame));
       const CGFloat spacing = ceilf(distace/3);
       const CGFloat startYPostion = ceilf(CGRectGetMaxY(title.frame) + (distace/2) - (spacing/2));
        
        for (NSUInteger row = 0; row < 2; row++) {
            
            UILabel *title = [[UILabel alloc] init];
            title.textColor = [UIColor whiteColor];
            title.font = GAME_FONT_WITH_SIZE(ceilf(CGRectGetHeight(self.bounds)/11));
            title.text = (row == 0) ? NSLocalizedString(@"sound", nil) : NSLocalizedString(@"music", nil);
            [title sizeToFit];
            title.center = CGPointMake(CGRectGetMidX(self.bounds) - CGRectGetMidX(self.bounds)/3.25f,
                                       startYPostion + (spacing * row));
            title.frame = CGRectIntegral(title.frame);
            title.shadowOffset = CGSizeMake(2.0f, 2.0f);
            title.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.1f];
            [self addSubview:title];
            
            // Setup switch with a static frame, use transform to adjust to screen size
            HDSwitch *toggle = [[HDSwitch alloc] initWithOnColor:[UIColor flatSTEmeraldColor]
                                                        offColor:[UIColor flatSTRedColor]];
            toggle.transform = CGAffineTransformMakeScale(TRANSFORM_SCALE_Y, TRANSFORM_SCALE_Y);
            toggle.frame = CGRectMake(0.0f, 0.0f, 70.0f, 35.0f);
            toggle.center = CGPointMake(CGRectGetMidX(self.bounds) + CGRectGetMidX(self.bounds)/3.25f,
                                        title.center.y);
            [self addSubview:toggle];
            
            switch (row) {
                case 0:
                    self.soundSwitch = toggle;
                    toggle.on = [HDSettingsManager sharedManager].sound;
                    break;
                case 1:
                    self.musicSwitch = toggle;
                    toggle.on = [HDSettingsManager sharedManager].music;
                    break;
                default:
                    break;
            }
        }
    }
    return self;
}

@end

@implementation HDIntroView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // Current score label
        _scoreLbl = [[HDCounterLabel alloc] init];
        _scoreLbl.textColor = [UIColor whiteColor];
        _scoreLbl.font      = GAME_FONT_WITH_SIZE(ceilf(CGRectGetHeight(self.bounds)/4.75f));
        _scoreLbl.text      = [NSString stringWithFormat:@"%zd",0];
        [_scoreLbl sizeToFit];
        _scoreLbl.frame  = CGRectInset(_scoreLbl.frame, -(CGRectGetWidth(self.bounds)/4), 0.0f);
        _scoreLbl.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        
        // Current score title Label
        UILabel *scoreTitleLbl = [[UILabel alloc] init];
        scoreTitleLbl.textColor = [UIColor flatEmeraldColor];
        scoreTitleLbl.font      = GAME_FONT_WITH_SIZE(ceilf(CGRectGetHeight(self.bounds)/10));
        scoreTitleLbl.text      = NSLocalizedString(@"score", nil);
        [scoreTitleLbl sizeToFit];
        scoreTitleLbl.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMinY(_scoreLbl.frame) - (8.0f * TRANSFORM_SCALE_Y));
        
        // Highscore Label
        _highScoreLbl = [[UILabel alloc] init];
        _highScoreLbl.attributedText = [self attributedStringFromHighscore:53];
        [_highScoreLbl sizeToFit];
        _highScoreLbl.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(_scoreLbl.frame) + (8.0f * TRANSFORM_SCALE_Y));
        
        // Title Label
        UILabel *title = [[UILabel alloc] init];
        title.textColor = [UIColor flatSTEmeraldColor];
        title.font = GAME_FONT_WITH_SIZE(ceilf(CGRectGetHeight(self.bounds)/6));
        title.text = @"SIDE TRAX";
        [title sizeToFit];
        title.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(title.bounds));
        
        // Get rid of redundant code
        for (UILabel *label in @[_scoreLbl, scoreTitleLbl, _highScoreLbl, title]) {
            label.textAlignment = NSTextAlignmentCenter;
            label.frame = CGRectIntegral(label.frame);
            label.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.1f];
            label.shadowOffset = CGSizeMake(2.0f, 2.0f);
            [self addSubview:label];
        }
        
        CGRect beginBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds)/1.8f, CGRectGetHeight(self.bounds)/6.f);
        self.playBtn = [HDButton buttonWithType:UIButtonTypeCustom];
        [self.playBtn setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
        self.playBtn.frame = beginBounds;
        self.playBtn.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetHeight(self.bounds) -  CGRectGetMidY(self.playBtn.bounds));
        self.playBtn.backgroundColor = [UIColor flatSTEmeraldColor];
        self.playBtn.layer.cornerRadius = CGRectGetMidY(self.playBtn.bounds);
        self.playBtn.adjustsImageWhenHighlighted = NO;
        self.playBtn.adjustsImageWhenDisabled = NO;
        self.playBtn.imageView.clipsToBounds = NO;
        self.playBtn.imageView.contentMode = UIViewContentModeCenter;
        self.playBtn.imageView.transform = CGAffineTransformMakeScale(TRANSFORM_SCALE_X, TRANSFORM_SCALE_X);
        [self addSubview:self.playBtn];

    }
    return self;
}

- (NSAttributedString *)attributedStringFromHighscore:(NSUInteger)highscore {
    
    UIFont *defaultFont = GAME_FONT_WITH_SIZE(ceilf(CGRectGetHeight(self.bounds)/15));
    
    NSDictionary *baseAttributes = @{ NSForegroundColorAttributeName: [UIColor flatEmeraldColor],
                                      NSFontAttributeName: defaultFont};
    
    NSDictionary *scoreAttributes = @{ NSForegroundColorAttributeName: [UIColor whiteColor],
                                       NSFontAttributeName: defaultFont };
    
    NSString *bestString = NSLocalizedString(@"best", nil);
    // Change the text portion of the label to "Flat Red", and remaining numbers white
    NSMutableAttributedString *string;
    string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %tu", bestString, highscore]];
    [string addAttributes:baseAttributes  range:NSMakeRange(0, [bestString length])];
    [string addAttributes:scoreAttributes range:NSMakeRange([bestString length], [string length] - [bestString length])];
    
    return string;
}

@end

@interface HDIntroViewController ()<UIScrollViewDelegate>
@end
@implementation HDIntroViewController {
    ADBannerView *_bannerView;
    HDIntroView *_introView;
    HDSettingsView *_settingView;
    HDPageControl *_pageControl;
    UIView *_containerView;
    BOOL _isBannerVisible;
    BOOL _isContainerVisible;
    BOOL _animating;
    BOOL _reversed;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IAPHelperProductPurchasedNotification
                                                  object:nil];
}

- (void)viewDidLoad {
    
    // Setup
    [self _setup];
    
    // Call super
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
    
    CGRect scrollViewBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)/2.0f);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollViewBounds];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds)*2, CGRectGetHeight(scrollViewBounds));
    scrollView.center = self.view.center;
    scrollView.delegate = self;
    [_containerView addSubview:scrollView];
    
    _introView = [[HDIntroView alloc] initWithFrame:scrollViewBounds];
    [_introView.reverseBtn addTarget:self action:@selector(_reverseControl:) forControlEvents:UIControlEventTouchUpInside];
    [_introView.playBtn    addTarget:self action:@selector(_liftOff:)        forControlEvents:UIControlEventTouchUpInside];
    _introView.center = CGPointMake(CGRectGetMidX(scrollView.bounds), CGRectGetMidY(scrollView.bounds));
    [scrollView addSubview:_introView];
    
    _settingView = [[HDSettingsView alloc] initWithFrame:scrollViewBounds];
    [_settingView.restoreBtn addTarget:[HDAppDelegate sharedDelegate]
                                action:@selector(restoreIAP:)
                      forControlEvents:UIControlEventTouchUpInside];
    [_settingView.soundSwitch addTarget:self
                                 action:@selector(_toggleSound:)
                       forControlEvents:UIControlEventValueChanged];
    [_settingView.musicSwitch addTarget:self
                                 action:@selector(_toggleMusic:)
                       forControlEvents:UIControlEventValueChanged];
    _settingView.center = CGPointMake(CGRectGetWidth(scrollView.bounds) + CGRectGetMidX(scrollView.bounds),
                                      CGRectGetMidY(scrollView.bounds));
    [scrollView addSubview:_settingView];
    
    CGRect controlBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), 50.0f);
    _pageControl = [[HDPageControl alloc] initWithFrame:controlBounds];
    _pageControl.numberOfPages = 2;
    _pageControl.currentPage = 0;
    _pageControl.currentPageIndicatorTintColor = [UIColor flatSTEmeraldColor];
    _pageControl.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                     CGRectGetHeight(self.view.bounds) - (CGRectGetWidth(self.view.bounds)/8.0f)*1.75f);
    [_containerView addSubview:_pageControl];
    
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
    
    // Number of buttons needed
    const NSUInteger buttonCount = 5;
    
    // Bottom button sizes, scale accordingly
    const CGSize buttonSize = CGSizeMake(ceilf(CGRectGetWidth(self.view.bounds)/7.75f), ceilf(CGRectGetWidth(self.view.bounds)/7.75f));
    
    // Spacing between Buttons
    const CGFloat padding = roundf(buttonSize.width/5);
    
    // Starting Origin X-Axis
    const CGFloat startxOrigin = ceil(CGRectGetMidX(self.view.bounds) - ((buttonSize.width + padding) * ((buttonCount -1)/2.0f)));
    
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
                // Puchase remove ads IAP
                button.titleLabel.font = GAME_FONT_WITH_SIZE(CGRectGetHeight(buttonBounds)/4.0f);
                button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                button.titleLabel.textAlignment = NSTextAlignmentCenter;
                [button setTitle:@"NO\nADS"
                        forState:UIControlStateNormal];
                [button setTitleColor:[UIColor flatEmeraldColor]
                             forState:UIControlStateNormal];
                [button addTarget:[HDAppDelegate sharedDelegate]
                           action:@selector(removeAds:)
                 forControlEvents:UIControlEventTouchUpInside];
                break;
            case 1:
                // Present Share View Controller
                [button setBackgroundImage:[UIImage imageNamed:@"Share"]
                                  forState:UIControlStateNormal];
                [button addTarget:[HDAppDelegate sharedDelegate]
                           action:@selector(presentActivityViewController:)
                 forControlEvents:UIControlEventTouchUpInside];
                break;
            case 2:
                // Present Game Center Leaderboards
                [button setBackgroundImage:[UIImage imageNamed:@"Leaderboard"]
                                  forState:UIControlStateNormal];
                [button addTarget:[HDAppDelegate sharedDelegate]
                           action:@selector(presentLeaderboardViewController:)
                 forControlEvents:UIControlEventTouchUpInside];
                break;
            case 3:
                // Open AppStore to rate application
                [button setBackgroundImage:[UIImage imageNamed:@"Star"]
                                  forState:UIControlStateNormal];
                [button addTarget:[HDAppDelegate sharedDelegate]
                           action:@selector(rateThisApp:)
                 forControlEvents:UIControlEventTouchUpInside];
                break;
            case 4:
                // Reverse Controls
                button.selected = [HDSettingsManager sharedManager].reversed;
                button.titleLabel.font = GAME_FONT_WITH_SIZE(CGRectGetHeight(buttonBounds)/5.15f);
                button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                button.titleLabel.textAlignment = NSTextAlignmentCenter;
                [button setTitleColor:[UIColor flatEmeraldColor] forState:UIControlStateNormal];
                [button setTitleColor:[UIColor flatEmeraldColor] forState:UIControlStateSelected];
                [button setTitle:@"DEFAULT"
                        forState:UIControlStateNormal];
                [button setTitle:@"REVERSE"
                        forState:UIControlStateSelected];
                [button addTarget:self
                           action:@selector(_reverseControl:)
                 forControlEvents:UIControlEventTouchUpInside];
                break;
            default:
                break;
        }
    }
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
            [self _updateHighscore];
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

- (void)_updateHighscore {
    
    HDPointsManager *manager = [HDPointsManager sharedManager];
    
    NSUInteger points = [HDSettingsManager sharedManager].reversed ? manager.reversedHighScore : manager.highScore;
    
    _introView.highScoreLbl.attributedText = [_introView attributedStringFromHighscore:points];
    [_introView.highScoreLbl sizeToFit];
    _introView.highScoreLbl.center = CGPointMake(CGRectGetMidX(_containerView.bounds), _introView.highScoreLbl.center.y);
    
    [UIView transitionWithView:_introView.highScoreLbl
                      duration:.5f
                       options:UIViewAnimationOptionTransitionFlipFromTop
                    animations:nil
                    completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!_isContainerVisible) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage backgroundImage]];
        [self.view insertSubview:imageView atIndex:0];
    }
    
    [self _updateHighscore];
    
    const NSInteger maxPointsInterval = 25;
    if ([[HDPointsManager sharedManager] score] > maxPointsInterval) {
        [_introView.scoreLbl countTo:[[HDPointsManager sharedManager] score]
                                from:[[HDPointsManager sharedManager] score] - maxPointsInterval
                            duration:.5f];
        return;
    }
    
    // Update score labels to reflect past game
    [_introView.scoreLbl countTo:[[HDPointsManager sharedManager] score]
                            from:0
                        duration:.500f];
}

- (BOOL)_rollTheDice {
   return ((arc4random() % 2 == 1) && (arc4random() % 2 == 1));
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
            UIImageView *imageView = [[self.view subviews] firstObject];
            [UIView animateWithDuration:1.0f animations:^{
                CGPoint position = imageView.center;
                position.y = -CGRectGetMidY(imageView.bounds);
                imageView.center = position;
            } completion:^(BOOL finished) {
                [imageView removeFromSuperview];
            }];
        }];
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isDragging || scrollView.isDecelerating){
        NSInteger page = floor((scrollView.contentOffset.x - CGRectGetWidth(scrollView.bounds)/2)/CGRectGetWidth(scrollView.bounds)) + 1;
        [_pageControl setCurrentPage:MIN(page, _pageControl.numberOfPages - 1)];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // When scrolling begins, disable touch events
    _containerView.userInteractionEnabled = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // When scrolling Ends, enable touch events
    _containerView.userInteractionEnabled = NO;
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

#pragma mark - Actions

- (IBAction)_toggleSound:(HDSwitch *)sender {
    [[HDSettingsManager sharedManager] setSound:![[HDSettingsManager sharedManager] sound]];
}

- (IBAction)_toggleMusic:(HDSwitch *)sender {
    [[HDSettingsManager sharedManager] setMusic:![[HDSettingsManager sharedManager] music]];
}

@end
