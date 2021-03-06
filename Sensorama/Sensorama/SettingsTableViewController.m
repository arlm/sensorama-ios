// Copyright © 2016 Wojciech Adam Koszek <wojciech@koszek.com>
// All rights reserved.
//
//  SettingsTableViewController.m
//  Sensorama


#import "SettingsTableViewController.h"
#import "SRUsageStats.h"
#import "SRUtils.h"
#import "SRDebug.h"
#import "SRAuth.h"
#import "SRCfg.h"
#import "SensoramaTabBarController.h"
#import "RecordViewController.h"
#import "InAppSettingsKit/IASKSettingsReader.h"

#import "SRCfg.h"

@interface SettingsTableViewController () <IASKViewController, UITextViewDelegate>
@property (strong, nonatomic) IBOutletCollection(UISwitch) NSArray *settingsState;
@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;
@property (weak, nonatomic) IBOutlet UILabel *frequencySamplingLabel;
@end

@implementation SettingsTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    UISwitch.appearance.onTintColor = [SRUtils mainColor];

    SRPROBE0();

    self.neverShowPrivacySettings = YES;
    self.showCreditsFooter = NO;
    self.delegate = self;

    [SRUsageStats eventAppSettings];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(settingsChanged:)
                                                 name:kIASKAppSettingChanged
                                               object:nil];
}

- (void) viewDidAppear:(BOOL)animate {
    [super viewDidAppear:animate];

    SRPROBE0();

    [self.tabBarController setTitle:@"Settings"];

    A0UserProfile *profile = [SRAuth currentProfile];

    NSLog(@"email=%@", profile.email);
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

    SRPROBE1(@"***********************************************");
}

// MARK: Logout button handling

- (CGFloat)settingsViewController:(id<IASKViewController>)settingsViewController
                        tableView:(UITableView *)tableView
        heightForHeaderForSection:(NSInteger)section {

    NSString* key = [self.settingsReader keyForSection:section];
    if ([key isEqualToString:@"ButtonLogout"]) {
        return [UIImage imageNamed:@"iconProfile"].size.height + 25;
    }
    return 55;
}

- (UIView *)settingsViewController:(id<IASKViewController>)settingsViewController
                         tableView:(UITableView *)tableView
           viewForHeaderForSection:(NSInteger)section {
    NSString* key = [settingsViewController.settingsReader keyForSection:section];
    if ([key isEqualToString:@"ButtonLogout"]) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconProfile"]];
        imageView.contentMode = UIViewContentModeCenter;
        return imageView;
    }
    return nil;
}

- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForSpecifier:(IASKSpecifier*)specifier {
    SRPROBE0();
    if ([specifier.key isEqualToString:@"ButtonLogout"]) {
        SRPROBE0();
        SensoramaTabBarController *stvc = (SensoramaTabBarController *)self.navigationController.parentViewController;
        RecordViewController *rvc = stvc.viewControllers[0].childViewControllers[0];
        [rvc logoutAuth0];
        [stvc setSelectedIndex:0];
    }
}

// Version on the bottom of the screen
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == [self.tableView numberOfSections] - 1) {
        return ([SRUtils humanSensoramaVersionString]);
    } else {
        return [super tableView:tableView titleForFooterInSection:section];
    }
}

- (void)settingsChanged:(NSNotification *)notification {

    NSArray *allChangedSettings = notification.userInfo.allKeys;
    NSLog(@"changed = %@", allChangedSettings);

    for (NSString *oneChangedSetting in allChangedSettings) {
        if ([oneChangedSetting isEqualToString:@"samplingFrequency"]) {
            NSString *samplingFrequency = [[NSUserDefaults standardUserDefaults] objectForKey:oneChangedSetting];
            if (samplingFrequency) {
                SRCfg *cfg = [SRCfg defaultConfiguration];
                cfg.sampleInterval = [samplingFrequency integerValue];
            }
        }
    }
}

@end
