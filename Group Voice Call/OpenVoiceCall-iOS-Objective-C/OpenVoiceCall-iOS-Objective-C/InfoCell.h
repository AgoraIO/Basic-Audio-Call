//
//  InfoCell.h
//  OpenVoiceCall-OC
//
//  Created by CavanSu on 2017/9/18.
//  Copyright © 2017 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoModel.h"

@interface InfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (nonatomic, weak) InfoModel *model;
@end
