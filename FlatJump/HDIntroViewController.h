//
//  HDIntroViewController.h
//  FlatJump
//
//  Created by Evan Ische on 4/1/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import iAd;
@import UIKit;

@class HDSwitch;
@class HDButton;
@class HDCounterLabel;
@interface HDSettingsView : UIView
@property (nonatomic, strong) HDSwitch *soundSwitch;
@property (nonatomic, strong) HDSwitch *musicSwitch;
@property (nonatomic, strong) HDButton *restoreBtn;
@end

@interface HDIntroView : UIView
@property (nonatomic, strong) HDButton *reverseBtn;
@property (nonatomic, strong) HDButton *playBtn;
@property (nonatomic, strong) UILabel *highScoreLbl;
@property (nonatomic, strong) HDCounterLabel *scoreLbl;
- (NSAttributedString *)attributedStringFromHighscore:(NSUInteger)highscore;
@end

@interface HDIntroViewController : UIViewController<ADBannerViewDelegate>
@end
