//
//  UserDetailViewController.h
//  MattFacebookHelper
//
//  Created by matthew on 2013-03-31.
//  Copyright (c) 2013 matthew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface UserDetailViewController : UIViewController
{
    IBOutlet FBProfilePictureView *profilePicView;
    IBOutlet UILabel *nameLabel;
}

@end
