//
//  HDAppDelegate.h
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDAppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;
+ (HDAppDelegate *)sharedDelegate;

- (IBAction)restoreIAP:(id)sender;
- (IBAction)removeAds:(id)sender;
- (IBAction)presentActivityViewController:(id)sender;
- (IBAction)presentLeaderboardViewController:(id)sender;

- (void)presentCompletionViewControllerWithMovesCompleted:(NSUInteger)moves;
- (void)presentGameViewController;
@end

