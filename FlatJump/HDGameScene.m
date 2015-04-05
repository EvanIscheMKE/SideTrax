//
//  HDGameScene.m
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import CoreMotion;

#import "HDSaveNode.h"
#import "HDGameScene.h"
#import "SKColor+HDColor.h"
#import "UIColor+FlatColors.h"
#import "HDPointsManager.h"
#import "HDObjectNode.h"
#import "HDPlatformNode.h"
#import "HDGridManager.h"
#import "HDAppDelegate.h"
#import "SKEmitterNode+HDEmitterAdditions.h"

typedef NS_OPTIONS(uint32_t, HDCollisionCategory) {
    HDCollisionCategoryNone     = 0x0,
    HDCollisionCategoryPlayer   = 0x1 << 0,
    HDCollisionCategoryPlatform = 0x1 << 1,
};

static const CGFloat kMaxPlayerDrop = 400.0f;
static const CGFloat xAccelerationMultiplier = 700.0f;

NSString * const HDSAVEME_KEY    = @"SAVE_ME";
NSString * const HDPLAYER_KEY    = @"PLAYER_NODE";
NSString * const HDBOOST_KEY     = @"BOOST_EMITTER";

NSString * const HDNODE_KEY      = @"HDKeyNode";
NSString * const HDNODE_PLATFORM = @"HDPlatformNode";
@interface HDGameScene ()<SKPhysicsContactDelegate>
@property (nonatomic, strong) SKNode *player;
@property (nonatomic, strong) SKNode *backgroundNode;
@property (nonatomic, strong) SKNode *objectLayerNode;
@property (nonatomic, strong) SKNode *hudLayerNode;
@end

@implementation HDGameScene {
    CMMotionManager *_motionManager;
    CGFloat _xAcceleration;
    CGFloat _endLevelY;
    CGFloat _maxPlayerY;
    BOOL _gameOver;
    BOOL _magnet;
}

- (instancetype)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        [self _setup];
        [self _initalizeMotionManager];
    }
    return self;
}

- (void)_setup {
    
    self.backgroundColor = [SKColor flatMidnightBlueColor];
    self.physicsWorld.gravity = CGVectorMake(0.0f, -2.5f);
    self.physicsWorld.contactDelegate = self;
    
    self.backgroundNode = [self _createBackground];
    [self addChild:self.backgroundNode];
    
    self.objectLayerNode = [SKNode node];
    [self addChild:self.objectLayerNode];
    
    self.hudLayerNode = [SKNode node];
    [self addChild:self.hudLayerNode];
    
    _maxPlayerY = self.player.position.y;
    _gameOver = NO;
}

- (void)_initalizeMotionManager {
    
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.accelerometerUpdateInterval = 0.2f;
    [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                         withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                             CMAcceleration acceleration = accelerometerData.acceleration;
                                             _xAcceleration = (acceleration.x * 0.75f) + (_xAcceleration * 0.25f);
                                         }];
}

- (SKNode *)_createBackground {
    
    SKNode *node = [SKNode node];
    for (NSUInteger row = 0; row < 5; row++) {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithColor:(row % 2 == 0) ?[SKColor flatMidnightBlueColor]:[SKColor flatWetAsphaltColor]
                                                             size:CGSizeMake(self.size.width/5, 2500.f)];
        sprite.anchorPoint = CGPointMake(0.0, 0.0f);
        sprite.position = CGPointMake(self.size.width/5 * row, 0.0f);
        [node addChild:sprite];
    }
    return node;
}

- (void)layoutChildrenNode {
    
    for (NSInteger row = 0; row < NumberOfRows; row++) {
        for (NSInteger column = 0; column < NumberOfColumns; column++) {
            
            NSNumber *type = [self.gridManager coinTypeAtRow:row column:column];
            NSUInteger intValue = [type unsignedIntegerValue];
            
            switch (intValue) {
                case 1:
                case 2:
                case 3: {
                    HDPlatformNode *platform = [self _createPlatformAtPosition:[self _coinPositionForRow:row column:column]
                                                                        ofType:intValue];
                    [self.objectLayerNode addChild:platform];
                } break;
                default:
                    break;
            }
        }
    }
    self.player = [self _createPlayer];
    [self.objectLayerNode addChild:self.player];
}

- (void)_saveMe {
    
    _gameOver = YES;
    
    CGSize size = CGSizeMake(self.size.width/3, 80.0f);
    CGPoint position = CGPointMake(self.size.width/2, _maxPlayerY - kMaxPlayerDrop*2 - size.height/2);
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:0.0f alpha:.5f] size:size];
    sprite.name = HDSAVEME_KEY;
    
    HDSaveNode *saveMe = [HDSaveNode node];
    saveMe.name = HDSAVEME_KEY;
    saveMe.position = position;
    [saveMe addChild:sprite];
    [self.objectLayerNode addChild:saveMe];
    
    CGFloat kPositionY = MAX(_maxPlayerY - kMaxPlayerDrop*1.25, size.height/2 + 10.0f);
    
    NSTimeInterval timeDelay = 5.0f;
    [saveMe runAction:[SKAction moveToY:kPositionY duration:.3f] completion:^{
        SKAction *waitAction = [SKAction waitForDuration:timeDelay];
        SKAction *positionAction = [SKAction moveTo:position duration:.3f];
        [saveMe runAction:[SKAction sequence:@[waitAction, positionAction]] completion:^{
            [saveMe removeFromParent];
            [self _endGame];
        }];
    }];
}

- (void)update:(CFTimeInterval)currentTime {
    
    if (_gameOver) {
        return;
    }
    
    if ((int)self.player.position.y > _maxPlayerY) {
        [HDPointsManager sharedManager].score += (int)_player.position.y - _maxPlayerY;
        _maxPlayerY = (int)_player.position.y;
        // Update Score Label
    }
    
    if ([self.objectLayerNode childNodeWithName:HDSAVEME_KEY]) {
        [(HDSaveNode *)[self.objectLayerNode childNodeWithName:HDSAVEME_KEY] checkNodePositionForRemoval:self.player.position.y];
    }
    
    [self.objectLayerNode enumerateChildNodesWithName:HDNODE_PLATFORM
                                           usingBlock:^(SKNode *node, BOOL *stop) {
                                               [(HDPlatformNode *)node checkNodePositionForRemoval:self.player.position.y];
                                           }];
    
    if (self.player.position.y > 200.0f) {
        self.objectLayerNode.position = CGPointMake(self.objectLayerNode.position.x, -(self.player.position.y - 200.0f));
        self.backgroundNode.position = CGPointMake(0.0f, -(_player.position.y - 200.0f));
    }
    
    if (self.player.position.y < (_maxPlayerY - kMaxPlayerDrop)) {
        [self _saveMe];
    }
}

- (void)_endGame {
    [[HDAppDelegate sharedDelegate] presentCompletionViewControllerWithMovesCompleted:50];
    [[HDPointsManager sharedManager] saveState];
}

- (void)_addBoostToNode:(SKSpriteNode *)node {
    
    SKEmitterNode *boost = [SKEmitterNode playerBoostWithColor:[UIColor flatEmeraldColor]];
    boost.name = HDBOOST_KEY;
    boost.position = CGPointMake(0.0f, -node.size.height/2);
    [self.player addChild:boost];
    
    NSTimeInterval delayInSeconds = boost.numParticlesToEmit / boost.particleBirthRate + boost.particleLifetime;
    [boost performSelector:@selector(removeFromParent) withObject:nil afterDelay:delayInSeconds];
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint position = [touch locationInNode:self.objectLayerNode];
    SKNode *node = [self.objectLayerNode nodeAtPoint:position];
    
    if ([node.name isEqualToString:HDSAVEME_KEY]) {
        // Check for Coins to make sure they have enough to purchase it, otherwise present buy coins menu
        self.player.physicsBody.dynamic = NO;
        self.player.position = CGPointMake(self.player.position.x, (_maxPlayerY - kMaxPlayerDrop) + 1.0f);
        self.player.physicsBody.dynamic = YES;
        [self.player.physicsBody applyImpulse:CGVectorMake(0.0f, 32.0f)];
        [self _addBoostToNode:(SKSpriteNode *)[self.player childNodeWithName:HDPLAYER_KEY]];
        _gameOver = NO;
    }
    
    if (!self.player.physicsBody.dynamic && !_gameOver){
         self.player.physicsBody.dynamic = YES;
        [self.player.physicsBody applyImpulse:CGVectorMake(0.0f, 25.0f)];
        [self _addBoostToNode:(SKSpriteNode *)[self.player childNodeWithName:HDPLAYER_KEY]];
    };
}

#pragma mark - <SKPhysicsContactDelegate>

- (void)didSimulatePhysics {
    
    self.player.physicsBody.velocity = CGVectorMake(_xAcceleration * xAccelerationMultiplier, _player.physicsBody.velocity.dy);
    
    const CGFloat kOffset = 20.0f;
    if (self.player.position.x < -kOffset) {
        self.player.position = CGPointMake(self.size.width + kOffset, _player.position.y);
    } else if (_player.position.x > self.size.width + kOffset) {
        self.player.position = CGPointMake(-kOffset, _player.position.y);
    }
    return;
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    SKNode *otherBody = (contact.bodyA.node != self.player) ? contact.bodyA.node : contact.bodyB.node;
    
    [(HDObjectNode *)otherBody collisionWithPlayer:self.player completion:^(BOOL update, HDObjectType type) {
        switch (type) {
                break;
            case HDObjectTypePlatform:
                [self _platformUpdate:update];
                break;
            case HDObjectTypeBomb:
                [self _bombUpdate:update];
                break;
            case HDObjectTypeKey:
                break;
            case HDObjectTypeNone:
                break;
            default:
                break;
        }
    }];
}

- (void)_bombUpdate:(BOOL)update {
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)_boostUpdate:(BOOL)update {
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)_platformUpdate:(BOOL)update {
    
    if (!update) {
        return;
    }
    
    if ([self.player childNodeWithName:HDBOOST_KEY]) {
        [[self.player childNodeWithName:HDBOOST_KEY] removeFromParent];
    }
    
    [self _addBoostToNode:(SKSpriteNode *)[self.player childNodeWithName:HDPLAYER_KEY]];
}

- (CGPoint)_coinPositionForRow:(NSUInteger)row column:(NSUInteger)column {
    
    CGFloat kDistance = ceilf(self.size.width / (NumberOfColumns - 1));
    return CGPointMake((kDistance * column), ((kDistance * 2.0f) * row));
}

#pragma mark - Nodes

- (SKNode *)_createPlayer {
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Player"];
    sprite.name = HDPLAYER_KEY;
    
    SKNode *playerNode = [SKNode node];
    playerNode.position = CGPointMake(self.size.width/2, 60.0f);
    playerNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
    playerNode.physicsBody.dynamic = NO;
    playerNode.physicsBody.allowsRotation = NO;
    playerNode.physicsBody.restitution = 1.0f;
    playerNode.physicsBody.friction = 0.0f;
    playerNode.physicsBody.angularDamping = 0.0f;
    playerNode.physicsBody.linearDamping = 0.0f;
    playerNode.physicsBody.usesPreciseCollisionDetection = YES;
    playerNode.physicsBody.categoryBitMask = HDCollisionCategoryPlayer;
    playerNode.physicsBody.collisionBitMask = 0;
    playerNode.physicsBody.contactTestBitMask = HDCollisionCategoryPlatform;
    [playerNode addChild:sprite];
    
    return playerNode;
}

- (HDPlatformNode *)_createPlatformAtPosition:(CGPoint)position ofType:(HDPlatformType)type {
    
    SKSpriteNode *sprite;
    if (type == HDPlatformTypeLarge) {
        sprite = [SKSpriteNode spriteNodeWithImageNamed:@"PlatformLarge"];
    } else if (type == HDPlatformTypeMedium) {
        sprite = [SKSpriteNode spriteNodeWithColor:[SKColor flatPeterRiverColor] size:CGSizeMake(50.0f, 15.0f)];
    } else if (type == HDPlatformTypeSmall) {
        sprite = [SKSpriteNode spriteNodeWithColor:[SKColor flatPeterRiverColor] size:CGSizeMake(25.0f, 15.0f)];
    }
    
    HDPlatformNode *node = [HDPlatformNode node];
    node.position = position;
    node.name = HDNODE_PLATFORM;
    node.platformType = type;
    node.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
    node.physicsBody.dynamic = NO;
    node.physicsBody.categoryBitMask = HDCollisionCategoryPlatform;
    node.physicsBody.collisionBitMask = 0;
    [node addChild:sprite];
    
    return node;
}

@end
