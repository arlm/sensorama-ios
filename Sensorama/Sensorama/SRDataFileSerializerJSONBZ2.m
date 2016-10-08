//
// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SRDataFileSerializerJSONBZ2.m
//  Sensorama


#import <BZipCompression/BZipCompression.h>

#import "SRDataFileSerializerJSONBZ2.h"
#import "SRDataFile.h"
#import "SRDebug.h"

@interface SRDataFileSerializerJSONBZ2 ()

@end

@implementation SRDataFileSerializerJSONBZ2

- (void) serializeWithFile:(SRDataFile *)dataFile {
    NSError *error = nil;

    NSDictionary *fileInMemory = [dataFile serializeToMemory];

    NSData *sampleDataJSON = [NSJSONSerialization dataWithJSONObject:fileInMemory
                                                             options:NSJSONWritingPrettyPrinted error:&error];

    NSLog(@"%@", [[NSString alloc] initWithData:sampleDataJSON encoding:NSUTF8StringEncoding]);
    NSData *compressedDataJSON = [BZipCompression compressedDataWithData:sampleDataJSON
                                                               blockSize:BZipDefaultBlockSize
                                                              workFactor:BZipDefaultWorkFactor
                                                                   error:&error];
    SRPROBE1(@([sampleDataJSON length]));
    SRPROBE1(@([compressedDataJSON length]));


    NSString *outFileName = [dataFile filePathName];
    [dataFile serializeWithData:compressedDataJSON path:outFileName];
}

@end
