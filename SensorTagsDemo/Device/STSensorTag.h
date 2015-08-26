#import <Foundation/Foundation.h>
#import "STSensorConstants.h"

@class STSensorTag;
@class STAccelerometerSensor;
@class STGyroscopeSensor;
@class STHumiditySensor;
@class STIRSensor;
@class STKeysSensor;
@class STMagnetometerSensor;

typedef struct {
    float x, y, z;
} STVector3D;

extern NSString *const STSensorTagDidFinishDiscoveryNotification;

@interface STSensorTag : NSObject
@property(nonatomic, readonly) CBPeripheral *peripheral;
@property(nonatomic) NSInteger rssi;
@property(nonatomic, copy) NSString *macAddress;

@property(nonatomic, readonly) STAccelerometerSensor *accelerometerSensor;
@property(nonatomic, readonly) STGyroscopeSensor *gyroscopeSensor;
@property(nonatomic, readonly) STHumiditySensor *humiditySensor;
@property(nonatomic, readonly) STIRSensor *irSensor;
@property(nonatomic, readonly) STKeysSensor *keysSensor;
@property(nonatomic, readonly) STMagnetometerSensor *magnetometerSensor;

+ (NSArray *)availableServicesUUIDArray;
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;
- (void)discoverServices;
@end
