//
//  HDGameViewController.m
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import SpriteKit;

#import "HDGameScene.h"
#import "HDGridManager.h"
#import "UIColor+FlatColors.h"
#import "HDGameViewController.h"

@interface HDGameViewController ()
@property (nonatomic, strong) HDGameScene *scene;
@property (nonatomic, strong) HDGridManager *gridManager;
@end

@implementation HDGameViewController {
    __weak SKView *_skView;
}

- (void)loadView {
    self.view = [[SKView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _skView = (SKView *)self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gridManager = [[HDGridManager alloc] initWithFileName:@"FilENAME"];
    [self.gridManager loadGridWithCallback:^{
        [self _setup];
    }];
}

- (void)_setup {
    if (!_skView.scene) {
        self.scene = [HDGameScene sceneWithSize:_skView.bounds.size];
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

@end
