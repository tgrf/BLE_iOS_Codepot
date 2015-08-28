#import "STSensorManager.h"
#import "STSensorTag.h"
#import "CBUUID+StringRepresentation.h"

#import <CocoaLumberjack/CocoaLumberjack.h>
static int ddLogLevel = DDLogLevelDebug;
static NSTimeInterval STWatchdogInterval = 15.f;

static NSString *const kSTSensorManagerLastDeviceUUID = @"kSTSensorManagerLastDeviceUUID";
static NSString *const STSensorManagerNoDeviceError = @"No device found.";
static NSString *const STSensorManagerConnectionTimeoutError = @"Connection timeout.";

NSString *const STSensorTagErrorDomain = @"STSensorTagErrorDomain";

@interface STSensorManager ()
@property(nonatomic, strong) CBCentralManager *centralManager;
@property(nonatomic) BOOL shouldStartScanning;
@property(nonatomic, strong) NSMutableDictionary *peripherals;
@property(nonatomic) BOOL isScanning;
@property(nonatomic, strong) STSensorTag *connectingSensor;
@property(nonatomic, strong) NSTimer *watchdogTimer;
@end

@implementation STSensorManager {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.peripherals = [NSMutableDictionary dictionary];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedDiscovery:) name:STSensorTagDidFinishDiscoveryNotification object:nil];
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopWatchdog];
}


- (void)finishedDiscovery:(NSNotification *)finishedDiscovery {
    [self stopWatchdog];
    [self.delegate manager:self didConnectSensor:finishedDiscovery.object];
}

#pragma mark -

- (void)startScanning {
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    self.shouldStartScanning = YES;
    [self scan];
}

- (void)stopScanning {
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
}

- (void)connectSensorWithUUID:(NSUUID *)uuid {
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, uuid);
    STSensorTag *sensorTag = self.peripherals[uuid.UUIDString];
    if (sensorTag) {
    } else {
    }
}

- (void)startWatchdogForSensor:(STSensorTag *)sensor {
    [self stopWatchdog];
    self.connectingSensor = sensor;
    self.watchdogTimer = [NSTimer timerWithTimeInterval:STWatchdogInterval
                                                     target:self
                                                   selector:@selector(watchdogFired)
                                                   userInfo:nil
                                                    repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.watchdogTimer forMode:NSDefaultRunLoopMode];
}

- (void)watchdogFired {
    DDLogError(@"%s", __PRETTY_FUNCTION__);

    [self.watchdogTimer invalidate];
    self.watchdogTimer = nil;
}

- (void)connectNearestSensor {
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(findNearestAndConnect) withObject:nil afterDelay:10 inModes:@[NSRunLoopCommonModes, NSDefaultRunLoopMode]];
    });
    [self startScanning];
}

- (void)connectLastSensor {
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    [self connectSensorWithUUID:[[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults] objectForKey:kSTSensorManagerLastDeviceUUID]]];
}

- (BOOL)hasPreviouslyConnectedSensor {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSTSensorManagerLastDeviceUUID] != nil;
}

- (void)findNearestAndConnect {
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
}

- (void)scan {
    DDLogInfo(@"%s", __PRETTY_FUNCTION__);
    if (self.shouldStartScanning && self.centralManager.state == CBCentralManagerStatePoweredOn) {
    }
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    [self.delegate manager:self didChangeStateTo:central.state];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    DDLogVerbose(@"%s %@", __PRETTY_FUNCTION__, peripheral);

}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    DDLogInfo(@"%s %@", __PRETTY_FUNCTION__, peripheral);
    [[NSUserDefaults standardUserDefaults] setObject:peripheral.identifier.UUIDString forKey:kSTSensorManagerLastDeviceUUID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    DDLogError(@"%s %@ %@", __PRETTY_FUNCTION__, peripheral, error);
    [self.delegate manager:self didFailToConnectToSensorWithError:error];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    DDLogInfo(@"%s %@ %@", __PRETTY_FUNCTION__, peripheral, error);
    [self.delegate manager:self didDisconnectSensor:self.peripherals[peripheral.identifier.UUIDString] error:error];
}

- (CBCentralManagerState)state {
    return self.centralManager.state;
}

- (void)disconnectSensor:(STSensorTag *)sensorTag {
    [self stopWatchdog];
    if (sensorTag.peripheral) {
    }
}

- (void)stopWatchdog {
    [self.watchdogTimer invalidate];
    self.watchdogTimer = nil;
}

- (NSArray *)sensors {
    return [self.peripherals allValues];
}

@end
