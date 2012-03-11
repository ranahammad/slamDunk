//
//  TBGameState.m
//  TBGame
//
//  Created by Rana Hammad Hussain on 4/22/11.
//  Copyright 2011 Azosh & Co. All rights reserved.
//

#import "TBGameState.h"


@implementation TBGameState

@synthesize screenSize;
@synthesize screenCenter;
@synthesize firstTimeRunning;
@synthesize selectedCharacterIndex;

-(id) initWithScreenSize:(CGSize)pSize
{
	self = [super init];
	if(self)
	{
		screenSize = pSize;
		screenCenter.x = screenSize.width/2;
		screenCenter.y = screenSize.height/2;
		firstTimeRunning = true;
		selectedCharacterIndex = 1;
		
		[self loadState];
	}
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) loadState
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if ([defaults objectForKey:@"GAME.STATE.FIRSTTIMERUNNING"]) 
	{
		firstTimeRunning = [defaults boolForKey:@"GAME.STATE.FIRSTTIMERUNNING"];
	}
	
	if([defaults objectForKey:@"GAME.STATE.SELECTEDCHARACTER"])
	{
		selectedCharacterIndex = [defaults integerForKey:@"GAME.STATE.SELECTEDCHARACTER"];
	}

}

-(void) saveState
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setBool:firstTimeRunning forKey:@"GAME.STATE.FIRSTTIMERUNNING"];
	[defaults setInteger:selectedCharacterIndex forKey:@"GAME.STATE.SELECTEDCHARACTER"];
	[defaults synchronize];
	
}

@end
