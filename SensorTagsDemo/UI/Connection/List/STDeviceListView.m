
#import "STDeviceListView.h"

@interface STDeviceListView ()
@property(nonatomic, readwrite) UITableView *tableView;
@end

@implementation STDeviceListView {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.separatorColor = [UIColor grayColor];
        [self addSubview:self.tableView];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.tableView.frame = self.bounds;
}


@end
