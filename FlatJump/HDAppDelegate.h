//
//  HDAppDelegate.h
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BARRIER_WIDTH      ceilf(14 * TRANSFORM_SCALE_X)

#define TRANSFORM_SCALE_X [UIScreen mainScreen].bounds.size.width  / 375.0f

#define COLUMN_WIDTH       floorf((([UIScreen mainScreen].bounds.size.width) - (BARRIER_WIDTH * 2))/5)

#define GAME_FONT_WITH_SIZE(x) [UIFont fontWithName:@"KimberleyBl-Regular" size:x]

typedef NS_OPTIONS(int8_t, HDDirectionState) {
    HDDirectionStateRegular = 0,
    HDDirectionStateReversed = 1,
    HDDirectionStateNone = 2
};

extern NSString * const HDMenuClicked;
@interface HDAppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow *window;
+ (HDAppDelegate *)sharedDelegate;
- (IBAction)restoreIAP:(id)sender;
- (IBAction)rateThisApp:(id)sender;
- (IBAction)removeAds:(id)sender;
- (IBAction)presentActivityViewController:(id)sender;
- (IBAction)presentLeaderboardViewController:(id)sender;
- (void)presentGameViewController;
- (void)returnHome;
@end

