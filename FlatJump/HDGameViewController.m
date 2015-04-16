//
//  HDGameViewController.m
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import iAd;
@import SpriteKit;

#import "HDGameScene.h"
#import "HDGridManager.h"
#import "UIColor+FlatColors.h"
#import "HDJumperIAdHelper.h"
#import "HDGameViewController.h"
#import "HDSoundManager.h"
#import "HDSettingsManager.h"

@interface HDGameViewController ()
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, strong) HDGameScene *scene;
@property (nonatomic, strong) HDGridManager *gridManager;
@end

@implementation HDGameViewController {
    __weak SKView *_skView;
}

- (void)dealloc {
    
    // Remove observers 
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HDLevelLayoutNotificationKey              object:nil];
}

- (void)loadView {
    self.view = [[SKView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _skView = (SKView *)self.view;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.gridManager = [[HDGridManager alloc] init];
    self.gridManager.range = NSMakeRange(0, NumberOfRows); // Inital 12 rows, layout more as needed
    [self.gridManager loadGridFromRangeWithCallback:nil];
    
    // Check if the user has purchased remove ads IAP, if not
    if (![[NSUserDefaults standardUserDefaults] boolForKey:IAPremoveAdsProductIdentifier]) {
        // prepare InterstitalAd
        [UIViewController prepareInterstitialAds];
    }
    
    // Called when more levels are needed.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_layoutAdditionalLevels:)
                                                 name:HDLevelLayoutNotificationKey
                                               object:nil];
    
    // Called when apps sent to the background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    // Called when application opens
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // Check if self.view's scene has been presented, if not, present it
    if (!_skView.scene) {
        self.scene = [HDGameScene sceneWithSize:_skView.bounds.size];
        self.scene.direction = [HDSettingsManager sharedManager].reversed;
        self.scene.gridManager = self.gridManager;
        self.scene.scaleMode = SKSceneScaleModeAspectFill;
        [_skView presentScene:self.scene];
        [self.scene layoutChildrenNode];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSNotificationCenter

- (void)_layoutAdditionalLevels:(NSNotification *)notification {
    
    // load an additional "NumberOfRows"
    [self.gridManager loadGridFromRangeWithCallback:^{
        if (self.scene) {
            // Once the rows are plotted, lay them out in the scene
        //    [self.scene layoutChildrenNode];
        }
    }];
}

- (void)_applicationDidBecomeActive:(NSNotification *)notification {
    // Unpause the Scene
    self.paused = NO;
    self.scene.view.paused = self.paused;
    [[HDSoundManager sharedManager] setPlayLoop:YES];
}

- (void)_applicationWillResignActive:(NSNotification *)notification {
    
    // Pause the Scene
    self.paused = YES;
    self.scene.view.paused = self.paused;
    
    // Check if the user has purchased remove ads IAP
    if (![[NSUserDefaults standardUserDefaults] boolForKey:IAPremoveAdsProductIdentifier]) {
        // If they haven't present banner Ad
        [self requestInterstitialAdPresentation];
    }
}


@end
