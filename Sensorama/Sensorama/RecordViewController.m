//
//  RecordViewController.m
//  
//
//  Created by Wojciech Koszek (home) on 3/1/16.
//
// Corner radius animation:
// http://stackoverflow.com/questions/5948167/uiview-animatewithduration-doesnt-animate-cornerradius-variation

#import <Lock/Lock.h>

@import JWTDecode;

#import "RecordViewController.h"
#import "SensoramaTabBarController.h"
#import "FilesTableViewController.h"
#import "SRUtils.h"
#import "SRUsageStats.h"
#import "SREngine.h"
#import "SRAuth.h"
#import "SimpleKeychain/A0SimpleKeychain.h"

@interface RecordViewController ()
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *gestureStartStop;

@property (weak,   nonatomic) IBOutlet UIView *recordView;

@property (nonatomic) BOOL isRecording;
@property (nonatomic) CGFloat savedCornerRadius;

@end

@implementation RecordViewController

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"%s", __func__);
    [super viewDidAppear:animated];
    [self.tabBarController setTitle:@"Record"];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Custom login screen for Sensorama.
    A0Theme *sensoramaTheme = [[A0Theme alloc] init];
    [sensoramaTheme registerColor:[SRUtils mainColor] forKey:A0ThemePrimaryButtonNormalColor];
    [sensoramaTheme registerColor:[SRUtils mainColor] forKey:A0ThemeSecondaryButtonBackgroundColor];
    [sensoramaTheme registerColor:[SRUtils mainColor] forKey:A0ThemeSecondaryButtonTextColor];
    [sensoramaTheme registerColor:[SRUtils mainColor] forKey:A0ThemeTextFieldTextColor];
    [sensoramaTheme registerColor:[UIColor lightGrayColor] forKey:A0ThemeTextFieldPlaceholderTextColor];
    [sensoramaTheme registerColor:[SRUtils mainColor] forKey:A0ThemeTextFieldIconColor];
    [sensoramaTheme registerColor:[SRUtils mainColor] forKey:A0ThemeTitleTextColor];
    [sensoramaTheme registerImageWithName:@"appLaunch" bundle:[NSBundle mainBundle] forKey:A0ThemeIconImageName];
    [[A0Theme sharedInstance] registerTheme:sensoramaTheme];

    
    A0SimpleKeychain *keychain = [SRAuth sharedInstance].keychain;
    A0UserProfile *profile = [NSKeyedUnarchiver unarchiveObjectWithData:[keychain dataForKey:@"profile"]];
    NSString *idToken = [keychain stringForKey:@"id_token"];
    
    if (idToken) {
        NSError *error = nil;
        A0JWT *jwt = [A0JWT decode:idToken error:&error];
        
        NSLog(@"jwt=%@", jwt);
#ifdef NOTYET
        if ([jwt expi]
            NSLog(@"Auth0 token has expired, refreshing.");
            NSString *refreshToken = [store stringForKey:@"refresh_token"];
            
            @weakify(self);
            A0APIClient *client = [[[Application sharedInstance] lock] apiClient];
            [client fetchNewIdTokenWithRefreshToken:refreshToken parameters:nil success:^(A0Token *token) {
                @strongify(self);
                [store setString:token.idToken forKey:@"id_token"];
                [self loginLayer:profile.userId];
            } failure:^(NSError *error) {
                [store clearAll];
            }];
            
        } else {
            //User is connected in Auth0 but layerclient isn't connected
            self.tokenID = idToken;
            [self loginLayer:profile.userId];
        }
    } else {
        [self signInToAuth0];
#endif
    }


    [self setIsRecording:false];
    [SRUsageStats eventAppRecord];
}

- (void)setIsRecording:(BOOL)isRecording
{
    SensoramaTabBarController *tabController = (SensoramaTabBarController *)self.parentViewController;
    FilesTableViewController *filesTVC = [tabController.viewControllers objectAtIndex:1];

    NSLog(@"fund: %s", __func__);
    NSLog(@"files: %@", filesTVC);


    [self makeStartStopTransition:isRecording];
    if (isRecording) {
        [tabController.srEngine recordingStart];
    } else {
        [tabController.srEngine recordingStop];
        filesTVC.filesList = [tabController.srEngine filesRecorded];
    }
    _isRecording = isRecording;
}

- (void)makeStartStopTransition:(BOOL)needSquare {
    NSLog(@"%s", __func__);
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        [self makeInitialCircle];
    });

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSNumber numberWithFloat:needSquare ? self.savedCornerRadius : 0];
    animation.toValue = [NSNumber numberWithFloat:needSquare ? 0.0f : self.savedCornerRadius];
    animation.duration = 0.1;
    [self.recordView.layer addAnimation:animation forKey:@"cornerRadius"];
    [self.recordView.layer setCornerRadius:needSquare ? 0 : self.savedCornerRadius];
}

- (void)makeInitialCircle {
    NSLog(@"%s", __func__);
    NSAssert(self.recordView.frame.size.width == self.recordView.frame.size.height,
             @"recordView must be rectangle");
    self.recordView.alpha = 1;
    self.recordView.layer.cornerRadius = self.recordView.frame.size.height / 2;
    self.recordView.backgroundColor = [SRUtils mainColor];

    self.savedCornerRadius = self.recordView.layer.cornerRadius;
}

- (IBAction)doStartStop:(UITapGestureRecognizer *)sender {
    NSLog(@"%s", __func__);

    [self setIsRecording:!self.isRecording];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
