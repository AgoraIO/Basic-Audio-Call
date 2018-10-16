//
//  MainViewController.m
//  OpenVoiceCall-OC
//
//  Created by CavanSu on 2017/9/16.
//  Copyright © 2017 Agora. All rights reserved.
//

#import "MainViewController.h"
#import "RoomViewController.h"
#import "ChannelNameCheck.h"

@interface MainViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UITextField *channelNameTextField;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateViews];
}

- (void)updateViews {
    self.view.backgroundColor = ThemeColor;
    self.welcomeLabel.adjustsFontSizeToFitWidth = YES;
    self.joinButton.backgroundColor = [UIColor whiteColor];
    [self.joinButton setTitleColor:ThemeColor forState:UIControlStateNormal];
    self.joinButton.layer.cornerRadius = self.joinButton.bounds.size.height * 0.5;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender {
    BOOL YesOrNo = self.channelNameTextField.text.length > 0 ? YES : NO;
    return YesOrNo;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender {
    RoomViewController *roomVC = segue.destinationViewController;
    roomVC.channelName = self.channelNameTextField.text;
}

- (IBAction)editingChannelName:(UITextField *)sender {
    NSString *legalChannelName = [ChannelNameCheck channelNameCheckLegal:sender.text];
    sender.text = legalChannelName;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.channelNameTextField endEditing:YES];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.channelNameTextField endEditing:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
