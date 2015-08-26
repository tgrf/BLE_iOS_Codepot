#import <Foundation/Foundation.h>
#import "STBaseSensor.h"

@interface STKeysSensor : STBaseSensor
@property(nonatomic, readonly) BOOL pressedLeftButton;
@property(nonatomic, readonly) BOOL pressedRightButton;
@end
