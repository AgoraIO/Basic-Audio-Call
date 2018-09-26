//
//  InfoModel.m
//  OpenVoiceCall-OC
//
//  Created by CavanSu on 2017/9/18.
//  Copyright © 2017 Agora. All rights reserved.
//

#import "InfoModel.h"

@implementation InfoModel

+ (instancetype)modelWithInfoStr:(NSString *)infoStr {
    InfoModel *model = [[ InfoModel alloc] init];
    model.infoStr = [[NSString alloc] initWithString:infoStr];
    return model;
}

@end
