//
//  MessageViewController.m
//  night
//
//  Created by Yan Wen on 4/8/14.
//  Copyright (c) 2014 Yan Wen. All rights reserved.
//

#import "MessageViewController.h"
#import "JSMessage.h"
#import <Parse/Parse.h>

@interface MessageViewController ()

@end

@implementation MessageViewController{
    NSMutableArray* messages;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.delegate = self;
    self.dataSource = self;
    [super viewDidLoad];
    
    [[JSBubbleView appearance] setFont: [UIFont systemFontOfSize:16.0f]];
    
    self.title = [self.person objectForKey:@"profile"][@"name"];
    self.messageInputView.textView.placeHolder = @"Say hi!";
    self.sender = [[PFUser currentUser] objectForKey:@"profile"][@"name"];
    [self.tabBarController.tabBar setHidden:YES];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center=self.view.center;
    [activityView startAnimating];
    [self.view addSubview:activityView];
    
    // get profile image of the person
    PFFile* imgFile = [self.person objectForKey:@"profileImage"];
    self.personImage = [UIImage imageWithData:[imgFile getData]];
    self.personImage = [JSAvatarImageFactory avatarImage:self.personImage croppedToCircle:YES];
    imgFile = [[PFUser currentUser] objectForKey:@"profileImage"];
    self.myImage = [UIImage imageWithData:[imgFile getData]];
    self.myImage = [JSAvatarImageFactory avatarImage:self.myImage croppedToCircle:YES];
    
    // get message history in a waiting way.
    PFQuery *sentByMe = [PFQuery queryWithClassName:@"Chat"];
    [sentByMe whereKey:@"sender" equalTo: [PFUser currentUser]];
    [sentByMe whereKey:@"receiver" equalTo: self.person];
    PFQuery *sentByPerson = [PFQuery queryWithClassName:@"Chat"];
    [sentByPerson whereKey:@"sender" equalTo: self.person];
    [sentByPerson whereKey:@"receiver" equalTo: [PFUser currentUser]];
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[sentByMe, sentByPerson]];
    [query orderByAscending:@"createdAt"];
    NSArray* objects = [query findObjects];
    
    // load data into array
    self.sender = [[PFUser currentUser] objectForKey:@"profile"] [@"name"];
    messages = [[NSMutableArray alloc] initWithCapacity:objects.count];
    for (PFObject* chat in objects) {
        NSString* txt = [chat objectForKey:@"content"];
        NSString* senderName = [chat objectForKey:@"senderName"];
        JSMessage* msg = [[JSMessage alloc] initWithText:txt sender:senderName date:[chat createdAt]];
        [messages addObject:msg];
    }
    
    [activityView stopAnimating];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scrollToBottomAnimated:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.tabBarController.tabBar setHidden:NO];
}

- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return messages.count;
}

- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date{
    [messages addObject:[[JSMessage alloc] initWithText:text sender:sender date:date]];
    
    PFObject* newChat = [PFObject objectWithClassName:@"Chat"];
    [newChat setObject: [PFUser currentUser] forKey: @"sender"];
    [newChat setObject: self.person forKey: @"receiver"];
    [newChat setObject: [[PFUser currentUser] objectForKey:@"profile"][@"name"] forKey:@"senderName"];
    [newChat setObject: [self.person objectForKey:@"profile"][@"name"] forKey:@"receiverName"];
    [newChat setObject:text forKey:@"content"];
    [newChat saveInBackground];
    
    PFQuery *find1 = [PFQuery queryWithClassName:@"Friend"];
    [find1 whereKey:@"from" equalTo: [PFUser currentUser].objectId];
    [find1 whereKey:@"to" equalTo: self.person.objectId];
    PFQuery *find2 = [PFQuery queryWithClassName:@"Friend"];
    [find2 whereKey:@"to" equalTo: [PFUser currentUser].objectId];
    [find2 whereKey:@"from" equalTo:self.person.objectId];
    PFQuery* updateFriend = [PFQuery orQueryWithSubqueries:@[find1, find2]];
    [updateFriend findObjectsInBackgroundWithBlock:^(NSArray* objects, NSError *err){
        if (updateFriend.countObjects == 0) {
            PFObject* obj = [PFObject objectWithClassName:@"Friend"];
            [obj setObject:[PFUser currentUser].objectId forKey:@"from"];
            [obj setObject:self.person.objectId forKey:@"to"];
            [obj saveInBackground];
        }
    }];
    
    [self finishSend];
    [self scrollToBottomAnimated:YES];
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath{
    // sent by me?
    JSMessage* msg = messages[indexPath.row];
    NSString* myName = [[PFUser currentUser] objectForKey:@"profile"][@"name"];
    if ([msg.sender isEqualToString:myName]) {
        return JSBubbleMessageTypeOutgoing;
    }
    return JSBubbleMessageTypeIncoming;
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self messageTypeForRowAtIndexPath:indexPath] == JSBubbleMessageTypeIncoming) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleLightGrayColor]];
    }
    
    return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                      color:[UIColor js_bubbleBlueColor]];
}

- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 3) {
        return NO;
    }
    return YES;
}

- (JSMessage *)messageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return messages[indexPath.row];
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender
{
    if ([((JSMessage*)messages[indexPath.row]).sender isEqualToString:[[PFUser currentUser] objectForKey:@"profile"][@"name"] ]) {
        return [[UIImageView alloc] initWithImage:self.myImage];
    }
    return [[UIImageView alloc] initWithImage:self.personImage];
}

- (BOOL)allowsPanToDismissKeyboard
{
    return YES;
}

- (BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

@end
