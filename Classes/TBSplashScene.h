//
//  TBSplashScene.h
//  TBGame
//
//  Created by Rana Hammad Hussain on 4/22/11.
//  Copyright 2011 Azosh & Co. All rights reserved.
//

#import "cocos2d.h"
#import "TBGameAppDelegate.h"

@interface TBSplashScene : CCLayer
{
	CCSprite *loadingSprite;
	TBGameAppDelegate *appDelegate;
}

+(id) scene;

@end
