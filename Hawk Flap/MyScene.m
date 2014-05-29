//
//  MyScene.m
//  Hawk Flap
//
//  Created by Wayne Knoesen on 22/03/14.
//  Copyright (c) 2014 Wayne Knoesen. All rights reserved.
//

#import "MyScene.h"

@interface MyScene () {
    SKSpriteNode* _bird;
    SKColor* _skyColor;
    SKTexture* _pipeTexture1;
    SKTexture* _pipeTexture2;
    SKAction* _moveAndRemovePipes;
    
}
@end

@implementation MyScene

static NSInteger const kVerticalPipeGap = 100;

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /*Setup your size here*/
        
        self.physicsWorld.gravity = CGVectorMake(0.0, -5.0);
        
        _skyColor = [SKColor colorWithRed:113.0/255.0 green:197.0/255.0 blue:207.0/255.0 alpha:1.0];
        [self setBackgroundColor:_skyColor];
        
        SKTexture* birdTexture1 = [SKTexture textureWithImageNamed:@"Bird1"];
        birdTexture1.filteringMode = SKTextureFilteringNearest;
        SKTexture* birdTexture2 = [SKTexture textureWithImageNamed:@"Bird2"];
        birdTexture2.filteringMode = SKTextureFilteringNearest;
        
        SKAction* flap = [SKAction repeatActionForever:[SKAction animateWithTextures:@[birdTexture1,birdTexture2] timePerFrame:0.2]];
        
        _bird = [SKSpriteNode spriteNodeWithTexture:birdTexture1];
        [_bird setScale:2.0];
        _bird.position = CGPointMake(self.frame.size.width / 4, CGRectGetMidY(self.frame));
        [_bird runAction:flap];
        
        _bird.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_bird.size.height / 2];
        _bird.physicsBody.dynamic = YES;
        _bird.physicsBody.allowsRotation = NO;
        
        
        [self addChild:_bird];
        
        //Create Ground
        
        SKTexture* groundTexture = [SKTexture textureWithImageNamed:@"Ground"];
        groundTexture.filteringMode = SKTextureFilteringNearest;
        
        SKAction* movesGroundSprite = [SKAction moveByX:-groundTexture.size.width*2 y:0 duration:0.02];
        SKAction* resetGroundSprite = [SKAction moveByX:groundTexture.size.width*2 y:0 duration:0];
        SKAction* movesGroundSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[movesGroundSprite, resetGroundSprite]]];
        
        for ( int i = 0; i < 2 + self.frame.size.width / (groundTexture.size.width * 2); ++i) {
            SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:groundTexture];
            [sprite setScale:2.0];
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2);
            [sprite runAction:movesGroundSpritesForever];
            [self addChild:sprite];
        }
        
        // Create ground physics
        
        SKNode* dummy = [SKNode node];
        dummy.position = CGPointMake(0, groundTexture.size.height);
        dummy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width, groundTexture.size.height *2)];
        dummy.physicsBody.dynamic = NO;
        [self addChild:dummy];
        
        
        //Create Skyline
        
        SKTexture* skylineTexture = [SKTexture textureWithImageNamed:@"Skyline"];
        skylineTexture.filteringMode = SKTextureFilteringNearest;
        
        SKAction* moveSkylineSprite = [SKAction moveByX:-skylineTexture.size.width*2 y:0 duration:0.1 *skylineTexture.size.width*2];
        SKAction* resetSkylineSprite = [SKAction moveByX:skylineTexture.size.width*2 y:0 duration:0];
        SKAction* moveSkyineSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveSkylineSprite, resetSkylineSprite]]];
        
        for ( int i = 0; i < 2 + self.frame.size.width / (skylineTexture.size.width * 2); ++i ) {
            SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithTexture:skylineTexture];
            [sprite setScale:2.0];
            sprite.zPosition = -20;
            sprite.position = CGPointMake(i * sprite.size.width, sprite.size.height / 2 + groundTexture.size.height * 2);
            [sprite runAction:moveSkyineSpritesForever];
            [self addChild:sprite];
        }
        
        //Create pipes
        SKTexture* _pipeTexture1 = [SKTexture textureWithImageNamed:@"Pipe1"];
        _pipeTexture1.filteringMode = SKTextureFilteringNearest;
        SKTexture* _pipTexture2 = [SKTexture textureWithImageNamed:@"Pipe2"];
        _pipTexture2.filteringMode = SKTextureFilteringNearest;
        
        SKNode* pipePair = [SKNode node];
        pipePair.position = CGPointMake(self.frame.size.width + _pipeTexture1.size.width * 2, 0);
        pipePair.zPosition = -10;
        
        CGFloat y = arc4random() % (NSInteger)(self.frame.size.height / 3);
        
        SKSpriteNode* pipe1 = [SKSpriteNode spriteNodeWithTexture:_pipeTexture1];
        [pipe1 setScale:2];
        pipe1.position = CGPointMake( 0, y );
        pipe1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe1.size];
        pipe1.physicsBody.dynamic = NO;
        [pipePair addChild:pipe1];
        
        SKSpriteNode* pipe2 = [SKSpriteNode spriteNodeWithTexture:_pipTexture2];
        [pipe2 setScale:2];
        pipe2.position = CGPointMake(0, y + pipe1.size.height + kVerticalPipeGap );
        pipe2.physicsBody.dynamic = NO;
        [pipePair addChild:pipe2];
        
        SKAction* movePipes = [SKAction repeatActionForever:[SKAction moveByX:-1 y:0 duration:0.02]];
        [pipePair runAction:movePipes];
        
        [self addChild:pipePair];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    _bird.physicsBody.velocity = CGVectorMake(0, 0);
    [_bird.physicsBody applyImpulse:CGVectorMake(0, 8)];
    
}


CGFloat clamp(CGFloat min, CGFloat max, CGFloat value) {
    if (value > max ) {
        return max;
    } else if (value < min ) {
        return min;
    } else {
        return value;
    }
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    _bird.zRotation = clamp(-1, 0.5, _bird.physicsBody.velocity.dy * (_bird.physicsBody.velocity.dy < 0 ? 0.003 : 0.001 ) );
}

@end



























