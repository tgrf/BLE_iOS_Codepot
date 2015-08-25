#import <Foundation/Foundation.h>

extern NSString *const STSensorTagErrorDomain;

typedef enum {
    STSensorManagerErrorNoDeviceFound,
    STSensorTagOptionUnavailable,
    STSensorManagerTimeout
} STSensorTagError;

@class STSensorManager;
@class STSensorTag;

@protocol STSensorManagerDelegate<NSObject>
- (void)manager:(STSensorManager *)manager didConnectSensor:(STSensorTag *)sensor;
- (void)manager:(STSensorManager *)manager didDisconnectSensor:(STSensorTag *)sensor error:(NSError *)error;
- (void)manager:(STSensorManager *)manager didFailToConnectToSensorWithError:(NSError *)error;
- (void)manager:(STSensorManager *)manager didDiscoverSensor:(STSensorTag *)sensor;
- (void)manager:(STSensorManager *)manager didChangeStateTo:(CBCentralManagerState)state;
@end

@interface STSensorManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, weak) id<STSensorManagerDelegate> delegate;

- (void)startScanning;
- (void)stopScanning;
- (void)connectSensorWithUUID:(NSUUID *)uuid;
- (void)connectNearestSensor;
- (void)connectLastSensor;
- (BOOL)hasPreviouslyConnectedSensor;
- (CBCentralManagerState)state;
- (void)disconnectSensor:(STSensorTag *)sensorTag;

- (NSArray *)sensors;
@end
