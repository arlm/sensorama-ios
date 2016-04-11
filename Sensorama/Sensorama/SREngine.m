//
//  SREngine.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/2/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BZipCompression/BZipCompression.h"
#import "CoreMotion/CoreMotion.h"
#import "UIKit/UIKit.h"
#import "SREngine.h"
#import "SRCfg.h"
#import "SRSync.h"
#import "SRUtils.h"
#import "SRDebug.h"
#import "SRAuth.h"

@interface SREngine ()

@property (strong, nonatomic) CMMotionManager *motionManager;

@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSString *pathDocuments;
@property (strong, nonatomic) SRCfg *srCfg;
@property (strong, nonatomic) NSThread *srThread;
@property (strong, nonatomic) NSTimer *srTimer;
@property (strong, nonatomic) NSMutableArray *srData;
@property (strong, nonatomic) UIDevice *srDevice;

@property (strong, nonatomic) NSString *startDateString;
@property (strong, nonatomic) NSString *startTimeString;
@property (strong, nonatomic) NSString *endTimeString;

@end

@implementation SREngine

- (instancetype) init {
    self = [super init];
    if (self) {
        self.fileManager = [NSFileManager defaultManager];
        self.pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.srCfg = [SRCfg new];
        self.srThread = [NSThread new];
        self.srData = [NSMutableArray new];
        self.srDevice = [UIDevice currentDevice];
    }
    return self;
}

- (void) recordingStart {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.motionManager = [CMMotionManager new];
    });

    [self startSensors];

    self.startDateString = [self.srCfg sensoramaDateString];
    self.startTimeString = [self.srCfg sensoramaTimeString];

    self.srTimer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                     target:self
                                   selector:@selector(updateData)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)startSensors {
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopMagnetometerUpdates];
    [self.motionManager stopGyroUpdates];

    [self.motionManager startAccelerometerUpdates];
    [self.motionManager startMagnetometerUpdates];
    [self.motionManager startGyroUpdates];
}

- (NSDictionary *)schemaDict {
    NSError *error;
    NSString *schemaFilePath = [[NSBundle mainBundle] pathForResource:@"sensorama.schema" ofType:@"json"];
    NSData *schemaData = [NSData dataWithContentsOfFile:schemaFilePath];
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:schemaData
                          options:kNilOptions
                          error:&error];
    NSAssert(jsonDict != nil, @"couldn't serialize JSON file");
    return jsonDict;
}

- (void) updateData {
    BOOL isSIM = true;
    BOOL hasAccelerometer = isSIM || (self.motionManager.accelerometerActive && self.motionManager.accelerometerAvailable);
    BOOL hasMagnetometer = isSIM || (self.motionManager.magnetometerActive && self.motionManager.magnetometerAvailable);
    BOOL hasGyroscope = isSIM || (self.motionManager.gyroActive && self.motionManager.gyroAvailable);
    NSMutableDictionary *oneDataPoint = [NSMutableDictionary new];

    SRPROBE0();

    CFTimeInterval curTime = CACurrentMediaTime();
    [oneDataPoint setObject:@(curTime) forKey:@"t"];

    if (hasAccelerometer) {
        CMAccelerometerData *accData = [self.motionManager accelerometerData];
        SRDEBUG(@"acc:%@", accData);
        CMAcceleration acc = [accData acceleration];
        [oneDataPoint setObject:@[ @(acc.x), @(acc.y), @(acc.z)] forKey:@"acc"];
    }
    if (hasMagnetometer) {
        CMMagnetometerData *magData = [self.motionManager magnetometerData];
        SRDEBUG(@"mag:%@", magData);
        CMMagneticField mag = [magData magneticField];
        [oneDataPoint setObject:@[ @(mag.x), @(mag.y), @(mag.z)] forKey:@"mag"];
    }
    if (hasGyroscope) {
        CMGyroData *gyroData = [self.motionManager gyroData];
        SRDEBUG(@"gyro:%@", gyroData);
        CMRotationRate gyro = [gyroData rotationRate];
        [oneDataPoint setObject:@[ @(gyro.x), @(gyro.y), @(gyro.z)] forKey:@"gyro"];
    }
    [self.srData addObject:oneDataPoint];
}

- (void) recordingStop {
    if (self.startDateString == nil || self.startTimeString == nil) {
        // didn't start yet
        return;
    }

    [self.srTimer invalidate];
    self.endTimeString = [self.srCfg sensoramaTimeString];

    NSString *dateString = [NSString stringWithFormat:@"%@_%@-%@",
                            self.startDateString, self.startTimeString, self.endTimeString];
    NSString *fileName = [NSString stringWithFormat:@"%@.json.bz2", dateString];
    NSString *sampleFilePath = [self.pathDocuments stringByAppendingPathComponent:fileName];

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[self schemaDict] copyItems:YES];
    [dict setObject:[SRAuth emailHashed] forKey:@"username"];
    [dict setObject:self.srData forKey:@"points"];
    [dict setObject:dateString forKey:@"date"];
    [dict setObject:@"Sensorama_iOS" forKey:@"desc"];
    [dict setObject:@(250) forKey:@"interval"];
    [dict setObject:[SRUtils deviceInfo] forKey:@"device_info"];

    NSError *error = nil;
    NSData *sampleDataJSON = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSData *compressedData = [BZipCompression compressedDataWithData:sampleDataJSON blockSize:BZipDefaultBlockSize workFactor:BZipDefaultWorkFactor error:&error];
    [compressedData writeToFile:sampleFilePath atomically:NO];

    SRSync *syncFile = [[SRSync alloc] initWithPath:sampleFilePath];
    [syncFile syncStart];
}

- (NSString *) filesPath {
    return self.pathDocuments;
}

- (NSArray *) filesRecorded {
    NSArray *filePaths = [self.fileManager contentsOfDirectoryAtPath:self.pathDocuments error:nil];


    return filePaths;
}


@end
