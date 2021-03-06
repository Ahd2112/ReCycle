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
//  BikeSpeedCadenceViewController.h
//  FisicaDemo
//
//  Created by Michael Moore on 2/21/10.
//  Copyright 2010 Wahoo Fitness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFSensorCommonViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
@class WFBikeSpeedCadenceConnection;


@interface BikeSpeedCadenceViewController : WFSensorCommonViewController <WFBikeSpeedCadenceDelegate>
{
	UILabel* lastCadenceTimeLabel;
	UILabel* totalCadenceRevolutionsLabel;
	UILabel* lastSpeedTimeLabel;
	UILabel* totalSpeedRevolutionsLabel;
	UILabel* computedCadenceLabel;
	UILabel* computedSpeedLabel;
    UILabel* distanceLabel;
    UILabel* temperatureLabel;
    UILabel* distanceBiked;
    
    UIWebView *myWebView;
    
}


@property (retain, nonatomic) IBOutlet UILabel *distanceBiked;
@property (readonly, nonatomic) WFBikeSpeedCadenceConnection* bikeSpeedCadenceConnection;
@property (retain, nonatomic) IBOutlet UILabel* lastCadenceTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel* totalCadenceRevolutionsLabel;
@property (retain, nonatomic) IBOutlet UILabel* lastSpeedTimeLabel;
@property (retain, nonatomic) IBOutlet UILabel* totalSpeedRevolutionsLabel;
@property (retain, nonatomic) IBOutlet UILabel* computedCadenceLabel;
@property (retain, nonatomic) IBOutlet UILabel* computedSpeedLabel;
@property (retain, nonatomic) IBOutlet UILabel* distanceLabel;
@property (retain, nonatomic) IBOutlet UILabel* temperatureLabel;

@property (retain, nonatomic) IBOutlet UIImageView *startScreen;
@property (retain, nonatomic) IBOutlet UIImageView *challengeQ;
@property (retain, nonatomic) IBOutlet UIImageView *challengeEnd;
@property (retain, nonatomic) IBOutlet UIButton *yesButton;
@property (retain, nonatomic) IBOutlet UIButton *noButton;
@property (retain, nonatomic) IBOutlet UIButton *sendMessage;

@property (retain,atomic) AVPlayer* storyPlayer;
@property (retain,atomic) AVPlayer* challengePlayer;
@property (retain,atomic) AVPlayerViewController* storyPlayerController;
@property (retain,atomic) AVPlayerViewController* challengePlayerController;

- (IBAction)odometerClicked:(id)sender;
@end
