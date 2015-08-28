
#import "STViewController.h"
#import "STView.h"
#import "STSensorManager.h"
#import "STBaseSensor.h"
#import "STBaseViewController.h"
#import "STDeviceListViewController.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

static int ddLogLevel = DDLogLevelDebug;

@interface STViewController ()
@property (nonatomic, strong, readonly) STSensorManager *sensorManager;
@end

@implementation STViewController

- (STView *)mainView {
    return (self.isViewLoaded ? (STView *)self.view : nil);
}

- (void)loadView {
    self.view = [[STView alloc] initWithFrame:CGRectZero];
}

@end
