//
//  HDGameScene.m
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import AVFoundation;
@import AudioToolbox;

#import "HDGameScene.h"
#import "HDSoundManager.h"
#import "SKColor+HDColor.h"
#import "UIColor+FlatColors.h"
#import "HDPointsManager.h"
#import "HDObjectNode.h"
#import "HDBarrierNode.h"
#import "HDGridManager.h"
#import "HDAppDelegate.h"
#import "HDSettingsManager.h"
#import "SKEmitterNode+HDEmitterAdditions.h"
#import "HDGameCenterManager.h"
#import "HDHelper.h"
#import "UIImage+ImageAdditions.h"

typedef NS_OPTIONS(NSUInteger, HDCollisionCategory) {
    HDCollisionCategoryNone     = 0x0,      // 00000000
    HDCollisionCategoryPlayer   = 0x1 << 0, // 00000001
    HDCollisionCategoryPlatform = 0x1 << 1, // 00000010
};

typedef NS_OPTIONS(NSUInteger, HDBarrierType){
    HDBarrierTypeHorizontal  = 0x0,      //00000000
    HDBarrierTypeVertical    = 0x1 << 0, //00000001
    HDBarrierTypeEndPiece    = 0x1 << 1, //00000010
    HDBarrierTypeNone        = 0x1 << 2  //00000100
};

static NSString * const HDSoundKey = @"HDSoundKey";

NSString * const HDPlayerKey  = @"HDPlayerKey";
NSString * const HDBarrierKey = @"HDBarrierKey";
NSString * const HDLabelKey   = @"HDLabelKey";
NSString * const HDEmitterKey = @"HDEmitterKey";

@interface HDGameScene ()<SKPhysicsContactDelegate>
@property (nonatomic, strong) SKAction *whoosh;
@property (nonatomic, strong) SKAction *explosion;
@end

@implementation HDGameScene {
    
    BOOL _previousRowDisplayedBorders;
    
    CGFloat _maxPlayerPositionY;
    CGFloat _barrierWidth;
    CGFloat _columnWidth;
    CGFloat _rowHeight;
    CGFloat _gameSpeed;
    CGFloat _maxSpeed;
    
    SKNode *_player;
    SKNode *_objectLayerNode;
    SKNode *_hudLayerNode;
    SKNode *_scoreNode;
    
    SKSpriteNode *_backgroundNode;
    
    SKLabelNode *_scoreLblNode;
    SKLabelNode *_instructionNode;
    
    NSMutableDictionary *_textureDictionary;
    
    NSRange _range;

    NSInteger  _currentRow;
    NSUInteger _score;
    
    BOOL _gameOver;
    BOOL _animating;
    
    NSTimeInterval _lastTimerStamp;
    NSTimeInterval _lastPointStamp;
}

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [UIColor flatSTBackgroundColor];
        self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
        self.physicsWorld.contactDelegate = self;
        
        _score      = 0;
        _currentRow = 2;
        _gameSpeed  = 270 * TRANSFORM_SCALE_X;
        _maxSpeed   = _gameSpeed + 35;
        _range      = NSMakeRange(0, 14);
        
        _maxPlayerPositionY = size.height/3.0f;
        _previousRowDisplayedBorders = NO;
        
        _barrierWidth = [HDHelper universalBarrierWidth];
        _rowHeight    = [HDHelper universalRowHeight];
        _columnWidth  = [HDHelper universalColumnWidth];
        
        NSLog(@"COLUMN WIDTH:%f",_columnWidth);
        
        _textureDictionary = [NSMutableDictionary dictionary];
        _textureDictionary[@"rightArrow"] = [SKTexture textureWithImageNamed:@"RightArrow"];
        _textureDictionary[@"leftArrow"]  = [SKTexture textureWithImageNamed:@"LeftArrow"];
        _textureDictionary[@"vertical"]   = [SKTexture textureWithImage:[UIImage shadowedBarrier:[HDHelper verticalBarrierSize]]];
        _textureDictionary[@"horizontal"] = [SKTexture textureWithImage:[UIImage shadowedBarrier:CGSizeMake(_columnWidth, _barrierWidth)]];
        _textureDictionary[@"endpiece"]   = [SKTexture textureWithImage:[UIImage shadowedBarrier:CGSizeMake([HDHelper verticalBarrierWidth], _barrierWidth)]];
    
        self.whoosh    = [SKAction playSoundFileNamed:@"Whoosh.wav"    waitForCompletion:NO];
        self.explosion = [SKAction playSoundFileNamed:@"Explosion.wav" waitForCompletion:NO];
        
        _backgroundNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:[UIImage backgroundImage]]];
        _backgroundNode.position = CGPointMake(size.width/2, size.height + size.height/2);
        [self addChild:_backgroundNode];
        
        _objectLayerNode = [SKNode node];
        [self addChild:_objectLayerNode];
        
        _hudLayerNode = [SKNode node];
        [self addChild:_hudLayerNode];
        
        _scoreNode = [self _scoreNode];
        [_hudLayerNode addChild:_scoreNode];
        
        _player = [self _createPlayer];
        [_objectLayerNode addChild:_player];
        
        _instructionNode = [self _instructionNode];
        [_hudLayerNode addChild:_instructionNode];
        
    }
    return self;
}

- (void)didMoveToView:(SKView *)view {
    if (view != nil) {
        
        SKAction *fadeIn  = [SKAction fadeInWithDuration:.200f];
        SKAction *wait    = [SKAction waitForDuration:1.5f];
        SKAction *fadeOut = [SKAction fadeOutWithDuration:.200f];
        [_instructionNode runAction:[SKAction sequence:@[fadeIn, wait, fadeOut]] completion:^{
            [_instructionNode removeFromParent];
            _instructionNode = nil;
        }];
        
        [_backgroundNode runAction:[SKAction moveToY:self.size.height/2 duration:.3f] completion:^{
            [_backgroundNode removeAllActions];
        }];
    }
}

- (void)_layoutIndicatorsForDirection:(HDArrowDirection)direction row:(NSUInteger)row {
    
    for (NSUInteger i = 0; i < 2; i++) {
        
        CGFloat positionX = (i == 0) ? self.size.width/2 - _columnWidth : self.size.width/2  + _columnWidth;
        CGPoint position = CGPointMake(positionX, _rowHeight*row + _rowHeight/2);
        HDObjectNode *objectNode = [self _createIndicatorAtPosition:position direction:direction];
        [_objectLayerNode addChild:objectNode];
    }
}

- (BOOL)_layoutBorders:(BOOL)displayBorders shadow:(BOOL)shadow row:(NSUInteger)row {
    
    CGSize size = [HDHelper verticalBarrierSize];
    if (!displayBorders) {
        size.height = _barrierWidth;
    }
    
    for (NSUInteger i = 0; i < 2; i++) {
        if (displayBorders) {
            // Position Borders on top of rows row + barrier height / 2
            const CGFloat positionX = (i == 0) ? size.width/2 : self.size.width - size.width/2;
            const CGPoint position = CGPointMake(positionX, _rowHeight*row - _barrierWidth/2 + size.height/2);
            HDBarrierNode *node = [self _createBarrierAtPosition:position type:HDBarrierTypeVertical size:size shadow:shadow];
            [_objectLayerNode addChild:node];
            continue;
        }
        // End Pieces for Rows inbetween rows with no borders
        const CGFloat positionX = (i == 0) ? size.width/2 : self.size.width - size.width/2;
        const CGPoint position = CGPointMake(positionX, _rowHeight*row);
        HDBarrierNode *node = [self _createBarrierAtPosition:position type:HDBarrierTypeEndPiece size:size shadow:shadow];
        [_objectLayerNode addChild:node];
    }
    return displayBorders;
}

- (void)layoutChildrenNode {
    
    for (NSInteger row = _range.location; row < _range.location + _range.length; row++) {
        
        NSDictionary *info = [self.gridManager infoForRow:row];
        if (!info) {
            continue;
        }
        
        BOOL displayBorder = [self _layoutBorders:[info[HDDisplayBorderKey] boolValue]
                                           shadow:!_previousRowDisplayedBorders
                                              row:row];
        if (!displayBorder) {
            _previousRowDisplayedBorders = NO;
            [self _layoutIndicatorsForDirection:[info[HDDirectionKey] unsignedIntegerValue] row:row];
        } else {
            _previousRowDisplayedBorders = YES;
        }
        
        if (row < startingRow) {
            continue;
        }
        
        for (NSInteger column = 0; column < NumberOfColumns; column++) {
            if ([info[HDColumnIndexKey] integerValue] != column) {
                HDBarrierNode *platform = [self _createBarrierAtPosition:[self _positionForRow:row column:column]
                                                                    type:HDBarrierTypeHorizontal
                                                                    size:CGSizeZero
                                                                  shadow:YES];
                [_objectLayerNode addChild:platform];
            }
        }
    }
    _range = NSMakeRange(_range.location + _range.length, 1);
}

- (void)update:(CFTimeInterval)currentTime {
    
    if (_gameOver) {
        return;
    }

    NSTimeInterval delta = (_lastTimerStamp == 0.0) ? 0.0 : currentTime - _lastTimerStamp;

    // Check for a large spike from the pause button
    if (delta > 0.017f) {
        delta = 0.017f;
    }
    
    CGPoint position = _player.position;
    position.y += delta * _gameSpeed;
    _player.position = position;
    
    const CGFloat rowHeight = _rowHeight;
    if (position.y > rowHeight * (startingRow - 1)) {
        NSUInteger points = (NSUInteger)(position.y/rowHeight - (startingRow - 1));
        if (points > _score) {
            
            NSLog(@"%f",currentTime-_lastPointStamp);
            
            _score = MAX(0, MIN(points, 5000));
            _scoreLblNode.text = [NSString stringWithFormat:@"%tu", _score];
             _gameSpeed = MIN(_maxSpeed, _gameSpeed + 1);
            [self layoutChildrenNode];
            
            _lastPointStamp = currentTime;
            if ((points % 480 == 0)) {
                if (self.updateDatabase) {
                    self.updateDatabase();
                }
            }
        }
    }
    
    [_objectLayerNode enumerateChildNodesWithName:HDBarrierKey usingBlock:^(SKNode *node, BOOL *stop) {
        BOOL remove = [(HDBarrierNode *)node checkNodePositionForRemoval:position.y];
        if (remove) {
            [node removeFromParent];
        }
    }];
    
    if (_player.position.y > _maxPlayerPositionY) {
        _objectLayerNode.position = CGPointMake(0.0f, -(position.y  - _maxPlayerPositionY));
    }
    _lastTimerStamp = currentTime;
}

- (void)_endGame {
    
    [HDPointsManager sharedManager].score = _score;
    [[HDPointsManager sharedManager] saveState];
    [[HDGameCenterManager sharedManager] reportLevelsCompleted:[HDPointsManager sharedManager].score
                                                        forKey:[HDGameCenterManager leaderboardIdentifierFromState:self.direction]];
    [[HDAppDelegate sharedDelegate] returnHome];
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_gameOver || _animating) {
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint position = [touch locationInNode:_objectLayerNode];
    
    BOOL reversed = (self.direction != HDDirectionStateRegular);
    
    NSTimeInterval animationDuration = .05f;
    
    _animating = YES;
    if (position.x > self.size.width/2) {
        
        BOOL end = !reversed ? [self _movePlayerRightWithDuration:animationDuration]
                             : [self _movePlayerLeftWithDuration:animationDuration];
        if (end) {
            return;
        }
    }
    !reversed ? [self _movePlayerLeftWithDuration:animationDuration]
              : [self _movePlayerRightWithDuration:animationDuration];
}

- (void)moveLeft {
    [self _movePlayerLeftWithDuration:.05f];
}

- (void)moveRight {
    [self _movePlayerRightWithDuration:.05f];
}

- (BOOL)_movePlayerLeftWithDuration:(NSTimeInterval)duration {
    
    _currentRow--;
    if (_currentRow < 0) {
        
        _currentRow = 4;
        SKAction *leftEdge = [SKAction moveToX:-self.player.size.width/2
                                      duration:duration/2];
        SKAction *position = [SKAction moveToX:self.size.width/2 + (2*_columnWidth)
                                      duration:leftEdge.duration];
        [_player runAction:leftEdge completion:^{
            _player.hidden = YES;
            _player.position = CGPointMake(self.size.width + self.player.size.width/2, _player.position.y);
            _player.hidden = NO;
            [_player runAction:position completion:^{
                [_player removeAllActions];
                _animating = NO;
            }];
        }];
         return YES;
         }
    
    SKAction *moveAction = [SKAction moveToX:_player.position.x - _columnWidth duration:duration];
    [_player runAction:moveAction completion:^{
        [_player removeAllActions];
        _animating = NO;
    }];
    
    return YES;
}

- (BOOL)_movePlayerRightWithDuration:(NSTimeInterval)duration {
    
    _currentRow++;
    if (_currentRow > 4) {
        
        _currentRow = 0;
        SKAction *rightEdge   = [SKAction moveToX:self.size.width + self.player.position.y/2
                                         duration:duration/2];
        SKAction *position    = [SKAction moveToX:self.size.width/2 - (2*_columnWidth)
                                         duration:rightEdge.duration];
        [_player runAction:rightEdge completion:^{
            _player.position = CGPointMake(-self.player.size.width/2, _player.position.y);
            [_player runAction:position completion:^{
                [_player removeAllActions];
                _animating = NO;
            }];
        }];
        return YES;
    }
    
    SKAction *moveAction = [SKAction moveToX:_player.position.x + _columnWidth duration:duration];
    [_player runAction:moveAction completion:^{
        [_player removeAllActions];
        _animating = NO;
    }];
    return YES;
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    // Find the physics body thats not the player
    SKNode *otherBody = (contact.bodyA.node != _player) ? contact.bodyA.node : contact.bodyB.node;
    
    BOOL collision = [(HDObjectNode *)otherBody collisionWithPlayer:_player];
    if (!collision) {
        return;
    }
    
    // If games over, return
    if (_gameOver) {
        return;
    }
    
    // Stop calling update and remove animations
    _gameOver = YES;
    
    // Stop playing background music
    [[HDSoundManager sharedManager] setPlayLoop:NO];
    
    // Play Explosion sound
    [self runAction:self.explosion withKey:HDSoundKey];
    
    // Vibrate
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    // Scroll the HUD node
    [_hudLayerNode runAction:[SKAction moveToY:self.size.height/2 duration:.400f] completion:^{
        [_hudLayerNode removeFromParent];
        _hudLayerNode = nil;
    }];
    
    SKAction *rotateCW  = [SKAction rotateByAngle:.003f  duration:.085f];
    SKAction *rotateCCW = [SKAction rotateByAngle:-.003f duration:.085f];
    SKAction *sequence  = [SKAction sequence:@[rotateCW, rotateCCW, rotateCW, rotateCCW, rotateCW, rotateCCW]];
    [_objectLayerNode runAction:sequence completion:^{
       [_objectLayerNode runAction:[SKAction rotateToAngle:0.0f duration:rotateCW.duration] completion:^{
           // Remove player and set the pointer to nil
           [_player removeFromParent];
           _player = nil;
           
           SKAction *fadeOut = [SKAction fadeOutWithDuration:.175f];
           [_objectLayerNode enumerateChildNodesWithName:HDBarrierKey usingBlock:^(SKNode *node, BOOL *stop) {
               
               if (node.position.x <= self.size.width/2) {
                   SKAction *position = [SKAction moveToX:-_columnWidth/2
                                                 duration:fadeOut.duration];
                   [node runAction:[SKAction group:@[fadeOut, position]]];
               } else {
                   SKAction *position = [SKAction moveToX:self.size.width + _columnWidth/2
                                                 duration:fadeOut.duration];
                   [node runAction:[SKAction group:@[fadeOut, position]]];
               }
           }];
           [self performSelector:@selector(_endGame) withObject:nil afterDelay:fadeOut.duration];
       }];
    }];
}

- (CGPoint)_positionForRow:(NSUInteger)row column:(NSUInteger)column {
    return CGPointMake(((self.size.width/2) - (2*_columnWidth)) + column*_columnWidth, _rowHeight *row);
}

#pragma mark - Convience Nodes

- (SKLabelNode *)scoreLabel {
    return (SKLabelNode *)[_scoreNode childNodeWithName:HDLabelKey];
}

- (SKSpriteNode *)player {
    return (SKSpriteNode *)[_player childNodeWithName:HDPlayerKey];
}

- (SKNode *)_createPlayer {
    
    CGSize playerSize = CGSizeMake(roundf(20.0f * TRANSFORM_SCALE_Y), roundf(20.0f * TRANSFORM_SCALE_Y));
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:[UIImage playerWithSize:playerSize]]];
    sprite.zPosition = 99;
    sprite.name = HDPlayerKey;
    
    SKNode *playerNode = [SKNode node];
    playerNode.zPosition   = 0;
    playerNode.position    = CGPointMake(self.size.width/2, 0.0f);
    playerNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
    playerNode.physicsBody.dynamic        = YES;
    playerNode.physicsBody.allowsRotation = YES;
    playerNode.physicsBody.affectedByGravity = NO;
    playerNode.physicsBody.usesPreciseCollisionDetection = NO;
    playerNode.physicsBody.categoryBitMask  = HDCollisionCategoryPlayer;
    playerNode.physicsBody.collisionBitMask = 0;
    playerNode.physicsBody.contactTestBitMask = HDCollisionCategoryPlatform;
    [playerNode addChild:sprite];
    
    SKEmitterNode *boost = [SKEmitterNode playerBoostWithColor:[UIColor flatEmeraldColor]];
    boost.name       = HDEmitterKey;
    boost.targetNode = self.scene;
    boost.zPosition  = 100;
    boost.position   = CGPointMake(0.0f, -sprite.size.height/2 + 3.0f);
    [sprite addChild:boost];
    
    return playerNode;
}

- (SKSpriteNode *)_barrierSpriteWithType:(HDBarrierType)type size:(CGSize)size shadow:(BOOL)shadow {
    SKSpriteNode *sprite;
    switch (type) {
        case HDBarrierTypeHorizontal:
            sprite = [SKSpriteNode spriteNodeWithTexture:_textureDictionary[@"horizontal"]];
            break;
        case HDBarrierTypeVertical:
            if (shadow) {
                sprite = [SKSpriteNode spriteNodeWithTexture:_textureDictionary[@"vertical"]];
            } else {
                sprite = [SKSpriteNode spriteNodeWithColor:[UIColor flatSTEmeraldColor] size:size];
            } break;
        case HDBarrierTypeEndPiece:
            if (shadow) {
                sprite = [SKSpriteNode spriteNodeWithTexture:_textureDictionary[@"endpiece"]];
            } else {
                sprite = [SKSpriteNode spriteNodeWithColor:[UIColor flatSTEmeraldColor] size:size];
            } break;
        default:
            return nil;
    }
    return sprite;
}

- (HDBarrierNode *)_createBarrierAtPosition:(CGPoint)position type:(HDBarrierType)type size:(CGSize)size shadow:(BOOL)shadow {
    
    SKSpriteNode *sprite = [self _barrierSpriteWithType:type size:size shadow:shadow];
    sprite.zPosition = 95;

    HDBarrierNode *node = [HDBarrierNode node];
    node.zPosition   = 0;
    node.position    = position;
    node.name        = HDBarrierKey;
    node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
    node.physicsBody.dynamic = NO;
    node.physicsBody.categoryBitMask = HDCollisionCategoryPlatform;
    node.physicsBody.collisionBitMask = 0;
    [node addChild:sprite];
    
    return node;
}

- (HDObjectNode *)_createIndicatorAtPosition:(CGPoint)position
                                   direction:(HDArrowDirection)direction {
    
    SKSpriteNode *arrowSprite;
    if (direction == HDArrowDirectionLeft) {
        arrowSprite = [SKSpriteNode spriteNodeWithTexture:_textureDictionary[@"leftArrow"]];
    } else {
        arrowSprite = [SKSpriteNode spriteNodeWithTexture:_textureDictionary[@"rightArrow"]];
    }
    arrowSprite.scale = TRANSFORM_SCALE_Y;
    arrowSprite.zPosition = 80;
    
    HDObjectNode *node = [HDObjectNode node];
    node.name = HDBarrierKey;
    node.zPosition = 0;
    node.position = position;
    [node addChild:arrowSprite];

    return node;
}

- (SKNode *)_scoreNode {
    
    const CGFloat fontSize = 40.0f * TRANSFORM_SCALE_Y;
    
    SKNode *node = [SKNode node];
    node.position = CGPointMake(self.size.width/2, self.size.height - fontSize/2 - 10.0f);
    
    _scoreLblNode = [SKLabelNode node];
    _scoreLblNode.name = HDLabelKey;
    _scoreLblNode.fontSize  = fontSize;
    _scoreLblNode.zPosition = 100;
    _scoreLblNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    _scoreLblNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    _scoreLblNode.fontColor = [SKColor whiteColor];
    _scoreLblNode.fontName  = @"KimberleyBl-Regular";
    [node addChild:_scoreLblNode];
    
    return node;
}

- (SKLabelNode *)_instructionNode {
    
    SKLabelNode *label;
    label = [SKLabelNode node];
    label.alpha = 0;
    label.name  = @"instuctionNode";
    label.fontSize  = ceilf(22.0f * TRANSFORM_SCALE_X);
    label.zPosition = 100;
    label.position  = CGPointMake(self.size.width/2, self.size.height/8);
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    label.fontColor = [SKColor flatEmeraldColor];
    label.fontName  = @"KimberleyBl-Regular";
    label.text      = NSLocalizedString(@"instruction", nil);
    return label;
}

#pragma mark - Setters

- (void)runAction:(SKAction *)action withKey:(NSString *)key {
    // for [SKAction playsoundwithfile:] check if the sounds turned in settings before calling super.
    if ([key isEqualToString:HDSoundKey] && [HDSettingsManager sharedManager].sound) {
        [super runAction:action withKey:key];
    }
}

@end
