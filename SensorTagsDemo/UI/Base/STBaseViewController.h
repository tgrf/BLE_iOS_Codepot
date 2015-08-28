
#import <Foundation/Foundation.h>

@class STSensorTag;


@interface STBaseViewController : UIViewController
@property (nonatomic, strong) STSensorTag *sensorTag;
- (void)setSensors:(NSArray *)sensors;
@end
