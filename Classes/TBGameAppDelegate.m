//
//  TBGameAppDelegate.m
//  TBGame
//
//  Created by Rana Hammad Hussain on 4/22/11.
//  Copyright Azosh & Co. 2011. All rights reserved.
//

#import "cocos2d.h"

#import "TBGameAppDelegate.h"
#import "GameConfig.h"
#import "RootViewController.h"
#import "TBSplashScene.h"
#import "TBMainMenuScene.h"

@implementation TBGameAppDelegate

@synthesize gameState;
@synthesize window;
@synthesize gameSceneRunning;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}
- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	pAudioEngine = [SimpleAudioEngine sharedEngine];

	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//	if( ! [director enableRetinaDisplay:YES] )
//		CCLOG(@"Retina Display Not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:NO];
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window addSubview: viewController.view];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	
	// Removes the startup flicker
	[self removeStartupFlicker];
	
	//[[CCDirector sharedDirector] winSizeInPixels];
	gameState = [[TBGameState alloc] initWithScreenSize:[[CCDirector sharedDirector] winSizeInPixels]];
	
	
	fbAgent = [[FacebookAgent alloc] initWithApiKey:FB_API_KEY 
										  ApiSecret:FB_API_SECRET 
										   ApiProxy:nil];
	fbAgent.delegate = self;
	
	// Run the intro Scene
	gameSceneRunning = FALSE;
	//[[CCDirector sharedDirector] runWithScene: [TBSplashScene scene]];		
	[[CCDirector sharedDirector] runWithScene:[TBMainMenuScene scene]];
}


- (void)applicationWillResignActive:(UIApplication *)application {
	
	if(gameState)
	{
		[gameState saveState];
	}
	
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {

	if(gameState)
	{
		[gameState saveState];
	}
	
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	
	if(gameState)
	{
		[gameState saveState];
	}
	
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	
	if(gameState)
	{
		[gameState release];
		gameState = nil;
	}
		
	[window release];
	[super dealloc];
}

-(void) playGamemusic
{
	[pAudioEngine playBackgroundMusic:@"gamemusic.wav" loop:YES];
}

-(void) stopGamemusic
{
	[pAudioEngine stopBackgroundMusic];
}

-(void) playClick
{
	[pAudioEngine playEffect:@"click.wav"];
}

-(void) playBallHit
{
	[pAudioEngine playEffect:@"ballhit_option2.wav"];
}

#pragma mark FacebookAgent related methods
-(void) postToFacebook:(int)score gameWin:(bool)win withCharIdx:(int)charIdx
{
	iScore = score;
	fbAgent.shouldResumeSession = FALSE;
	
	NSData* myData = UIImagePNGRepresentation([UIImage imageNamed:@"Facebook_wallshare_icon.jpg"]);
//	if(charIdx == 1)
//		myData = UIImagePNGRepresentation([UIImage imageNamed:@"Blue.png"]);
//	else if(charIdx == 2)
//		myData = UIImagePNGRepresentation([UIImage imageNamed:@"Orange.png"]);	
//	else
//		myData = UIImagePNGRepresentation([UIImage imageNamed:@"Yellow.png"]);
	
	if(win)
	{
		[fbAgent uploadPhotoAsData:myData
						withStatus:[NSString stringWithFormat:@"My score is %d in Slam Dunk. Can anyone beat my score? Anyone??",score]
						   caption:@"Slam Dunk is brought to you by 3SCrowd"
						   toAlbum:nil];
	}	
	else 
	{
		[fbAgent uploadPhotoAsData:myData
						withStatus:nil
						   caption:@"Slam Dunk is brought to you by 3SCrowd"
						   toAlbum:nil];
		
	}

}

- (void) facebookAgent:(FacebookAgent*)agent requestFaild:(NSString*) message{
	//[fbAgent setStatus:@"status from iPhone demo 1 2"];
}

- (void) facebookAgent:(FacebookAgent*)agent photoUploaded:(NSString*) pid
{
	[fbAgent publishFeedWithName:@"Slam Dunk" 
					 captionText:[NSString stringWithFormat:@"My score is %d in Slam Dunk. Can anyone beat my score? Anyone??",iScore]
						imageurl:nil 
						 linkurl:nil 
			   userMessagePrompt:nil targetId:nil];	
	
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Slam Dunk" 
//													message:@"Thank you for sharing news about 'Slam Dunk'." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//	[alert show];
//	[alert release];
}

- (void) facebookAgent:(FacebookAgent*)agent statusChanged:(BOOL) success{
}

- (void) facebookAgent:(FacebookAgent*)agent loginStatus:(BOOL) loggedIn{
}


@end
