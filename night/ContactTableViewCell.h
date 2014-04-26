//
//  ContactTableViewCell.h
//  night
//
//  Created by Yan Wen on 4/13/14.
//  Copyright (c) 2014 Yan Wen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ContactTableViewCell : PFTableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *contactThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *contactName;
@property (weak, nonatomic) IBOutlet UILabel *contactCity;

@end
