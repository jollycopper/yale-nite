//
//  ProfileViewController.m
//  night
//
//  Created by Yan Wen on 4/12/14.
//  Copyright (c) 2014 Yan Wen. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#include <stdlib.h>

@interface ProfileViewController ()

@property (nonatomic, strong) NSMutableData *imageData;

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
    
    if ([[PFUser currentUser] objectForKey:@"profileImage"]) {
        PFImageView *profileImage = [[PFImageView alloc] init];
        profileImage.file = [[PFUser currentUser] objectForKey:@"profileImage"];
        [profileImage loadInBackground:^(UIImage *image, NSError *error){
            self.roundedProfileImage.image = image;
            [self.roundedProfileImage layoutIfNeeded];
        }];
    }
    else {
        [self loadImageAsyncFromFB];
    }
    
    //add photo & friend num
    int pNum = arc4random_uniform(5);
    int fNum = arc4random_uniform(4);
    self.numOfPhoto.text = [NSString stringWithFormat:@"%d", pNum];
    self.numOfFriend.text = [NSString stringWithFormat:@"%d", fNum];
    [self.numOfPhoto sizeToFit];
    [self.numOfFriend sizeToFit];
    
}

- (void) loadImageAsyncFromFB{
    if ([[PFUser currentUser] objectForKey:@"profileImage"]) {
        return;
    }
    // Download the user's facebook profile picture
    self.imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
    
    if ([[PFUser currentUser] objectForKey:@"profile"][@"pictureURL"]) {
        NSURL *pictureURL = [NSURL URLWithString:[[PFUser currentUser] objectForKey:@"profile"][@"pictureURL"]];
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                              timeoutInterval:2.0f];
        // Run network request asynchronously
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        if (!urlConnection) {
            NSLog(@"Failed to download picture");
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // As chuncks of the image are received, we build our data file
    [self.imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    UIImage* img =[UIImage imageWithData:self.imageData];
    // save it to parse
    NSData *imageData = UIImagePNGRepresentation(img);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    [imageFile saveInBackground];
    
    PFUser *user = [PFUser currentUser];
    [user setObject:imageFile forKey:@"profileImage"];
    [user saveInBackground];
    
    self.roundedProfileImage.image = img;
    [self.roundedProfileImage layoutIfNeeded];
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
