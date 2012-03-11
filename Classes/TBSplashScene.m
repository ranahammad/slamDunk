//
//  TBSplashScene.m
//  TBGame
//
//  Created by Rana Hammad Hussain on 4/22/11.
//  Copyright 2011 Azosh & Co. All rights reserved.
//

#import "TBSplashScene.h"
#import "TBMainMenuScene.h"

@implementation TBSplashScene
+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TBSplashScene *layer = [TBSplashScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) 
	{
		
		appDelegate = (TBGameAppDelegate*)[[UIApplication sharedApplication] delegate];
		
		loadingSprite = [CCSprite spriteWithFile:@"splash.png"];
		loadingSprite.position = appDelegate.gameState.screenCenter;
		
		[self addChild:loadingSprite];
		
		[loadingSprite runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0],
								  [CCCallFunc actionWithTarget:self selector:@selector(show3Logo)],
								  [CCFadeOut actionWithDuration:1.0],
								  nil]];
	}
	return self;
}

-(void)show3Logo
{	
	CCSprite *threeLogo = [CCSprite spriteWithFile:@"3logo.png"];
	threeLogo.position = appDelegate.gameState.screenCenter;
	[self addChild:threeLogo];
	
	threeLogo.opacity = 0;
	[threeLogo runAction:[CCSequence actions:[CCFadeIn actionWithDuration:1.0],
						  [CCDelayTime actionWithDuration:1.0],
						  [CCCallFunc actionWithTarget:self selector:@selector(showMainMenu)],
						  nil]];
}

-(void)showMainMenu
{
	[[CCDirector sharedDirector] replaceScene:
	 [CCTransitionRotoZoom transitionWithDuration:2.0 
											scene:[TBMainMenuScene scene]]];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
