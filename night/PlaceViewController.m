//
//  PlaceViewController.m
//  night
//
//  Created by Yan Wen on 4/13/14.
//  Copyright (c) 2014 Yan Wen. All rights reserved.
//

#import "PlaceViewController.h"
#import "PlaceTableViewCell.h"
#import "PhotoWallViewController.h"

#define IPHONE_PORTRAIT_GRID   (CGSize){312, 0}
#define IPHONE_PORTRAIT_PHOTO  (CGSize){304, 148}

@interface PlaceViewController ()

@end

@implementation PlaceViewController{

}

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 5;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scroll_background"]];
    [tempImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = tempImageView;
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:@"Location"];
    
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByDescending:@"updatedAt"];
    
    return query;
}

- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *identifier = @"place_cell";
    
    PlaceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PlaceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    PFFile *thumbnail = [object objectForKey:@"coverPicture"];
    cell.placeTextLabel.text = [object objectForKey:@"name"];
    cell.placeDescription.text = [object objectForKey:@"description"];
    cell.placeImage.image = [UIImage imageNamed:@"logo_chatt"];
    cell.placeImage.file = thumbnail;
    [cell.placeImage loadInBackground];
    return cell;
}

#pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
     PFObject* obj = [self.objects objectAtIndex:selectedIndexPath.row];
     PhotoWallViewController* pvc = [segue destinationViewController];
     pvc.currentLocation = obj;
 }

@end
