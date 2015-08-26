#import <Foundation/Foundation.h>
#import "STBaseSensor.h"

typedef enum {
    STSensorPressureDisabled          = 0x00,
    STSensorPressureEnabled           = 0x01,
    STSensorPressureReadCalibration   = 0x02,
} STSensorBarometerConfig;

@interface STPressureSensor : STBaseSensor
@property(nonatomic, readonly) float pressure;
@property(nonatomic, readonly) float temperature;

- (void)calibrate;
@end
