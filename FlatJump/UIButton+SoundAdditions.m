//
//  UIButton+SoundAdditions.m
//  FlatJump
//
//  Created by Evan Ische on 4/15/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import AVFoundation;

#import "UIButton+SoundAdditions.h"
#import <objc/runtime.h>

static char * const HDSoundDictionaryKey = "key";
@implementation UIButton (SoundAdditions)

- (void)addSoundNamed:(NSString *)filename forControlEvent:(UIControlEvents)controlEvent {
    
    NSParameterAssert(filename);
    
    NSString *eventKey = [NSString stringWithFormat:@"%tu", controlEvent];
    AVAudioPlayer *oldSound = [[self soundDictionary] objectForKey:eventKey];
    if (oldSound) {
          [self removeTarget:oldSound action:@selector(play) forControlEvents:controlEvent];
    }
    
    NSString *soundPathURL = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];

    NSError *error = nil;
    AVAudioPlayer *tapSound = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:soundPathURL]
                                                                     error:&error];
    if (!tapSound) {
        NSLog(@"SELECTOR: %@, ERROR: %@", NSStringFromSelector(_cmd),error);
        return;
    }
    [[self soundDictionary] setObject:tapSound forKey:eventKey];
    [tapSound prepareToPlay];
    
    [self addTarget:tapSound action:@selector(play) forControlEvents:controlEvent];
}

- (void)setSoundDictionary:(NSMutableDictionary *)soundDictionary {
    objc_setAssociatedObject(self, HDSoundDictionaryKey, soundDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)soundDictionary {
    
    NSMutableDictionary *sounds = objc_getAssociatedObject(self, HDSoundDictionaryKey);
    
    if (!sounds) {
        sounds = [[NSMutableDictionary alloc] initWithCapacity:2];
        [self setSoundDictionary:sounds];
    }
    return sounds;
}

@end
