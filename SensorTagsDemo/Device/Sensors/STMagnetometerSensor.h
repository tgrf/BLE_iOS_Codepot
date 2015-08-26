#import <Foundation/Foundation.h>
#import "STBaseSensor.h"
#import "STSensorTag.h"

typedef enum {
    STSensorMagnetometerDisabled       = 0x00,
    STSensorMagnetometerEnabled        = 0x01,
} STSensorMagnetometerConfig;

@interface STMagnetometerSensor : STBaseSensor
- (STVector3D)value;
-(void)calibrate;
@end
