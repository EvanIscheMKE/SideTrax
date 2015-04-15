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

#define ROW_HEIGHT floor((COLUMN_WIDTH * 1.9f))
#define GAME_SPEED_NORMAL 4.25

typedef NS_OPTIONS(uint32_t, HDCollisionCategory) {
    HDCollisionCategoryNone     = 0x0,
    HDCollisionCategoryPlayer   = 0x1 << 0,
    HDCollisionCategoryPlatform = 0x1 << 1,
};

NSString * const HDPlayerKey   = @"playerKey";
NSString * const HDPlatformKey = @"HDPlatformNode";
NSString * const HDEmitterKey  = @"emitterKey";
static NSString * const HDSoundKey = @"soundKey";
NSString * const HDLevelLayoutNotificationKey = @"layoutNotificationKey";
@interface HDGameScene ()<SKPhysicsContactDelegate>

@property (nonatomic, strong) SKNode *player;
@property (nonatomic, strong) SKNode *backgroundNode;
@property (nonatomic, strong) SKNode *objectLayerNode;
@property (nonatomic, strong) SKNode *hudLayerNode;

@property (nonatomic, strong) SKLabelNode *scoreNode;
@property (nonatomic, strong) SKLabelNode *instructionNode;

@property (nonatomic, strong) SKAction *whoosh;
@property (nonatomic, strong) SKAction *explosion;

@end

@implementation HDGameScene {
    BOOL _gameOver;
    BOOL _animating;
    NSInteger _currentRow;
    CGPoint _velocity;
}

- (instancetype)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    
    [HDPointsManager sharedManager].score = 0;
    
    self.whoosh    = [SKAction playSoundFileNamed:@"Whoosh.wav" waitForCompletion:NO];
    self.explosion = [SKAction playSoundFileNamed:@"Explosion.wav" waitForCompletion:NO];
    
    self.backgroundColor = [SKColor flatSTBackgroundColor];
    self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
    self.physicsWorld.contactDelegate = self;
    
    self.backgroundNode = [self _createBackground];
    [self addChild:self.backgroundNode];
    
    self.objectLayerNode = [SKNode node];
    [self addChild:self.objectLayerNode];
    
    self.hudLayerNode = [SKNode node];
    [self addChild:self.hudLayerNode];
    
    self.scoreNode = [self _scoreNode];
    [self.hudLayerNode addChild:self.scoreNode];
    
    self.instructionNode = [self _instructionNode];
    [self.hudLayerNode addChild:self.instructionNode];
    
    _velocity.y = GAME_SPEED_NORMAL;
    _currentRow = 3;
    _gameOver   = NO;
    
    [self performSelector:@selector(_removeInstructionNode) withObject:nil afterDelay:1.5f];
}

- (void)_removeInstructionNode {
    
    [self.instructionNode runAction:[SKAction fadeAlphaTo:0.0f duration:.3f] completion:^{
        [self.instructionNode removeFromParent];
        self.instructionNode = nil;
    }];
}

- (void)_increaceVelocityTo:(NSNumber *)velocity {
    _velocity.y = [velocity floatValue];
}

- (SKNode *)_createBackground {
    
    SKNode *node = [SKNode node];
    for (NSUInteger column = 0; column < 5; column++) {
        
        SKColor *stripeColor = [SKColor flatSTAccentColor];
        CGPoint position = CGPointMake(((self.size.width / 2) - (2 * COLUMN_WIDTH)) + column * COLUMN_WIDTH, 0.0f);
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithColor:(column % 2 == 0) ? self.backgroundColor : stripeColor
                                                            size:CGSizeMake(COLUMN_WIDTH, self.size.height)];
        sprite.anchorPoint = CGPointMake(0.5f, 0.0f);
        sprite.position = position;
        [node addChild:sprite];
    }
    return node;
}

- (SKNode *)_createBorderWithRow:(NSUInteger)row {

    CGFloat width  = self.size.width/2 - COLUMN_WIDTH*2.5;
    CGFloat height = COLUMN_WIDTH*2 + BARRIER_WIDTH/2;
    
    HDBarrierNode *container = [HDBarrierNode node];
    container.name = HDPlatformKey;
    for (NSUInteger i = 0; i < 2; i++) {
        
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithColor:[UIColor flatSTEmeraldColor]
                                                            size:CGSizeMake(width, height)];
        
        HDBarrierNode *node = [HDBarrierNode node];
        node.name = HDPlatformKey;
        node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
        node.physicsBody.dynamic = NO;
        node.physicsBody.categoryBitMask = HDCollisionCategoryPlatform;
        node.physicsBody.collisionBitMask = 0;
        [node addChild:sprite];
        [container addChild:node];
        
        switch (i) {
            case 0:
                node.position = CGPointMake(sprite.size.width/2, sprite.size.height/2);
                break;
            case 1:
                node.position = CGPointMake(self.size.width - sprite.size.width/2, sprite.size.height/2);
                break;
            default:
                break;
        }
    }
    return container;
}

- (SKNode *)layoutArrowsFromDirection:(HDArrowDirection)direction row:(NSUInteger)row {
    
    HDBarrierNode *container = [HDBarrierNode node];
    container.name = HDPlatformKey;
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
        
        
        switch (i) {
            case 0:
                arrow.position = CGPointMake(self.size.width/2 - COLUMN_WIDTH, 0.0f);
                break;
            case 1:
                arrow.position = CGPointMake(self.size.width/2 + COLUMN_WIDTH, 0.0f);
                break;
            default:
                break;
        }
        
        [container addChild:arrow];
    }
    return container;
}

- (void)layoutChildrenNode {
    
    void (^layoutBorders)(NSUInteger row) = ^(NSUInteger row){
        SKNode *node = [self _createBorderWithRow:row];
        node.position = CGPointMake( 0.0f, ROW_HEIGHT * row -BARRIER_WIDTH/2);
        [self.objectLayerNode addChild:node];
    };
    
    void (^layoutArrows)(NSUInteger row, HDArrowDirection direction) = ^(NSUInteger row, HDArrowDirection direction) {
        SKNode *node = [self layoutArrowsFromDirection:direction row:row];
        node.position = CGPointMake(0.0f, ROW_HEIGHT * row + ROW_HEIGHT/2);
        [self.objectLayerNode addChild:node];
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
            NSNumber *type = [self.gridManager coinTypeAtRow:row column:column];
            
            if ([type unsignedIntegerValue] == 0) {
                continue;
            }
            
            HDBarrierNode *platform = [self _createBarrierAtPosition:[self _positionForRow:row column:column]
                                                              ofType:[type unsignedIntegerValue]];
            [self.objectLayerNode addChild:platform];
        }
    }
    
    self.gridManager.range = NSMakeRange(range.location + range.length, range.length);
    
    if (!self.player) {
        self.player = [self _createPlayer];
        [self.objectLayerNode addChild:self.player];
        [self _addThrustToNode:(SKSpriteNode *)[self.player childNodeWithName:HDPlayerKey]];
    }
}

- (void)_saveMe {
    
    if (_gameOver) {
        return;
    }
    
    _gameOver = YES;
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    SKAction *right = [SKAction rotateToAngle:.002f duration:.08f];
    SKAction *left  = [SKAction rotateToAngle:-.002f duration:.08f];
    SKAction *final = [SKAction repeatAction:[SKAction sequence:@[right, left]] count:3];
    [self.objectLayerNode runAction:final completion:^{
        [self.objectLayerNode runAction:[SKAction rotateToAngle:0.0f duration:.15f]];
        [self _endGame];
    }];
}

- (void)update:(CFTimeInterval)currentTime {
    
    if (_gameOver) {
        return;
    }
    
    CGPoint position = self.player.position;
    position.y += _velocity.y;
    self.player.position = position;
    
    if (fmod(self.player.position.y + 5.0f, 550.0f) < 4) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HDLevelLayoutNotificationKey object:nil];
    }
    
    if (self.player.position.y > ROW_HEIGHT) {
        NSInteger points = self.player.position.y/ROW_HEIGHT;
        
        points -= 4;
        if (points > 0) {
            NSUInteger score = [HDPointsManager sharedManager].score;
            if (points > score) {
                [HDPointsManager sharedManager].score = points;
                self.scoreNode.text = [NSString stringWithFormat:@"%tu",points];
                _velocity.y += .01f;
            }
        }
    }
    
    [self.objectLayerNode enumerateChildNodesWithName:HDPlatformKey usingBlock:^(SKNode *node, BOOL *stop) {
        [(HDBarrierNode *)node checkNodePositionForRemoval:self.player.position.y];
    }];
    
    if (self.player.position.y > 200.0f) {
        CGPoint position = self.objectLayerNode.position;
        position.y -= _velocity.y;
        self.objectLayerNode.position = position;
    }
}

- (void)_endGame {
    [[HDAppDelegate sharedDelegate] returnHome];
    [[HDPointsManager sharedManager] saveState];
}

- (void)_addThrustToNode:(SKSpriteNode *)node {
    
    SKEmitterNode *boost = [SKEmitterNode playerBoostWithColor:[UIColor whiteColor]];
    boost.name = HDEmitterKey;
    boost.targetNode = self.scene;
    boost.position = CGPointMake(0.0f, -node.size.height/2);
    [self.player addChild:boost];
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_gameOver || _animating) {
        return;
    }
    
    [self runAction:self.whoosh withKey:HDSoundKey];
    
    UITouch *touch = [touches anyObject];
    CGPoint position = [touch locationInNode:self.objectLayerNode];
    
    _animating = YES;
    if (position.x > self.size.width/2) {
        
        _currentRow++;
        if (_currentRow > 5) {
            
            _currentRow = 1;
            
            SKAction *rightEdge = [SKAction moveToX:self.size.width duration:.035f];
            SKAction *hide = [SKAction hide];
            
            [self.player runAction:[SKAction sequence:@[rightEdge,hide]] completion:^{
                CGPoint position = self.player.position;
                position.x = 0;
                self.player.position = position;
                
                SKAction *show = [SKAction unhide];
                SKAction *move = [SKAction moveToX:BARRIER_WIDTH + COLUMN_WIDTH/2 duration:rightEdge.duration];
                [self.player runAction:[SKAction sequence:@[show, move]] completion:^{
                    _animating = NO;
                }];
            }];
            return;
        }
        
        [self.player runAction:[SKAction moveToX:self.player.position.x + COLUMN_WIDTH duration:.07f] completion:^{
            _animating = NO;
        }];
        return;
    }
    
    _currentRow--;
    if (_currentRow < 1) {
        
        _currentRow = 5;
        
        SKAction *rightEdge = [SKAction moveToX:0.0f duration:.045f];
        SKAction *hide = [SKAction hide];
        
        [self.player runAction:[SKAction sequence:@[rightEdge,hide]] completion:^{
            CGPoint position = self.player.position;
            position.x = self.size.width;
            self.player.position = position;
            
            SKAction *show = [SKAction unhide];
            SKAction *move = [SKAction moveToX:self.size.width - (BARRIER_WIDTH + COLUMN_WIDTH/2)
                                      duration:rightEdge.duration];
            [self.player runAction:[SKAction sequence:@[show, move]] completion:^{
                _animating = NO;
            }];
        }];
        return;
    }
    
    [self.player runAction:[SKAction moveToX:self.player.position.x - COLUMN_WIDTH duration:.07f] completion:^{
        _animating = NO;
    }];
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    SKNode *otherBody = (contact.bodyA.node != self.player) ? contact.bodyA.node : contact.bodyB.node;
    
    [(HDObjectNode *)otherBody collisionWithPlayer:self.player completion:^(BOOL update, HDObjectType type) {
        [self runAction:self.explosion withKey:HDSoundKey];
        [self _saveMe];
    }];
}

- (CGPoint)_positionForRow:(NSUInteger)row column:(NSUInteger)column {
    return CGPointMake(((self.size.width/2) - (2*COLUMN_WIDTH)) + column*COLUMN_WIDTH, ROW_HEIGHT *row);
}

#pragma mark - Convience Nodes

- (SKNode *)_createPlayer {
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    sprite.name = HDPlayerKey;
    
    SKNode *playerNode = [SKNode node];
    playerNode.position = CGPointMake(self.size.width/2, sprite.size.height);
    playerNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
    playerNode.physicsBody.dynamic = YES;
    playerNode.physicsBody.allowsRotation = YES;
    playerNode.physicsBody.restitution = 1.0f;
    playerNode.physicsBody.friction = 0.0f;
    playerNode.physicsBody.angularDamping = 0.0f;
    playerNode.physicsBody.linearDamping = 0.0f;
    playerNode.physicsBody.affectedByGravity = NO;
    playerNode.physicsBody.usesPreciseCollisionDetection = YES;
    playerNode.physicsBody.categoryBitMask = HDCollisionCategoryPlayer;
    playerNode.physicsBody.collisionBitMask = 0;
    playerNode.physicsBody.contactTestBitMask = HDCollisionCategoryPlatform;
    [playerNode addChild:sprite];
    
    return playerNode;
}

- (HDBarrierNode *)_createBarrierAtPosition:(CGPoint)position ofType:(HDBarrierType)type {
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithColor:[UIColor flatSTEmeraldColor]
                                                        size:CGSizeMake(COLUMN_WIDTH, BARRIER_WIDTH)];
    
    HDBarrierNode *node = [HDBarrierNode node];
    node.position = position;
    node.name = HDPlatformKey;
    node.barrierType = type;
    node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
    node.physicsBody.dynamic = NO;
    node.physicsBody.categoryBitMask = HDCollisionCategoryPlatform;
    node.physicsBody.collisionBitMask = 0;
    [node addChild:sprite];
    
    return node;
}

#pragma mark - Convenice Label Node

- (SKLabelNode *)_scoreNode {
    
    SKLabelNode *label = [SKLabelNode node];
    label.fontSize = 40.0f;
    label.zPosition = 100;;
    label.position = CGPointMake(self.size.width/2, self.size.height - label.fontSize/2 - 10.0f);
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    label.fontColor = [SKColor whiteColor];
    label.fontName = @"KimberleyBl-Regular";
    
    return label;
}

- (SKLabelNode *)_instructionNode {
    
    SKLabelNode *label = [SKLabelNode node];
    label.fontSize = 22.0f;
    label.zPosition = 100;;
    label.position = CGPointMake(self.size.width/2, self.size.height/8);
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    label.fontColor = [SKColor flatSTRedColor];
    label.fontName = @"KimberleyBl-Regular";
    label.text = @"TAP LEFT OR RIGHT TO MOVE";
    
    return label;
}

#pragma mark - Setters 

- (void)runAction:(SKAction *)action withKey:(NSString *)key {
    
    if ([key isEqualToString:HDSoundKey] && [HDSettingsManager sharedManager].sound) {
        [super runAction:action withKey:key];
    }
}

@end
