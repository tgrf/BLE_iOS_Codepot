
#import <Foundation/Foundation.h>
#import "STSensorManager.h"

@class STSensorManager;
@class STBaseViewController;

typedef enum {
    STDeviceListTypeSingleSelection,
    STDeviceListTypeDoubleSelection
} STDeviceListType;

@interface STDeviceListViewController : UIViewController <STSensorManagerDelegate, UITableViewDelegate, UITableViewDataSource>
- (instancetype)initWithFinalViewController:(STBaseViewController *)viewController type:(STDeviceListType)type;
@end
