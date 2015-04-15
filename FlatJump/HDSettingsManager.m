//
//  HDSettingsManager.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/18/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDSettingsManager.h"

NSString * const HDSoundKey = @"sound";
NSString * const HDMusicKey = @"music";
@implementation HDSettingsManager

#pragma mark - Configure

- (void)configureSettingsForFirstRun {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HDSoundKey];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HDMusicKey];
    self.sound = [[NSUserDefaults standardUserDefaults] boolForKey:HDSoundKey];
    self.music = [[NSUserDefaults standardUserDefaults] boolForKey:HDMusicKey];
}

#pragma mark - Initalize

- (instancetype)init {
    if (self = [super init]) {
        self.sound = [[NSUserDefaults standardUserDefaults] boolForKey:HDSoundKey];
        self.music = [[NSUserDefaults standardUserDefaults] boolForKey:HDMusicKey];
    }
    return self;
}

+ (HDSettingsManager *)sharedManager {
    static HDSettingsManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HDSettingsManager alloc] init];
    });
    return manager;
}

#pragma mark - Override Setters

- (void)setSound:(BOOL)sound {
    
    _sound = sound;
    if (_sound != [[NSUserDefaults standardUserDefaults] boolForKey:HDSoundKey]) {
        [[NSUserDefaults standardUserDefaults] setBool:_sound forKey:HDSoundKey];
    }
}

- (void)setMusic:(BOOL)music {
    
    _music = music;
    if (_music != [[NSUserDefaults standardUserDefaults] boolForKey:HDMusicKey]) {
        [[NSUserDefaults standardUserDefaults] setBool:_music forKey:HDMusicKey];
    }
}

@end
