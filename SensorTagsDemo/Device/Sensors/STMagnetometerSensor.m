#import "STMagnetometerSensor.h"

#define MAG3110_RANGE 2000.0

static NSString *const STSensorMagnetometerServiceUUID = @"F000AA30-0451-4000-B000-000000000000";

// Magnetometer Characteristic UUID
static NSString *const STSensorMagnetometerDataCharacteristicUUID = @"F000AA31-0451-4000-B000-000000000000";     // XLSB:XMSB:YLSB:YMSB:ZLSB:ZMSB Coordinates
static NSString *const STSensorMagnetometerConfigCharacteristicUUID = @"F000AA32-0451-4000-B000-000000000000";   // Write "01" to start Sensor and Measurements, "00" to put to sleep
static NSString *const STSensorMagnetometerPeriodCharacteristicUUID = @"F000AA33-0451-4000-B000-000000000000";   // Period =[Input*10]ms, (lower limit 100 ms), default 2000 ms

@interface STMagnetometerSensor ()
@property(nonatomic) double lastX;
@property(nonatomic) double lastY;
@property(nonatomic) double lastZ;
@property(nonatomic) double calX;
@property(nonatomic) double calY;
@property(nonatomic) double calZ;
@end

@implementation STMagnetometerSensor {

}

-(void)calibrate {
    self.calX = self.lastX;
    self.calY = self.lastY;
    self.calZ = self.lastZ;
    [self.sensorDelegate sensorDidFinishCalibration:self];
}

- (BOOL)processReadFromCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (![super processReadFromCharacteristic:characteristic error:error]) {
        return NO;
    }

    NSData *data = characteristic.value;
    // Orientation of sensor on board means we need to swap X and Y (multiplying with -1)
    char scratchVal[6];
    [data getBytes:&scratchVal length:6];
    int16_t rawX = (int16_t) ((scratchVal[0] & 0xff) | ((scratchVal[1] << 8) & 0xff00));
    int16_t rawY = (int16_t) ((scratchVal[2] & 0xff) | ((scratchVal[3] << 8) & 0xff00));
    int16_t rawZ = (int16_t) ((scratchVal[4] & 0xff) | ((scratchVal[5] << 8) & 0xff00));
    self.lastX = (((float)rawX * 1.0) / ( 65536 / MAG3110_RANGE )) * -1;
    self.lastY = (((float)rawY * 1.0) / ( 65536 / MAG3110_RANGE )) * -1;
    self.lastZ =  ((float)rawZ * 1.0) / ( 65536 / MAG3110_RANGE );

    [self.sensorDelegate sensorDidUpdateValue:self];
    return YES;
}

- (STVector3D)value {
    STVector3D vector3D = {(float) (self.lastX - self.calX), (float) (self.lastY - self.calY), (float) (self.lastZ - self.calZ)};
    return vector3D;
}


+ (NSString *)serviceUUID {
    return STSensorMagnetometerServiceUUID;
}

+ (NSString *)configurationCharacteristicUUID {
    return STSensorMagnetometerConfigCharacteristicUUID;
}

+ (NSString *)periodCharacteristicUUID {
    return STSensorMagnetometerPeriodCharacteristicUUID;
}

+ (NSString *)dataCharacteristicUUID {
    return STSensorMagnetometerDataCharacteristicUUID;
}

@end
