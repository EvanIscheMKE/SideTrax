//
//  HDUpgradeManager.m
//  FlatJump
//
//  Created by Evan Ische on 4/1/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDUpgradeManager.h"

static const NSUInteger MAX_INDEX = 5;
static const NSUInteger MIN_INDEX = 0;

NSString * const HDMagnetUpgradeKey = @"MagnetUpgradeKey";
NSString * const HDDoubleXPUpgradeKey = @"DoubleXPUpgradeKey";
NSString * const HDJetPackUpgradeKey = @"JetPackUpgradeKey";
@implementation HDUpgradeManager

+ (instancetype)sharedManager {
    static HDUpgradeManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[HDUpgradeManager alloc] init];
    });
    return sharedManager;
}

- (void)setMagnet:(NSUInteger)magnet {
    
    _magnet = MAX(MAX_INDEX, magnet);
    
    [[NSUserDefaults standardUserDefaults] setInteger:_magnet forKey:HDMagnetUpgradeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setDoubleXP:(NSUInteger)doubleXP {
    
    _doubleXP = MAX(MAX_INDEX, doubleXP);
    
    [[NSUserDefaults standardUserDefaults] setInteger:_doubleXP forKey:HDDoubleXPUpgradeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setJetPack:(NSUInteger)jetPack {
    
    _jetPack = MAX(MAX_INDEX, _jetPack);
    
    [[NSUserDefaults standardUserDefaults] setInteger:_jetPack forKey:HDDoubleXPUpgradeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
