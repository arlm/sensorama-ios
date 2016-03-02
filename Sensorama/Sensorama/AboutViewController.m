//
//  AboutViewController.m
//  Sensorama
//
//  Created by Wojciech Koszek (home) on 3/2/16.
//  Copyright © 2016 Wojciech Adam Koszek. All rights reserved.
//

#import "Crashlytics/Crashlytics.h"

#import "AboutViewController.h"

#import "SRUsageStats.h"


@interface AboutViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *forceCrashButton;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.forceCrashButton;
    [SRUsageStats eventAppSettingsAbout];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)forceCrash:(id)sender {
    NSLog(@"force crash!");
    [[Crashlytics sharedInstance] crash];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
