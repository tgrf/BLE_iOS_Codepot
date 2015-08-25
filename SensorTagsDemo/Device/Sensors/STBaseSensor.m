#import <CocoaLumberjack/DDLegacy.h>
#import "STBaseSensor.h"
#import "CBUUID+StringRepresentation.h"
#import "DDLog.h"
#import "STSensorManager.h"

static int ddLogLevel = DDLogLevelDebug;

@interface STBaseSensor ()
@property (nonatomic, readwrite) CBPeripheral *peripheral;
@end

@implementation STBaseSensor {

}

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral {
    self = [self init];
    if (self) {
        self.peripheral = peripheral;
    }
    return self;
}

- (void)configureWithValue:(char)value {
    CBCharacteristic *configurationCharacteristic = [self characteristicForUUID:[[self class] configurationCharacteristicUUID]];
    if (configurationCharacteristic) {
        [self.peripheral writeValue:[NSData dataWithBytes:&value length:sizeof(value)] forCharacteristic:configurationCharacteristic type:CBCharacteristicWriteWithResponse];
    } else {
        DDLogError(@"Cannot configure value for sensor %@", self);
        [self.sensorDelegate sensorDidFailCommunicating:self withError:[NSError errorWithDomain:STSensorTagErrorDomain code:STSensorTagOptionUnavailable userInfo:nil]];
    }
}

- (void)setPeriodValue:(char)periodValue {
    CBCharacteristic *configurationCharacteristic = [self characteristicForUUID:[[self class] periodCharacteristicUUID]];
    if (configurationCharacteristic) {
        [self.peripheral writeValue:[NSData dataWithBytes:&periodValue length:sizeof(periodValue)] forCharacteristic:configurationCharacteristic type:CBCharacteristicWriteWithResponse];
    } else {
        DDLogError(@"Cannot configure period for sensor %@", self);
        [self.sensorDelegate sensorDidFailCommunicating:self withError:[NSError errorWithDomain:STSensorTagErrorDomain code:STSensorTagOptionUnavailable userInfo:nil]];
    }
}

- (void)setNotificationsEnabled:(BOOL)enabled {
    CBCharacteristic *dataCharacteristic = [self characteristicForUUID:[[self class] dataCharacteristicUUID]];
    if (dataCharacteristic) {
        [self.peripheral setNotifyValue:enabled forCharacteristic:dataCharacteristic];
    }
}

- (BOOL)canBeConfigured {
    return [self characteristicForUUID:[[self class] configurationCharacteristicUUID]] != nil;
}

- (BOOL)canSetPeriod {
    return [self characteristicForUUID:[[self class] periodCharacteristicUUID]] != nil;
}

#pragma mark -

- (CBCharacteristic *)characteristicForUUID:(NSString *)UUID {
    CBCharacteristic *configurationCharacteristic;
    for (CBService *service in self.peripheral.services) {
        NSString *string = [[service.UUID stringRepresentation] lowercaseString];
        NSString *aString = [[[self class] serviceUUID] lowercaseString];
        if ([string isEqualToString:aString]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([[[characteristic.UUID stringRepresentation] lowercaseString] isEqualToString:[UUID lowercaseString] ]) {
                    configurationCharacteristic = characteristic;
                }
            }
        }
    }
    return configurationCharacteristic;
}

#pragma mark - Override in subclasses
- (BOOL)processReadFromCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ([[characteristic.UUID.stringRepresentation lowercaseString] isEqualToString:[[[self class] dataCharacteristicUUID] lowercaseString]] &&
            [[characteristic.service.UUID stringRepresentation] isEqualToString:[[[self class] serviceUUID] lowercaseString]]) {
        if (error) {
            DDLogError(@"%s %@", __PRETTY_FUNCTION__, error);
            [self.sensorDelegate sensorDidFailCommunicating:self withError:error];
            return NO;
        }
        return YES;
    }
    return NO;
}

- (BOOL)processWriteFromCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ([[characteristic.UUID.stringRepresentation lowercaseString] isEqualToString:[[[self class] configurationCharacteristicUUID] lowercaseString] ] &&
            [[[characteristic.service.UUID stringRepresentation] lowercaseString] isEqualToString:[[[self class] serviceUUID] lowercaseString] ]) {
        if (error) {
            DDLogError(@"%s %@", __PRETTY_FUNCTION__, error);
            [self.sensorDelegate sensorDidFailCommunicating:self withError:error];
            return NO;
        }
        return YES;
    }
    return NO;
}

- (BOOL)processNotificationsUpdateFromCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ([[characteristic.UUID.stringRepresentation lowercaseString] isEqualToString:[[[self class] dataCharacteristicUUID] lowercaseString] ] &&
            [[[characteristic.service.UUID stringRepresentation] lowercaseString] isEqualToString:[[[self class] serviceUUID] lowercaseString] ]) {
        if (error) {
            DDLogError(@"%s %@", __PRETTY_FUNCTION__, error);
            [self.sensorDelegate sensorDidFailCommunicating:self withError:error];
            return NO;
        }
        return YES;
    }
    return NO;
}

+ (NSString *)serviceUUID {
    return nil;
}

+ (NSString *)configurationCharacteristicUUID {
    return nil;
}

+ (NSString *)periodCharacteristicUUID {
    return nil;
}

+ (NSString *)dataCharacteristicUUID {
    return nil;
}

@end
