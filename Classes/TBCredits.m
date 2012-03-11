//
//  TBCredits.m
//  TBGame
//
//  Created by Rana Hammad Hussain on 4/22/11.
//  Copyright 2011 Azosh & Co. All rights reserved.
//

#import "TBCredits.h"
#import "TBGameAppDelegate.h"
#import "TBMainMenuScene.h"


@implementation TBCredits
+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TBCredits *layer = [TBCredits node];
	
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
	if( (self=[super init] )) {
		
		CGPoint center = [(TBGameAppDelegate*)[[UIApplication sharedApplication] delegate] gameState].screenCenter;
		
		CCSprite *background = [CCSprite spriteWithFile:@"credits.png"];
		background.position = center;
		[self addChild:background];
				
		CCMenuItem *back = [CCMenuItemImage itemFromNormalImage:@"Back_button.png"
														   target:self
														 selector:@selector(backClicked)];
		CCMenuItem *crowdInfo = [CCMenuItemImage itemFromNormalImage:@"credits_crowd.png"
															  target:self
															selector:@selector(crowdsClicked)];
		CCMenu *menu = [CCMenu menuWithItems:back,nil];
		menu.position = ccp(0,0);
		back.position = ccp(430, 30);
		
		
		CCMenu *menu1 = [CCMenu menuWithItems:crowdInfo, nil];
		[menu1 setPosition:ccp(0,0)];
		crowdInfo.position = ccp(82,258);
		
		menu1.opacity = 0;
		
		[self addChild:menu];
		[self addChild:menu1];
		
		// 3crowd.com
	}
	return self;
}

- (void) crowdsClicked
{
	[(TBGameAppDelegate*)[[UIApplication sharedApplication] delegate] playClick];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.3scrowd.com"]];
}

- (void) backClicked
{
	[(TBGameAppDelegate*)[[UIApplication sharedApplication] delegate] playClick];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.5 
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
