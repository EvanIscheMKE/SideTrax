//
//  HDSwitch.h
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/29/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDSwitch : UIControl
@property (nonatomic, getter=isOn, assign) BOOL on;
- (instancetype)initWithOnColor:(UIColor *)onColor offColor:(UIColor *)offColor;
- (instancetype)initWithFrame:(CGRect)frame onColor:(UIColor *)onColor offColor:(UIColor *)offColor;
@end
