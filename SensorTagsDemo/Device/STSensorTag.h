#import <Foundation/Foundation.h>
#import "STSensorConstants.h"

@class STSensorTag;

typedef struct {
    float x, y, z;
} STVector3D;

extern NSString *const STSensorTagDidFinishDiscoveryNotification;

@interface STSensorTag : NSObject

@property(nonatomic, readonly) CBPeripheral *peripheral;

@property(nonatomic) NSInteger rssi;

@property(nonatomic, copy) NSString *macAddress;

+ (NSArray *)availableServicesUUIDArray;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral;

- (void)discoverServices;

@end
