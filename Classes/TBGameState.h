//
//  TBGameState.h
//  TBGame
//
//  Created by Rana Hammad Hussain on 4/22/11.
//  Copyright 2011 Azosh & Co. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBGameState : NSObject 
{
	// store device resolution
	
	CGSize screenSize;
	CGPoint screenCenter;
	
	// store game states
	
	BOOL firstTimeRunning;
	int selectedCharacterIndex;
}

@property (nonatomic) CGSize screenSize;
@property (nonatomic) CGPoint screenCenter;
@property (nonatomic) BOOL firstTimeRunning;
@property (nonatomic) int selectedCharacterIndex;

-(id) initWithScreenSize:(CGSize)pSize;

-(void) saveState;
-(void) loadState;

@end
