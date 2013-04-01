//
//  AppDelegate.m
//  MattFacebookHelper
//
//  Created by matthew on 2013-03-27.
//  Copyright (c) 2013 matthew. All rights reserved.
//

#import "AppDelegate.h"
#import "FirstViewController.h"
#import "UserDetailViewController.h"
#import "SecondViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation AppDelegate

@synthesize fbUserManager = _fbUserManager;

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

/*
 * If we have a valid session at the time of openURL call, we handle
 * Facebook transitions by passing the url argument to handleOpenURL
 */
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // attempt to extract a token from the url
    
    if (_fbUserManager.currentSession)
        return [_fbUserManager.currentSession handleOpenURL:url];
    else
        return [FBSession.activeSession handleOpenURL:url];
    
//    return [FBSession.activeSession handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FBLoginView class];
    [FBProfilePictureView class];
    
    _fbUserManager = [[MattFbUserManager alloc] init];
    if ([_fbUserManager.userDict count]>0)
        [_fbUserManager logInUserAtIndex:0 allowLoginUI:NO withSuccessBlock:nil andFailBlock:nil];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    UIViewController *viewController1, *viewController2, *viewController3;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        viewController1 = [[[FirstViewController alloc] initWithNibName:@"FirstViewController_iPhone" bundle:nil] autorelease];
        viewController2 = [[[UserDetailViewController alloc] initWithNibName:@"UserDetailViewController" bundle:nil] autorelease];
        viewController3 = [[[SecondViewController alloc] initWithNibName:@"SecondViewController_iPhone" bundle:nil] autorelease];
    } else {
        viewController1 = [[[FirstViewController alloc] initWithNibName:@"FirstViewController_iPad" bundle:nil] autorelease];
        viewController2 = [[[UserDetailViewController alloc] initWithNibName:@"UserDetailViewController" bundle:nil] autorelease];
        viewController3 = [[[SecondViewController alloc] initWithNibName:@"SecondViewController_iPad" bundle:nil] autorelease];
    }
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = @[viewController2, viewController3];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // We need to properly handle activation of the application with regards to Facebook Login
    // (e.g., returning from iOS 6.0 Login Dialog or from fast app switching).
    
    if (_fbUserManager.currentSession)
        [_fbUserManager.currentSession handleDidBecomeActive];
    
//    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    if (_fbUserManager.currentSession)
        [_fbUserManager.currentSession close];
        
//    [FBSession.activeSession close];
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
