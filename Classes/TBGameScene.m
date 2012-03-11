//
//  TBGameScene.m
//  TBGame
//
//  Created by Rana Hammad Hussain on 4/22/11.
//  Copyright 2011 Azosh & Co. All rights reserved.
//

#import "TBGameScene.h"
#import "TBGameAppDelegate.h"
#import "TBMainMenuScene.h"

#define GAME_TIME	120

#define CHARACTER_WIDTH	68
#define CHARACTER_HEIGHT	75
#define PLAYER_START_Y CHARACTER_HEIGHT/2
#define PLAYER_MOVE_X	5
#define PLAYER_JUMP_HEIGHT	100
#define PLAYER_JUMP_SPEED	0.6

#define BALL_RADIUS	22
#define HEAD_RADIUS 20
#define BALL_MOVE_X	4.0//(48/6.0)
#define BALL_MOVE_Y	5.0//32/6

#define BALL_X_DELTA 0.0
#define BALL_Y_DELTA 0.0

#define BALL_MOVE_SPEED 0.5

@implementation TBGameScene
+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TBGameScene *layer = [TBGameScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) initGamePlayVariables
{
	gameDelegate = (TBGameAppDelegate*)[[UIApplication sharedApplication] delegate];
	gameDelegate.gameSceneRunning = TRUE;
	
	gameState = [(TBGameAppDelegate*)[[UIApplication sharedApplication] delegate] gameState];

	characterIdx = gameState.selectedCharacterIndex;
	pause = true;
	gameOver = true;
	timer = GAME_TIME;
	playerScore = 0;
	computerScore = 0;
	
	playerJumping = false;
	computerJumping = false;
	showingGoLabel = false;

}

-(void) addBall
{
	ball = [CCSprite spriteWithFile:@"ball.png"];
		
	ball.position = ccp(gameState.screenCenter.x, gameState.screenSize.height + BALL_RADIUS);
	ballMovementDelta = ccp(-BALL_MOVE_X, -BALL_MOVE_Y);
	ballRadius = BALL_RADIUS;
	
	ballOverBasket = false;
	[self addChild:ball z:3];
}

-(void) addBaskets
{
	// add left basket
	leftBasket = [CCSprite spriteWithFile:@"Rightpole.png"];
	leftBasket.position = ccp(44, gameState.screenCenter.y-25);
	[self addChild:leftBasket z:2];
	
	// add right basket
	rightBasket = [CCSprite spriteWithFile:@"Leftpole.png"];
	rightBasket.position = ccp(gameState.screenSize.width-44, gameState.screenCenter.y-25);
	[self addChild:rightBasket z:2];
}

-(void) leftClicked
{}

-(void) rightClicked
{}

-(void) addCharacters
{
	int rand2 = random()%2;
	// add player character
	switch(characterIdx)
	{
		case 1:
			player = [CCSprite spriteWithFile:@"Blue.png"];
			if(rand2==0)
			{
				computerIdx = 3;
				computer = [CCSprite spriteWithFile:@"Yellow.png"];
			}
			else 
			{
				computerIdx = 2;
				computer = [CCSprite spriteWithFile:@"Orange.png"];
			}
			break;
		case 2:
			player = [CCSprite spriteWithFile:@"Orange.png"];
			if(rand2==0)
			{
				computerIdx = 3;
				computer = [CCSprite spriteWithFile:@"Yellow.png"];
			}
			else 
			{
				computerIdx = 1;
				computer = [CCSprite spriteWithFile:@"Blue.png"];
			}
			
			break;
		default:
			player = [CCSprite spriteWithFile:@"Yellow.png"];
			if(rand2==0)
			{
				computerIdx = 1;
				computer = [CCSprite spriteWithFile:@"Blue.png"];
			}
			else 
			{
				computerIdx = 2;
				computer = [CCSprite spriteWithFile:@"Orange.png"];
			}
			
			break;
	}
	
	player.position = ccp(gameState.screenCenter.x - 40, PLAYER_START_Y);
	computer.position = ccp(gameState.screenCenter.x + 40, PLAYER_START_Y);
	[self addChild:player z:9];
	// add controls to handle it
	
	[self addChild:computer z:9];
	
	playerJumping = FALSE;
	moveLeft = FALSE;
	moveRight = FALSE;
	
	leftControl = [CCMenuItemImage itemFromNormalImage:@"backarrow.png"
															  target:self 
															selector:@selector(leftClicked)];
	
	rightControl = [CCMenuItemImage itemFromNormalImage:@"nextarrow.png"
															   target:self 
															 selector:@selector(rightClicked)];

	leftControl.position = ccp(40,20);
	rightControl.position = ccp(gameState.screenSize.width-40, 20);
	
	leftControl.scale = 1.4f;
	rightControl.scale = 1.4f;
	
	CCMenu *menu = [CCMenu menuWithItems:leftControl, rightControl, nil];
	menu.position = ccp(0,0);
}

-(void) playerLanded
{
	[player stopAllActions];
	player.scale = 1.0f;
	player.position = ccp(player.position.x, PLAYER_START_Y);

	playerJumping = false;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
	if(!pause && !gameOver)
	{
		if(!playerJumping)
		{
			playerJumping = true;

//			[player setPosition:ccp(player.position.x,player.position.y-10)];
			CCSequence *seq1 = [CCSequence actions:
								[CCJumpBy actionWithDuration:(PLAYER_JUMP_SPEED)
													position:ccp(0,0)
													  height:PLAYER_JUMP_HEIGHT
													   jumps:1],
								//								[CCScaleBy actionWithDuration:(PLAYER_JUMP_SPEED/3.0) scaleX:1 scaleY:0.8f],
//								[CCScaleTo actionWithDuration:(2.0*PLAYER_JUMP_SPEED/3.0) scaleX:1 scaleY:1.0f],
								[CCCallFunc actionWithTarget:self selector:@selector(playerLanded)], nil];
			
//			CCSequence *seq2 = [CCSequence actions:[CCDelayTime actionWithDuration:(PLAYER_JUMP_SPEED/3.0)],
//								[CCJumpBy actionWithDuration:(2.0*PLAYER_JUMP_SPEED/3.0)
//													position:ccp(0,10)
//													  height:PLAYER_JUMP_HEIGHT
//													   jumps:1],nil];
			
		//	CCSpawn *spawn = [CCSpawn actions:seq1,seq2,nil];

			[player runAction:seq1];
		}
	}
}

-(void)characterSelectedEnded
{
	[self addGameObjects];
	[self showGoLabel];
}

- (void) characterSelected
{
	[gameDelegate playClick];
	[self removeChild:menuPlayerSelection cleanup:TRUE];
	[self removeChild:selectedCharacterBg cleanup:TRUE];
	menuPlayerSelection = nil;
	
	[charactersBg runAction:[CCSequence actions:
							   [CCFadeOut actionWithDuration:1.0],
							   [CCCallFunc actionWithTarget:self selector:@selector(characterSelectedEnded)],nil]];

}

- (void)yellowCharacterClicked
{
	[gameDelegate playClick];
	
	characterIdx = 3;
	selectedCharacterBg.position = ccp(gameState.screenCenter.x + 100, gameState.screenCenter.y-40);
}

- (void)orangeCharacterClicked
{
	[gameDelegate playClick];
	characterIdx = 2;
	selectedCharacterBg.position = ccp(gameState.screenCenter.x, gameState.screenCenter.y-40);
}

- (void)blueCharacterClicked
{
	[gameDelegate playClick];
	characterIdx = 1;
	selectedCharacterBg.position = ccp(gameState.screenCenter.x - 100, gameState.screenCenter.y-40);
}

- (void) selectCharacter
{
	selectedCharacterBg = [CCSprite spriteWithFile:@"Select_box.png"];
	charactersBg = [CCSprite spriteWithFile:@"Select_Character.png"];
	charactersBg.position = gameState.screenCenter;
	[self addChild:charactersBg z:5];
	
	CCMenuItem *menuBack = [CCMenuItemImage itemFromNormalImage:@"menu_btn.png"
														   target:self
														 selector:@selector(menuClicked)];
	
	CCMenuItem *blueCharacter = [CCMenuItemImage itemFromNormalImage:@"Blue.png"
													   selectedImage:@"Blue.png"
															  target:self
															selector:@selector(blueCharacterClicked)];
	CCMenuItem *orangeCharacter = [CCMenuItemImage itemFromNormalImage:@"Orange.png"
														 selectedImage:@"Orange.png"
															  target:self
															selector:@selector(orangeCharacterClicked)];
	CCMenuItem *yellowCharacter = [CCMenuItemImage itemFromNormalImage:@"Yellow.png"
														 selectedImage:@"Yellow.png"
															  target:self
															selector:@selector(yellowCharacterClicked)];
	
	CCMenuItem *menuNext = [CCMenuItemImage itemFromNormalImage:@"Select_btn.png" 
														   target:self
														 selector:@selector(characterSelected)];
	menuPlayerSelection = [CCMenu menuWithItems:menuBack, blueCharacter, orangeCharacter, yellowCharacter,menuNext, nil];
	[self addChild:selectedCharacterBg z:6];
	[self addChild:menuPlayerSelection z:7];
	menuPlayerSelection.position = ccp(0,0);
	menuBack.position = ccp(80, 280);
	menuNext.position = ccp(390, 50);
	
	blueCharacter.position = ccp(gameState.screenCenter.x - 100, gameState.screenCenter.y-40);
	orangeCharacter.position = ccp(gameState.screenCenter.x, gameState.screenCenter.y-40);
	yellowCharacter.position = ccp(gameState.screenCenter.x + 100, gameState.screenCenter.y-40);
	
	characterIdx = 1;
	//selectedCharacterBg.opacity = 32;
	selectedCharacterBg.position = ccp(blueCharacter.position.x, blueCharacter.position.y);
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	if(fabs(acceleration.y) < 0.02)
		return;
	
	if(!pause && !gameOver && !playerJumping)
	{
		if(acceleration.y<0)
		{
			player.position = ccp(player.position.x+PLAYER_MOVE_X, player.position.y);
			if(player.position.x >= (gameState.screenSize.width-60))
				player.position = ccp(gameState.screenSize.width-60, player.position.y);			
		}
		else
		{
			player.position = ccp(player.position.x-PLAYER_MOVE_X,player.position.y);
			if(player.position.x <= 60)
				player.position = ccp(60, player.position.y);
		}
	}
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		
		[self initGamePlayVariables];
		
		CCSprite *background = [CCSprite spriteWithFile:@"level_bg.png"];
		background.position = gameState.screenCenter;
		[self addChild:background];

		// add poles
		[self addBaskets];
		
		[self setIsTouchEnabled:true];
		self.isAccelerometerEnabled = YES;
		
		[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60)];
		
		menuInstructions = nil;
		menuPlayerSelection = nil;
		pause = false;

		if(gameState.firstTimeRunning)
		{
			// show instructions menu
			[self showInstructions];
			
			gameState.firstTimeRunning = false;
			[gameState saveState];
			// then show select player
		}
		else
		{
			[self selectCharacter];
		}
	}
	return self;
}

- (void) showGoLabel
{
	startTime = 3;
	pause = false;
	gameOver = true;
	showingGoLabel = true;
	if(goLabel3)
	{
		[goLabel3 stopAllActions];
		[self removeChild:goLabel3 cleanup:YES];
		goLabel3 = nil;
	}
	if(goLabel2)
	{
		[goLabel2 stopAllActions];
		[self removeChild:goLabel2 cleanup:YES];
		goLabel2 = nil;
	}
	if(goLabel1)
	{
		[goLabel1 stopAllActions];
		[self removeChild:goLabel1 cleanup:YES];
		goLabel1 = nil;
	}
	if(goLabelGO)
	{
		[goLabelGO stopAllActions];
		[self removeChild:goLabelGO cleanup:YES];
		goLabelGO = nil;
	}
	
	goLabel3 = [CCSprite spriteWithFile:@"GOThree.png"];
	goLabel2 = [CCSprite spriteWithFile:@"GOTwo.png"];
	goLabel1 = [CCSprite spriteWithFile:@"GOOne.png"];	
	goLabelGO = [CCSprite spriteWithFile:@"GOGo.png"];
	
	[goLabel3 setOpacity:0];
	[self addChild:goLabel3 z:10];

	[goLabel2 setOpacity:0];
	[self addChild:goLabel2 z:10];

	[goLabel1 setOpacity:0];
	[self addChild:goLabel1 z:10];

	[goLabelGO setOpacity:0];
	[self addChild:goLabelGO z:10];

	[goLabel3 setPosition:gameState.screenCenter];
	[goLabel2 setPosition:gameState.screenCenter];
	[goLabel1 setPosition:gameState.screenCenter];
	[goLabelGO setPosition:gameState.screenCenter];
	
	[goLabel3 runAction:[CCSequence actions:[CCFadeTo actionWithDuration:0.5 opacity:255],
						[CCScaleTo actionWithDuration:0.5 scale:1.5],
						[CCCallFunc actionWithTarget:self
											selector:@selector(updateGoLabel)],nil]];			
}

-(void) menuClicked
{
	[gameDelegate playClick];
	
	[Backmenu setOpacity:0];
	[gameDelegate stopGamemusic];

	gameDelegate.gameSceneRunning = FALSE;
	[[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:0.5 
																					 scene:[TBMainMenuScene scene]]];	
}

- (void) shareClicked
{
	
	[gameDelegate postToFacebook:playerScore gameWin:(playerScore>computerScore) withCharIdx:characterIdx];
}

- (void) resumeClicked
{
	[gameDelegate playClick];

	[Backmenu runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(0, 0)]];

	[self removeChild:pauseBg cleanup:YES];
	pause = false;
	ball.opacity = 255;

	if(ballOverBasket)
	{
		[self resetBallPosition];
	}
		
	if(!showingGoLabel)
	{
		[ball runAction:[CCRepeat actionWithAction:[CCRotateBy actionWithDuration:0.1 angle:30.0f] times:-1]];
		[ball runAction:[CCSequence actions:[CCMoveBy actionWithDuration:1/60 position:ballMovementDelta],
						 [CCCallFunc actionWithTarget:self selector:@selector(updateBallPosition)],nil]];
	}
	
	[NSTimer scheduledTimerWithTimeInterval:0.1
									 target:self
								   selector:@selector(updateTimer)
								   userInfo:nil
									repeats:NO];
}

- (void) restartClicked
{
	[gameDelegate playClick];

	[Backmenu runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(0, 0)]];

	if(gameOver)
	{
		[self removeChild:gameOverBg cleanup:YES];
	}

	if(pause)
	{
		[self removeChild:pauseBg cleanup:YES];
	}
	ball.opacity = 0;	
	[ball stopAllActions];
	[gameDelegate stopGamemusic];

	player.scale = 1.0f;
	computer.scale = 1.0f;
	player.position = ccp(gameState.screenCenter.x - 40, PLAYER_START_Y);
	computer.position = ccp(gameState.screenCenter.x + 40, PLAYER_START_Y);

	
	[self showGoLabel];
	
	//[self startClicked];
}

- (CCLayer *)addScores:(CGPoint)center
{
	CCLayer *layer = [CCLayer node];
	
	if(playerScore < 10)
	{
		CCSprite *sprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%d.png",playerScore]];
		[layer addChild:sprite];
		sprite.position = center;
	}
	else if(playerScore < 100)
	{
		CCSprite *sprite1 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%d.png",playerScore/10]];
		[layer addChild:sprite1];
		sprite1.position = ccp(center.x - 20, center.y);

		CCSprite *sprite2 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%d.png",playerScore%10]];
		[layer addChild:sprite2];
		sprite2.position = ccp(center.x + 20, center.y);
	}
	else if(playerScore < 1000)
	{
		CCSprite *sprite2 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%d.png",playerScore%10]];
		[layer addChild:sprite2];
		sprite2.position = ccp(center.x + 40, center.y);
		
		playerScore /= 10;

		CCSprite *sprite1 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%d.png",playerScore/10]];
		[layer addChild:sprite1];
		sprite1.position = ccp(center.x - 40, center.y);

		CCSprite *sprite3 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%d.png",playerScore%10]];
		[layer addChild:sprite3];
		sprite3.position = ccp(center.x, center.y);
		

	}
	
	layer.position = ccp(0,0);
	
	return layer;
}

- (void) gameOver
{
	gameOver = true;
	ball.opacity = 0;
	[ball stopAllActions];
	
	// add Background
	gameOverBg = [CCSprite spriteWithFile:@"Gameover_bg.png"];
	gameOverBg.position = ccp(gameState.screenCenter.x, gameState.screenCenter.y);
	[self addChild:gameOverBg z:10];
	
	// add Label
	CCSprite *gameStateLabel;
	// add menu buttons - menu/share/restart
	
	if(playerScore > computerScore)
	{
		gameStateLabel = [CCSprite spriteWithFile:@"Winner.png"];
		
		gameStateLabel.position = ccp(gameState.screenCenter.x, gameState.screenCenter.y + 35);
		[gameOverBg addChild:gameStateLabel];
		[gameOverBg addChild:[self addScores:ccp(gameState.screenCenter.x, gameState.screenCenter.y - 20)]];

	}
	else if(playerScore < computerScore)
	{
		gameStateLabel = [CCSprite spriteWithFile:@"Loser.png"];
		
		gameStateLabel.position = ccp(gameState.screenCenter.x, gameState.screenCenter.y + 35);
		[gameOverBg addChild:gameStateLabel];
		[gameOverBg addChild:[self addScores:ccp(gameState.screenCenter.x, gameState.screenCenter.y - 20)]];
	}
	else
	{
		gameStateLabel = [CCSprite spriteWithFile:@"draw.png"];
		
		gameStateLabel.position = ccp(gameState.screenCenter.x, gameState.screenCenter.y + 15);
		[gameOverBg addChild:gameStateLabel];
	}

	CCMenuItem *backMenu1 = [CCMenuItemImage itemFromNormalImage:@"menu_btn.png"
														 target:self
													   selector:@selector(menuClicked)];
	CCMenuItem *shareMenu = [CCMenuItemImage itemFromNormalImage:@"share_game_btn.png"
														  target:self
														selector:@selector(shareClicked)];
	CCMenuItem *restartMenu = [CCMenuItemImage itemFromNormalImage:@"Restart_btn.png"
														  target:self
														selector:@selector(restartClicked)];
	
	CCMenu *menu = [CCMenu menuWithItems:backMenu1,shareMenu,restartMenu, nil];
	menu.position = ccp(0,0);
	[gameOverBg addChild:menu];
	
	backMenu1.position = ccp(gameOverBg.position.x - 50, gameOverBg.position.y - 70);
	shareMenu.position = ccp(gameOverBg.position.x + 50, gameOverBg.position.y - 70);
	restartMenu.position = ccp(gameOverBg.position.x, gameOverBg.position.y - 105);
	
	CCSprite *playerSprite;
	if(characterIdx==1)
	{
		if(playerScore > computerScore)
			playerSprite = [CCSprite spriteWithFile:@"Blue.png"];
		else
			playerSprite = [CCSprite spriteWithFile:@"Blue_sad.png"];
	}
	else if(characterIdx==2)
	{
		if(playerScore > computerScore)
			playerSprite = [CCSprite spriteWithFile:@"Orange.png"];
		else
			playerSprite = [CCSprite spriteWithFile:@"orange_sad.png"];
	}
	else
	{
		if(playerScore > computerScore)
			playerSprite = [CCSprite spriteWithFile:@"Yellow.png"];
		else
			playerSprite = [CCSprite spriteWithFile:@"yellow_sad.png"];
	}	

	playerSprite.position = ccp(gameState.screenCenter.x + 160, PLAYER_START_Y);
	[gameOverBg addChild:playerSprite];
}

- (void) pause
{
	pause = true;
	ball.opacity = 0;
	[ball stopAllActions];
	
	pauseBg = [CCSprite spriteWithFile:@"Black_opacity_layer.png"];
	pauseBg.position = gameState.screenCenter;
	[self addChild:pauseBg z:10];
	
	CCSprite *tBg = [CCSprite spriteWithFile:@"Game_Pause_popup.png"];
	tBg.position = gameState.screenCenter;
	[pauseBg addChild:tBg];
	
	CCMenuItem *resumMenu = [CCMenuItemImage itemFromNormalImage:@"Resume_btn.png" 
														  target:self
														selector:@selector(resumeClicked)];
	
	CCMenuItem *restartMenu = [CCMenuItemImage itemFromNormalImage:@"Restart_btn.png" 
															target:self 
														  selector:@selector(restartClicked)];

	CCMenuItem *quitToMenu = [CCMenuItemImage itemFromNormalImage:@"menu_btn.png" 
														   target:self 
														 selector:@selector(menuClicked)];
	
	CCMenu *menu = [CCMenu menuWithItems:quitToMenu, resumMenu, restartMenu, nil];
	menu.position = ccp(0,0);
	[pauseBg addChild:menu];
	resumMenu.position = ccp(pauseBg.position.x, pauseBg.position.y - 60);
	restartMenu.position = ccp(pauseBg.position.x, pauseBg.position.y - 20);
	quitToMenu.position = ccp(pauseBg.position.x, pauseBg.position.y + 20);
}

- (void) showInstructions
{
	instructionsBg = [CCSprite spriteWithFile:@"Instructions_bg.png"];
	instructionsBg.position = gameState.screenCenter;
	[self addChild:instructionsBg z:5];
	
	CCMenuItem *menuBack = [CCMenuItemImage itemFromNormalImage:@"Back_button.png"
														   target:self
														 selector:@selector(menuClicked)];
	CCMenuItem *menuNext = [CCMenuItemImage itemFromNormalImage:@"Start_btn.png"
														   target:self
														 selector:@selector(nextClicked)];
	menuInstructions = [CCMenu menuWithItems:menuBack, menuNext, nil];
	[self addChild:menuInstructions z:6];
	menuInstructions.position = ccp(0,0);
	menuBack.position = ccp(80, 280);
	menuNext.position = ccp(400, 40);
}

- (void) nextClicked
{
	[self removeChild:menuInstructions cleanup:TRUE];
	menuInstructions = nil;
	
	[instructionsBg runAction:[CCSequence actions:
							   [CCFadeOut actionWithDuration:1.0],
							   [CCCallFunc actionWithTarget:self selector:@selector(instructionsEnded)],nil]];
}

- (void) instructionsEnded
{
	[self selectCharacter];
}

- (void) addGameObjects
{
	
	CCSprite *scoreHolder = [CCSprite spriteWithFile:@"scoreboard.png"];
	scoreHolder.position = ccp(gameState.screenCenter.x, gameState.screenSize.height - 40);
	[self addChild:scoreHolder];
	
	playerScoreLabel = [CCLabelTTF labelWithString:@"0"
										  fontName:@"Helvetica"
										  fontSize:25];
	[playerScoreLabel setColor:ccc3(255, 200, 40)];
	[scoreHolder addChild:playerScoreLabel];
	playerScoreLabel.position = ccp(50, 35);
	
	computerScoreLabel = [CCLabelTTF labelWithString:@"0" 
											fontName:@"Helvetica" 
											fontSize:25];
	[computerScoreLabel setColor:ccc3(255, 200, 40)];
	[scoreHolder addChild:computerScoreLabel];
	computerScoreLabel.position = ccp(200,35);
	
	timerLabel = [CCLabelTTF labelWithString:@"2:00" 
									fontName:@"Helvetica" 
									fontSize:25];
	[scoreHolder addChild:timerLabel];
	timerLabel.position = ccp(125, 35);
	
	CCMenuItem *back = [CCMenuItemImage itemFromNormalImage:@"Quit_btn.png"
											  selectedImage:@"Quit_btn.png"
													   target:self
													 selector:@selector(backClicked)];
		
	Backmenu = [CCMenu menuWithItems:back,nil];
	Backmenu.position = ccp(0,0);
	back.position = ccp(50, 290);
	
	[self addChild:Backmenu];
	
	// add characters
	[self addCharacters];
	
	// add ball
	[self addBall];	
}

- (void) updateGoLabel
{
	if(pause)
	{
		[goLabel3 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.1],
							[CCCallFunc actionWithTarget:self selector:@selector(updateGoLabel)],nil]];
	}
	else 
	{
		[goLabel3 setOpacity:0];
		[goLabel2 setOpacity:0];
		[goLabel1 setOpacity:0];
		[goLabelGO setOpacity:0];
		
		startTime--;

		if(startTime == 2)
		{
			//[goLabel setString:[NSString stringWithFormat:@"%d",startTime]];
			
			[goLabel2 runAction:[CCSequence actions:[CCFadeTo actionWithDuration:0.5 opacity:255],
								[CCScaleTo actionWithDuration:0.5 scale:1.5],
								[CCCallFunc actionWithTarget:self
													selector:@selector(updateGoLabel)],nil]];	
			
		}
		else if(startTime == 1)
		{
			[goLabel1 runAction:[CCSequence actions:[CCFadeTo actionWithDuration:0.5 opacity:255],
								 [CCScaleTo actionWithDuration:0.5 scale:1.5],
								 [CCCallFunc actionWithTarget:self
													 selector:@selector(updateGoLabel)],nil]];				
		}
		else if(startTime == 0)
		{
//			[goLabel setString:@"GO !!!"];
			[goLabelGO runAction:[CCSequence actions:[CCFadeTo actionWithDuration:0.5 opacity:255],
								[CCScaleTo actionWithDuration:0.5 scale:1.5],
								[CCCallFunc actionWithTarget:self
													selector:@selector(updateGoLabel)],nil]];			
		}
		else 
		{
			[self removeChild:goLabel3 cleanup:YES];
			goLabel3 = nil;
			
			[self removeChild:goLabel2 cleanup:YES];
			goLabel2 = nil;
			
			[self removeChild:goLabel1 cleanup:YES];
			goLabel1 = nil;
			
			[self removeChild:goLabelGO cleanup:YES];
			goLabelGO = nil;
			
			showingGoLabel = false;
			[self startClicked];
		}
	}
}

- (void) startClicked
{
//	start.visible = false;
	playerScore = 0;
	computerScore = 0;
	gameOver = false;
	timer = GAME_TIME;
	
	ball.opacity = 255;
	ball.position = ccp(gameState.screenCenter.x, gameState.screenSize.height + 20);
	ballMovementDelta = ccp(-BALL_MOVE_X, -BALL_MOVE_Y);
	ballRadius = BALL_RADIUS;	
	ballOverBasket = false;
	
	[playerScoreLabel setString:[NSString stringWithFormat:@"%d",playerScore]];
	[computerScoreLabel setString:[NSString stringWithFormat:@"%d",computerScore]];
	//[timerLabel setString:[NSString stringWithFormat:@"%d:%d",timer/60,timer%60]];
	int minutes = timer%60;
	if(minutes > 9)
		[timerLabel setString:[NSString stringWithFormat:@"%d:%d",timer/60,minutes]];
	else
		[timerLabel setString:[NSString stringWithFormat:@"%d:0%d",timer/60,minutes]];
	
	pause = false;
	
	[ball runAction:[CCRepeat actionWithAction:[CCRotateBy actionWithDuration:0.1 angle:30.0f] times:-1]];
	[ball runAction:[CCSequence actions:[CCMoveBy actionWithDuration:1/60 position:ballMovementDelta],
					 [CCCallFunc actionWithTarget:self selector:@selector(updateBallPosition)],nil]];

//	[ball runAction:[CCSpawn actions:[CCRepeat actionWithAction:[CCRotateBy actionWithDuration:0.1 angle:30.0f] times:-1],
//					 [CCMoveBy actionWithDuration:BALL_MOVE_SPEED position:ballMovementDelta],nil]];
	
	[self schedule:@selector(update)];
	
	[NSTimer scheduledTimerWithTimeInterval:0.1
									 target:self
								   selector:@selector(updateTimer)
								   userInfo:nil
									repeats:NO];
	
	[gameDelegate playGamemusic];
}

- (void) backClicked
{
	[gameDelegate playClick];

	[Backmenu runAction:[CCMoveBy actionWithDuration:0.5 position:ccp(-100,0)]];
	
	if(timer > 0)
	{
		[self pause];
	}
	else
	{
		[self gameOver];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 0)
	{
	}
	else if(buttonIndex == 1)
	{
		[self startClicked];
	}
	else if(buttonIndex == 2)
	{
		pause = false;
		[ball runAction:[CCRepeat actionWithAction:[CCRotateBy actionWithDuration:0.1 angle:30.0f] times:-1]];
		[ball runAction:[CCSequence actions:[CCMoveBy actionWithDuration:1/60 position:ballMovementDelta],
						 [CCCallFunc actionWithTarget:self selector:@selector(updateBallPosition)],nil]];
	}
}

- (void) updateTimer
{
	if(!pause)
	{
		timer--;
		[playerScoreLabel setString:[NSString stringWithFormat:@"%d",playerScore]];
		[computerScoreLabel setString:[NSString stringWithFormat:@"%d",computerScore]];
		int minutes = timer%60;
		if(minutes >= 10)
			[timerLabel setString:[NSString stringWithFormat:@"%d:%d",timer/60,minutes]];
		else
			[timerLabel setString:[NSString stringWithFormat:@"%d:0%d",timer/60,minutes]];

		if(timer > 0)
		{
			[NSTimer scheduledTimerWithTimeInterval:1
											 target:self
										   selector:@selector(updateTimer)
										   userInfo:nil
											repeats:NO];
		}
		else 
		{
			[self gameOver];
		}
	}
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

-(int) detectOverBasket
{
	int detected = 0;
	
	if(ball.position.x<gameState.screenSize.width/2)
	{
		if((ball.position.y-ballRadius >= (leftBasket.position.y+40)) &&
			(ball.position.x-ballRadius <= (leftBasket.position.x)))
		{
			if(ballMovementDelta.y < 0)
			{
				detected = -1;
			}
		}
	}
	else 
	{
		if((ball.position.y-ballRadius >= (rightBasket.position.y+40)) &&
		   (ball.position.x+ballRadius >= (rightBasket.position.x)))
		{
			if(ballMovementDelta.y < 0)
			{
				detected = 1;
			}
		}
	}
	
	return detected;
}

-(bool) detectBallBoundaryCheck
{
	bool ballCollided = false;

	// horizontal check
	if(ball.position.x-ballRadius<0 && ballMovementDelta.x<0)
	{
		ballMovementDelta.x = -ballMovementDelta.x;
		ballCollided = true;
		[gameDelegate playBallHit];
	}
	else if(ball.position.x+ballRadius>gameState.screenSize.width && ballMovementDelta.x>0)
	{
		ballMovementDelta.x = -ballMovementDelta.x;
		ballCollided = true;
		[gameDelegate playBallHit];
	}
	
	// vertical check
	if(ball.position.y-ballRadius<0 && ballMovementDelta.y < 0)
	{
		ballMovementDelta.y = -ballMovementDelta.y;
		ballCollided = true;
		[gameDelegate playBallHit];
	}
	else if(ball.position.y+ballRadius>gameState.screenSize.height && ballMovementDelta.y >0)
	{
		ballMovementDelta.y = -ballMovementDelta.y;
		ballCollided = true;
		[gameDelegate playBallHit];
	}
	
	// beneath baskets check
	if(((ball.position.y-ballRadius >= (leftBasket.position.y)) &&
		(ball.position.x-ballRadius <= (leftBasket.position.x+22))) || 

	   ((ball.position.y-ballRadius >= (rightBasket.position.y)) &&
	   (ball.position.x+ballRadius >= (rightBasket.position.x-22))) )
	{
		if(ballMovementDelta.y > 0)
		{
			//[gameDelegate playBallHit];
			ballMovementDelta.y = -BALL_MOVE_Y;
			ballCollided = true;
		}
	}

	return ballCollided;
}

-(bool) detectBallPlayerCollision:(CCSprite *)cPlayer
{
	// detect collision with player and reflect update 
	CGRect playerRect = [cPlayer boundingBox];
	CGRect ballRect = [ball boundingBox];
	
	CGPoint headCenter = CGPointMake(cPlayer.position.x, playerRect.origin.y + 
														 playerRect.size.height - 
														 HEAD_RADIUS);
	CGPoint ballCenter = ball.position;	
	CGPoint playerCenter = cPlayer.position;
	
	if (CGRectIntersectsRect(playerRect, ballRect))
	{
		float x2 = (ballCenter.x - headCenter.x);
		x2 *= x2;
		
		float y2 = (ballCenter.y - headCenter.y);
		y2 *= y2;
		
		float r2 = (ballRadius - HEAD_RADIUS);
		r2 *= r2;
		
		if(x2+y2-r2 <= 0)
		{
			if(ballCenter.y > headCenter.y)
			{
				float xDiff = ballCenter.x - headCenter.x;
				if(xDiff == 0)
				{
					if (ballMovementDelta.y < 0) 
						ballMovementDelta = CGPointMake(ballMovementDelta.x, -ballMovementDelta.y);
				}
				else 
				{
					float yDiff = ballCenter.y - headCenter.y;
					float slope = fabs(yDiff/xDiff);
					
					if(slope < 1)
					{
						if(ballCenter.x < playerCenter.x)
							ballMovementDelta = CGPointMake(-(BALL_MOVE_X/2)*BALL_MOVE_X, -BALL_MOVE_Y);
						else
							ballMovementDelta = CGPointMake((BALL_MOVE_X/2)*BALL_MOVE_X, -BALL_MOVE_Y);
					}
					else if(slope == 1)
					{					
						if(ballCenter.x < playerCenter.x)
							ballMovementDelta = CGPointMake(-BALL_MOVE_X, -BALL_MOVE_Y);
						else
							ballMovementDelta = CGPointMake(BALL_MOVE_X, BALL_MOVE_Y);
					}
					else
					{
						if(ballCenter.x < playerCenter.x)
							ballMovementDelta = CGPointMake(-BALL_MOVE_X, -(BALL_MOVE_Y/2)*BALL_MOVE_Y);
						else
							ballMovementDelta = CGPointMake(BALL_MOVE_X, -(BALL_MOVE_Y/2)*BALL_MOVE_Y);
					}
				}
			}
		}
		else// if(ballCenter.y > playerCenter.y)
		{
			// heading under head
			if(ballCenter.x > playerCenter.x  && ballMovementDelta.x < 0)
			{
				ballMovementDelta = CGPointMake(-ballMovementDelta.x, ballMovementDelta.y);
			}
			else if(ballCenter.x < playerCenter.x && ballMovementDelta.x > 0)
			{
				ballMovementDelta = CGPointMake(-ballMovementDelta.x, ballMovementDelta.y);
			}
		}

		
		return true;
	}
	
	return false;
}

-(void)computerLanded
{
	[computer stopAllActions];
	computer.scale = 1.0f;
	computer.position = ccp(computer.position.x, PLAYER_START_Y);

	computerJumping = false;
}

-(void) updateComputerMovements
{
	if(!computerJumping)
	{
		if(ball.position.x + ballRadius <= computer.position.x)
		{
			computer.position = ccp(computer.position.x-PLAYER_MOVE_X,computer.position.y);
			if(computer.position.x <= 60)
				computer.position = ccp(60, computer.position.y);
		}
		else if(ball.position.x - ballRadius >= computer.position.x)
		{
			computer.position = ccp(computer.position.x+PLAYER_MOVE_X, computer.position.y);
			if(computer.position.x >= (gameState.screenSize.width-60))
				computer.position = ccp(gameState.screenSize.width-60, computer.position.y);
		}
		else if(abs(computer.position.y - ball.position.y) < (computer.position.y + PLAYER_JUMP_HEIGHT)
				&& (ball.position.x <= computer.position.x) )
		{
			computerJumping = true;

//			[computer setPosition:ccp(computer.position.x,computer.position.y-10)];
			CCSequence *seq1 = [CCSequence actions:
								[CCJumpBy actionWithDuration:PLAYER_JUMP_SPEED 
													position:ccp(0,0)
													  height:PLAYER_JUMP_HEIGHT
													   jumps:1],
//							   [CCScaleBy actionWithDuration:(PLAYER_JUMP_SPEED/3.0) scaleX:1 scaleY:0.8f],
//							   [CCScaleTo actionWithDuration:(2.0*PLAYER_JUMP_SPEED/3.0) scaleX:1 scaleY:1.0f],
							   [CCCallFunc actionWithTarget:self selector:@selector(computerLanded)], nil];
			
//			CCSequence *seq2 = [CCSequence actions:[CCDelayTime actionWithDuration:(PLAYER_JUMP_SPEED/3.0)],
//								[CCJumpBy actionWithDuration:(2.0*PLAYER_JUMP_SPEED/3.0)
//													position:ccp(0,10)
//													  height:PLAYER_JUMP_HEIGHT
//													   jumps:1],nil];
//			
//			CCSpawn *spawn = [CCSpawn actions:seq1,seq2,nil];
			
			[computer runAction:seq1];			
		}
	}
}

-(void) resetBallPosition
{
	ballOverBasket = false;
	[self reorderChild:ball z:3];
	//[CCMoveTo actionWithDuration:0.0 position:],
	ball.position = ccp(gameState.screenCenter.x, gameState.screenSize.height+20);
	[ball runAction:[CCRepeat actionWithAction:[CCRotateBy actionWithDuration:0.1 angle:30.0f] times:-1]];
	[ball runAction:[CCSequence actions:[CCMoveBy actionWithDuration:1/60 position:ballMovementDelta],
					 [CCCallFunc actionWithTarget:self selector:@selector(updateBallPosition)],nil]];
}

-(void) updateBallPosition
{
	if(ballOverBasket)
		return;
	
	int overBasket = [self detectOverBasket];
	if(overBasket == 0)
	{
		[self detectBallBoundaryCheck];
		[self detectBallPlayerCollision:computer];
		[self detectBallPlayerCollision:player];

//		ball.position = ccpAdd(ball.position, ballMovementDelta);
		[ball runAction:[CCSequence actions:[CCMoveBy actionWithDuration:1/60 position:ballMovementDelta],
						 [CCCallFunc actionWithTarget:self selector:@selector(updateBallPosition)],nil]];

	}
	else 
	{
		ballOverBasket = true;
		[self reorderChild:ball z:1];
		
		[ball stopAllActions];
//		[self computerLanded];
//		[self playerLanded];
		if(overBasket > 0)
		{
			playerScore++;
			// score player
			ballMovementDelta = ccp(BALL_MOVE_X, -BALL_MOVE_Y);
			[ball runAction:[CCSequence actions:[CCMoveTo actionWithDuration:0.1 position:ccp(rightBasket.position.x,rightBasket.position.y+70)],
							 [CCMoveBy actionWithDuration:0.6 position:ccp(0, -80)],
							 [CCMoveBy actionWithDuration:0.1 position:ccp(overBasket*10, -20)],
							 //						 [CCMoveBy actionWithDuration:0.2 position:ccp(overBasket*0, -10)],
							 [CCMoveBy actionWithDuration:0.25 position:ccp(overBasket*50, 0)],
//							 [CCFadeTo actionWithDuration:0.1 opacity:0],
							 //[CCFadeTo actionWithDuration:0.2 opacity:255],
							 //[CCMoveBy actionWithDuration:0.75 position:ccp(0, -50)],
							 [CCCallFunc actionWithTarget:self selector:@selector(resetBallPosition)],nil]];
		}
		else 
		{
			computerScore++;
			ballMovementDelta = ccp(-BALL_MOVE_X, -BALL_MOVE_Y);
			[ball runAction:[CCSequence actions:[CCMoveTo actionWithDuration:0.1 position:ccp(leftBasket.position.x, leftBasket.position.y + 70)],
							 [CCMoveBy actionWithDuration:0.6 position:ccp(0, -80)],
							 [CCMoveBy actionWithDuration:0.1 position:ccp(overBasket*10, -20)],
							 //						 [CCMoveBy actionWithDuration:0.2 position:ccp(overBasket*0, -10)],
							 [CCMoveBy actionWithDuration:0.25 position:ccp(overBasket*50, 0)],
//							 [CCFadeTo actionWithDuration:0.1 opacity:0],
//							 [CCMoveTo actionWithDuration:0.0 position:ccp(gameState.screenCenter.x, gameState.screenSize.height+20)],
							 //[CCFadeTo actionWithDuration:0.2 opacity:255],
							 //[CCMoveBy actionWithDuration:0.75 position:ccp(0, -50)],
							 [CCCallFunc actionWithTarget:self selector:@selector(resetBallPosition)],nil]];
			
		}
		
		
		// animate ball to go through the pipe
		// update points based on left/right pipe
	}
}

- (void) update
{
	if(!gameOver)
	{
		if(!pause && !ballOverBasket)
		{			
//			[self updateBallPosition];
			
			[self updateComputerMovements];
			
//			if(moveLeft)
//			{
//				player.position = ccp(player.position.x-PLAYER_MOVE_X,player.position.y);
//				if(player.position.x <= 90)
//					player.position = ccp(90, player.position.y);
//				moveLeft = false;
//			}
//			if(moveRight)
//			{
//				player.position = ccp(player.position.x+PLAYER_MOVE_X, player.position.y);
//				if(player.position.x >= (gameState.screenSize.width-90))
//					player.position = ccp(gameState.screenSize.width-90, player.position.y);
//				moveRight = false;
//			}
		}
	}
}

@end
