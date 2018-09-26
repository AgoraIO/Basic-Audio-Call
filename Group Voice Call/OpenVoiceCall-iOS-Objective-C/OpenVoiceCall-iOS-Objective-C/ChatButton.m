//
//  ChatButton.m
//  OpenVoiceCall-OC
//
//  Created by CavanSu on 2017/9/12.
//  Copyright © 2017 Agora. All rights reserved.
//

#import "ChatButton.h"

@implementation ChatButton

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageViewWH = 44;
    CGFloat imageViewY = (self.frame.size.width - imageViewWH) * 0.5;
    CGFloat labelWH = 20;
    
    self.imageView.frame = CGRectMake(imageViewY, 0, imageViewWH, imageViewWH);
    self.titleLabel.frame = CGRectMake(0, imageViewWH, self.frame.size.width, labelWH);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
}

- (void)sendAction:(SEL)action to:(nullable id)target forEvent:(nullable UIEvent *)event {
    self.selected = !self.selected;
    [super sendAction:action to:target forEvent:event];
}

@end
