#import "STSensorTag.h"
#import "STSensorConstants.h"
#import "STSensorManager.h"
#import "CBUUID+StringRepresentation.h"
#import "STBaseSensor.h"
#import "STAccelerometerSensor.h"
#import "STGyroscopeSensor.h"
#import "STHumiditySensor.h"
#import "STIRSensor.h"
#import "STKeysSensor.h"
#import "STMagnetometerSensor.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
static int ddLogLevel = DDLogLevelWarning;

NSString *const STSensorTagDidFinishDiscoveryNotification = @"STSensorTagDidFinishDiscoveryNotification";
NSString *const STSensorTagConnectionFailureNotification = @"STSensorTagConnectionFailureNotification";
NSString *const STSensorTagConnectionFailureNotificationErrorKey = @"STSensorTagConnectionFailureNotificationErrorKey";

@interface STSensorTag () <CBPeripheralDelegate>
@property(nonatomic, readwrite) CBPeripheral *peripheral;
@property(nonatomic) int numberOfDiscoveredServices;
@property(nonatomic) UInt16 *calibrationDataUnsigned;
@property(nonatomic) int16_t *calibrationDataSigned;
@property(nonatomic, readwrite) STIRSensor *irSensor;
@property(nonatomic, readwrite) STAccelerometerSensor *accelerometerSensor;
@property(nonatomic, readwrite) STGyroscopeSensor *gyroscopeSensor;
@property(nonatomic, readwrite) STHumiditySensor *humiditySensor;
@property(nonatomic, readwrite) STKeysSensor *keysSensor;
@property(nonatomic, readwrite) STMagnetometerSensor *magnetometerSensor;
@end

@implementation STSensorTag {
}

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    self = [self init];
    if (self) {
        self.peripheral = peripheral;
        self.peripheral.delegate = self;
        
        self.calibrationDataUnsigned = (UInt16 *)malloc(sizeof(UInt16) * 8);
        self.calibrationDataSigned = (int16_t *)malloc(sizeof(int16_t) * 8);
        self.numberOfDiscoveredServices = 0;

        self.accelerometerSensor = [[STAccelerometerSensor alloc] initWithPeripheral:peripheral];
        self.gyroscopeSensor = [[STGyroscopeSensor alloc] initWithPeripheral:peripheral];
        self.humiditySensor = [[STHumiditySensor alloc] initWithPeripheral:peripheral];
        self.irSensor = [[STIRSensor alloc] initWithPeripheral:peripheral];
        self.keysSensor = [[STKeysSensor alloc] initWithPeripheral:peripheral];
        self.magnetometerSensor = [[STMagnetometerSensor alloc] initWithPeripheral:peripheral];
    }
    return self;
}

- (void)dealloc {
    if (self.calibrationDataUnsigned) {
        free(self.calibrationDataUnsigned);
    }

    if (self.calibrationDataSigned) {
        free(self.calibrationDataSigned);
    }
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, peripheral.services);

    if (error) {
        DDLogError(@"%s %@", __PRETTY_FUNCTION__, error);
        [[NSNotificationCenter defaultCenter] postNotificationName:STSensorTagConnectionFailureNotification object:self userInfo:@{STSensorTagConnectionFailureNotificationErrorKey : error}];
    } else {
        for (CBService *service in [peripheral services]) {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    DDLogInfo(@"%s peripheral:%@, service:%@, characteristics: %@", __PRETTY_FUNCTION__, peripheral.identifier, service, service.characteristics);

    if (error) {
        DDLogError(@"%s %@", __PRETTY_FUNCTION__, error);
        [[NSNotificationCenter defaultCenter] postNotificationName:STSensorTagConnectionFailureNotification object:self userInfo:@{STSensorTagConnectionFailureNotificationErrorKey : error}];
    } else {

        if ([service.UUID.stringRepresentation isEqualToString:@"180a"]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID.stringRepresentation isEqualToString:@"2a23"]) {
                    [peripheral readValueForCharacteristic:characteristic];
                }
            }
        }
        ++self.numberOfDiscoveredServices;
        [self tryToFinishConnection];
    }
}

- (void)tryToFinishConnection {
    if (self.numberOfDiscoveredServices == [STSensorTag availableServicesUUIDArray].count && self.macAddress) {
        [[NSNotificationCenter defaultCenter] postNotificationName:STSensorTagDidFinishDiscoveryNotification object:self];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    DDLogInfo(@"%s %@ %@", __PRETTY_FUNCTION__, peripheral.identifier, characteristic);
    NSMutableString* tmpString = [NSMutableString string];
    for (size_t i = characteristic.value.length - 1; i > 0; i -= 1)
    {
        Byte byteValue;
        [characteristic.value getBytes:&byteValue range:NSMakeRange(i, sizeof(Byte))];
        [tmpString appendFormat:@"%02x", byteValue];
    }
    self.macAddress = tmpString;

    [self tryToFinishConnection];
    [[self sensorForCharacteristic:characteristic] processReadFromCharacteristic:characteristic error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, peripheral.identifier);
    [[self sensorForCharacteristic:characteristic] processWriteFromCharacteristic:characteristic error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, peripheral.identifier);
    [[self sensorForCharacteristic:characteristic] processNotificationsUpdateFromCharacteristic:characteristic error:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices {
    DDLogInfo(@"%s %@ %@", __PRETTY_FUNCTION__, peripheral, invalidatedServices);
    [peripheral discoverServices:invalidatedServices];
}

#pragma mark -

- (void)discoverServices {
    self.numberOfDiscoveredServices = 0;
    [self.peripheral discoverServices:[STSensorTag availableServicesUUIDArray]];
}

#pragma mark -
+ (NSArray *)availableServicesUUIDArray {
    return @[
            [CBUUID UUIDWithString:[STAccelerometerSensor serviceUUID]],
            [CBUUID UUIDWithString:[STGyroscopeSensor serviceUUID]],
            [CBUUID UUIDWithString:[STHumiditySensor serviceUUID]],
            [CBUUID UUIDWithString:[STIRSensor serviceUUID]],
            [CBUUID UUIDWithString:[STKeysSensor serviceUUID]],
            [CBUUID UUIDWithString:[STMagnetometerSensor serviceUUID]],
            [CBUUID UUIDWithString:@"180A"]
    ];
}

#pragma mark -
- (STBaseSensor *)sensorForCharacteristic:(CBCharacteristic *)characteristic {
    NSString *uuid = [[characteristic.service.UUID stringRepresentation] lowercaseString];
    if ([uuid isEqualToString:[[STAccelerometerSensor serviceUUID] lowercaseString]]) {
        return self.accelerometerSensor;
    } else if ([uuid isEqualToString:[[STGyroscopeSensor serviceUUID] lowercaseString] ]) {
        return self.gyroscopeSensor;
    } else if ([uuid isEqualToString:[[STHumiditySensor serviceUUID] lowercaseString] ]) {
        return self.humiditySensor;
    } else if ([uuid isEqualToString:[[STIRSensor serviceUUID] lowercaseString] ]) {
        return self.irSensor;
    } else if ([uuid isEqualToString:[[STKeysSensor serviceUUID] lowercaseString] ]) {
        return self.keysSensor;
    } else if ([uuid isEqualToString:[[STMagnetometerSensor serviceUUID] lowercaseString] ]) {
        return self.magnetometerSensor;
    }

    return nil;
}

@end
