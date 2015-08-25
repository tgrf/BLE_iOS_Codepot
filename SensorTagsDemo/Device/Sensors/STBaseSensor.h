#import <Foundation/Foundation.h>

@class STBaseSensor;

@protocol STBaseSensorDelegate<NSObject>
- (void)sensorDidUpdateValue:(STBaseSensor *)sensor;
- (void)sensorDidFailCommunicating:(STBaseSensor *)sensor withError:(NSError *)error;
- (void)sensorDidFinishCalibration:(STBaseSensor *)sensor;
@end

@interface STBaseSensor : NSObject

@property (nonatomic, readonly) CBPeripheral *peripheral;
@property (nonatomic, weak) id<STBaseSensorDelegate> sensorDelegate;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;

- (void)configureWithValue:(char)value;
- (void)setPeriodValue:(char)periodValue;
- (void)setNotificationsEnabled:(BOOL)enabled;

- (BOOL)canBeConfigured;
- (BOOL)canSetPeriod;

- (CBCharacteristic *)characteristicForUUID:(NSString *)UUID;

// Methods to override
- (BOOL)processReadFromCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
- (BOOL)processWriteFromCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
- (BOOL)processNotificationsUpdateFromCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

+ (NSString *)serviceUUID;
+ (NSString *)configurationCharacteristicUUID;
+ (NSString *)periodCharacteristicUUID;
+ (NSString *)dataCharacteristicUUID;
@end
