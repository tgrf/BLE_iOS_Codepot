
#import "STViewController.h"
#import "STView.h"
#import "STSensorManager.h"
#import "STBaseSensor.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

static int ddLogLevel = DDLogLevelDebug;

@interface STViewController () <STSensorManagerDelegate>
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

    self.sensorManager.delegate = self;
}

#pragma mark - JSTSensorManagerDelegate

- (void)manager:(STSensorManager *)manager didChangeStateTo:(CBCentralManagerState)state {
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
}

- (void)manager:(STSensorManager *)manager didConnectSensor:(STSensorTag *)sensor {
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, sensor);
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
}

- (void)sensorDidFailCommunicating:(STBaseSensor *)sensor withError:(NSError *)error {
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, sensor);
}

- (void)sensorDidFinishCalibration:(STBaseSensor *)sensor {
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, sensor);
}

@end
