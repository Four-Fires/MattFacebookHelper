//
//  MattFbUserManager.h
//  MattFacebookHelper
//
//  Created by matthew on 2013-03-30.
//  Copyright (c) 2013 matthew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

#define MattFbUserManagerGotUserInfoNotification    @"com.matthewli.mattfbusermananger.gotuserinfo"
#define MattFbUserManagerLoggedOutUserNotification    @"com.matthewli.mattfbusermananger.userloggedout"

@interface MattFbUserManager : NSObject
{
    NSDictionary<FBGraphUser>* delegate;
}

- (void)addNewUserWithSuccessBlock:(void(^)(void))sBlock andFailBlock:(void(^)(NSError*))fBlock;
- (void)removeUserAtIndex:(int)index;
- (void)logInUserAtIndex:(int)index allowLoginUI:(BOOL)allowUI withSuccessBlock:(void(^)(void))sBlock andFailBlock:(void(^)(NSError*))fBlock;
- (void)logOutCurrentUser;
- (int)loggedInUserIndex;

@property (nonatomic, readonly) NSMutableDictionary *userDict;
@property (nonatomic, readonly) FBSession *currentSession;
@property (nonatomic, retain) NSDictionary<FBGraphUser> *currentUser;

@end
