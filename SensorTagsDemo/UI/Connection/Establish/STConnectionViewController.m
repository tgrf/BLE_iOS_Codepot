
#import "STConnectionViewController.h"
#import "STSensorTag.h"
#import "STSensorManager.h"
#import "STAppDelegate.h"
#import "STConnectionView.h"
#import "STBaseViewController.h"


@interface STConnectionViewController ()
@property(nonatomic, copy) NSString *iconName;
@property(nonatomic, strong) STSensorManager *sensorManager;
@property(nonatomic, strong) STBaseViewController *finalViewController;
@property(nonatomic, strong) NSArray *sensors;
@end

@implementation STConnectionViewController {

}

- (instancetype)initWithSensors:(NSArray *)sensors iconName:(NSString *)iconName finalViewController:(STBaseViewController *)finalViewController {
    self = [self init];
    if (self) {
        self.iconName = iconName;
        self.sensors = sensors;
        self.finalViewController = finalViewController;
        
        self.sensorManager = [STSensorManager sharedInstance];
        self.sensorManager.delegate = self;
    }
    return self;
}

- (void)loadView {
    [super loadView];

    STConnectionView *view = [[STConnectionView alloc] init];
    view.iconView.text = self.iconName;
    [view.retryButton addTarget:self action:@selector(retry) forControlEvents:UIControlEventTouchUpInside];
    self.view = view;
}

- (void)retry {
    [self.sensorManager connectSensorWithUUID:((STSensorTag *)[self.sensors firstObject]).peripheral.identifier];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.sensorManager.delegate = self;
    if (self.sensorManager.state == CBPeripheralManagerStatePoweredOn) {
        [self.sensorManager connectSensorWithUUID:((STSensorTag *)[self.sensors firstObject]).peripheral.identifier];
    }
}

#pragma mark - Sensor manager

- (void)manager:(STSensorManager *)manager didConnectSensor:(STSensorTag *)sensor {
    BOOL allSensorsConnected = YES;
    for (STSensorTag *sensorTag in self.sensors) {
        allSensorsConnected &= (sensorTag.peripheral.state == CBPeripheralStateConnected);
    }
    if (allSensorsConnected) {
        NSMutableArray *array = [self.navigationController.viewControllers mutableCopy];
        while (array.count > 1) {
            [array removeLastObject];
        }
        [array addObject:self.finalViewController];
        self.finalViewController.sensorTag = sensor;
        [self.finalViewController setSensors:self.sensors];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController setViewControllers:array animated:YES];
        });
    } else {
        STSensorTag *next = nil;
        for (STSensorTag *sensorTag in self.sensors) {
            if (sensorTag.peripheral.state != CBPeripheralStateConnected) {
                next = sensorTag;
                break;
            }
        }
        [self.sensorManager connectSensorWithUUID:next.peripheral.identifier];
    }
}

- (void)manager:(STSensorManager *)manager didDisconnectSensor:(STSensorTag *)sensor error:(NSError *)error {

}

- (void)manager:(STSensorManager *)manager didFailToConnectToSensorWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    });
}

- (void)manager:(STSensorManager *)manager didDiscoverSensor:(STSensorTag *)sensor {

}

- (void)manager:(STSensorManager *)manager didChangeStateTo:(CBCentralManagerState)state {
    if (self.sensorManager.state == CBPeripheralManagerStatePoweredOn) {
        [self.sensorManager connectSensorWithUUID:((STSensorTag *)[self.sensors firstObject]).peripheral.identifier];
    }
}

@end
