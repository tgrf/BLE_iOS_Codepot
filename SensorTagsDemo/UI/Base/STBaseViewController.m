
#import "STBaseViewController.h"
#import "STSensorTag.h"


@implementation STBaseViewController {

}
- (void)setSensors:(NSArray *)sensors {
    self.sensorTag = [sensors firstObject];
}

@end
