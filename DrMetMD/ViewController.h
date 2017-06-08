/************************************************************************
 *
 *  DrMetMD
 *  ViewController.h
 *
 *  Created by Mack Hagen on 6/30/14.
 *  Copyright (c) 2014 mackhagen. All rights reserved.
 *
 ************************************************************************/

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Foundation/Foundation.h>
#import "ObjectAL.h"
#include <mach/mach.h>
#include <mach/mach_time.h>
#include "Metronome.h"

@interface ViewController : UIViewController

// ----- UI Objects and Functions ----- //

@property __block double   timeFactor;

@property Metronome *pMetronome;

@property (weak, nonatomic)   IBOutlet UILabel *bpmDisplay;
@property (weak, nonatomic)   IBOutlet UIStepper *bpmStep;
@property (strong, nonatomic) IBOutlet UISlider *bpmControl;

- (IBAction)adjustBPM:(id)sender;
- (IBAction)stepBPM:(id)sender;

@property (strong, nonatomic) IBOutlet UISlider *accentVol;
@property (strong, nonatomic) IBOutlet UISlider *quarterVol;
@property (strong, nonatomic) IBOutlet UISlider *eighthVol;
@property (strong, nonatomic) IBOutlet UISlider *sixteenthVol;

- (IBAction)adjustAccent:(id)sender;
- (IBAction)adjustQuarter:(id)sender;
- (IBAction)adjustEighth:(id)sender;
- (IBAction)adjustSixteenth:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *accentButton;
@property (strong, nonatomic) IBOutlet UIButton *quarterButton;
@property (strong, nonatomic) IBOutlet UIButton *eighthButton;
@property (strong, nonatomic) IBOutlet UIButton *sixteenthButton;

- (IBAction)toggleMet:(id)sender;
- (IBAction)toggleAccent:(id)sender;
- (IBAction)toggleQuarter:(id)sender;
- (IBAction)toggleEighth:(id)sender;
- (IBAction)toggleSixteenth:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *masterVolView;

- (void)createAndDisplayMPVolumeView;

- (IBAction)tapTempo:(id)sender;

@end

