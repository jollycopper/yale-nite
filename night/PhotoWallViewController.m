//
//  PhotoWallViewController.m
//  night
//
//  Created by Yan Wen on 4/13/14.
//  Copyright (c) 2014 Yan Wen. All rights reserved.
//

#import "PhotoWallViewController.h"
#import "PostViewCell.h"
#import "PostHeaderView.h"
#import "MessageViewController.h"

#define IPHONE_PORTRAIT_GRID   (CGSize){312, 0}
#define IPHONE_PORTRAIT_PHOTO  (CGSize){148, 148}

@interface PhotoWallViewController ()

@property (nonatomic, strong) NSMutableSet *reusableSectionHeaderViews;

@end

@implementation PhotoWallViewController{
}

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        self.parseClassName = @"Post";
        
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 5;
        
        self.reusableSectionHeaderViews = [NSMutableSet setWithCapacity:3];
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
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"location" equalTo:self.currentLocation];

    if ([query countObjects] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }

    [query orderByDescending:@"updatedAt"];
    return query;
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath {
    // overridden, since we want to implement sections
    if (indexPath.section < self.objects.count) {
        return [self.objects objectAtIndex:indexPath.section];
    }    
    return nil;
}

- (PostViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *identifier = @"post_cell";
    
    PostViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[PostViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell.photoButton addTarget:self action:@selector(didTapOnPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    cell.photoButton.tag = indexPath.section;
    PFFile *thumbnail = [object objectForKey:@"picture"];
    cell.imageView.image = [UIImage imageNamed:@"logo_chatt"];
    cell.imageView.file = thumbnail;
    [cell.imageView loadInBackground];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == self.objects.count) {
        // Load More section
        return nil;
    }
    PostHeaderView *headerView = [self dequeueReusableSectionHeaderView];
    if (!headerView) {
        headerView = [[PostHeaderView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.view.bounds.size.width, 44.0f)];
        [self.reusableSectionHeaderViews addObject:headerView];
    }
    headerView.tag = section;
    [headerView setPushObject:self.objects[section]];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, self.tableView.bounds.size.width, 16.0f)];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 16.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 280.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sections = self.objects.count;
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (PostHeaderView *)dequeueReusableSectionHeaderView {
    for (PostHeaderView *sectionHeaderView in self.reusableSectionHeaderViews) {
        if (!sectionHeaderView.superview) {
            // we found a section header that is no longer visible
            return sectionHeaderView;
        }
    }
    
    return nil;
}


#pragma mark - Image Picker Controller delegate methods
- (IBAction)onAddPicButtonTouched:(id)sender {
    NSInteger sourse = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        sourse = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = sourse;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    chosenImage = [self imageByCroppingImage:chosenImage];
    NSData *imageData = UIImageJPEGRepresentation(chosenImage, 0.4);
    PFFile *imageFile = [PFFile fileWithData:imageData];
    [imageFile saveInBackground];
    
    PFObject *userPost = [PFObject objectWithClassName:@"Post"];
    [userPost setObject: [PFUser currentUser] forKey:@"owner"];
    [userPost setObject: self.currentLocation forKey:@"location"];
    [userPost setObject: imageFile forKey:@"picture"];
    [userPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded) {
            // reload table and scroll to top
            [self loadObjects];
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 100, 100) animated:YES];
        }
    }];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (UIImage *)imageByCroppingImage:(UIImage *)original
{
    UIImage *ret = nil;
    float originalWidth  = original.size.width;
    float originalHeight = original.size.height;
    float edge = fminf(originalWidth, originalHeight);
    float posX = (originalWidth   - edge) / 2.0f;
    float posY = (originalHeight  - edge) / 2.0f;
    CGRect cropSquare = CGRectMake(posX, posY, edge, edge);
    CGImageRef imageRef = CGImageCreateWithImageInRect([original CGImage], cropSquare);
    ret = [UIImage imageWithCGImage:imageRef
                              scale:original.scale
                        orientation:original.imageOrientation];
    CGImageRelease(imageRef);
    return ret;
}

#pragma mark - Navigation

-(void)didTapOnPhotoAction:(UIButton *)sender{
    PFObject *post = self.objects[sender.tag];
    NSLog(@"%d", [self.tableView indexPathForSelectedRow].section);
    PFUser* owner = (PFUser*)[post objectForKey:@"owner"];
    // if you tap on your own picture, you do nothing.
    if ([owner.objectId isEqualToString: [PFUser currentUser].objectId]) {
        return;
    }
    if ([owner isDataAvailable]) {
        [self performSegueWithIdentifier:@"chat" sender:owner];
    }
    else{
        [owner fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *err){
            [self performSegueWithIdentifier:@"chat" sender:object];
        }];
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"chat"]) {
        MessageViewController* mvc = [segue destinationViewController];
        mvc.person = sender;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
