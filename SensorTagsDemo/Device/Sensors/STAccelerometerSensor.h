//
//  STAccelerometerSensor.h
//  SensorTagsDemo
//
//  Created by Tomasz Grynfelder on 28/08/15.
//  Copyright (c) 2015 codepot.pl. All rights reserved.
//

#import "STBaseSensor.h"
#import "STSensorTag.h"

typedef enum {
    STSensorAccelerometerDisabled      = 0x00,
    STSensorAccelerometer2GRange       = 0x01,
    STSensorAccelerometer4GRange       = 0x02,
    STSensorAccelerometer8GRange       = 0x03,
} STSensorAccelerometerConfig;

@interface STAccelerometerSensor : STBaseSensor
@property(nonatomic, assign) STVector3D acceleration;
@end
