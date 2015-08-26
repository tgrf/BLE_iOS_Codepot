#import <CocoaLumberjack/DDLogMacros.h>
#import "STPressureSensor.h"
#import "CBUUID+StringRepresentation.h"

static int ddLogLevel = DDLogLevelError;

NSString *const STSensorPressureServiceUUID = @"F000AA40-0451-4000-B000-000000000000";

// Pressure Characteristic UUID
NSString *const STSensorPressureDataCharacteristicUUID = @"F000AA41-0451-4000-B000-000000000000";        // TempLSB:TempMSB:PressureLSB:PressureMSB
NSString *const STSensorPressureConfigCharacteristicUUID = @"F000AA42-0451-4000-B000-000000000000";      // Write "01" to start Sensor and Measurements, "00" to put to sleep, "02" to read calibration values from sensor
NSString *const STSensorPressurePeriodCharacteristicUUID = @"F000AA44-0451-4000-B000-000000000000";      // Period =[Input*10]ms, (lower limit 100 ms), default 1000 ms
NSString *const STSensorPressureCalibrationCharacteristicUUID = @"F000AA43-0451-4000-B000-000000000000"; // When write "02" to Barometer conf. has been issued, the calibration values is found here.

@interface STPressureSensor ()
///Calibration values unsigned
@property UInt16 c1,c2,c3,c4;
///Calibration values signed
@property int16_t c5,c6,c7,c8;
@property(nonatomic, readwrite) float pressure;
@property(nonatomic) BOOL isCalibrated;
@property(nonatomic, readwrite) float temperature;
@property(nonatomic) BOOL isCalibrating;
@end

@implementation STPressureSensor {

}

+ (NSString *)dataCharacteristicUUID {
    return STSensorPressureDataCharacteristicUUID;
}

- (BOOL)processReadFromCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (![super processReadFromCharacteristic:characteristic error:error]) {
        if (!error &&
                [[[characteristic.UUID stringRepresentation] lowercaseString] isEqualToString:[STSensorPressureCalibrationCharacteristicUUID lowercaseString] ] &&
                [[[characteristic.service.UUID stringRepresentation] lowercaseString] isEqualToString:[[[self class] serviceUUID] lowercaseString] ]) {
            [self processCalibrationDataFromCharacteristic:characteristic];
            return YES;
        }
        return NO;
    }

    NSData *data = characteristic.value;
    if (data.length < 4 || !self.isCalibrated) {
        self.pressure = -1;
        self.temperature = -1;
    } else {
        char scratchVal[4];
        [data getBytes:&scratchVal length:4];
        int16_t temp;
        uint16_t pressure;

        temp = (int16_t) ((scratchVal[0] & 0xff) | ((scratchVal[1] << 8) & 0xff00));
        pressure = (uint16_t) ((scratchVal[2] & 0xff) | ((scratchVal[3] << 8) & 0xff00));

        long long tempTemp = (long long)temp;
        // Temperature calculation
        long temperature = ((((long)self.c1 * (long)tempTemp)/(long)1024) + (long)((self.c2) / (long)4 - (long)16384));
        DDLogInfo(@"%s temperature = %ld(%lx)", __PRETTY_FUNCTION__, temperature, temperature);
        // Barometer calculation

        long long S = self.c3 + ((self.c4 * tempTemp)/((long long)1 << 17)) + ((self.c5 * (tempTemp * tempTemp)) / ((long long)1 << 34));
        long long O = (self.c6 * ((long long)1 << 14)) + (((self.c7 * tempTemp)/((long long)1 << 3))) + ((self.c8 * (tempTemp * tempTemp)) / ((long long)1 << 19));
        long long Pa = (((S * (long long)pressure) + O) / ((long long)1 << 14));

        DDLogInfo(@"%s pressure = %ld(%lx)", __PRETTY_FUNCTION__, Pa / 100.f, Pa / 100);
        self.pressure = Pa;
        self.temperature = temperature;
    }

    [self.sensorDelegate sensorDidUpdateValue:self];
    return YES;
}

- (void)processCalibrationDataFromCharacteristic:(CBCharacteristic *)characteristic {
    NSData *data = characteristic.value;
    
    unsigned char scratchVal[16];
    [data getBytes:&scratchVal length:16];
    self.c1 = (UInt16) ((scratchVal[0] & 0xff) | ((scratchVal[1] << 8) & 0xff00));
    self.c2 = (UInt16) ((scratchVal[2] & 0xff) | ((scratchVal[3] << 8) & 0xff00));
    self.c3 = (UInt16) ((scratchVal[4] & 0xff) | ((scratchVal[5] << 8) & 0xff00));
    self.c4 = (UInt16) ((scratchVal[6] & 0xff) | ((scratchVal[7] << 8) & 0xff00));
    self.c5 = (int16_t) ((scratchVal[8] & 0xff) | ((scratchVal[9] << 8) & 0xff00));
    self.c6 = (int16_t) ((scratchVal[10] & 0xff) | ((scratchVal[11] << 8) & 0xff00));
    self.c7 = (int16_t) ((scratchVal[12] & 0xff) | ((scratchVal[13] << 8) & 0xff00));
    self.c8 = (int16_t) ((scratchVal[14] & 0xff) | ((scratchVal[15] << 8) & 0xff00));
    self.isCalibrated = YES;
    self.isCalibrating = NO;

    [self configureWithValue:STSensorPressureEnabled];
    [self.sensorDelegate sensorDidFinishCalibration:self];
}

- (void)calibrate {
    CBCharacteristic *configurationCharacteristic = [self characteristicForUUID:[[self class] configurationCharacteristicUUID]];
    if (configurationCharacteristic) {
        self.isCalibrating = YES;
        char value = (char)STSensorPressureReadCalibration;
        [self.peripheral writeValue:[NSData dataWithBytes:&value length:sizeof(char)] forCharacteristic:configurationCharacteristic type:CBCharacteristicWriteWithResponse];
    } else {
        [self.sensorDelegate sensorDidFailCommunicating:self withError:nil];
    }
}

- (BOOL)processWriteFromCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    BOOL result = [super processWriteFromCharacteristic:characteristic error:error];
    if (self.isCalibrating &&
            [[characteristic.UUID.stringRepresentation lowercaseString] isEqualToString:[[[self class] configurationCharacteristicUUID] lowercaseString]] &&
            [[[characteristic.service.UUID stringRepresentation] lowercaseString] isEqualToString:[[[self class] serviceUUID] lowercaseString] ]) {
        [self.peripheral readValueForCharacteristic:[self characteristicForUUID:STSensorPressureCalibrationCharacteristicUUID]];
    }
    return result;
}


+ (NSString *)serviceUUID {
    return STSensorPressureServiceUUID;
}

+ (NSString *)configurationCharacteristicUUID {
    return STSensorPressureConfigCharacteristicUUID;
}

+ (NSString *)periodCharacteristicUUID {
    return STSensorPressurePeriodCharacteristicUUID;
}

@end
