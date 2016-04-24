//
//  SRDataPoint.m
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 23/04/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//



#import "SRDataPoint.h"
#import "SRUtils.h"

@implementation SRDataPoint

#pragma mark - General helpers

+ (BOOL) isSimulator {
    return [SRUtils isSimulator];
}

#pragma mark - Realm relationship methods

//+ (NSString *)primaryKey
//{
//    return @"fileId";
//}
//
//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{@"fileId": @(-1) };
//}

#pragma mark - JSON helper methods

- (NSDictionary *) toDict {
    return @{
             @"acc" : @[ _accX, _accY, _accZ ],
             @"mag" : @[ _magX, _magY, _magZ ],
             @"gyro": @[ _gyroX, _gyroY, _gyroZ ],
             @"fileId" : @(_fileId),
             @"curTime" : _curTime
             };
}

+ (CMMotionManager *)motionManager {
    __block CMMotionManager *motionManager = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        motionManager = [CMMotionManager new];
    });

    return motionManager;
}


#pragma mark - Actual sensor data fetching

- (CMAcceleration) curAccData {
    CMAcceleration vals;
    if (![SRDataPoint isSimulator]) {
        return [[[SRDataPoint motionManager] accelerometerData] acceleration];
    }
    vals.x = (double)arc4random();
    vals.y = (double)arc4random();
    vals.z = (double)arc4random();
    return vals;
}

- (CMMagneticField) curMagData {
    CMMagneticField vals;
    if (![SRDataPoint isSimulator]) {
        return [[[SRDataPoint motionManager] magnetometerData] magneticField];
    }
    vals.x = (double)arc4random();
    vals.y = (double)arc4random();
    vals.z = (double)arc4random();
    return vals;
}

- (CMRotationRate) curGyroData {
    CMRotationRate vals;
    if (![SRDataPoint isSimulator]) {
        return [[[SRDataPoint motionManager] gyroData] rotationRate];
    }
    vals.x = (double)arc4random();
    vals.y = (double)arc4random();
    vals.z = (double)arc4random();
    return vals;
}

#pragma mark - initializer

- (instancetype) init {
    self = [super init];
    if (!self) {
        return self;
    }

    self.curTime = @(CACurrentMediaTime());

    CMAcceleration  acc = [self curAccData];
    CMMagneticField mag = [self curMagData];
    CMRotationRate gyro = [self curGyroData];

    self.accX = @(acc.x);
    self.accY = @(acc.y);
    self.accZ = @(acc.z);

    self.magX = @(mag.x);
    self.magY = @(mag.y);
    self.magZ = @(mag.z);

    self.gyroX = @(gyro.x);
    self.gyroY = @(gyro.y);
    self.gyroZ = @(gyro.z);

    return self;
}

@end
