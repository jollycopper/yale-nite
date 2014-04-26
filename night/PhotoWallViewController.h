//
//  PhotoWallViewController.h
//  night
//
//  Created by Yan Wen on 4/13/14.
//  Copyright (c) 2014 Yan Wen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PhotoWallViewController : PFQueryTableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property PFObject* currentLocation;

@end
