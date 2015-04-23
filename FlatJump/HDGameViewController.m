//
//  HDGameViewController.m
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import iAd;
@import SpriteKit;

#import "HDButton.h"
#import "HDGameScene.h"
#import "HDGridManager.h"
#import "UIColor+FlatColors.h"
#import "HDJumperIAdHelper.h"
#import "HDGameViewController.h"
#import "HDSoundManager.h"
#import "HDSettingsManager.h"

@interface HDGameViewController () <UITextFieldDelegate>
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, strong) HDGameScene *scene;
@property (nonatomic, strong) HDGridManager *gridManager;
@end

@implementation HDGameViewController {
    __weak SKView *_skView;
    UIButton *_pauseBtn;
    
    // REMOVE BEFORE SUBMITTING
    BOOL keyboardShown;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification  object:nil];
}

- (void)loadView {
    self.view = [[SKView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _skView = (SKView *)self.view;
    _skView.ignoresSiblingOrder = YES;
    _skView.multipleTouchEnabled = NO;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
    
    UITextView *hiddenTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [hiddenTextView setHidden:YES];
    hiddenTextView.text = @"aa";
    hiddenTextView.delegate = self;
    hiddenTextView.selectedRange = NSMakeRange(1, 0);
    [self.view addSubview:hiddenTextView];
    
    [hiddenTextView becomeFirstResponder];
    if (keyboardShown)
        [hiddenTextView resignFirstResponder];
    
    self.gridManager = [[HDGridManager alloc] init];
    self.gridManager.range = NSMakeRange(0, 500); // Inital 100 rows
    [self.gridManager loadGridFromRangeWithCallback:nil];
    
    // Check if the user has purchased remove ads IAP, if not
    if (![[NSUserDefaults standardUserDefaults] boolForKey:IAPremoveAdsProductIdentifier]) {
        // prepare InterstitalAd
        [UIViewController prepareInterstitialAds];
    }
    
    // Called when apps sent to the background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    // Called when application moves back to foreground
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    _pauseBtn = [self _pauseBtn];
    _pauseBtn.center = CGPointMake(CGRectGetMidY(_pauseBtn.bounds) + 5.0f,
                                  CGRectGetHeight(self.view.bounds) + CGRectGetMidY(_pauseBtn.bounds));
    [self.view addSubview:_pauseBtn];
}

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
    if (!_skView.scene) {
        
        self.scene = [HDGameScene sceneWithSize:_skView.bounds.size];
        self.scene.direction = [HDSettingsManager sharedManager].reversed;
        self.scene.gridManager = self.gridManager;
        self.scene.scaleMode = SKSceneScaleModeAspectFill;
        [_skView presentScene:self.scene];
        [self.scene layoutChildrenNode];
        
        __weak typeof(self) weakSelf = self;
       dispatch_block_t update = ^{
            [weakSelf.gridManager loadGridFromRangeWithCallback:nil];
        };
        self.scene.updateDatabase = update;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:.300f
                     animations:^{
                         CGPoint position = _pauseBtn.center;
                         position.y = CGRectGetHeight(self.view.bounds) - CGRectGetMidY(_pauseBtn.bounds) - 5.0f;
                         _pauseBtn.center = position;
                     }];
}

- (void)setPaused:(BOOL)paused {
    
    _paused = paused;
    if (paused) {
        
        //
        _skView.paused = YES;
        
        //
        self.scene.paused = YES;
        
        //
        _pauseBtn.selected = YES;
        
        //
        [[HDSoundManager sharedManager] setPlayLoop:NO];
        
    } else {
        
        //
        _skView.paused = NO;
        
        //
        self.scene.paused = NO;
        
        //
        _pauseBtn.selected = NO;
        
        //
        [[HDSoundManager sharedManager] setPlayLoop:YES];
        
    }
}

- (IBAction)_togglePausedState:(HDButton *)sender {
    self.paused = !self.paused;
}

#pragma mark - NSNotificationCenter

- (void)_applicationDidBecomeActive:(NSNotification *)notification {
    // Pause it again because it gets unpaused for some odd reason
    self.paused = YES;
}

- (void)_applicationWillResignActive:(NSNotification *)notification {
    
    // Pause the Scene
    self.paused = YES;
    
    // Check if the user has purchased remove ads IAP
    if (![[NSUserDefaults standardUserDefaults] boolForKey:IAPremoveAdsProductIdentifier]) {
        // If they haven't present banner Ad
        [self requestInterstitialAdPresentation];
    }
}

#pragma mark - Convenice buttons

- (UIButton *)_pauseBtn {
    
    UIImage *paused = [UIImage imageNamed:@"Paused-Small"];
    UIImage *play   = [UIImage imageNamed:@"Play-Small"];
    
    CGRect bounds = CGRectMake(0.0f, 0.0f, paused.size.width, paused.size.width);
    HDButton *pauseBtn = [HDButton buttonWithType:UIButtonTypeCustom];
    pauseBtn.frame = bounds;
    [pauseBtn addSoundNamed:HDMenuClicked forControlEvent:UIControlEventTouchUpInside];
    [pauseBtn setImage:paused forState:UIControlStateNormal];
    [pauseBtn setImage:play forState:UIControlStateSelected];
    [pauseBtn addTarget:self action:@selector(_togglePausedState:) forControlEvents:UIControlEventTouchUpInside];
    
    return pauseBtn;
}




- (void)textViewDidChangeSelection:(UITextView *)textView {
    
    /******TEXT FIELD CARET CHANGED******/
    
    if (textView.selectedRange.location == 2) {
        
        [self.scene moveRight];
        NSLog(@"down");
        // End of text - down arrow pressed
        textView.selectedRange = NSMakeRange(1, 0);
        
    } else if (textView.selectedRange.location == 0) {
        
        [self.scene moveLeft];
        NSLog(@"up");
        // Beginning of text - up arrow pressed
        textView.selectedRange = NSMakeRange(1, 0);
        
    }
    
    //  Check if text has changed and replace with original
    if (![textView.text isEqualToString:@"aa"])
        textView.text = @"aa";
}

- (void)keyboardWillAppear:(NSNotification *)aNotification {
    keyboardShown = YES;
}

- (void)keyboardWillDisappear:(NSNotification *)aNotification {
    keyboardShown = NO;
}









@end
