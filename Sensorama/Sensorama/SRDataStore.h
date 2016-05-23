//
//  SRDataStore.h
//  Sensorama
//
//  Created by Wojciech Adam Koszek (h) on 23/04/2016.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

@import Foundation;

#import "SRDataPoint.h"
#import "SRDataFile.h"

@protocol SRDataFileSerializeDelegate <NSObject>
@required
- (void)serializeWithFile:(SRDataFile *)dataFile;
@end

@protocol SRDataFileExportDelegate <NSObject>
@required
- (void)exportWithFile:(SRDataFile *)dataFile;
@end


@interface SRDataStore : NSObject

@property (nonatomic) id<SRDataFileSerializeDelegate> delegate;

+ (SRDataStore *)sharedInstance;
- (void) addSerializer:(id<SRDataFileSerializeDelegate>)serializer;
- (void) addExporter:(id<SRDataFileExportDelegate>)exporter;

+ (void) handleMigrations;

- (void) insertDataFile:(SRDataFile *)dataFile;
- (void) insertDataPoints:(NSArray<SRDataPoint *> *) points;

- (void) serializeFile:(SRDataFile *)fileInMemory;
- (void) exportFiles:(NSArray <SRDataFile *> *)filesToSync;

@end