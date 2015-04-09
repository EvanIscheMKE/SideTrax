//
//  HDSettingsManager.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/18/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDSettingsManager : NSObject
@property (nonatomic, assign) BOOL sound;
@property (nonatomic, assign) BOOL music;
+ (HDSettingsManager *)sharedManager;
- (void)configureSettingsForFirstRun;
@end
