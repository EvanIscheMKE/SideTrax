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
#import "SKSpriteNode+HDSpriteNodeAdditions.h"
#import "HDGameCenterManager.h"
#import "HDHelper.h"

#define MAX_PLAYER_POSITIONY [UIScreen mainScreen].bounds.size.height/3.0f

#define LOAD_NEW_LEVEL 230.0f * TRANSFORM_SCALE_Y

#define GAME_SPEED_NORMAL 250.0f

typedef NS_OPTIONS(uint32_t, HDCollisionCategory) {
    HDCollisionCategoryNone     = 0x0,
    HDCollisionCategoryPlayer   = 0x1 << 0,
    HDCollisionCategoryPlatform = 0x1 << 1,
};

static NSString * const HDSoundKey = @"soundKey";

NSString * const HDPlayerKey            = @"playerKey";
NSString * const HDHorizontalBarrierKey = @"HDHorizontalNode";
NSString * const HDVerticalBarrierKey   = @"HDverticalNode";
NSString * const HDVerticalArrowKey     = @"HDArrowNode";
NSString * const HDEmitterKey           = @"emitterKey";
NSString * const HDLevelLayoutNotificationKey = @"layoutNotificationKey";

@interface HDGameScene ()<SKPhysicsContactDelegate>

@property (nonatomic, strong) SKNode *hudLayerNode;

@property (nonatomic, strong) SKLabelNode *instructionNode;

@property (nonatomic, strong) SKAction *whoosh;
@property (nonatomic, strong) SKAction *explosion;
@end

@implementation HDGameScene {
    
    SKNode *_player;
    SKNode *_objectLayerNode;
    
    SKLabelNode *_scoreNode;
    
    NSMutableArray *_borderBank;
    NSMutableArray *_barrierBank;
    
    NSInteger _currentRow;
    NSUInteger _score;
    
    BOOL _gameOver;
    BOOL _animating;
    
    NSTimeInterval _lastTimerStamp;
    
    CGPoint _velocity;
}

- (instancetype)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        _score = 0;
        _currentRow = 3;
        _gameOver = YES;
        
        _barrierBank = [NSMutableArray arrayWithCapacity:30];
        _borderBank  = [NSMutableArray arrayWithCapacity:10];
        
        [self _setup];
        
    }
    return self;
}

- (void)_setup {
    
    self.whoosh    = [SKAction playSoundFileNamed:@"Whoosh.wav" waitForCompletion:NO];
    self.explosion = [SKAction playSoundFileNamed:@"Explosion.wav" waitForCompletion:NO];
    
    self.backgroundColor = [SKColor flatSTBackgroundColor];
    
    self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
    self.physicsWorld.contactDelegate = self;
    
    _objectLayerNode = [SKNode node];
    _objectLayerNode.position = CGPointMake(0.0f, self.size.height);
    [self addChild:_objectLayerNode];
    
    self.hudLayerNode = [self _layoutHUDLayerNode];
    [self addChild:self.hudLayerNode];
    
    SKAction *positionAction = [SKAction moveToY:-0.0f duration:.600f];
    positionAction.timingMode = SKActionTimingEaseOut;
    [_objectLayerNode runAction:[SKAction moveToY:-0.0f duration:.600f] completion:[self _completionBlock]];
}

- (dispatch_block_t)_completionBlock {
    
    dispatch_block_t completion = ^{
        
        _gameOver = NO;
        _velocity.y = GAME_SPEED_NORMAL*1.75f;
        
        [_objectLayerNode removeAllActions];
        
        _player = [self _createPlayer];
        [_objectLayerNode addChild:_player];
        [self _addThrustToNode:(SKSpriteNode *)[_player childNodeWithName:HDPlayerKey]];
        
        self.instructionNode = [self _instructionNode];
        self.instructionNode.alpha = 0;
        [self.hudLayerNode addChild:self.instructionNode];
        
        [self.instructionNode runAction:[SKAction fadeInWithDuration:.200f]];
        
        [self performSelector:@selector(_removeInstructionNode) withObject:nil afterDelay:1.5f];
        
        [self performSelector:@selector(_changeVelocityTo:) withObject:@(GAME_SPEED_NORMAL) afterDelay:.650f];
    };
    
    return completion;
}

- (void)_removeInstructionNode {
    // Fade out the instruction text
    [self.instructionNode runAction:[SKAction fadeAlphaTo:0.0f duration:.300f] completion:^{
        [self.instructionNode removeFromParent];
        self.instructionNode = nil;
    }];
}

- (void)_changeVelocityTo:(NSNumber *)velocity {
    _velocity.y = [velocity floatValue];
}

- (SKNode *)_layoutHUDLayerNode {
    
    SKNode *node = [SKNode node];
    _scoreNode = [self _scoreNode];
    [node addChild:_scoreNode];
    return node;
}

- (HDObjectNode *)_createBorderNodes {
    
    if (_borderBank.count) {
        
        HDObjectNode *_border = [_borderBank firstObject];
        [_borderBank removeObject:_border];
        return _border;
    }
    
    CGFloat width  = !IS_IPAD ? self.size.width/2 - self.columnWidth*2.5f : self.barrierWidth;
    CGFloat height = self.rowHeight + self.barrierWidth;
    
    HDObjectNode *container = [HDObjectNode node];
    container.name = HDVerticalBarrierKey;
    
    for (NSUInteger i = 0; i < 2; i++) {
        
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithColor:[UIColor flatSTEmeraldColor] size:CGSizeMake(width, height)];
        
        HDBarrierNode *node = [HDBarrierNode node];
        node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
        node.physicsBody.dynamic = NO;
        node.physicsBody.categoryBitMask = HDCollisionCategoryPlatform;
        node.physicsBody.collisionBitMask = 0;
        [node addChild:sprite];
        [container addChild:node];
        
        CGFloat positionX;
        if (i == 0) {
            positionX = IS_IPAD ? self.size.width/2 - self.columnWidth*2.5f - sprite.size.width/2 : sprite.size.width/2;
        } else {
            positionX = IS_IPAD ? self.size.width/2 + self.columnWidth*2.5f + sprite.size.width/2 : self.size.width - sprite.size.width/2;
        }
        node.position = CGPointMake(positionX, sprite.size.height/2);;
    }
    return container;
}

- (HDObjectNode *)layoutArrowsFromDirection:(HDArrowDirection)direction row:(NSUInteger)row {
    
    HDObjectNode *container = [HDObjectNode node];
    container.name = HDVerticalArrowKey;
    for (NSUInteger i = 0; i < 2; i++) {
        
        SKSpriteNode *arrow = nil;
        switch (direction) {
            case HDArrowDirectionLeft:
                arrow = [SKSpriteNode spriteNodeWithImageNamed:@"LeftArrow"];
                break;
            case HDArrowDirectionRight:
                arrow = [SKSpriteNode spriteNodeWithImageNamed:@"RightArrow"];
                break;
            case HDArrowDirectionUp:
                arrow = [SKSpriteNode spriteNodeWithImageNamed:@"UpArrow"];
                break;
            default:
                break;
        }
        
        const CGFloat offset = i == 0 ? - self.columnWidth : self.columnWidth;
        arrow.position = CGPointMake(self.size.width/2 + offset, 0.0f);
        [container addChild:arrow];
    }
    return container;
}

- (void)layoutChildrenNode {
    
    void (^layoutBorders)(NSUInteger row) = ^(NSUInteger row){
        
        CGPoint position = CGPointMake( 0.0f, self.rowHeight * row -self.barrierWidth/2);
        SKNode *node = [self _createBorderNodes];
        node.position = position;
        [_objectLayerNode addChild:node];
    };
    
    void (^layoutArrows)(NSUInteger, HDArrowDirection) = ^(NSUInteger row, HDArrowDirection direction) {
        
        CGPoint position = CGPointMake(0.0f, self.rowHeight*row + self.rowHeight/2);
        SKNode *node = [self layoutArrowsFromDirection:direction row:row];
        node.position = position;
        [_objectLayerNode addChild:node];
    };
    
    NSRange range = self.gridManager.range;
    for (NSInteger row = range.location; row < range.location + range.length; row++) {
        
        [self.gridManager displayRowBordersForRowAtIndex:row
                                              completion:^(BOOL displayBorders, HDArrowDirection direction) {
                                                  
                                                  if (displayBorders && direction == HDArrowDirectionUp) {
                                                      layoutBorders(row);
                                                      layoutArrows(row,direction);
                                                  } else if (displayBorders) {
                                                      layoutBorders(row);
                                                  } else {
                                                      layoutArrows(row,direction);
                                                  }
                                              }];
        
        for (NSInteger column = 0; column < NumberOfColumns; column++) {
            BOOL display = [self.gridManager presentBarrierForRow:row column:column];
            
            if (display) {
                HDBarrierNode *platform = [self _createBarrierAtPosition:[self _positionForRow:row column:column]];
                [_objectLayerNode addChild:platform];
            }
        }
    }
    
    self.gridManager.range = NSMakeRange(range.location + range.length, range.length);
}

- (void)update:(CFTimeInterval)currentTime {
    
    if (_gameOver) {
        return;
    }

    const NSTimeInterval delta = (_lastTimerStamp == 0.0) ? 0.0 : currentTime - _lastTimerStamp;
    
    CGPoint position = _player.position;
    position.y += _velocity.y * delta;
    _player.position = position;
    
    const CGFloat rowHeight = self.rowHeight;
    if (fmod(position.y + 5.0f, LOAD_NEW_LEVEL) < 4) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HDLevelLayoutNotificationKey object:nil];
    }
    
    if (position.y > rowHeight * NumberOfColumns) {
        NSUInteger points = (NSUInteger)(position.y/rowHeight - NumberOfColumns);
        if (points > _score) {
            _score = points;
            _velocity.y += 1;
            _scoreNode.text = [NSString stringWithFormat:@"%tu",_score];
        }
    }
    
//    [objectLayerNode enumerateChildNodesWithName:HDVerticalArrowKey usingBlock:^(SKNode *node, BOOL *stop) {
//        BOOL remove = [(HDBarrierNode *)node checkNodePositionForRemoval:position.y];
//        if (remove) {
//            [node removeFromParent];
//        }
//    }];
//    
//    [objectLayerNode enumerateChildNodesWithName:HDVerticalBarrierKey usingBlock:^(SKNode *node, BOOL *stop) {
//        BOOL remove = [(HDBarrierNode *)node checkNodePositionForRemoval:position.y];
//        if (remove) {
//            [_borderBank addObject:node];
//            [node removeFromParent];
//        }
//    }];
//    
//    [objectLayerNode enumerateChildNodesWithName:HDHorizontalBarrierKey usingBlock:^(SKNode *node, BOOL *stop) {
//        BOOL remove = [(HDBarrierNode *)node checkNodePositionForRemoval:position.y];
//        if (remove) {
//            [_barrierBank addObject:node];
//            [node removeFromParent];
//        }
//    }];
    
    // Once the player node reaches 200pt, move the ObjectNode down at the same rate the players increasing
    if (position.y > MAX_PLAYER_POSITIONY) {
        _objectLayerNode.position = CGPointMake(_objectLayerNode.position.x, -(position.y - MAX_PLAYER_POSITIONY));
    }
    
    _lastTimerStamp = currentTime;
}

- (void)_endGame {
    [[HDAppDelegate sharedDelegate] returnHome];
    [[HDPointsManager sharedManager] saveState];
    [[HDGameCenterManager sharedManager] reportLevelsCompleted:[HDPointsManager sharedManager].score
                                                        forKey:[HDGameCenterManager leaderboardIdentifierFromState:self.direction]];
}

- (void)_addThrustToNode:(SKSpriteNode *)node {
    
    SKEmitterNode *boost = [SKEmitterNode playerBoostWithColor:[UIColor whiteColor]];
    boost.name       = HDEmitterKey;
    boost.targetNode = self.scene;
    boost.position   = CGPointMake(0.0f, -node.size.height/2);
    [_player addChild:boost];
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_gameOver || _animating) {
        return;
    }
    
    [self runAction:self.whoosh withKey:HDSoundKey];
    
    UITouch *touch = [touches anyObject];
    CGPoint position = [touch locationInNode:_objectLayerNode];
    
    BOOL reversed = self.direction != HDDirectionStateRegular;
    
    NSTimeInterval animationDuration = .07f;
    
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
    return;
}

- (BOOL)_movePlayerLeftWithDuration:(NSTimeInterval)duration {
    
    _currentRow--;
    
    if (_currentRow < 1) {
        
        _currentRow = 5;
        SKAction *rightEdge = [SKAction moveToX:0.0f duration:duration/2];
        SKAction *hide = [SKAction hide];
        
        [_player runAction:[SKAction sequence:@[rightEdge,hide]] completion:^{
            
            CGPoint position = _player.position;
            position.x = self.size.width;
            _player.position = position;
            
            SKAction *show = [SKAction unhide];
            SKAction *move = [SKAction moveToX:self.size.width/2 + (2 * self.columnWidth)
                                      duration:rightEdge.duration];
            [_player runAction:[SKAction sequence:@[show, move]] completion:^{
                _animating = NO;
            }];
        }];
        return YES;
    }
    
    [_player runAction:[SKAction moveToX:_player.position.x - self.columnWidth
                                    duration:duration]
                completion:^{
                    _animating = NO;
                }];
    
    return YES;
}

- (BOOL)_movePlayerRightWithDuration:(NSTimeInterval)duration {
    
    _currentRow++;
    
    if (_currentRow > 5) {
        
        _currentRow = 1;
        SKAction *rightEdge = [SKAction moveToX:self.size.width duration:duration/2];
        SKAction *hide = [SKAction hide];
        
        [_player runAction:[SKAction sequence:@[rightEdge,hide]] completion:^{
            CGPoint position = _player.position;
            position.x = 0;
            _player.position = position;
            
            SKAction *show = [SKAction unhide];
            SKAction *move = [SKAction moveToX:self.size.width/2 - (2*self.columnWidth)
                                      duration:rightEdge.duration];
            [_player runAction:[SKAction sequence:@[show, move]] completion:^{
                _animating = NO;
            }];
        }];
        return YES;
    }
    
    [_player runAction:[SKAction moveToX:_player.position.x + self.columnWidth
                                    duration:duration]
                completion:^{
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
    [self.hudLayerNode runAction:[SKAction moveToY:self.size.height/2 duration:.400f]];
    
    // Default Position = _objectLayerNode.position.y + self.size.height*1.3f
    SKAction *wait     = [SKAction waitForDuration:1.2f];
    SKAction *position = [SKAction moveToY:0.0f duration:1.400f];
    
    SKAction *sequence = [SKAction sequence:@[wait,position]];
    
    // Scroll maze to the top, then dismiss View Controller
    [_objectLayerNode runAction:sequence completion:^{
        
        [_player removeFromParent];
        _player = nil;
        
        [_objectLayerNode removeAllActions];
        [self _endGame];
        
    }];
}

- (CGPoint)_positionForRow:(NSUInteger)row column:(NSUInteger)column {
    return CGPointMake(((self.size.width/2) - (2*self.columnWidth)) + column*self.columnWidth, self.rowHeight *row);
}

#pragma mark - Convience Nodes

- (SKNode *)_createPlayer {
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    sprite.scale = TRANSFORM_SCALE_X;
    sprite.name = HDPlayerKey;
    
    SKNode *playerNode = [SKNode node];
    playerNode.position    = CGPointMake(self.size.width/2, 0.0f);
    playerNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
    playerNode.physicsBody.dynamic        = YES;
    playerNode.physicsBody.allowsRotation = YES;
    playerNode.physicsBody.restitution    = 1.0f;
    playerNode.physicsBody.friction       = 0.0f;
    playerNode.physicsBody.angularDamping = 0.0f;
    playerNode.physicsBody.linearDamping  = 0.0f;
    playerNode.physicsBody.affectedByGravity = NO;
    playerNode.physicsBody.usesPreciseCollisionDetection = YES;
    playerNode.physicsBody.categoryBitMask  = HDCollisionCategoryPlayer;
    playerNode.physicsBody.collisionBitMask = 0;
    playerNode.physicsBody.contactTestBitMask = HDCollisionCategoryPlatform;
    [playerNode addChild:sprite];
    
    return playerNode;
}

- (HDBarrierNode *)_createBarrierAtPosition:(CGPoint)position {
    
    if (_barrierBank.count) {
        HDBarrierNode *barrier = [_barrierBank firstObject];
        barrier.position = position;
        [_barrierBank removeObject:barrier];
        return barrier;
    }
    
    NSLog(@"%f,%f",self.columnWidth, self.barrierWidth);
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithColor:[UIColor flatSTEmeraldColor]
                                                        size:CGSizeMake(self.columnWidth, self.barrierWidth)];
    
    HDBarrierNode *node = [HDBarrierNode node];
    node.position    = position;
    node.name        = HDHorizontalBarrierKey;
    node.barrierType = HDBarrierTypeHorizontalSquare;
    node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
    node.physicsBody.dynamic = NO;
    node.physicsBody.categoryBitMask = HDCollisionCategoryPlatform;
    node.physicsBody.collisionBitMask = 0;
    [node addChild:sprite];
    
    return node;
}

#pragma mark - Convenice Label Node

- (SKLabelNode *)_scoreNode {
    
    static SKLabelNode *label;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        label = [SKLabelNode node];
        label.name = @"scoreNode";
        label.fontSize  = 40.0f;
        label.zPosition = 100;;
        label.scale     = TRANSFORM_SCALE_Y;
        label.position  = CGPointMake(self.size.width/2, self.size.height - label.fontSize/2 - 10.0f);
        label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        label.fontColor = [SKColor whiteColor];
        label.fontName  = @"KimberleyBl-Regular";
        label.text      = @"";
    });
    return label;
}

- (SKLabelNode *)_instructionNode {
    
    static SKLabelNode *label;;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        label = [SKLabelNode node];
        label.name = @"instuctionNode";
        label.fontSize  = 22.0f;
        label.zPosition = 100;;
        label.scale     = TRANSFORM_SCALE_X;
        label.position  = CGPointMake(self.size.width/2, self.size.height/8);
        label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        label.fontColor = [SKColor flatSTRedColor];
        label.fontName  = @"KimberleyBl-Regular";
        label.text      = NSLocalizedString(@"instruction", nil);
    });
    return label;
}

#pragma mark - Setters

- (void)runAction:(SKAction *)action withKey:(NSString *)key {
    // for [SKAction playsoundwithfile:] check if the sounds turned in settings before calling super.
    if ([key isEqualToString:HDSoundKey] && [HDSettingsManager sharedManager].sound) {
        [super runAction:action withKey:key];
    }
}

#pragma mark - Getters

- (CGFloat)barrierWidth {
    return [HDHelper universalBarrierWidth];
}

- (CGFloat)rowHeight {
    return [HDHelper universalRowHeight];
}

- (CGFloat)columnWidth {
    return [HDHelper universalColumnWidth];
}

@end
