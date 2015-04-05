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
- (void)presentCompletionViewControllerWithMovesCompleted:(NSUInteger)moves;
- (void)presentGameViewController;
@end

