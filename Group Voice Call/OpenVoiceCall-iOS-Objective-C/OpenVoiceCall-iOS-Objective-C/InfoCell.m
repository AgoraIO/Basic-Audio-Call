//
//  InfoCell.m
//  OpenVoiceCall-OC
//
//  Created by CavanSu on 2017/9/18.
//  Copyright © 2017 Agora. All rights reserved.
//

#import "InfoCell.h"

@implementation InfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.infoLabel.textColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.infoLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 20;
}

- (void)setModel:(InfoModel *)model {
    self.infoLabel.text = model.infoStr;
    [self layoutIfNeeded];
    if (!model.height ) {
        model.height = CGRectGetMaxY(self.infoLabel.frame);
    }
}

@end
