//
//  SRUtils.h
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/1/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

@import Foundation;
@import UIKit;
@import CoreMotion;

@interface SRUtils : NSObject

+ (UIColor *)mainColor;
+ (NSDictionary *)deviceInfo;
+ (NSString*)computeSHA256DigestForString:(NSString*)input;
+ (BOOL)isSimulator;
+ (NSString *)activityString:(CMMotionActivity *)activity;
+ (NSInteger)activityInteger:(CMMotionActivity *)activity;
+ (NSString *)bundleVersionString;
+ (NSString *)bundleShortVersionString;
+ (NSString *)humanSensoramaVersionString;
+ (BOOL) hasWifi;

+ (void) notifyOK:(NSString *)string;
+ (void) notifyWarn:(NSString *)string;
+ (void) notifyError:(NSString *)string;
+ (void) notifyDebugWithUserInfo:(NSDictionary *)userInfo;

@end
