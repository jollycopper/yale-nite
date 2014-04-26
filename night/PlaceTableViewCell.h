//
//  PlaceTableViewCell.h
//  night
//
//  Created by Yan Wen on 4/15/14.
//  Copyright (c) 2014 Yan Wen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PlaceTableViewCell : PFTableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *placeImage;
@property (weak, nonatomic) IBOutlet UILabel *placeTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeDescription;

@end
