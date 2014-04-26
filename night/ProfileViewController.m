//
//  ProfileViewController.m
//  night
//
//  Created by Yan Wen on 4/12/14.
//  Copyright (c) 2014 Yan Wen. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[PFUser currentUser] objectForKey:@"profile"][@"name"]) {
        self.nameLabel.text = [[PFUser currentUser] objectForKey:@"profile"][@"name"];
    }
    PFImageView *profileImage = [[PFImageView alloc] init];
    profileImage.file = [[PFUser currentUser] objectForKey:@"profileImage"];
    [profileImage loadInBackground:^(UIImage *image, NSError *error){
        self.roundedProfileImage.image = image;
        [self.roundedProfileImage layoutIfNeeded];
    }];
}

- (IBAction)onLogoutTouched:(id)sender {
    [PFUser logOut];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
