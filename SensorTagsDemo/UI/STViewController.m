
#import "STViewController.h"
#import "STView.h"
#import "STSensorManager.h"
#import "STBaseSensor.h"
#import "STAppDelegate.h"
#import "STAccelerometerSensor.h"
#import "STSensorTag.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

static int ddLogLevel = DDLogLevelDebug;

@interface STViewController () <STSensorManagerDelegate, STBaseSensorDelegate>
@property (nonatomic, strong, readonly) STSensorManager *sensorManager;
@end

@implementation STViewController

- (STView *)mainView {
    return (self.isViewLoaded ? (STView *)self.view : nil);
}

- (void)loadView {
    self.view = [[STView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _sensorManager = [STSensorManager sharedInstance];
    self.sensorManager.delegate = self;
    [self.sensorManager connectNearestSensor];
}

#pragma mark - JSTSensorManagerDelegate

- (void)manager:(STSensorManager *)manager didChangeStateTo:(CBCentralManagerState)state {
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
}

- (void)manager:(STSensorManager *)manager didConnectSensor:(STSensorTag *)sensor {
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, sensor);

    sensor.accelerometerSensor.sensorDelegate = self;
    [sensor.accelerometerSensor configureWithValue:STSensorAccelerometer2GRange];
    [sensor.accelerometerSensor setPeriodValue:10];
    [sensor.accelerometerSensor setNotificationsEnabled:YES];
}

- (void)manager:(STSensorManager *)manager didDisconnectSensor:(STSensorTag *)sensor error:(NSError *)error {
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, sensor);
}

- (void)manager:(STSensorManager *)manager didFailToConnectToSensorWithError:(NSError *)error {
    DDLogError(@"%s %@", __PRETTY_FUNCTION__, error);
}

- (void)manager:(STSensorManager *)manager didDiscoverSensor:(STSensorTag *)sensor {
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, sensor);
}

- (void)sensorDidUpdateValue:(STBaseSensor *)sensor {
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, sensor);

    STAccelerometerSensor *accelerometerSensor = (STAccelerometerSensor *)sensor;
    NSLog(@"self.mainView.x = %f, self.mainView.y = %f, self.mainView.z = %f", accelerometerSensor.acceleration.x, accelerometerSensor.acceleration.y, accelerometerSensor.acceleration.z);

    dispatch_async(dispatch_get_main_queue(), ^{
        self.mainView.x.text = [NSString stringWithFormat:@"%f", accelerometerSensor.acceleration.x];
        self.mainView.y.text = [NSString stringWithFormat:@"%f", accelerometerSensor.acceleration.y];
        self.mainView.z.text = [NSString stringWithFormat:@"%f", accelerometerSensor.acceleration.z];

        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    });
}

- (void)sensorDidFailCommunicating:(STBaseSensor *)sensor withError:(NSError *)error {
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, sensor);
}

- (void)sensorDidFinishCalibration:(STBaseSensor *)sensor {
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, sensor);
}

@end
