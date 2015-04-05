//
//  HDAppDelegate.m
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDAppDelegate.h"
#import "HDIntroViewController.h"
#import "HDGameViewController.h"
#import "HDCompletionViewController.h"

@interface HDAppDelegate ()
@property (nonatomic, strong) UINavigationController *navigationController;
@end

@implementation HDAppDelegate

+ (HDAppDelegate *)sharedDelegate {
    return [[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    application.statusBarHidden = YES;
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:[HDIntroViewController new]];
    self.navigationController.navigationBarHidden = YES;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)presentCompletionViewControllerWithMovesCompleted:(NSUInteger)moves {
    HDCompletionViewController *viewController = [[HDCompletionViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)presentGameViewController {
    
  //  [self presentCompletionViewControllerWithMovesCompleted:50];
    HDGameViewController *viewController = [[HDGameViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES]; 
}

@end
