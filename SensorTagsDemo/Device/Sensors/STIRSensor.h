#import <Foundation/Foundation.h>
#import "STBaseSensor.h"

typedef enum {
    STSensorIRTemperatureDisabled      = 0x00,
    STSensorIRTemperatureEnabled       = 0x01,
} STSensorIRTemperatureConfig;

@interface STIRSensor : STBaseSensor
@property(nonatomic, readonly) float ambientTemperature;
@property(nonatomic) float objectTemperature;
@end
