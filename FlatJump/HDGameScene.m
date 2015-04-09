//
//  HDGameScene.m
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDSaveNode.h"
#import "HDGameScene.h"
#import "SKColor+HDColor.h"
#import "UIColor+FlatColors.h"
#import "HDPointsManager.h"
#import "HDObjectNode.h"
#import "HDDividerNode.h"
#import "HDGridManager.h"
#import "HDAppDelegate.h"
#import "SKEmitterNode+HDEmitterAdditions.h"


#define TRANSFORM_SCALE_X [UIScreen mainScreen].bounds.size.width  / 375.0f

#define COLUMN_WIDTH ([UIScreen mainScreen].bounds.size.width - BARRIER_WIDTH * 2)/5

#define ROW_HEIGHT floor((COLUMN_WIDTH * 2.325f))

#define BARRIER_WIDTH ceilf(14 * TRANSFORM_SCALE_X)


typedef NS_OPTIONS(uint32_t, HDCollisionCategory) {
    HDCollisionCategoryNone     = 0x0,
    HDCollisionCategoryPlayer   = 0x1 << 0,
    HDCollisionCategoryPlatform = 0x1 << 1,
};

NSString * const HDSAVEME_KEY = @"SAVE_ME";
NSString * const HDPLAYER_KEY = @"PLAYER_NODE";
NSString * const HDBOOST_KEY  = @"BOOST_EMITTER";
NSString * const HDNODE_KEY      = @"HDKeyNode";
NSString * const HDNODE_PLATFORM = @"HDPlatformNode";

@interface HDGameScene ()<SKPhysicsContactDelegate>
@property (nonatomic, strong) SKNode *player;
@property (nonatomic, strong) SKNode *parallexBottomNode;
@property (nonatomic, strong) SKNode *parallexMiddleNode;
@property (nonatomic, strong) SKNode *parallexTopNode;
@property (nonatomic, strong) SKNode *objectLayerNode;
@property (nonatomic, strong) SKNode *hudLayerNode;
@end

@implementation HDGameScene {
    CGPoint _velocity;
    CGFloat _endLevelY;
    CGFloat _maxPlayerY;
    BOOL _gameOver;
}

- (instancetype)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    
    self.backgroundColor = [SKColor flatMidnightBlueColor];
    self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
    self.physicsWorld.contactDelegate = self;
    
    self.parallexBottomNode = [self _createParallexBottomNode];
    [self addChild:self.parallexBottomNode];
    
    self.parallexTopNode = [self _layoutStars];
    [self addChild:self.parallexTopNode];
    
    self.objectLayerNode = [SKNode node];
    [self addChild:self.objectLayerNode];
    
    self.hudLayerNode = [SKNode node];
    [self addChild:self.hudLayerNode];
    
    _velocity.y = 0;
    _velocity.x = 0;
    _maxPlayerY = self.player.position.y;
    _gameOver = NO;
}

- (SKNode *)_createParallexBottomNode {
    
    SKNode *node = [SKNode node];
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Parallex-Bottom"];
    sprite.anchorPoint = CGPointMake(0.0, 0.0f);
    sprite.position = CGPointMake(0.0, 0.0f);
    [node addChild:sprite];
    
    return node;
}

- (SKNode *)_layoutStars {
    
    SKNode *backgroundNode = [SKNode node];
    for (NSUInteger nodeCount = 1; nodeCount < 9; nodeCount++) {
        NSString *backgroundImageName = [NSString stringWithFormat:@"Background%tu", nodeCount];
        SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:backgroundImageName];

        node.anchorPoint = CGPointMake(0.5f, 0.0f);
        node.position = CGPointMake(self.size.width/2, (nodeCount - 1)*node.size.height);
        [backgroundNode addChild:node];
    }
    return backgroundNode;
}

- (void)layoutChildrenNode {
    
    for (NSInteger row = 0; row < NumberOfRows; row++) {
        for (NSInteger column = 0; column < NumberOfColumns; column++) {
            
            NSNumber *type = [self.gridManager coinTypeAtRow:row column:column];
            NSUInteger intValue = [type unsignedIntegerValue];
            
            switch (intValue) {
                case 1:
                case 2:
                case 3:{
                    HDDividerNode *platform = [self _createBarrierAtPosition:[self _positionForRow:row column:column]
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
    [self _endGame];
//    CGSize size = CGSizeMake(self.size.width/3, 80.0f);
//    CGPoint position = CGPointMake(self.size.width/2, _maxPlayerY - kMaxPlayerDrop*2 - size.height/2);
//    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithWhite:0.0f alpha:.5f] size:size];
//    sprite.name = HDSAVEME_KEY;
//    
//    HDSaveNode *saveMe = [HDSaveNode node];
//    saveMe.name = HDSAVEME_KEY;
//    saveMe.position = position;
//    [saveMe addChild:sprite];
//    [self.objectLayerNode addChild:saveMe];
//    
//    CGFloat kPositionY = MAX(_maxPlayerY - kMaxPlayerDrop*1.25, size.height/2 + 10.0f);
//    
//    NSTimeInterval timeDelay = 3.0f;
//    [saveMe runAction:[SKAction moveToY:kPositionY duration:.3f] completion:^{
//        SKAction *waitAction = [SKAction waitForDuration:timeDelay];
//        SKAction *positionAction = [SKAction moveTo:position duration:.3f];
//        [saveMe runAction:[SKAction sequence:@[waitAction, positionAction]] completion:^{
//            [saveMe removeFromParent];
//            [self _endGame];
//        }];
//    }];
}

- (void)update:(CFTimeInterval)currentTime {
    
    if (_gameOver) {
        return;
    }
    
    CGPoint position = self.player.position;
    position.y += _velocity.y;
    position.x += _velocity.x;
    self.player.position = position;
    
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
                                               [(HDDividerNode *)node checkNodePositionForRemoval:self.player.position.y];
                                           }];
    
    if (self.player.position.y > 200.0f) {
        self.objectLayerNode.position    = CGPointMake(self.objectLayerNode.position.x, -(self.player.position.y - 200.0f));
        self.parallexBottomNode.position = CGPointMake(0.0f, -((_player.position.y - 200.0f)/10));
        self.parallexTopNode.position    = CGPointMake(0.0f, -((_player.position.y - 200.0f)/4));
    }
}

- (void)_endGame {
    [[HDAppDelegate sharedDelegate] presentCompletionViewControllerWithMovesCompleted:50];
    [[HDPointsManager sharedManager] saveState];
}

- (void)_addBoostToNode:(SKSpriteNode *)node {
    
    SKEmitterNode *boost = [SKEmitterNode playerBoostWithColor:[UIColor flatSTWhiteColor]];
    boost.name = HDBOOST_KEY;
    boost.targetNode = self.scene;
    boost.position = CGPointMake(0.0f, -node.size.height/2);
    [self.player addChild:boost];
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint position = [touch locationInNode:self.objectLayerNode];
    SKNode *node = [self.objectLayerNode nodeAtPoint:position];
    
    [self touchesMoved:touches withEvent:event];
    
    if ([node.name isEqualToString:HDSAVEME_KEY]) {
        // Check for Coins to make sure they have enough to purchase it, otherwise present buy coins menu
        self.player.physicsBody.dynamic = NO;
    //    self.player.position = CGPointMake(self.player.position.x, (_maxPlayerY - kMaxPlayerDrop) + 1.0f);
        self.player.physicsBody.dynamic = YES;
        [self _addBoostToNode:(SKSpriteNode *)[self.player childNodeWithName:HDPLAYER_KEY]];
        _gameOver = NO;
    }
    
    if (!self.player.physicsBody.dynamic && !_gameOver){
         _velocity.y = 4;
         self.player.physicsBody.dynamic = YES;
        [self _addBoostToNode:(SKSpriteNode *)[self.player childNodeWithName:HDPLAYER_KEY]];
        return;
    };
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint position = [touch locationInNode:self.objectLayerNode];
    
    if (position.x > self.size.width/2) {
        _velocity.x = 5.0f;
    } else {
        _velocity.x = -5.0f;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _velocity.x = 0;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _velocity.x = 0;
}

#pragma mark - <SKPhysicsContactDelegate>

- (void)didSimulatePhysics {
    
    SKSpriteNode *player = (SKSpriteNode *)[self.player childNodeWithName:HDPLAYER_KEY];
    const CGFloat kOffset = player.size.width/2;
    if (self.player.position.x < -kOffset) {
        self.player.position = CGPointMake(self.size.width + kOffset, _player.position.y);
    } else if (_player.position.x > self.size.width + kOffset) {
        self.player.position = CGPointMake(-kOffset, _player.position.y);
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    SKNode *otherBody = (contact.bodyA.node != self.player) ? contact.bodyA.node : contact.bodyB.node;
    
    [(HDObjectNode *)otherBody collisionWithPlayer:self.player completion:^(BOOL update, HDObjectType type) {
        switch (type) {
                break;
            case HDObjectTypePlatform:
                [self _platformUpdate:update];
                break;
            case HDObjectTypeNone:
                break;
            default:
                break;
        }
    }];
}

- (void)_boostUpdate:(BOOL)update {
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)_platformUpdate:(BOOL)update {
    
    _velocity.y = 0;
//    [self _saveMe];
    
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (CGPoint)_positionForRow:(NSUInteger)row column:(NSUInteger)column {

    CGFloat kPositionY = (ROW_HEIGHT * row);

    if (column == 0) {
        return CGPointMake(BARRIER_WIDTH/2, kPositionY);
    }
    
    if (column == NumberOfColumns -1) {
        return CGPointMake(self.size.width - BARRIER_WIDTH/2, kPositionY);
    }
    
    return CGPointMake(((self.size.width/2) - (2 * COLUMN_WIDTH)) + (COLUMN_WIDTH * (column-1)), kPositionY);
}

#pragma mark - Convience Nodes

- (SKNode *)_createPlayer {
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Player"];
    sprite.name = HDPLAYER_KEY;
    
    SKNode *playerNode = [SKNode node];
    playerNode.position = CGPointMake(self.size.width/2, 0.0f);
    playerNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
    playerNode.physicsBody.dynamic = NO;
    playerNode.physicsBody.allowsRotation = NO;
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

- (HDDividerNode *)_createBarrierAtPosition:(CGPoint)position ofType:(HDDividerType)type {
    
    SKSpriteNode *sprite;
    switch (type) {
        case 1:
            sprite = [SKSpriteNode spriteNodeWithColor:[UIColor flatSTRedColor] size:CGSizeMake(COLUMN_WIDTH, BARRIER_WIDTH)];
            sprite.anchorPoint = CGPointMake(.5f, 1.f);
            break;
        case 2:
            sprite = [SKSpriteNode spriteNodeWithColor:[UIColor flatSTRedColor] size:CGSizeMake(BARRIER_WIDTH, ROW_HEIGHT)];
            sprite.anchorPoint = CGPointMake(.5f, 1.f);
            break;
        default:
            break;
    }
 
    HDDividerNode *node = [HDDividerNode node];
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
