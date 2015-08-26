#import "STHumiditySensor.h"

static NSString *const STSensorHumidityServiceUUID = @"F000AA20-0451-4000-B000-000000000000";

static NSString *const STSensorHumidityDataCharacteristicUUID = @"F000AA21-0451-4000-B000-000000000000";         // TempLSB:TempMSB:HumidityLSB:HumidityMSB
static NSString *const STSensorHumidityConfigCharacteristicUUID = @"F000AA22-0451-4000-B000-000000000000";       // Write "01" to start measurements, "00" to stop
static NSString *const STSensorHumidityPeriodCharacteristicUUID = @"F000AA23-0451-4000-B000-000000000000";       // Period =[Input*10]ms, (lower limit 100 ms), default 1000 ms


@interface STHumiditySensor ()
@property(nonatomic, readwrite) float humidity;
@property(nonatomic, readwrite) UInt16 temperature;
@end

@implementation STHumiditySensor {

}

+ (NSString *)dataCharacteristicUUID {
    return STSensorHumidityDataCharacteristicUUID;
}

+ (NSString *)serviceUUID {
    return STSensorHumidityServiceUUID;
}

+ (NSString *)configurationCharacteristicUUID {
    return STSensorHumidityConfigCharacteristicUUID;
}

+ (NSString *)periodCharacteristicUUID {
    return STSensorHumidityPeriodCharacteristicUUID;
}

- (BOOL)processReadFromCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (![super processReadFromCharacteristic:characteristic error:error]) {
        return NO;
    }

    NSData *data = characteristic.value;
    char scratchVal[data.length];
    [data getBytes:&scratchVal length:data.length];
    UInt16 hum;
    float rHVal;
    hum = (UInt16) ((scratchVal[2] & 0xff) | ((scratchVal[3] << 8) & 0xff00));
    rHVal = -6.0f + 125.0f * hum / 65535.f;
    UInt16 temp;
    temp = (UInt16) ((scratchVal[0] & 0xff) | ((scratchVal[1] << 8) & 0xff00));
    
    self.temperature = temp;
    self.humidity = rHVal;
    
    [self.sensorDelegate sensorDidUpdateValue:self];
    return YES;
}

@end
