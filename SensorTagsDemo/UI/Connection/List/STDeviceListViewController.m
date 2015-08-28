
#import "STDeviceListViewController.h"
#import "STAppDelegate.h"
#import "STSensorTag.h"
#import "STDeviceListView.h"
#import "STDeviceListCell.h"
#import "STConnectionViewController.h"
#import "STBaseViewController.h"

static NSString *const reuseIdentifier = @"reuseIdentifier";

@interface STDeviceListViewController ()
@property(nonatomic, copy) NSString *icon;
@property(nonatomic, strong) STBaseViewController *finalViewController;
@property(nonatomic, strong) STSensorManager *sensorManager;
@property(nonatomic) STDeviceListType type;
@property(nonatomic, strong) NSMutableArray *selectedSensors;
@end

@implementation STDeviceListViewController {

}
- (instancetype)initWithFinalViewController:(STBaseViewController *)viewController type:(STDeviceListType)type {
    self = [self init];
    if (self) {
        self.icon = nil;
        self.finalViewController = viewController;

        self.sensorManager = [STSensorManager sharedInstance];
        self.sensorManager.delegate = self;
        
        self.type = type;
        
        self.selectedSensors = [NSMutableArray array];
    }
    return self;
}

- (void)loadView {
    [super loadView];

    STDeviceListView *view = [[STDeviceListView alloc] init];
    view.tableView.dataSource = self;
    view.tableView.delegate = self;
    [view.tableView registerClass:[STDeviceListCell class] forCellReuseIdentifier:reuseIdentifier];

    UILabel *header = [[UILabel alloc] init];
    header.textAlignment = NSTextAlignmentCenter;
    header.font = [UIFont fontWithName:@"mce_st_icons" size:100];
    header.textColor = [UIColor blackColor];
    header.text = self.icon;
    [header sizeToFit];
    view.tableView.tableHeaderView = header;

    self.view = view;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.sensorManager.delegate = self;
    if (self.sensorManager.state == CBCentralManagerStatePoweredOn) {
        [self.sensorManager startScanning];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.sensorManager stopScanning];
}

- (STDeviceListView *)deviceListView {
    if (self.isViewLoaded) {
        return (STDeviceListView *) self.view;
    }
    return nil;
}

#pragma mark - Table view

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.type == STDeviceListTypeSingleSelection) {
        return @"Pick one device to connect";
    } else {
        return @"Pick two devices to connect";
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
    UITableViewHeaderFooterView *headerFooterView = (UITableViewHeaderFooterView *) view;
    headerFooterView.contentView.backgroundColor = [UIColor clearColor];
    headerFooterView.textLabel.textColor = [UIColor blackColor];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sensorManager.sensors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STDeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    STSensorTag *sensorTag = self.sensorManager.sensors[(NSUInteger) indexPath.row];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = [sensorTag.peripheral.identifier UUIDString];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"RSSI: %d", sensorTag.rssi];

    if ([self.selectedSensors containsObject:sensorTag]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    STSensorTag *sensorTag = self.sensorManager.sensors[(NSUInteger) indexPath.row];
    if ([self.selectedSensors containsObject:sensorTag]) {
        [self.selectedSensors removeObject:sensorTag];
    } else {
        [self.selectedSensors addObject:sensorTag];
    }

    if (self.type == STDeviceListTypeSingleSelection || (self.type == STDeviceListTypeDoubleSelection && self.selectedSensors.count == 2)) {
        STConnectionViewController *viewController = [[STConnectionViewController alloc] initWithSensors:self.selectedSensors iconName:self.icon finalViewController:self.finalViewController];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - Sensor manager delegate
- (void)manager:(STSensorManager *)manager didConnectSensor:(STSensorTag *)sensor {

}

- (void)manager:(STSensorManager *)manager didDisconnectSensor:(STSensorTag *)sensor error:(NSError *)error {

}

- (void)manager:(STSensorManager *)manager didFailToConnectToSensorWithError:(NSError *)error {

}

- (void)manager:(STSensorManager *)manager didDiscoverSensor:(STSensorTag *)sensor {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.deviceListView.tableView reloadData];
    });
}

- (void)manager:(STSensorManager *)manager didChangeStateTo:(CBCentralManagerState)state {
    if (manager.state == CBCentralManagerStatePoweredOn) {
        [manager startScanning];
    }
}

@end
