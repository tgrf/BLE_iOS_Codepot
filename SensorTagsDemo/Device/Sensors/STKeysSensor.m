#import "STKeysSensor.h"

NSString *const STSensorSimpleKeysServiceUUID = @"FFE0";

// Simple Keys Characteristic UUID
NSString *const STSensorSimpleKeysCharacteristicUUID = @"FFE1";    // Key press state

@interface STKeysSensor ()
@property(nonatomic, readwrite) BOOL pressedLeftButton;
@property(nonatomic, readwrite) BOOL pressedRightButton;
@end

@implementation STKeysSensor {

}

+ (NSString *)dataCharacteristicUUID {
    return STSensorSimpleKeysCharacteristicUUID;
}

+ (NSString *)serviceUUID {
    return STSensorSimpleKeysServiceUUID;
}

- (BOOL)processReadFromCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (![super processReadFromCharacteristic:characteristic error:error]) {
        return NO;
    }

    NSData *data = characteristic.value;
    char scratchVal[data.length];
    [data getBytes:&scratchVal length:data.length];

    self.pressedLeftButton = (scratchVal[0] & 0x02) != 0;
    self.pressedRightButton = (scratchVal[0] & 0x01) != 0;
    [self.sensorDelegate sensorDidUpdateValue:self];
    return YES;
}

@end
