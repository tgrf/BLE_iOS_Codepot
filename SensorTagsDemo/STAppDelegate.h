
#import <UIKit/UIKit.h>
#import "STSensorManager.h"

@interface STAppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;

+ (STAppDelegate *)sharedInstance;
@end

@interface STSensorManager (SharedInstance)
+ (STSensorManager *)sharedInstance;
@end
