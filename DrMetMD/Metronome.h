//
//  Metronome.h
//  DrMetMD
//
//  Created by Mack Hagen on 7/15/15.
//  Copyright (c) 2015 mackhagen. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ObjectAL.h"
#import <Foundation/Foundation.h>
#include <mach/mach.h>
#include <mach/mach_time.h>

@interface Metronome:(double)dTimeFactor : NSObject

@property __block BOOL playing;
@property __block BOOL accentOn;
@property __block BOOL quarterOn;
@property __block BOOL eighthOn;
@property __block BOOL sixteenthOn;

@property __block int      iBpm;
@property __block uint64_t ullBpmMs;
@property __block uint64_t ullInterval;
@property __block double   dTimeFactor;

@property int iTimeSignature;

// ----- Audio Objects ----- //

@property ALDevice* device;
@property ALContext* context;

@property __block ALChannelSource* accentChannel;
@property __block ALChannelSource* quarterChannel;
@property __block ALChannelSource* eighthChannel;
@property __block ALChannelSource* sixteenthChannel;

@property __block ALBuffer* accent;
@property __block ALBuffer* quarter;
@property __block ALBuffer* eighth;
@property __block ALBuffer* sixteenth;

@property __block ALBuffer* accentTrimmed;
@property __block ALBuffer* quarterTrimmed;
@property __block ALBuffer* eighthTrimmed;
@property __block ALBuffer* sixteenthTrimmed;

- (void)ToggleMet:(bool)bOn;
- (void)SetBpm:(int)iBpm;
- (void)SetAccentVolume:(float)iVolume;
- (void)SetQuarterVolume:(float)iVolume;
- (void)SetEighthVolume:(float)iVolume;
- (void)SetSixteenthVolume:(float)iVolume;

@end
