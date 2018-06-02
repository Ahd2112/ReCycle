///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2013 Wahoo Fitness. All Rights Reserved.
//
// The information contained herein is property of Wahoo Fitness LLC.
// Terms and conditions of usage are described in detail in the
// WAHOO FITNESS API LICENSE AGREEMENT.
//
// Licensees are granted free, non-transferable use of the information.
// NO WARRANTY of ANY KIND is provided.
// This heading must NOT be removed from the file.
///////////////////////////////////////////////////////////////////////////////
//
//  BikeSpeedCadenceViewController.m
//  FisicaDemo
//
//  Created by Michael Moore on 2/21/10.
//  Copyright 2010 Wahoo Fitness. All rights reserved.
//

#import "BikeSpeedCadenceViewController.h"
#import "OdometerHistoryVC.h"


@implementation BikeSpeedCadenceViewController

@synthesize lastCadenceTimeLabel;
@synthesize totalCadenceRevolutionsLabel;
@synthesize lastSpeedTimeLabel;
@synthesize totalSpeedRevolutionsLabel;
@synthesize computedCadenceLabel;
@synthesize computedSpeedLabel;
@synthesize distanceLabel;
@synthesize temperatureLabel;
@synthesize startScreen;
@synthesize challengeQ;
@synthesize distanceBiked;
static NSUInteger timeNotActive = 0;
static bool isPlaying = false; //if the player is playing
static bool inChallenge = false;
static bool sleepNow = false;
static bool addSubviews = true;
#pragma mark -
#pragma mark UIViewController Implementation

//--------------------------------------------------------------------------------
- (void)dealloc
{
	[lastCadenceTimeLabel release];
	[totalCadenceRevolutionsLabel release];
	[lastSpeedTimeLabel release];
	[totalSpeedRevolutionsLabel release];
	[computedCadenceLabel release];
	[computedSpeedLabel release];
    [distanceLabel release];
    [temperatureLabel release];
    
    [startScreen release];
    [challengeQ release];
    [_yesButton release];
    [_noButton release];
    [distanceBiked release];
    [distanceBiked release];
    [_challengeEnd release];
    [super dealloc];
}

//--------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

//--------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( (self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) )
    {
        sensorType = WF_SENSORTYPE_BIKE_SPEED_CADENCE;
        applicableNetworks = WF_NETWORKTYPE_ANTPLUS | WF_NETWORKTYPE_BTLE;
    }
    return self;
}

//--------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Bike Speed & Cadence";
    
    [self initStoryPlayer];
    [self initChallengePlayer];
}

//--------------------------------------------------------------------------------
- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

//--------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // register as the delegate for the BSC connection.
    if ( self.bikeSpeedCadenceConnection )
    {
        self.bikeSpeedCadenceConnection.delegate = self;
    }
}

#pragma mark -
#pragma mark WFBikeSpeedCadenceDelegate Implementation

//--------------------------------------------------------------------------------
- (void)cscConnection:(WFBikeSpeedCadenceConnection*)cscConn didReceiveOdometerHistory:(WFOdometerHistory*)history
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"BlueSC" message:@"Received Odometer History" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    alert = nil;
}

//--------------------------------------------------------------------------------
- (void)cscConnection:(WFBikeSpeedCadenceConnection*)cscConn didResetOdometer:(BOOL)bSuccess
{
    //NSString* msg = [NSString stringWithFormat:@"Received Odometer Reset response.\n\nStatus: %@", bSuccess?@"SUCCESS":@"FAILED"];
    //UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"BTLE CSC" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //[alert show];
    //[alert release];
    //alert = nil;
}

//--------------------------------------------------------------------------------
- (void)cscConnection:(WFBikeSpeedCadenceConnection*)cscConn didReceiveGearRatio:(BOOL)bSuccess numerator:(USHORT)usNumerator denominator:(USHORT)usDenominator
{
    NSString* msg = [NSString stringWithFormat:@"Received Gear Ratio.\n\nStatus: %@\nNumerator: %u\nDenominator: %u", bSuccess?@"SUCCESS":@"FAILED", usNumerator, usDenominator];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"BTLE CSC" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    alert = nil;
}

//--------------------------------------------------------------------------------
- (void)cscConnection:(WFBikeSpeedCadenceConnection*)cscConn didReceiveSetGearRatioResponse:(BOOL)bSuccess
{
    NSString* msg = [NSString stringWithFormat:@"Received Set Gear Ratio response.\n\nStatus: %@", bSuccess?@"SUCCESS":@"FAILED"];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"BTLE CSC" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    alert = nil;
}


#pragma mark -
#pragma mark WFSensorCommonViewController Implementation

//--------------------------------------------------------------------------------
- (void)onSensorConnected:(WFSensorConnection*)connectionInfo
{
    [super onSensorConnected:connectionInfo];
    
    // set the CSC delegate parameters.
    WFBikeSpeedCadenceConnection* bikeSpeedCadenceConnection = self.bikeSpeedCadenceConnection;
    if ( bikeSpeedCadenceConnection )
    {
        bikeSpeedCadenceConnection.cscDelegate = self;
        
    }
}

//--------------------------------------------------------------------------------
- (void)resetDisplay
{
	[super resetDisplay];
    
	lastCadenceTimeLabel.text = @"n/a";
	totalCadenceRevolutionsLabel.text = @"n/a";
	lastSpeedTimeLabel.text = @"n/a";
	totalSpeedRevolutionsLabel.text = @"n/a";
	computedCadenceLabel.text = @"n/a";
	computedSpeedLabel.text = @"n/a";
    distanceLabel.text = @"n/a";
    temperatureLabel.text = @"n/a";
}

//--------------------------------------------------------------------------------
- (void)updateData
{
    [super updateData];
    
	WFBikeSpeedCadenceData* bscData = [self.bikeSpeedCadenceConnection getBikeSpeedCadenceData];
	if ( bscData != nil )
	{
        if(addSubviews){
            _challengePlayerController.view.frame = self.view.bounds;
            [[self view] addSubview:_challengePlayerController.view];
            _storyPlayerController.view.frame = self.view.bounds;
             [[self view] addSubview:_storyPlayerController.view];
            addSubviews= false;
            [self.view bringSubviewToFront:startScreen];
        }
        [[self navigationController]setNavigationBarHidden:true];
        startScreen.hidden = false;
        [startScreen setFrame:self.view.bounds];
        [challengeQ setFrame:self.view.bounds];
        [_challengeEnd setFrame:self.view.bounds];
        // update basic data.
		lastCadenceTimeLabel.text = [NSString stringWithFormat:@"%3.3f", bscData.accumCadenceTime];
		totalCadenceRevolutionsLabel.text = [NSString stringWithFormat:@"%ld", bscData.accumCrankRevolutions];
		lastSpeedTimeLabel.text = [NSString stringWithFormat:@"%3.3f", bscData.accumSpeedTime];
		totalSpeedRevolutionsLabel.text = [NSString stringWithFormat:@"%ld", bscData.accumWheelRevolutions];
        
		computedSpeedLabel.text = [bscData formattedSpeed:TRUE];
        computedCadenceLabel.text = [bscData formattedCadence:TRUE];
        distanceLabel.text = [bscData formattedDistance:TRUE];
        //the movie is currently not running
        if(sleepNow){
            [self.view bringSubviewToFront:startScreen];
            [NSThread sleepForTimeInterval:10.0];
            _challengeEnd.hidden = true;
            startScreen.hidden = false;
            
            sleepNow = false;
        }
        if ([computedCadenceLabel.text isEqualToString:@"--"] &&!inChallenge){
            timeNotActive++;
            NSLog([NSString stringWithFormat:@"%lu",(unsigned long)timeNotActive]);
            //NSLog(computedCadenceLabel.text);
        }
        //if started and got off reset to startcreen
        if([computedCadenceLabel.text isEqualToString:@"--"] && timeNotActive>10 && !inChallenge){
            isPlaying = false;
            startScreen.hidden = false;
            [self.view bringSubviewToFront:startScreen];
            [_storyPlayer seekToTime:kCMTimeZero];
            [_storyPlayer pause];
            //go back to restart screen
        }
        //if not running play movie and bike not moving play movie
        else if (![computedCadenceLabel.text isEqualToString:@"--"] && !isPlaying &&!inChallenge){
            timeNotActive = 0;
            [self.view bringSubviewToFront:_storyPlayerController.view];
            //NSLog(@"%d",timeNotActive);
            isPlaying = true;
           
            [_storyPlayer play];
        }
        float storyTime;
        float challengeTime;
        if(isPlaying){
            storyTime = CMTimeGetSeconds(self.storyPlayer.currentTime);
            challengeTime = CMTimeGetSeconds(self.challengePlayer.currentTime);
            //NSLog([NSString stringWithFormat:@"%f", time]);
        }
        //if someone completed the video
        if ((storyTime>CMTimeGetSeconds(_storyPlayer.currentItem.asset.duration)-1.0 ||storyTime>CMTimeGetSeconds(_storyPlayer.currentItem.asset.duration)+1.0) && !inChallenge && isPlaying){
            isPlaying = false;
            inChallenge = true;
            _noButton.hidden = false;
            _yesButton.hidden = false;
            [_storyPlayer pause];
            [_storyPlayer seekToTime:kCMTimeZero];
            challengeQ.hidden = false;
            CGPoint noCenter = self.view.center;
            CGPoint yesCenter = self.view.center;
            noCenter.x += 100;
            noCenter.y -= 50;
            yesCenter.x -= 150;
            yesCenter.y -= 50;
            CGRect buttonFrame = _noButton.frame;
            buttonFrame.size = CGSizeMake(200, 240);
            _yesButton.frame = buttonFrame;
            _noButton.frame = buttonFrame;
            _yesButton.center = yesCenter;
            _noButton.center = noCenter;
            [self.view bringSubviewToFront:challengeQ];
            [self.view bringSubviewToFront:_noButton];
            [self.view bringSubviewToFront:_yesButton];
            
        }
        //challenge ends
        else if ((challengeTime>CMTimeGetSeconds(_challengePlayer.currentItem.asset.duration)-1.0 ||challengeTime>CMTimeGetSeconds(_challengePlayer.currentItem.asset.duration)+1.0) && isPlaying && inChallenge){
            inChallenge = false;
            isPlaying = false;
            timeNotActive = 0;
            _challengeEnd.hidden = false;
            [_challengePlayer pause];
            [_challengePlayer seekToTime:kCMTimeZero];
            CGPoint center = self.view.center;
            center.y -= 60;
            distanceBiked.center = center;
            [self.view bringSubviewToFront:_challengeEnd];
            //[distanceBiked setFont:[UIFont fontWithName:@"Rubik-Medium" size:48]];
            UIFont *font = [UIFont fontWithName:@"Rubik-Medium" size:48.0];
            NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                        forKey:NSFontAttributeName];
            
            NSString* revs =[NSString stringWithFormat:@"%.1f", bscData.accumCrankRevolutions*7.33/5280.0];
            NSString *fullText = [NSString stringWithFormat:@"You Biked \n %@ miles!",revs];
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:fullText attributes:attrsDictionary];
            distanceBiked.attributedText = attrString;
            distanceBiked.hidden = false;
            NSString *post = [NSString stringWithFormat:@"Distance=%@",revs];
            NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:@"http://www.abcde.com/xyz/login.aspx"]];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];

            [self.view bringSubviewToFront:distanceBiked];
            
            //NSLog(@"%lu", bscData.accumCrankRevolutions);
            sleepNow = true;
        }
        NSLog(@"%lu", bscData.accumCrankRevolutions);
        // get BTLE specific data.
        if ( [bscData isKindOfClass:[WFBTLEBikeSpeedCadenceData class]] )
        {
            WFBTLEBikeSpeedCadenceData* btleData = (WFBTLEBikeSpeedCadenceData*)bscData;
            
            // check for Wahoo CBSC device extended data.
            if ( btleData.wahooData )
            {
                // the Wahoo device reports ambient temperature.
                float temp = btleData.wahooData.temperature;
                NSString* units = @"° C";
                if ( !hardwareConnector.settings.useMetricUnits )
                {
                    const float convFactor = (9.0/5.0);
                    temp = (convFactor * temp) + 32;
                    units = @"° F";
                }
                temperatureLabel.text = [NSString stringWithFormat:@"%1.2f%@", temp, units];
            }
        }
        NSLog(@"BSC DISTANCE:  %@", [bscData formattedDistance:TRUE]);
        /*
         * this demonstrates computing speed manually, using unformatted values.
         
        // calculate the speed.
        //
		// API provides wheel cadence in RPM's, need to multiply by circumference(6.79ft) or metric and 60 minutes
		// Be sure and add Wheel Size variable somewhere in App
		
		computedSpeedLabel.text = [NSString stringWithFormat:@"%0.0f", (float) bscData.instantWheelRPM * 0.0771743];
		computedCadenceLabel.text = [NSString stringWithFormat:@"%d", bscData.instantCrankRPM];
        */
	}
	else
	{
		[self resetDisplay];
	}
}



#pragma mark -
#pragma mark BikeSpeedCadenceViewController Implementation

#pragma mark Properties

//--------------------------------------------------------------------------------
- (WFBikeSpeedCadenceConnection*)bikeSpeedCadenceConnection
{
	WFBikeSpeedCadenceConnection* retVal = nil;
	if ( [self.sensorConnection isKindOfClass:[WFBikeSpeedCadenceConnection class]] )
	{
		retVal = (WFBikeSpeedCadenceConnection*)self.sensorConnection;
	}
	
	return retVal;
}


#pragma mark Event Handlers

//--------------------------------------------------------------------------------
- (IBAction)odometerClicked:(id)sender
{
    BOOL bAlert = FALSE;
    NSString* msg = nil;
    
    // only available for BTLE S/C sensor.
    WFBTLEBikeSpeedCadenceData* cscData = [self.bikeSpeedCadenceConnection getCSCData];
    if ( cscData )
    {
        // check for Wahoo BlueSC device.
        if ( cscData.wahooData )
        {
            // check for odometer history.
            if ( cscData.wahooData.odometerHistory )
            {
                // configure and display the sensor manager view.
                OdometerHistoryVC* vc = [[OdometerHistoryVC alloc] initWithNibName:@"OdometerHistoryVC" bundle:nil];
                vc.odometerHistory = cscData.wahooData.odometerHistory;
                vc.bscConnection = self.bikeSpeedCadenceConnection;
                [self.navigationController pushViewController:vc animated:TRUE];
            }
            // history not available yet.
            else
            {
                msg = @"The odometer history has not been received yet.";
                bAlert = TRUE;
            }
        }
        // not a Wahoo BlueSC device.
        else
        {
            msg = @"Odometer history is only available from the Wahoo BlueSC.";
            bAlert = TRUE;
        }
    }
    else
    {
        msg = @"Odometer history is not available from ANT+ devices.";
        bAlert = TRUE;
    }
    
    // show the error message.
    if ( bAlert  )
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Odometer History" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
        alert = nil;
    }
    
}
- (void)initStoryPlayer{
    NSString *path = [[NSBundle mainBundle] resourcePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *dirandfilenames = [fm contentsOfDirectoryAtPath:path error:&error];
    //NSLog(@"%@",dirandfilenames[11]);
    NSString *path1 = dirandfilenames[14];
    
    NSArray *components = [NSArray arrayWithObjects:path,path1,nil];
    NSString *fullpath = [NSString pathWithComponents:components];
    NSURL *url = [NSURL fileURLWithPath:fullpath];
    
    AVPlayer *player = [AVPlayer playerWithURL:url];
    AVPlayerViewController * controller = [[AVPlayerViewController alloc]init];
    controller.player = player;
    //controller.view.frame = self.view.bounds;
    _storyPlayer = player;
    _storyPlayerController = controller;
}
- (void) initChallengePlayer{
    NSString *path = [[NSBundle mainBundle] resourcePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *dirandfilenames = [fm contentsOfDirectoryAtPath:path error:&error];
    NSLog(@"%@",dirandfilenames);
    NSString *path1 = dirandfilenames[26];
    
    NSArray *components = [NSArray arrayWithObjects:path,path1,nil];
    NSString *fullpath = [NSString pathWithComponents:components];
    NSURL *url = [NSURL fileURLWithPath:fullpath];
    AVPlayer *player = [AVPlayer playerWithURL:url];
    AVPlayerViewController * controller = [[AVPlayerViewController alloc]init];
    
    controller.player = player;
    //controller.view.frame = self.view.bounds;
    //TODO possible memory leak
    //controller.showsPlaybackControls = false;

    _challengePlayer = player;
    _challengePlayerController = controller;
}

- (IBAction)yesAction:(id)sender {
    //AudioServicesPlaySystemSound (1100);
    isPlaying = true;
    [self.bikeSpeedCadenceConnection requestOdometerReset:0.0];
    //controller.showsPlaybackControls = false;
    [self.view bringSubviewToFront:_challengePlayerController.view];
    [_challengePlayer play];
}
- (IBAction)noAction:(id)sender {
    //AudioServicesPlaySystemSound (1100);
    
    inChallenge = false;
    startScreen.hidden=false;
    isPlaying = false;
    [self.view bringSubviewToFront:startScreen];
    sleepNow = true;
}



@end
