//
//  FirstViewController.m
//  MattFacebookHelper
//
//  Created by matthew on 2013-03-27.
//  Copyright (c) 2013 matthew. All rights reserved.
//

#import "FirstViewController.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

@interface FirstViewController ()
{
    IBOutlet UIButton *_authButton;
    IBOutlet FBProfilePictureView *_profilePicView;
}

@end

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    

}

- (void)viewDidUnload
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
