
#import "STConnectionView.h"


@interface STConnectionView ()
@property(nonatomic, strong) UILabel *iconView;
@property(nonatomic, strong) UILabel *connectingLabel;
@property(nonatomic, strong) UIButton *retryButton;
@end

@implementation STConnectionView {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.iconView = [[UILabel alloc] init];
        self.iconView.font = [UIFont fontWithName:@"mce_st_icons" size:100];
        self.iconView.textAlignment = NSTextAlignmentCenter;
        self.iconView.textColor = [UIColor blackColor];
        [self addSubview:self.iconView];
        
        self.connectingLabel = [[UILabel alloc] init];
        self.connectingLabel.text = @"Connecting...";
        self.connectingLabel.textColor = [UIColor blackColor];
        self.connectingLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.connectingLabel];
        
        self.retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.retryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.retryButton setTitle:@"Retry" forState:UIControlStateNormal];
        [self addSubview:self.retryButton];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    float offset = 30;
    [self.iconView sizeToFit];
    self.iconView.center = CGPointMake(self.bounds.size.width * 0.5f, self.bounds.size.height * 0.5f - offset);

    [self.connectingLabel sizeToFit];
    self.connectingLabel.center = CGPointMake(self.iconView.center.x, self.bounds.size.height * 0.5f + offset);

    [self.retryButton sizeToFit];
    self.retryButton.center = CGPointMake(self.iconView.center.x, CGRectGetMaxY(self.connectingLabel.frame) + offset);
}


@end
