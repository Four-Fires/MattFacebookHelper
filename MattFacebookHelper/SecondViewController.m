//
//  SecondViewController.m
//  MattFacebookHelper
//
//  Created by matthew on 2013-03-27.
//  Copyright (c) 2013 matthew. All rights reserved.
//

#import "SecondViewController.h"
#import "MattFbUserManager.h"
#import "AppDelegate.h"

@interface SecondViewController () <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *_userTableView;
    MattFbUserManager *_fbUserManager;
    IBOutlet UIBarButtonItem *_barButton;
}

@end

@implementation SecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Account Setting", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        
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
    [_userTableView reloadData];
    [self _updateBarButtonTitle];
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if (!_fbUserManager)
    {
        AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        _fbUserManager = appDelegate.fbUserManager;
    }
    [self _updateBarButtonTitle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_onAddBtn:(id)sender
{
    [_fbUserManager addNewUserWithSuccessBlock:^{
        [_userTableView reloadData];
        [self _updateBarButtonTitle];
    } andFailBlock:^(NSError *error) {
        [_userTableView reloadData];
        [self _updateBarButtonTitle];
    }];
}

- (IBAction)_onChangeUserBtn:(id)sender
{
    int numOfUsers = [_fbUserManager.userDict count];
    
    for (int i=0; i<numOfUsers; i++)
        [_fbUserManager removeUserAtIndex:0];
    
    [_fbUserManager addNewUserWithSuccessBlock:^{
        [_userTableView reloadData];
        [self _updateBarButtonTitle];
    } andFailBlock:^(NSError *error) {
        [_userTableView reloadData];
        [self _updateBarButtonTitle];
    }];
}

- (void)_updateBarButtonTitle
{
    if ([_userTableView numberOfRowsInSection:0] == 0)
        _barButton.title = @"Add User";
    else
        _barButton.title = @"Change User";
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_fbUserManager.userDict count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72.0;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        [cell.contentView addSubview:[[[NSBundle mainBundle] loadNibNamed:@"UserTableCell" owner:nil options:nil] lastObject]];
    }
    
    // TODO: not sure why sometimes tableView:numberOfRowsInSection: and tableView:cellForRowAtIndexPath: are not called in the
    // same loop and may cause crash (reproducable by login on UserDetailVC, goto SecondVC, go back, logout, goto SecondVC again,
    // it'll crash). don't have time for it right now, so here's just a quick workaround
    if ([_fbUserManager.userDict count]==0)
    {
        double delayInSeconds = 0.05;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [tableView reloadData];
            [self _updateBarButtonTitle];
        });
        return cell;
    }
    NSNumber *key = [[_fbUserManager.userDict allKeys] objectAtIndex:indexPath.row];
    if (key==nil)
        return cell;
    
    UILabel *titleLabel = (UILabel*)[cell.contentView viewWithTag:998];
    if (titleLabel) {
        titleLabel.text = [_fbUserManager.userDict objectForKey:key];
        
        if (indexPath.row == [_fbUserManager loggedInUserIndex] && _fbUserManager.currentUser) {
            titleLabel.text = _fbUserManager.currentUser.name;
        }
    }
    
    if (indexPath.row == [_fbUserManager loggedInUserIndex])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    FBProfilePictureView *picView = (FBProfilePictureView*)[cell.contentView viewWithTag:999];
    if (indexPath.row == [_fbUserManager loggedInUserIndex])
    {
        if (picView.profileID != _fbUserManager.currentUser.id)
            picView.profileID = _fbUserManager.currentUser.id;
    }
    else
        picView.profileID = nil;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		[_fbUserManager removeUserAtIndex:indexPath.row];
        [_userTableView reloadData];
        [self _updateBarButtonTitle];
    }
}


#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_fbUserManager loggedInUserIndex] == indexPath.row)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Log out facebook account %@?", _fbUserManager.currentUser.name] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert show];
        [alert release];
    }
    else
    {
        [_fbUserManager logInUserAtIndex:indexPath.row allowLoginUI:YES withSuccessBlock:^{
            [tableView reloadData];
            [self _updateBarButtonTitle];

        } andFailBlock:^(NSError *error) {
            [tableView reloadData];
            [self _updateBarButtonTitle];

        }];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=alertView.cancelButtonIndex)
    {
        [_fbUserManager removeUserAtIndex:0];
        [_userTableView reloadData];
        [self _updateBarButtonTitle];
    }
}


@end
