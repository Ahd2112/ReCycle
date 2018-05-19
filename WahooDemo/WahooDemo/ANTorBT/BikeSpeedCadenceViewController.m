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
static NSUInteger timeNotActive = 0;
static bool isPlaying = false;
static bool inChallange = false;
static bool atMovieEnd = false;
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
    NSString* msg = [NSString stringWithFormat:@"Received Odometer Reset response.\n\nStatus: %@", bSuccess?@"SUCCESS":@"FAILED"];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"BTLE CSC" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
    alert = nil;
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
        [[self navigationController]setNavigationBarHidden:true];
        startScreen.hidden = false;
        
        // update basic data.
		lastCadenceTimeLabel.text = [NSString stringWithFormat:@"%3.3f", bscData.accumCadenceTime];
		totalCadenceRevolutionsLabel.text = [NSString stringWithFormat:@"%ld", bscData.accumCrankRevolutions];
		lastSpeedTimeLabel.text = [NSString stringWithFormat:@"%3.3f", bscData.accumSpeedTime];
		totalSpeedRevolutionsLabel.text = [NSString stringWithFormat:@"%ld", bscData.accumWheelRevolutions];
        
		computedSpeedLabel.text = [bscData formattedSpeed:TRUE];
        computedCadenceLabel.text = [bscData formattedCadence:TRUE];
        distanceLabel.text = [bscData formattedDistance:TRUE];
        //the movie is currently not running
        if ([computedCadenceLabel.text isEqualToString:@"--"]){
            timeNotActive++;
            NSLog([NSString stringWithFormat:@"%lu",(unsigned long)timeNotActive]);
        }
        //if started and got off reset to startcreen
        if([computedCadenceLabel.text isEqualToString:@"--"] && timeNotActive>10){
            isPlaying = false;
            startScreen.hidden = false;
            [[self view] addSubview:startScreen];
            [self.thePlayer pause];
            [self.thePlayer release];
            //go back to restart screen
        }
        //if not running play movie and bike not moving play movie
        if (![computedCadenceLabel.text isEqualToString:@"--"] && !isPlaying){
            timeNotActive = 0;
            self.thePlayer=[self playMovie];
        }
        if(isPlaying && _thePlayer!=nil){
            float time = CMTimeGetSeconds(self.thePlayer.currentTime);
            NSLog([NSString stringWithFormat:@"%f", time]);
        }
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
- (AVPlayer*)playMovie {
    NSString *path = [[NSBundle mainBundle] resourcePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *dirandfilenames = [fm contentsOfDirectoryAtPath:path error:error];
    NSLog(@"%@",dirandfilenames[3]);
    NSString *path1 = dirandfilenames[3];
    
    NSArray *components = [NSArray arrayWithObjects:path,path1,nil];
    NSString *fullpath = [NSString pathWithComponents:components];
    NSURL *url = [NSURL fileURLWithPath:fullpath];
    AVPlayer *player = [AVPlayer playerWithURL:url];
    AVPlayerViewController * controller = [[AVPlayerViewController alloc]init];
    
    controller.player = player;
    controller.view.frame = self.view.bounds;
    
    [[self view] addSubview:controller.view];
    if (![computedCadenceLabel.text isEqualToString:@"--"] && !isPlaying)
    {
        isPlaying = true;
        [player play];
    }
    return player;
    
}

- (IBAction)recycle:(id)sender {
    
    NSString *path = [[NSBundle mainBundle] resourcePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *dirandfilenames = [fm contentsOfDirectoryAtPath:path error:error];
    NSLog(@"%@",dirandfilenames[3]);
    NSString *path1 = dirandfilenames[3];
    
    NSArray *components = [NSArray arrayWithObjects:path,path1,nil];
    NSString *fullpath = [NSString pathWithComponents:components];
    NSURL *url = [NSURL fileURLWithPath:fullpath];
    AVPlayer *player = [AVPlayer playerWithURL:url];
    AVPlayerViewController * controller = [[AVPlayerViewController alloc]init];
    
    controller.player = player;
    controller.view.frame = self.view.bounds;
    
    [[self view] addSubview:controller.view];
    startScreen.hidden = true;
    [player play];
    
     
}

@end
