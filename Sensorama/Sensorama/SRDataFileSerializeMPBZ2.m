//
//  SRDataFileSerializeMPBZ2.m
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 19/05/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "BZipCompression/BZipCompression.h"

#import "SRDataFileSerializeMPBZ2.h"
#import "MPMessagePack/MPMessagePack.h"

#import "SRDataFile.h"
#import "SRDebug.h"

@implementation SRDataFileSerializeMPBZ2

- (void) serializeWithFile:(SRDataFile *)dataFile {
    NSError *error = nil;

    NSDictionary *fileInMemory = [dataFile serializeToMemory];


    NSData *sampleDataMP = [fileInMemory mp_messagePack];

    NSData *compressedDataMP = [BZipCompression compressedDataWithData:sampleDataMP
                                                             blockSize:BZipDefaultBlockSize
                                                            workFactor:BZipDefaultWorkFactor
                                                                 error:&error];

    SRPROBE1(@([sampleDataMP length]));
    SRPROBE1(@([compressedDataMP length]));

    NSString *outFileName = [dataFile filePathName];
    [dataFile serializeWithData:compressedDataMP path:outFileName];
}

@end
