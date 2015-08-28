
#import "STView.h"

@implementation STView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        _x = [[UILabel alloc] initWithFrame:CGRectZero];
        self.x.text = @"X";
        [self addSubview:self.x];

        _y = [[UILabel alloc] initWithFrame:CGRectZero];
        self.y.text = @"Y";
        [self addSubview:self.y];

        _z = [[UILabel alloc] initWithFrame:CGRectZero];
        self.z.text = @"Z";
        [self addSubview:self.z];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.x sizeToFit];
    self.x.center = CGPointMake(self.center.x, self.x.center.y);
    self.x.frame = CGRectMake(self.x.frame.origin.x, self.frame.origin.y + 64, self.x.frame.size.width, self.x.frame.size.height);

    [self.y sizeToFit];
    self.y.center = CGPointMake(self.center.x, self.y.center.y);
    self.y.frame = CGRectMake(self.y.frame.origin.x, CGRectGetMaxY(self.x.frame) + 64, self.y.frame.size.width, self.y.frame.size.height);

    [self.z sizeToFit];
    self.z.center = CGPointMake(self.center.x, self.z.center.y);
    self.z.frame = CGRectMake(self.z.frame.origin.x, CGRectGetMaxY(self.y.frame) + 64, self.z.frame.size.width, self.z.frame.size.height);
}

@end
