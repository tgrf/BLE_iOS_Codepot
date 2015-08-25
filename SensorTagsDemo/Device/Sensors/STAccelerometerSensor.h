#import <Foundation/Foundation.h>
#import "STBaseSensor.h"
#import "STSensorTag.h"


typedef enum {
    STSensorAccelerometerDisabled      = 0x00,
    STSensorAccelerometer2GRange       = 0x01,
    STSensorAccelerometer4GRange       = 0x02,
    STSensorAccelerometer8GRange       = 0x03,
} STSensorAccelerometerConfig;

@interface STAccelerometerSensor : STBaseSensor
@property(nonatomic, readonly) STVector3D acceleration;
@end
