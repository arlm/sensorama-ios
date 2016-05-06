//
//  SREngine.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/2/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

@import UIKit;
@import CoreMotion;



#import "SREngine.h"
#import "SRCfg.h"
#import "SRSync.h"
#import "SRUtils.h"
#import "SRDebug.h"
#import "SRAuth.h"
#import "SRDataFile.h"
#import "SRDataPoint.h"

#if 0
#import "ObjCBSON/BSONSerialization.h"
#endif


@interface SREngine ()

@property (nonatomic) SRCfg *configuration;
@property (nonatomic) SRDataFile *dataFile;
@property (nonatomic) NSTimer *timer;
@end

@implementation SREngine

- (instancetype) initWithConfiguration:(SRCfg *)configuration {
    self = [super init];
    if (self) {
        _configuration = configuration;
        _dataFile = nil;
    }
    return self;
}

- (instancetype) init {
    return [self initWithConfiguration:[SRCfg defaultConfiguration]];
}

- (void) recordingStartWithUpdates:(BOOL)enableUpdates {
    [self startSensors];

    self.dataFile = [[SRDataFile alloc] initWithConfiguration:[SRCfg defaultConfiguration] userName:[SRAuth emailHashed]];
    [self.dataFile startWithDate:[NSDate date]];

    self.timer = nil;
    if (enableUpdates) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.25 //self.configuration.sampleInterval / 1000
                                         target:self
                                       selector:@selector(recordingUpdate)
                                       userInfo:nil
                                        repeats:YES];
    }
}

- (void)recordingUpdate {
    SRPROBE0();
    if (self.timer == nil) {
        NSLog(@"stopped!");
    }

    SRDataPoint *newPoint = [SRDataPoint new];
    [self.dataFile updateWithPoint:newPoint];
}

- (void) recordingStart {
    [self recordingStartWithUpdates:YES];
}

- (void) recordingStopWithSync:(BOOL)doSync {
    [self.timer invalidate];
    self.timer = nil;
    [self.dataFile finalizeWithDate:[NSDate date]];
    [self.dataFile saveWithSync:doSync];
}

- (void) recordingStop {
    [self recordingStopWithSync:YES];
}



- (CMPedometerHandler)pedometerUpdateHandler {
    void (^handler)(CMPedometerData *, NSError *) = ^(CMPedometerData *d, NSError *error) {
        [SRDataPoint pedometerDataUpdate:d];
    };
    return handler;
}

- (void)startSensors {
    [[SRDataPoint motionManager] stopAccelerometerUpdates];
    [[SRDataPoint motionManager] stopMagnetometerUpdates];
    [[SRDataPoint motionManager] stopGyroUpdates];
    [[SRDataPoint pedometerInstance] stopPedometerUpdates];

    [[SRDataPoint motionManager] startAccelerometerUpdates];
    [[SRDataPoint motionManager] startMagnetometerUpdates];
    [[SRDataPoint motionManager] startGyroUpdates];
    [[SRDataPoint pedometerInstance] startPedometerUpdatesFromDate:[NSDate date]
                                                       withHandler:self.pedometerUpdateHandler];
}

- (NSArray<SRDataFile *> *) allRecordedFiles {
    NSMutableArray *array = [NSMutableArray new];
    for (SRDataFile *file in [[SRDataFile allObjects] sortedResultsUsingProperty:@"fileId" ascending:YES]) {
        [array addObject:file];
    }
    return array;
}

@end
