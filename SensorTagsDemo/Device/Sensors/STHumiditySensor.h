#import <Foundation/Foundation.h>
#import "STBaseSensor.h"

typedef enum {
    STSensorHumidityDisabled           = 0x00,
    STSensorHumidityEnabled            = 0x01,
} STSensorHumidityConfig;

@interface STHumiditySensor : STBaseSensor
@property(nonatomic, readonly) float humidity;
@property(nonatomic, readonly) UInt16 temperature;
@end
