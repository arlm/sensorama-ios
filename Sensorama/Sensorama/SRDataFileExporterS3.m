//
//  SRSync.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/11/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>

#import "SRDataFileExporterS3.h"
#import "SRAuth.h"
#import "SRUtils.h"
#import "SRDebug.h"
#import "SRDataFile.h"
#import "SRDataStore.h"

#import "SensoramaVars.h"

@interface SRDataFileExporterS3 ()
@end

@implementation SRDataFileExporterS3

- (void)exportWithFile:(SRDataFile *)dataFile;
{
    NSString *fileBaseName = [dataFile fileBasePathName];
    NSURL *fileURL = [NSURL fileURLWithPath:[dataFile filePathName]];
    SRPROBE1(fileURL);

    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = @"sensorama-data";
    uploadRequest.key = [NSString stringWithFormat:@"%@/%@", [SRAuth emailHashed], fileBaseName];
    uploadRequest.body = fileURL;

    NSInteger fileId = [dataFile fileId];

    [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
        NSLog(@"download block: %@", [task error]);
        if ([task error] == nil) {
            dispatch_async([SRDataFile saveQueue], ^{
                RLMRealm *realm = [RLMRealm defaultRealm];
                SRDataFile *file = [SRDataFile objectForPrimaryKey:@(fileId)];
                [realm beginWriteTransaction];
                file.isExported = true;
                [realm addOrUpdateObject:file];
                [realm commitWriteTransaction];
            });
            NSLog(@"task finished");
        } else {
            NSLog(@"error = %@", [[task error] localizedDescription]);
        }
        return nil;
    }];
}

@end
