
#import <Foundation/Foundation.h>
#import "STSensorManager.h"

@class STSensorTag;
@class STSensorManager;
@class STBaseViewController;


@interface STConnectionViewController : UIViewController <STSensorManagerDelegate>

- (instancetype)initWithSensors:(NSArray *)sensors iconName:(NSString *)iconName finalViewController:(STBaseViewController *)finalViewController;

@end
