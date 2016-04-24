//
//  SRDataPoint.h
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 23/04/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

@import QuartzCore;
@import CoreMotion;
@import Foundation;

#import "Realm/Realm.h"

@interface SRDataPoint : RLMObject

@property NSNumber<RLMInt> *accX;
@property NSNumber<RLMInt> *accY;
@property NSNumber<RLMInt> *accZ;

@property NSNumber<RLMInt> *magX;
@property NSNumber<RLMInt> *magY;
@property NSNumber<RLMInt> *magZ;

@property NSNumber<RLMInt> *gyroX;
@property NSNumber<RLMInt> *gyroY;
@property NSNumber<RLMInt> *gyroZ;

@property NSInteger fileId;
@property NSInteger pointId;
@property NSNumber<RLMDouble> *curTime;

- (instancetype) initWithTime:(NSTimeInterval)timeVal;
- (instancetype) init;
- (NSDictionary *)toDict;
+ (CMMotionManager *)motionManager;

@end
RLM_ARRAY_TYPE(SRDataPoint)
