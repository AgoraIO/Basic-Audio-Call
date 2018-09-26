//
//  InfoModel.h
//  OpenVoiceCall-OC
//
//  Created by CavanSu on 2017/9/18.
//  Copyright © 2017 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoModel : NSObject
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, copy) NSString *infoStr;
+ (instancetype)modelWithInfoStr:(NSString *)infoStr;
@end
