//
//  ChannelNameCheck.m
//  OpenVoiceCall-OC
//
//  Created by CavanSu on 2017/9/18.
//  Copyright © 2017 Agora. All rights reserved.
//

#import "ChannelNameCheck.h"

@implementation ChannelNameCheck
+ (NSString *)channelNameCheckLegal:(NSString *)channelName {
    NSString *includerChars = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#$%&()+,-:;<=.>?@[]^_`{|}~";
    NSCharacterSet *invertedSet = [[NSCharacterSet characterSetWithCharactersInString:includerChars] invertedSet];
    NSArray *separatedArray = [channelName componentsSeparatedByCharactersInSet:invertedSet];
    NSString *fixedChannelName = [separatedArray componentsJoinedByString:@""];
    return fixedChannelName;
}
@end
