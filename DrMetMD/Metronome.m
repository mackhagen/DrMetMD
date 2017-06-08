//
//  Metronome.m
//  DrMetMD
//
//  Created by Mack Hagen on 7/15/15.
//  Copyright (c) 2015 mackhagen. All rights reserved.
//

#import "Metronome.h"

static NSString *tick = @"hi_click loud.wav";
static NSString *tock = @"low_click loud.wav";
static NSString *tack = @"softclick hi res.wav";

//-------------------------------------------------------------------------------

@implementation Metronome

- (void)Metronome:(double)dTimeFactor {
    _playing     = NO;
    _accentOn    = YES;
    _quarterOn   = YES;
    _eighthOn    = NO;
    _sixteenthOn = NO;
    
    _dTimeFactor = dTimeFactor;
    _iTimeSignature = 4;
    
    // Create the device and context
    _device = [ALDevice deviceWithDeviceSpecifier:nil];
    _context = [ALContext contextOnDevice:_device attributes:nil];
    [OpenALManager sharedInstance].currentContext = _context;
    
    [OALAudioSession sharedInstance].handleInterruptions = YES;
    [OALAudioSession sharedInstance].allowIpod           = NO;
    [OALAudioSession sharedInstance].honorSilentSwitch   = YES;
    
    // Take all 32 sources
    _accentChannel    = [ALChannelSource channelWithSources:1];
    _quarterChannel   = [ALChannelSource channelWithSources:1];
    _eighthChannel    = [ALChannelSource channelWithSources:1];
    _sixteenthChannel = [ALChannelSource channelWithSources:1];
    
    // Preload the buffers
    _accent    = [[OpenALManager sharedInstance] bufferFromFile:tick]; // 657
    _quarter   = [[OpenALManager sharedInstance] bufferFromFile:tock]; // 999
    _eighth    = [[OpenALManager sharedInstance] bufferFromFile:tack]; // 657
    _sixteenth = [[OpenALManager sharedInstance] bufferFromFile:tick]; // 657
    
    _accentTrimmed    = [_accent    sliceWithName:nil offset:0 size:300];
    _quarterTrimmed   = [_quarter   sliceWithName:nil offset:0 size:300];
    _eighthTrimmed    = [_eighth    sliceWithName:nil offset:0 size:300];
    _sixteenthTrimmed = [_sixteenth sliceWithName:nil offset:0 size:300];
    
    _accentChannel.gain    = 1.0;
    _quarterChannel.gain   = 1.0;
    _eighthChannel.gain    = 0.75;
    _sixteenthChannel.gain = 0.5;
    
    [_accentChannel    setMuted:!_accentOn];
    [_quarterChannel   setMuted:!_quarterOn];
    [_eighthChannel    setMuted:!_eighthOn];
    [_sixteenthChannel setMuted:!_sixteenthOn];
}

//-------------------------------------------------------------------------------

- (void)ToggleMet:(bool)bOn {
    if (!_playing && bOn) { // Don't start another thread if already playing
        _playing = YES;
        dispatch_queue_t metQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        [self executeInBackground:^{
            int iBeat = 1;
            while (_playing) {
                uint64_t now = mach_absolute_time() * 1.0;
                
                if (iBeat == 1) {
                    [_quarterChannel play:_quarterTrimmed];
                }
                else if (iBeat % 2 == 0) {
                    [_sixteenthChannel play:_sixteenthTrimmed];
                }
                else if (iBeat == 3) {
                    [_eighthChannel play:_eighthTrimmed];
                }
                mach_wait_until(now + _ullBpmMs);
                
                //uint64_t then = mach_absolute_time() * 1.0;
                //NSLog(@"End %llu", then - now);
            }
        } inQueue:metQueue];
    }
    else if (!bOn){
        _playing = NO;
    }
}

//-------------------------------------------------------------------------------

- (void)SetBPM:(int)iBpm {
    [self executeInBackground:^{
        _iBpm = (int)ceil(iBpm);
        _ullInterval = (((60.0 / iBpm) * 1000.0) - 3.0);
        
        _ullInterval = (uint64_t)(_ullInterval * _dTimeFactor)  * 0.25;
        //NSLog(@"Interval = %llu", _interval);
        
        _ullBpmMs = _ullInterval * 1.0;
    } inQueue:dispatch_get_main_queue()];
}

//-------------------------------------------------------------------------------

- (void)SetAccentVolume:(float)iVolume {
    _accentChannel.gain = iVolume;
}

//-------------------------------------------------------------------------------

- (void)SetQuarterVolume:(float)iVolume {
    _quarterChannel.gain = iVolume;
}

//-------------------------------------------------------------------------------

- (void)SetEighthVolume:(float)iVolume {
    _eighthChannel.gain = iVolume;
}

//-------------------------------------------------------------------------------

- (void)SetSixteenthVolume:(float)iVolume {
    _sixteenthChannel.gain = iVolume;
}

//-------------------------------------------------------------------------------

- (void)executeInBackground:(void (^)())block inQueue:(dispatch_queue_t)queue{
    dispatch_async(queue, ^{
        block();
    });
}

@end
