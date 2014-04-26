//
//  ViewController.m
//  night
//
//  Created by Yan Wen on 4/7/14.
//  Copyright (c) 2014 Yan Wen. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>

@interface ViewController ()
@property (nonatomic, strong) NSMutableData *imageData;
@end

@implementation ViewController


//  Resize the input image to standard size
-(UIImage*)imageWithImage:(UIImage*)image{
    UIGraphicsBeginImageContext(CGSizeMake(480, 320));
    [image drawInRect:CGRectMake(0, 0, 480, 320)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // start animation
    NSMutableArray *images = [NSMutableArray array];
    for (int i=250; i <= 310; i++) {
        NSString *strImgeName = [NSString stringWithFormat:@"img%d.jpg", i];
        UIImage *image = [UIImage imageNamed:strImgeName];
        image = [self imageWithImage:image];
        if (!image) {
            NSLog(@"Could not load image named: %@", strImgeName);
        }
        else {
            [images addObject:image];
        }
    }
    int width = [[UIScreen mainScreen]applicationFrame].size.width;
    int height = [[UIScreen mainScreen]applicationFrame].size.height + 20;
    UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    animationImageView.animationImages = images;
    animationImageView.animationDuration = 3;
    [self.view addSubview:animationImageView];
    [self.view sendSubviewToBack:animationImageView];
    [animationImageView startAnimating];
    
}
- (IBAction)onLoginBtnClick:(id)sender {
    
    NSArray *permissionsArray = @[ @"user_about_me", @"user_location"];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            if (!error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        } else {
            [self loadUserDataFromFB];
            [self performSegueWithIdentifier:@"login_success" sender:self];
        }
    }];
}

- (BOOL) loadUserDataFromFB{
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Parse the data received
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            NSMutableDictionary *userProfile = [NSMutableDictionary dictionaryWithCapacity:8];
            
            if (facebookID) {
                userProfile[@"facebookId"] = facebookID;
            }
            
            if (userData[@"name"]) {
                userProfile[@"name"] = userData[@"name"];
            }
            
            if (userData[@"location"][@"name"]) {
                userProfile[@"location"] = userData[@"location"][@"name"];
            }
            
            if (userData[@"gender"]) {
                userProfile[@"gender"] = userData[@"gender"];
            }

            if ([pictureURL absoluteString]) {
                userProfile[@"pictureURL"] = [pictureURL absoluteString];
            }
            
            [self uploadImageAsyncFromFBIfNewUser];
            
            [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
            [[PFUser currentUser] saveInBackground];
            
        } else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                    isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
            NSLog(@"The facebook session was invalidated");
        } else {
            NSLog(@"Some other error: %@", error);
        }
    }];
    
    if ([PFUser currentUser]) {
        return YES;
    }
    return NO;
}

- (void) uploadImageAsyncFromFBIfNewUser{
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
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"login_success"]) {
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
