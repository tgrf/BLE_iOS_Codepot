#import "STSensorTag.h"
#import "STSensorConstants.h"
#import "STSensorManager.h"
#import "CBUUID+StringRepresentation.h"
#import "STBaseSensor.h"
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
@end

@implementation STSensorTag {
}

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    self = [self init];
    if (self) {
        
        self.calibrationDataUnsigned = (UInt16 *)malloc(sizeof(UInt16) * 8);
        self.calibrationDataSigned = (int16_t *)malloc(sizeof(int16_t) * 8);
        self.numberOfDiscoveredServices = 0;
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
}

#pragma mark -

- (void)discoverServices {
    self.numberOfDiscoveredServices = 0;
}

#pragma mark -
+ (NSArray *)availableServicesUUIDArray {
    return @[
            [CBUUID UUIDWithString:@"180A"]
    ];
}

#pragma mark -
- (STBaseSensor *)sensorForCharacteristic:(CBCharacteristic *)characteristic {
    NSString *uuid = [[characteristic.service.UUID stringRepresentation] lowercaseString];

    return nil;
}

@end
