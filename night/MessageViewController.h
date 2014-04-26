//
//  MessageViewController.h
//  night
//
//  Created by Yan Wen on 4/8/14.
//  Copyright (c) 2014 Yan Wen. All rights reserved.
//

#import "JSMessagesViewController.h"
#import <Parse/Parse.h>

@interface MessageViewController : JSMessagesViewController <JSMessagesViewDelegate, JSMessagesViewDataSource>
@property (strong, nonatomic) PFUser* person;
@property (strong, nonatomic) UIImage* personImage;
@property (strong, nonatomic) UIImage* myImage;
@end
