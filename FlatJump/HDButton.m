//
//  UIButton+SoundAdditions.m
//  FlatJump
//
//  Created by Evan Ische on 4/15/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import AVFoundation;

#import "HDSettingsManager.h"
#import "HDButton.h"

NS_INLINE BOOL isFlagSet(UIControlEvents events, UIControlEvents event) {
    return (events & event) != 0;
}

@implementation HDButton {
    NSMutableDictionary *_soundDictionary;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _soundDictionary = [NSMutableDictionary new];
    }
    return self;
}

- (void)addSoundNamed:(NSString *)filename forControlEvent:(UIControlEvents)controlEvent {
    
    NSParameterAssert(filename);
    
    [self addTarget:self action:@selector(_sendActionsForControlEvents:) forControlEvents:controlEvent];
    
    NSNumber *eventKey = @(controlEvent);
    AVAudioPlayer *oldSound = [_soundDictionary objectForKey:eventKey];
    if (oldSound) {
        [self removeTarget:oldSound action:@selector(play) forControlEvents:controlEvent];
    }
    
    NSString *soundPathURL = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
    
    NSError *error = nil;
    AVAudioPlayer *tapSound = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:soundPathURL]
                                                                     error:&error];
    if (!tapSound) {
        NSLog(@"SELECTOR: %@, ERROR: %@", NSStringFromSelector(_cmd), error);
        return;
    }
    
    [_soundDictionary setObject:tapSound forKey:eventKey];
    [tapSound prepareToPlay];
}

- (void)_sendActionsForControlEvents:(UIControlEvents)controlEvents {
    
    if (![HDSettingsManager sharedManager].sound) {
        return;
    }
    
    [_soundDictionary enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, AVAudioPlayer *player, BOOL *stop) {
        UIControlEvents event = [key unsignedIntegerValue];
        if (isFlagSet(controlEvents,event)) {
            [player play];
        }
    }];
}



@end
