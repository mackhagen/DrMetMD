/************************************************************************
 *
 *  DrMetMD
 *  ViewController.m
 *
 *  Created by Mack Hagen on 6/30/14.
 *  Copyright (c) 2014 mackhagen. All rights reserved.
 *  
 *  http://kstenerud.github.io/ObjectAL-for-iPhone/
 *  https://developer.apple.com/library/ios/technotes/tn2169/_index.html
 *
 ************************************************************************/


#import "ViewController.h"
#import "ObjectAL/OALSimpleAudio.h"
#import "ObjectAL.h"
#import "math.h"
#include <MediaPlayer/MediaPlayer.h>
#include <mach/mach.h>
#include <mach/mach_time.h>

const uint64_t NANOS_PER_MILLISEC = 1000000ULL;

static NSString *tick = @"hi_click loud.wav";
static NSString *tock = @"low_click loud.wav";
static NSString *tack = @"softclick hi res.wav";

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    mach_timebase_info_data_t timebase_info;
    mach_timebase_info(&timebase_info);
    _timeFactor = ((double)timebase_info.denom / (double)timebase_info.numer) * NANOS_PER_MILLISEC;
    
    _pMetronome = [Metronome self];
    
    [_pMetronome SetBpm:120];
    
    _accentButton.selected = YES;
    _quarterButton.selected = YES;

    //[self createAndDisplayMPVolumeView];
    
    //_bpmControl.transform = CGAffineTransformRotate(_bpmControl.transform, 90.0/180*M_PI);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createAndDisplayMPVolumeView {
    // Create a simple holding UIView and give it a frame
    _masterVolView = [[UIView alloc] initWithFrame: CGRectMake(30, 200, 260, 20)];
    // set the UIView backgroundColor to clear.
    [_masterVolView setBackgroundColor: [UIColor clearColor]];
    // add the holding view as a subView of the main view
    [self.view addSubview: _masterVolView];
    
    // Create an instance of MPVolumeView and give it a frame
    MPVolumeView *myVolumeView = [[MPVolumeView alloc] initWithFrame: _masterVolView.bounds];
    // Add myVolumeView as a subView of the volumeHolder
    [_masterVolView addSubview: myVolumeView];
}

/*********** BPM Changes ***********/

- (IBAction)adjustBPM:(UISlider *)sender {
    //mach_timebase_info(&timebase_info);
    [self setBPM:sender.value];
    [_bpmStep setValue:sender.value];
}

- (IBAction)stepBPM:(UIStepper *)sender {
    //mach_timebase_info(&timebase_info);
    [self setBPM:sender.value];
    [_bpmControl setValue:sender.value];
}

/*********** Volume Changes ***********/

- (IBAction)adjustAccent:(UISlider *)sender {
    float val = sender.value;
    _accentChannel.gain = val;
}

- (IBAction)adjustQuarter:(UISlider *)sender {
    float val = sender.value;
    _quarterChannel.gain = val;
}

- (IBAction)adjustEighth:(UISlider *)sender {
    float val = sender.value;
    _eighthChannel.gain = val;
}

- (IBAction)adjustSixteenth:(UISlider *)sender {
    float val = sender.value;
    _sixteenthChannel.gain = val;
}

/*********** Toggle Met ***********/

- (IBAction)toggleMet:(UIButton *)sender {
    
    if (!_playing) { // Don't start another thread if already playing
        sender.selected = YES;
        _playing = YES;
        dispatch_queue_t metQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        [self executeInBackground:^{
			while (_playing) {
                uint64_t now = mach_absolute_time() * 1.0;
                
                [_quarterChannel play:_quarterTrimmed];
                mach_wait_until(now + _bpm1);
                
                if (!_playing) break;
                
                [_sixteenthChannel play:_sixteenthTrimmed];
                mach_wait_until(now + _bpm2);
             
                if (!_playing) break;
                
                [_eighthChannel play:_eighthTrimmed];
                mach_wait_until(now + _bpm3);
                
                if (!_playing) break;
                
                [_sixteenthChannel play:_sixteenthTrimmed];
                mach_wait_until(now + _bpm4);
                
                //uint64_t then = mach_absolute_time() * 1.0;
                //NSLog(@"End %llu", then - now);
			}
        } inQueue:metQueue];
	}
    else {
        _playing = NO;
        sender.selected = NO;
    }
}

/*********** Subdivision Toggles ***********/

- (IBAction)toggleAccent:(UIButton *)sender {
    _accentOn = !_accentOn;
    sender.selected = !sender.selected;
    [_accentChannel setMuted:!_accentOn];
}

- (IBAction)toggleQuarter:(UIButton *)sender {
    _quarterOn = !_quarterOn;
    sender.selected = !sender.selected;
    [_quarterChannel setMuted:!_quarterOn];
}

- (IBAction)toggleEighth:(UIButton *)sender {
    _eighthOn = !_eighthOn;
    sender.selected = !sender.selected;
    [_eighthChannel setMuted:!_eighthOn];
}

- (IBAction)toggleSixteenth:(UIButton *)sender {
    _sixteenthOn = !_sixteenthOn;
    sender.selected = !sender.selected;
    [_sixteenthChannel setMuted:!_sixteenthOn];
}

/*********** Tap Tempo ***********/

- (IBAction)tapTempo:(id)sender {
    
}


/*********** Utility Functions ***********/
/*
- (uint64_t)getBPM:(int)value {
    static mach_timebase_info_data_t    sTimebaseInfo;
    [self executeInBackground:^{
        _interval = (((60.0 / value) * 1000) - 4) * NANOS_PER_MILLISEC;
    
        if ( sTimebaseInfo.denom == 0 ) {
            (void) mach_timebase_info(&sTimebaseInfo);
        }
    
        _interval = _interval * sTimebaseInfo.numer / sTimebaseInfo.denom;
    }];
    return _interval;
}*/

- (void)setBPM:(int)value {
    [self executeInBackground:^{
        _bpmR = (int)ceil(value);
        _interval = (((60.0 / value) * 1000.0) - 3.0);
        
        _interval = (uint64_t)(_interval * _timeFactor)  * 0.25;
        NSLog(@"Interval = %llu", _interval);
        
        _bpm1 = _interval * 1.0;
        _bpm2 = _interval * 2.0;
        _bpm3 = _interval * 3.0;
        _bpm4 = _interval * 4.0;
        _bpmDisplay.text = [NSString stringWithFormat:@"%.1d", _bpmR];
    } inQueue:dispatch_get_main_queue()];
}

- (void)executeInBackground:(void (^)())block inQueue:(dispatch_queue_t)queue{
    dispatch_async(queue, ^{
        block();
    });
}

@end
