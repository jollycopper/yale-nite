//
//  FriendsViewController.m
//  night
//
//  Created by Yan Wen on 4/15/14.
//  Copyright (c) 2014 Yan Wen. All rights reserved.
//

#import "FriendsViewController.h"
#import "ContactTableViewCell.h"
#import "MessageViewController.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 25;
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    PFQuery *find1 = [PFQuery queryWithClassName:@"Friend"];
    [find1 whereKey:@"from" equalTo: [PFUser currentUser].objectId];
    PFQuery *user1 = [PFQuery queryWithClassName:@"_User"];
    [user1 whereKey:@"objectId" matchesKey:@"to" inQuery:find1];
    
    PFQuery *find2 = [PFQuery queryWithClassName:@"Friend"];
    [find2 whereKey:@"to" equalTo: [PFUser currentUser].objectId];
    PFQuery *user2 = [PFQuery queryWithClassName:@"_User"];
    [user2 whereKey:@"objectId" matchesKey:@"from" inQuery:find2];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[user1, user2]];

    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByDescending:@"updatedAt"];
    
    return query;
}

- (PFTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *identifier = @"friend_cell";
    
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.contactName.text = [object objectForKey:@"profile"][@"name"];
    cell.contactCity.text = [object objectForKey:@"profile"][@"location"];
    PFFile *thumbnail = [object objectForKey:@"profileImage"];
    cell.contactThumbnail.image = [UIImage imageNamed:@"logo_chatt"];
    cell.contactThumbnail.file = thumbnail;
    [cell.contactThumbnail loadInBackground];

    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MessageViewController* mvc = [segue destinationViewController];
    mvc.person = (PFUser*)[self objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
