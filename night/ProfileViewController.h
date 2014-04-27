//
//  ProfileViewController.h
//  night
//
//  Created by Yan Wen on 4/12/14.
//  Copyright (c) 2014 Yan Wen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGMedallionView.h"

@interface ProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet AGMedallionView *roundedProfileImage;
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UILabel *numOfPhoto;
@property (weak, nonatomic) IBOutlet UILabel *numOfFriend;

@end
