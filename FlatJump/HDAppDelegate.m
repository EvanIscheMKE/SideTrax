//
//  HDAppDelegate.m
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import GameKit;
@import StoreKit;

#import "HDAppDelegate.h"
#import "HDJumperIAdHelper.h"
#import "HDIntroViewController.h"
#import "HDGameViewController.h"
#import "HDCompletionViewController.h"
#import "HDGameCenterManager.h"

@interface HDAppDelegate ()<GKGameCenterControllerDelegate>
@property (nonatomic, strong) UINavigationController *navigationController;
@end

@implementation HDAppDelegate

+ (HDAppDelegate *)sharedDelegate {
    return (HDAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    application.statusBarHidden = YES;
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:[HDIntroViewController new]];
    self.navigationController.navigationBarHidden = YES;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    [[HDGameCenterManager sharedManager] authenticateGameCenter];
    
    return YES;
}

#pragma mark - View Hieacry

- (void)presentCompletionViewControllerWithMovesCompleted:(NSUInteger)moves {
    HDCompletionViewController *viewController = [[HDCompletionViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)presentGameViewController {
    
    [self presentCompletionViewControllerWithMovesCompleted:50];
   //HDGameViewController *viewController = [[HDGameViewController alloc] init];
   //[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UIActivityController 

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
    controller.leaderboardIdentifier = @"YOLO";
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

@end
