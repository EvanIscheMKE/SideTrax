//
//  HDGameScene.m
//  FlatJump
//
//  Created by Evan Ische on 3/27/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

@import AVFoundation;
@import AudioToolbox;

#import "HDSaveNode.h"
#import "HDGameScene.h"
#import "SKColor+HDColor.h"
#import "UIColor+FlatColors.h"
#import "HDPointsManager.h"
#import "HDObjectNode.h"
#import "HDBarrierNode.h"
#import "HDGridManager.h"
#import "HDAppDelegate.h"
#import "SKEmitterNode+HDEmitterAdditions.h"
#import "SKSpriteNode+HDSpriteNodeAdditions.h"

#define TRANSFORM_SCALE_X [UIScreen mainScreen].bounds.size.width  / 375.0f

#define COLUMN_WIDTH ([UIScreen mainScreen].bounds.size.width - BARRIER_WIDTH * 2)/5

#define ROW_HEIGHT floor((COLUMN_WIDTH * 2.0f))

#define BARRIER_WIDTH ceilf(14 * TRANSFORM_SCALE_X)

#define GAME_SPEED_NORMAL 4
#define GAME_SPEED_FAST 6

typedef NS_OPTIONS(uint32_t, HDCollisionCategory) {
    HDCollisionCategoryNone     = 0x0,
    HDCollisionCategoryPlayer   = 0x1 << 0,
    HDCollisionCategoryPlatform = 0x1 << 1,
};

NSString * const HDPlayerKey   = @"playerKey";
NSString * const HDPlatformKey = @"HDPlatformNode";
NSString * const HDEmitterKey  = @"emitterKey";
NSString * const HDLevelLayoutNotificationKey = @"layoutNotificationKey";
@interface HDGameScene ()<SKPhysicsContactDelegate>
@property (nonatomic, strong) SKNode *player;
@property (nonatomic, strong) SKNode *objectLayerNode;
@property (nonatomic, strong) SKNode *hudLayerNode;
@property (nonatomic, strong) SKLabelNode *labelNode;
@end

@implementation HDGameScene {
    
    BOOL _gameOver;
    BOOL _animating;
    
    NSInteger _currentRow;
    
    CGPoint _velocity;
    CGFloat _velocityX;
}

- (instancetype)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    
    [HDPointsManager sharedManager].score = 0;
    
    self.backgroundColor = [SKColor flatMidnightBlueColor];
    self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
    self.physicsWorld.contactDelegate = self;
    
    self.objectLayerNode = [SKNode node];
    [self addChild:self.objectLayerNode];
    
    self.hudLayerNode = [SKNode node];
    [self addChild:self.hudLayerNode];
    
    self.labelNode = [self _labelNode];
    [self.hudLayerNode addChild:self.labelNode];
    
    _currentRow = 3;
    _gameOver = NO;
}

- (void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
    _velocityX = self.gameSpeed == HDGameSpeedFast ? GAME_SPEED_FAST : GAME_SPEED_NORMAL;
}

- (SKLabelNode *)_labelNode {
    
    SKLabelNode *label = [SKLabelNode node];
    label.fontSize = 46.0f;
    label.zPosition = 100;;
    label.position = CGPointMake(self.size.width/2, self.size.height - label.fontSize);
    label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    label.fontColor = [SKColor whiteColor];
    label.fontName = @"GillSans";
    
    return label;
}

- (void)layoutChildrenNode {
    
    NSRange range = self.gridManager.range;
    for (NSInteger row = range.location; row < range.location + range.length; row++) {
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
    
    if (fmod(self.player.position.y + 5.0f, self.speed != HDGameSpeedNormal ? 550.0f : 1100.0f) < 4) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HDLevelLayoutNotificationKey object:nil];
    }
    
    if (self.player.position.y > ROW_HEIGHT) {
        NSInteger points = self.player.position.y/ROW_HEIGHT;
        
        points -= 3;
        if (points > 0) {
            NSUInteger score = [HDPointsManager sharedManager].score;
            if (points > score) {
                [HDPointsManager sharedManager].score = points;
                self.labelNode.text = [NSString stringWithFormat:@"%tu",points];
                _velocity.y += .025f;
            }
        }
    }
    
    [self.objectLayerNode enumerateChildNodesWithName:HDPlatformKey usingBlock:^(SKNode *node, BOOL *stop) {
        [(HDBarrierNode *)node checkNodePositionForRemoval:self.player.position.y];
    }];
    
    if (self.player.position.y > 200.0f) {
        self.objectLayerNode.position = CGPointMake(self.objectLayerNode.position.x, -(self.player.position.y - 200.0f));
    }
}

- (void)_endGame {
    [[HDAppDelegate sharedDelegate] presentCompletionViewControllerWithMovesCompleted:50];
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
    
    if (_gameOver && _animating) {
        return;
    }
    
    if (!self.player.physicsBody.dynamic){
        _velocity.y = self.gameSpeed == HDGameSpeedNormal ? GAME_SPEED_NORMAL : GAME_SPEED_FAST;
        self.player.physicsBody.dynamic = YES;
        return;
    };
    
    UITouch *touch = [touches anyObject];
    CGPoint position = [touch locationInNode:self.objectLayerNode];
    
    _animating = YES;
    if (position.x > self.size.width/2) {
        
        _currentRow++;
        if (_currentRow > 5) {
            
            _currentRow = 1;
            
            SKAction *rightEdge = [SKAction moveToX:self.size.width duration:.05f];
            SKAction *hide = [SKAction hide];
            
            [self.player runAction:[SKAction sequence:@[rightEdge,hide]] completion:^{
                CGPoint position = self.player.position;
                position.x = 0;
                self.player.position = position;
                
                SKAction *show = [SKAction unhide];
                SKAction *move = [SKAction moveToX:BARRIER_WIDTH + COLUMN_WIDTH/2 duration:.05f];
                [self.player runAction:[SKAction sequence:@[show, move]] completion:^{
                    _animating = NO;
                }];
            }];
            return;
        }
        
        [self.player runAction:[SKAction moveToX:self.player.position.x + COLUMN_WIDTH duration:.1f] completion:^{
            _animating = NO;
        }];
        return;
    }
    
    _currentRow--;
    if (_currentRow < 1) {
        
        _currentRow = 5;
        
        SKAction *rightEdge = [SKAction moveToX:0.0f duration:.05f];
        SKAction *hide = [SKAction hide];
        
        [self.player runAction:[SKAction sequence:@[rightEdge,hide]] completion:^{
            CGPoint position = self.player.position;
            position.x = self.size.width;
            self.player.position = position;
            
            SKAction *show = [SKAction unhide];
            SKAction *move = [SKAction moveToX:self.size.width - (BARRIER_WIDTH + COLUMN_WIDTH/2) duration:.05f];
            [self.player runAction:[SKAction sequence:@[show, move]] completion:^{
                _animating = NO;
            }];
        }];
        return;
    }
    
    [self.player runAction:[SKAction moveToX:self.player.position.x - COLUMN_WIDTH duration:.1f] completion:^{
        _animating = NO;
    }];
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    SKNode *otherBody = (contact.bodyA.node != self.player) ? contact.bodyA.node : contact.bodyB.node;
    
    [(HDObjectNode *)otherBody collisionWithPlayer:self.player completion:^(BOOL update, HDObjectType type) {
        switch (type) {
                break;
            case HDObjectTypePlatform:
                [self _platformUpdate];
                break;
            case HDObjectTypeNone:
                break;
            default:
                break;
        }
    }];
}

- (void)_platformUpdate {
    [self _saveMe];
}

- (CGPoint)_positionForRow:(NSUInteger)row column:(NSUInteger)column {
    
    CGFloat kPositionY = (ROW_HEIGHT * row);
    
    if (column == 0) {
        return CGPointMake(BARRIER_WIDTH/2, kPositionY - ROW_HEIGHT/2 - BARRIER_WIDTH/2);
    }
    
    if (column == NumberOfColumns -1) {
        return CGPointMake(self.size.width - BARRIER_WIDTH/2, kPositionY - ROW_HEIGHT/2 - BARRIER_WIDTH/2);
    }
    
    return CGPointMake(((self.size.width/2) - (2 * COLUMN_WIDTH)) + (COLUMN_WIDTH * (column-1)), kPositionY);
}

#pragma mark - Convience Nodes

- (SKNode *)_createPlayer {
    
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    sprite.name = HDPlayerKey;
    
    SKNode *playerNode = [SKNode node];
    playerNode.position = CGPointMake(self.size.width/2, sprite.size.height);
    playerNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width/2];
    playerNode.physicsBody.dynamic = NO;
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
    
    SKSpriteNode *sprite;
    sprite.zPosition = 5;
    switch (type) {
        case HDBarrierTypeHorizontalSquare:
            sprite = [SKSpriteNode spriteNodeWithColor:[SKColor flatSTYellowColor]
                                                  size:CGSizeMake(COLUMN_WIDTH, BARRIER_WIDTH)];
            sprite.anchorPoint = CGPointMake(.5f, 1.f);
            break;
        case HDBarrierTypeVerticalSquare:
            sprite = [SKSpriteNode spriteNodeWithColor:[SKColor flatSTYellowColor]
                                                  size:CGSizeMake(BARRIER_WIDTH, ROW_HEIGHT + BARRIER_WIDTH)];
            sprite.anchorPoint = CGPointMake(.5f, .5f);
            break;
    }
    
    HDBarrierNode *node = [HDBarrierNode node];
    node.zPosition = 10;
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

@end
