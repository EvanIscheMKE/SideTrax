//
//  HDAppDelegate.m
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import GameKit;
@import StoreKit;

#define TRACKS_APPLICATION_ID 982812027

#import "HDAppDelegate.h"
#import "HDJumperIAdHelper.h"
#import "HDIntroViewController.h"
#import "HDGameViewController.h"
#import "HDGameCenterManager.h"
#import "HDSettingsManager.h"
#import "HDSoundManager.h"

NSString * const HDFirstRunKey = @"first";
NSString * const HDMenuClicked = @"menuClicked.wav";
NSString * const iOS8AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%d";
@interface HDAppDelegate ()<GKGameCenterControllerDelegate>
@end

@implementation HDAppDelegate

+ (HDAppDelegate *)sharedDelegate {
    return (HDAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    application.statusBarHidden = YES;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [HDIntroViewController new];
    [self.window makeKeyAndVisible];
    
    [[HDGameCenterManager sharedManager] authenticateGameCenter];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:HDFirstRunKey]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HDFirstRunKey];
        [[HDSettingsManager sharedManager] configureSettingsForFirstRun];
    }
    
    [[HDSoundManager sharedManager] preloadLoopWithName:HDMusicLoopKey];
  
    return YES;
}

#pragma mark - View Hierarchy

- (void)returnHome {
    [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)presentGameViewController {
   HDGameViewController *viewController = [[HDGameViewController alloc] init];
   [self.window.rootViewController presentViewController:viewController animated:NO completion:nil];
}

#pragma mark - UIActivityController 

- (IBAction)rateThisApp:(id)sender {
    
    NSURL *rateThisApp = [NSURL URLWithString:[NSString stringWithFormat:iOS8AppStoreURLFormat,TRACKS_APPLICATION_ID]];
    if ([[UIApplication sharedApplication] canOpenURL:rateThisApp]) {
        [[UIApplication sharedApplication] openURL:rateThisApp];
    }
}

- (IBAction)presentActivityViewController:(id)sender {
    
    NSArray *activityItems = @[[self _frontViewControllerScreenShot]];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                                     applicationActivities:@[]];
    activityController.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                                                 UIActivityTypePrint,
                                                 UIActivityTypeCopyToPasteboard,
                                                 UIActivityTypeAssignToContact,
                                                 UIActivityTypeAddToReadingList,
                                                 UIActivityTypePostToVimeo,
                                                 UIActivityTypePostToTencentWeibo,
                                                 UIActivityTypeAirDrop];
    
    [self.window.rootViewController presentViewController:activityController animated:YES completion:nil];
}

- (UIImage *)_frontViewControllerScreenShot {
    
    UIGraphicsBeginImageContextWithOptions(self.window.bounds.size, YES, 0);
    [self.window.rootViewController.view drawViewHierarchyInRect:self.window.bounds afterScreenUpdates:YES];
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return screenShot;
}

#pragma mark - <GKGameCenterControllerDelegate>

- (IBAction)presentLeaderboardViewController:(id)sender {
    
    GKGameCenterViewController *controller = [[GKGameCenterViewController alloc] init];
    controller.gameCenterDelegate    = self;
    controller.leaderboardIdentifier = HDNormalLeaderboardKey;
    controller.viewState             = GKGameCenterViewControllerStateLeaderboards;
    [self.window.rootViewController presentViewController:controller animated:YES completion:nil];
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IAP

- (IBAction)restoreIAP:(id)sender {
    
    [[HDJumperIAdHelper sharedHelper] restoreCompletedTransactions];
}

- (IBAction)removeAds:(id)sender {
    
    [[HDJumperIAdHelper sharedHelper] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        
        if (success && products.count) {
            SKProduct *removeAdsProduct = nil;
            for (SKProduct *product in products) {
                if ([product.productIdentifier isEqualToString:IAPremoveAdsProductIdentifier]) {
                    removeAdsProduct = product;
                    break;
                }
            }
            
            if (!removeAdsProduct) {
                return;
            }
            
            BOOL purchased = [[HDJumperIAdHelper sharedHelper] productPurchased:removeAdsProduct.productIdentifier];
            if (!purchased) {
                [[HDJumperIAdHelper sharedHelper] buyProduct:removeAdsProduct];
            }
        }
    }];
}

#pragma mark - <UIApplicationDelegate>

- (void)applicationWillResignActive:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[HDSoundManager sharedManager] stopAudio];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[HDSoundManager sharedManager] startAudio];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[HDSoundManager sharedManager] stopAudio];
}

@end
