//
//  TBGameScene.h
//  TBGame
//
//  Created by Rana Hammad Hussain on 4/22/11.
//  Copyright 2011 Azosh & Co. All rights reserved.
//

#import "cocos2d.h"
#import "TBGameState.h"

@class TBGameAppDelegate;

@interface TBGameScene : CCLayer {

	TBGameAppDelegate* gameDelegate;
	TBGameState *gameState;
	
	bool pause;
	bool ballOverBasket;
	bool gameOver;
	CGPoint ballMovementDelta;
	float ballRadius;
	
	CCMenuItem *leftControl;
	CCMenuItem *rightControl;
	//CCMenuItem *start;
	CCMenu *Backmenu;
	
	CCSprite *goLabel3;
	CCSprite *goLabel2;
	CCSprite *goLabel1;	
	CCSprite *goLabelGO;
	
	
	int startTime;
	int characterIdx;
	int computerIdx;

	bool showingGoLabel;
	bool computerJumping;
	bool playerJumping;
	bool moveLeft;
	bool moveRight;
	int playerScore;
	int computerScore;
	int timer;
	
	CCLabelTTF *playerScoreLabel;
	CCLabelTTF *computerScoreLabel;
	CCLabelTTF *timerLabel;
	
	CCSprite *ball;
	CCSprite *player;
	CCSprite *computer;
	CCSprite *leftBasket;
	CCSprite *rightBasket;
	
	// instructions
	CCSprite *instructionsBg;
	CCSprite *charactersBg;
	CCSprite *playerSelectionBg;
	CCMenu *menuInstructions;
	CCMenu *menuPlayerSelection;
		
	CCSprite *gameOverBg;
	CCSprite *pauseBg;
	CCSprite *selectedCharacterBg;
}

+(id) scene;

- (void) showGoLabel;
- (void) updateGoLabel;
- (void) showInstructions;
- (void) instructionsEnded;
- (void) addGameObjects;

- (void) startClicked;
- (void) backClicked;
- (void) nextClicked;
- (void) updateTimer;

// game specific
-(int) detectOverBasket;
-(bool) detectBallBoundaryCheck;
-(bool) detectBallPlayerCollision:(CCSprite *)cPlayer;
-(void) resetBallPosition;
-(void) updateBallPosition;

@end
