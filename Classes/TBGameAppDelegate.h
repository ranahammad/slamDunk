//
//  TBGameAppDelegate.h
//  TBGame
//
//  Created by Rana Hammad Hussain on 4/22/11.
//  Copyright Azosh & Co. 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBGameState.h"
#import "SimpleAudioEngine.h"
#import "FacebookAgent.h"

#define FB_API_KEY		@"026d6776f92b58328aac11fd545475bc"
#define FB_API_SECRET	@"a851efb8e4d0a73322b2ac670c4cdf9f"

@class RootViewController;

@interface TBGameAppDelegate : NSObject <UIApplicationDelegate,FacebookAgentDelegate>
{
	UIWindow			*window;
	RootViewController	*viewController;
	
	TBGameState *gameState;
	
	BOOL gameSceneRunning;
	
	SimpleAudioEngine *pAudioEngine;
	FacebookAgent* fbAgent;
	
	int iScore;

}

@property (nonatomic, retain) TBGameState *gameState;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic) BOOL gameSceneRunning;


-(void) playGamemusic;
-(void) stopGamemusic;
-(void) playClick;
-(void) playBallHit;
-(void) postToFacebook:(int)score gameWin:(bool)win withCharIdx:(int)charIdx;


@end
