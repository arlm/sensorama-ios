// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SRAuth.h
//  Sensorama


#import <Foundation/Foundation.h>
#import "SimpleKeychain/A0SimpleKeychain.h"
#import <AWSCore/AWSCore.h>
#import <Lock/Lock.h>

@class A0Lock;

@interface SRAuth : NSObject
@property (readonly, nonatomic) A0Lock *lock;
@property A0SimpleKeychain *keychain;
@property (nonatomic) AWSCognitoCredentialsProvider *credentialsProvider;

+ (SRAuth *)sharedInstance;
+ (void) setLogLevel:(AWSLogLevel)logLevel;
+ (void) startWithLaunchOptions:(NSDictionary *)launchOptions;
+ (A0UserProfile *) currentProfile;
+ (NSString *)emailHashed;
+ (void)doAmazonLogin:(NSString *)token;

@end
