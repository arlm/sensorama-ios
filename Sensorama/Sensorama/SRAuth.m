//
//  SRAuth.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/16/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "SRAuth.h"
#import <Lock/Lock.h>

#import "SensoramaVars.h"

@implementation SRAuth

+ (void)enableDebugging {
    [[AWSLogger defaultLogger] setLogLevel:AWSLogLevelVerbose];
}

- (NSString *)cognitoPoolID {
    return [NSString stringWithUTF8String:SENSORAMA_COGNITO_POOL_ID];
}

+ (SRAuth *)sharedInstance {
    static SRAuth *sharedApplication = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedApplication = [[self alloc] init];
    });
    return sharedApplication;
}

- (id)init {
    self = [super init];
    if (self) {
        _lock = [A0Lock newLock];
        _keychain = [A0SimpleKeychain keychainWithService:@"Sensorama"];
        _credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                   identityPoolId:[self cognitoPoolID]];
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1
                                                                             credentialsProvider:_credentialsProvider];
        AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    }
    return self;
}

+ (void) startWithLaunchOptions:(NSDictionary *)launchOptions {
    A0Lock *lock = [[SRAuth sharedInstance] lock];
    [lock applicationLaunchedWithOptions:launchOptions];
}

+ (A0UserProfile *) currentProfile {
    A0SimpleKeychain *keychain = [SRAuth sharedInstance].keychain;
    NSData *decodedData = [keychain dataForKey:@"profile"];
    A0UserProfile *profile = [NSKeyedUnarchiver unarchiveObjectWithData:decodedData];
    return profile;
}

@end

