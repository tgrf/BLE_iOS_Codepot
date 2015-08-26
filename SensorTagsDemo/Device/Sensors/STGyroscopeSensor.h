#import <Foundation/Foundation.h>
#import "STBaseSensor.h"
#import "STSensorTag.h"

typedef enum {
    STSensorGyroscopeDisabled          = 0x00,
    STSensorGyroscopeXOnly             = 0x01,
    STSensorGyroscopeYOnly             = 0x02,
    STSensorGyroscopeXAndY             = 0x03,
    STSensorGyroscopeZOnly             = 0x04,
    STSensorGyroscopeXAndZ             = 0x05,
    STSensorGyroscopeYAndZ             = 0x06,
    STSensorGyroscopeAllAxis           = 0x07,
} STSensorGyroscopeConfig;

@interface STGyroscopeSensor : STBaseSensor

- (void)calibrate;
- (STVector3D)value;
@end
