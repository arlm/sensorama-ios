//
//  SRCfg.h
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/2/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SRCfg : NSObject

@property (nonatomic) NSInteger sampleInterval;
#define SRCFG_DEFAULT_SAMPLE_INTERVAL 250


#define SENSORAMA_MAIN_COLOR 0xc51162
#define SENSORAMA_DATE_FORMAT @"YYYYMMdd-HHmmss"

+ (SRCfg *) defaultConfiguration;
- (NSString *)stringFromDate:(NSDate *)date;

@end
