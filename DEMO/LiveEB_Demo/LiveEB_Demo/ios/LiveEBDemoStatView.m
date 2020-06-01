//
//  LiveEBDemoStatView.m
//  LiveEB_Demo
//
//  Created by ts on 5/19/20.
//  Copyright © 2020 ts. All rights reserved.
//

#import "LiveEBDemoStatView.h"

@implementation LiveEBDemoStatView {
  UILabel *_statsLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _statsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _statsLabel.numberOfLines = 0;
    _statsLabel.font = [UIFont fontWithName:@"Roboto" size:10];
    _statsLabel.adjustsFontSizeToFitWidth = YES;
    _statsLabel.minimumScaleFactor = 0.6;
    _statsLabel.textColor = [UIColor greenColor];
    [self addSubview:_statsLabel];
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
  }
  return self;
}

- (void)setStats:(NSString *)stats {
    _statsLabel.text = stats;
}

- (void)layoutSubviews {
  _statsLabel.frame = self.bounds;
}

- (CGSize)sizeThatFits:(CGSize)size {
  return [_statsLabel sizeThatFits:size];
}

@end
