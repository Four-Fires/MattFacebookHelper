//
//  AppDelegate.h
//  MattFacebookHelper
//
//  Created by matthew on 2013-03-27.
//  Copyright (c) 2013 matthew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MattFbUserManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>
{
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property (nonatomic, retain) MattFbUserManager *fbUserManager;

@end
