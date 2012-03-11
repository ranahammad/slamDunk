//
//  TBMainMenuScene.m
//  TBGame
//
//  Created by Rana Hammad Hussain on 4/22/11.
//  Copyright 2011 Azosh & Co. All rights reserved.
//

#import "TBMainMenuScene.h"

#import "TBGameScene.h"
#import "TBInstructions.h"
#import "TBCredits.h"

@implementation TBMainMenuScene

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TBMainMenuScene *layer = [TBMainMenuScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void) playClicked
{
	[appDelegate playClick];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5
																					 scene:[TBGameScene scene]]];
}

- (void) instructionsClicked
{
	[appDelegate playClick];
	
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5
																					 scene:[TBInstructions scene]]];
}

- (void) shareClicked
{
	[appDelegate playClick];
	
	[appDelegate postToFacebook:0 gameWin:false withCharIdx:(rand()%3)+1];
	
	// show pop up and share stuff
}

- (void) creditsClicked
{
	[appDelegate playClick];
	
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:0.5
																					 scene:[TBCredits scene]]];
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) 
	{
		
		appDelegate = (TBGameAppDelegate*)[[UIApplication sharedApplication] delegate];
		
		CGPoint center = appDelegate.gameState.screenCenter;
		
		CCSprite *backgroundSprite = [CCSprite spriteWithFile:@"background.png"];
		backgroundSprite.position = center;
		[self addChild:backgroundSprite];
		
		ball = [CCSprite spriteWithFile:@"ball.png"];
		ball.position = ccp(86, 178);
		[self addChild:ball];
		
		[ball runAction:[CCCallFunc actionWithTarget:self selector:@selector(performJumps)]];
				
		CCSprite *menuHolder = [CCSprite spriteWithFile:@"Menu.png"];
		menuHolder.position = ccp(360, 160);
		[self addChild:menuHolder];
		
		
		CCMenuItem *play = [CCMenuItemImage itemFromNormalImage:@"Play_btn.png"
														   target:self
														 selector:@selector(playClicked)];
		
		CCMenuItem *instructions = [CCMenuItemImage itemFromNormalImage:@"Instructions_btn.png"
																   target:self
																 selector:@selector(instructionsClicked)];
		
		CCMenuItem *share = [CCMenuItemImage itemFromNormalImage:@"Share_btn.png"
															target:self
														  selector:@selector(shareClicked)];

		CCMenuItem *credits = [CCMenuItemImage itemFromNormalImage:@"Credits_btn.png"
															target:self
														  selector:@selector(creditsClicked)];
		
		CCMenu *menu = [CCMenu menuWithItems:play, instructions, share, credits, nil];
		[menu alignItemsVertically];
		menu.position = ccp(360, 120);
		
		[self addChild:menu];
	}
	return self;
}

- (void)performJumps
{
	[ball runAction:[CCSequence actions:[CCJumpBy actionWithDuration:1.0f
															position:ccp(0,0)
															  height:50
															   jumps:1],
					 [CCCallFunc actionWithTarget:self selector:@selector(performJumps)],
					 nil]];
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
