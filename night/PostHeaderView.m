//
//  PostHeaderView.m
//  night
//
//  Created by Yan Wen on 4/17/14.
//  Copyright (c) 2014 Yan Wen. All rights reserved.
//

#import "PostHeaderView.h"
#import <Parse/Parse.h>

@interface PostHeaderView ()
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) PFImageView *avatarImageView;
@property (nonatomic, strong) UIButton *userButton;
@end

@implementation PostHeaderView{
    PFObject* pushObject;
}

@synthesize containerView;
@synthesize avatarImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.containerView.clipsToBounds = NO;
        self.superview.clipsToBounds = NO;
        [self setBackgroundColor:[UIColor clearColor]];
        
        // translucent portion
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake( 20.0f, 0.0f, self.bounds.size.width - 20.0f * 2.0f, self.bounds.size.height)];
        [self addSubview:self.containerView];
        //[self.containerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundComments.png"]]];
        
        self.avatarImageView = [[PFImageView alloc] init];
        self.avatarImageView.frame = CGRectMake( 4.0f, 4.0f, 35.0f, 35.0f);
        [self.containerView addSubview:self.avatarImageView];
        
        CALayer *layer = [containerView layer];
        layer.backgroundColor = [[UIColor whiteColor] CGColor];
        layer.masksToBounds = NO;
        layer.shadowRadius = 1.0f;
        layer.shadowOffset = CGSizeMake( 0.0f, 2.0f);
        layer.shadowOpacity = 0.5f;
        layer.shouldRasterize = YES;
        layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake( 0.0f, containerView.frame.size.height - 4.0f, containerView.frame.size.width, 4.0f)].CGPath;
        
        self.userButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [containerView addSubview:self.userButton];
        [self.userButton setBackgroundColor:[UIColor clearColor]];
        [[self.userButton titleLabel] setFont:[UIFont boldSystemFontOfSize:15]];
        [self.userButton setTitleColor:[UIColor colorWithRed:73.0f/255.0f green:55.0f/255.0f blue:35.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [self.userButton setTitleColor:[UIColor colorWithRed:134.0f/255.0f green:100.0f/255.0f blue:65.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
        [[self.userButton titleLabel] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[self.userButton titleLabel] setShadowOffset:CGSizeMake( 0.0f, 1.0f)];
        [self.userButton setTitleShadowColor:[UIColor colorWithWhite:1.0f alpha:0.750f] forState:UIControlStateNormal];
        [[self.userButton titleLabel] setText:@"fffffsdfasdfsd"];
    }
    return self;
}

-(void) setPushObject:(PFObject *)object{
    pushObject = object;
    PFUser* u = [object objectForKey:@"owner"];
    [u fetchIfNeededInBackgroundWithBlock:^(PFObject* user, NSError *error){
        NSString* authorName = [user objectForKey:@"profile"] [@"name"];
        self.avatarImageView.file = [user objectForKey:@"profileImage"];
        [self.avatarImageView loadInBackground];
        [self.userButton setTitle:authorName forState:UIControlStateNormal];
        CGFloat constrainWidth = containerView.bounds.size.width;
        CGPoint userButtonPoint = CGPointMake(50.0f, 6.0f);
        constrainWidth -= userButtonPoint.x;
        CGSize constrainSize = CGSizeMake(constrainWidth, containerView.bounds.size.height - userButtonPoint.y*2.0f);
        CGSize userButtonSize = [self.userButton.titleLabel.text boundingRectWithSize:constrainSize
                                                                              options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                                                           attributes:@{NSFontAttributeName:self.userButton.titleLabel.font}
                                                                              context:nil].size;
        CGRect userButtonFrame = CGRectMake(userButtonPoint.x, userButtonPoint.y, userButtonSize.width, userButtonSize.height);
        [self.userButton setFrame:userButtonFrame];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
