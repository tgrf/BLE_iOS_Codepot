//
//  STAccelerometerSensor.m
//  SensorTagsDemo
//
//  Created by Tomasz Grynfelder on 28/08/15.
//  Copyright (c) 2015 codepot.pl. All rights reserved.
//

#import "STAccelerometerSensor.h"

static NSString *const STSensorAccelerometerServiceUUID = @"F000AA10-0451-4000-B000-000000000000";

// Accelerometer Characteristic UUID
static NSString *const STSensorAccelerometerDataCharacteristicUUID = @"F000AA11-0451-4000-B000-000000000000";    // X:Y:Z Coordinates
static NSString *const STSensorAccelerometerConfigCharacteristicUUID = @"F000AA12-0451-4000-B000-000000000000";  // Write "01" to select range 2G, "02" for 4G, "03" for 8G, "00" disable sensor
static NSString *const STSensorAccelerometerPeriodCharacteristicUUID = @"F000AA13-0451-4000-B000-000000000000";  // Period =[Input*10]ms, (lower limit 100 ms), default 1000 ms

@interface STAccelerometerSensor ()
@property(nonatomic, assign) char range;
@end

@implementation STAccelerometerSensor

- (void)configureWithValue:(char)value {
    [super configureWithValue:value];
    self.range = value;
}

- (BOOL)processReadFromCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (![super processReadFromCharacteristic:characteristic error:error]) {
        return NO;
    }

    NSData *data = characteristic.value;

    //Orientation of sensor on board means we need to swap Y (multiplying with -1)
    char scratchVal[data.length];
    [data getBytes:&scratchVal length:3];

    float x = (float) ((scratchVal[0] * 1.0) / (256 / [self currentRange]));
    float y = (float) (((scratchVal[1] * 1.0) / (256 / [self currentRange])) * -1);
    float z = (float) ((scratchVal[2] * 1.0) / (256 / [self currentRange]));

    STVector3D vector3D = { x, y, z };
    self.acceleration = vector3D;

    [self.sensorDelegate sensorDidUpdateValue:self];
    return YES;
}

+ (NSString *)serviceUUID {
    return STSensorAccelerometerServiceUUID;
}

+ (NSString *)configurationCharacteristicUUID {
    return STSensorAccelerometerConfigCharacteristicUUID;
}

+ (NSString *)periodCharacteristicUUID {
    return STSensorAccelerometerPeriodCharacteristicUUID;
}

+ (NSString *)dataCharacteristicUUID {
    return STSensorAccelerometerDataCharacteristicUUID;
}

- (float)currentRange {
    switch (self.range) {
        case STSensorAccelerometer2GRange:
            return 2.f;
        case STSensorAccelerometer4GRange:
            return 4.f;
        case STSensorAccelerometer8GRange:
            return 8.f;
        default:
            return -1.f;
    }
}

@end
