//
//  UserDetailViewController.m
//  MattFacebookHelper
//
//  Created by matthew on 2013-03-31.
//  Copyright (c) 2013 matthew. All rights reserved.
//

#import "UserDetailViewController.h"
#import "AppDelegate.h"
#import "MattFbUserManager.h"

@interface UserDetailViewController ()
{
    NSDictionary<FBGraphUser> *_fbUser;
    MattFbUserManager *_fbUserManager;
    IBOutlet UIButton *_friendsPickerBtn;
    IBOutlet UIButton *_loginoutBtn;
}

@end

@implementation UserDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Account Detail", @"Detail");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbUserInfoUpdated) name:MattFbUserManagerGotUserInfoNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbUserInfoUpdated) name:MattFbUserManagerLoggedOutUserNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)fbUserInfoUpdated
{
    if (_fbUserManager.currentUser)
    {
        profilePicView.profileID = _fbUserManager.currentUser.id;
        nameLabel.text = _fbUserManager.currentUser.name;
        _friendsPickerBtn.enabled = YES;
    }
    else
    {
        profilePicView.profileID =  nil;
        nameLabel.text = @"user name";
        _friendsPickerBtn.enabled = NO;
    }
    [self _updateLoginoutBtnTitle];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (!_fbUserManager)
    {
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        _fbUserManager = appDelegate.fbUserManager;
    }
    
    [self fbUserInfoUpdated];
    [self _updateLoginoutBtnTitle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPickFriends:(id)sender
{
    FBFriendPickerViewController *friendPicker = [[FBFriendPickerViewController alloc] init];
    friendPicker.userID = _fbUserManager.currentUser.id;
    [friendPicker loadData];
    [friendPicker presentModallyFromViewController:self
                                          animated:YES
                                           handler:^(FBViewController *sender, BOOL donePressed) {
                                               if (donePressed) {
                                                   for (NSDictionary<FBGraphUser> *friend in friendPicker.selection)
                                                   {
                                                       NSLog(@"friend name: %@", friend.name);
                                                       NSLog(@"friend id: %@", friend.id);
                                                   }
                                               }
                                           }];
}

- (void)_updateLoginoutBtnTitle
{
    if (_fbUserManager.currentUser)
        [_loginoutBtn setTitle:@"Logout" forState:UIControlStateNormal];
    else
        [_loginoutBtn setTitle:@"Login" forState:UIControlStateNormal];
}

- (IBAction)onLoginoutBtn:(id)sender
{
    if (_fbUserManager.currentUser)
    {
//        [_fbUserManager logOutCurrentUser];
        [_fbUserManager removeUserAtIndex:[_fbUserManager loggedInUserIndex]];
        [self _updateLoginoutBtnTitle];
    }
    else
    {
        [_fbUserManager addNewUserWithSuccessBlock:^{
            [self _updateLoginoutBtnTitle];
        } andFailBlock:^(NSError *error) {
            [self _updateLoginoutBtnTitle];
        }];
    }
}

@end
