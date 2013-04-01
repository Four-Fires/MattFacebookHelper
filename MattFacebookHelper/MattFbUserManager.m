//
//  MattFbUserManager.m
//  MattFacebookHelper
//
//  Created by matthew on 2013-03-30.
//  Copyright (c) 2013 matthew. All rights reserved.
//

#import "MattFbUserManager.h"
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>

@interface MattFbUserManager ()
{
    NSMutableDictionary *_userDict;
    long _globalKey;
    int _currentUserIndex;
    NSDictionary<FBGraphUser> *_currentUser;
}

@end

@implementation MattFbUserManager

@synthesize userDict = _userDict;
@synthesize currentSession = _currentSession;
@synthesize currentUser = _currentUser;

- (id)init
{
    if (self = [super init])
    {
        _currentUserIndex = -1;
        
        // read _userDict from disk
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
        NSString *userDictPath = [libraryPath stringByAppendingPathComponent:@"FBUsers"];
        _userDict = [NSMutableDictionary dictionaryWithContentsOfFile:userDictPath];
        if (!_userDict) {
            _userDict = [NSMutableDictionary dictionary];
        }
        [_userDict retain];
        
        // load _globalKey from NSUserDefaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _globalKey = [[defaults objectForKey:@"FBUserGlobalKey"] intValue];
        
        if (_globalKey==0)
            _globalKey = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

- (FBSessionTokenCachingStrategy*)_cachingStrategyForUserKey:(int)key
{    
    NSString *tokenInfoKey = [NSString stringWithFormat:@"PVUserTokenInfo%d", key];
    NSLog(@"_cachingStrategyForUserKey with tokenInfoKey %@", tokenInfoKey);
    FBSessionTokenCachingStrategy *tokenCachingStrategy = [[[FBSessionTokenCachingStrategy alloc]
                                                           initWithUserDefaultTokenInformationKeyName:tokenInfoKey] autorelease];
    return tokenCachingStrategy;
}


- (FBSession*)_createSessionForUserKey:(int)key
{
    // FBSample logic
    // Getting the right strategy instance for the right slot matters for this application
    FBSessionTokenCachingStrategy *tokenCachingStrategy = [self _cachingStrategyForUserKey:key];
    
    // create a session object, with defaults accross the board, except that we provide a custom
    // instance of FBSessionTokenCachingStrategy
    FBSession *session = [[[FBSession alloc] initWithAppID:nil permissions:nil urlSchemeSuffix:nil tokenCacheStrategy:tokenCachingStrategy] autorelease];
    return session;
}

- (void)_clearFbCookie
{
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"facebook"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }
}

- (void)addNewUserWithSuccessBlock:(void(^)(void))sBlock andFailBlock:(void(^)(NSError*))fBlock
{
    [self logOutCurrentUser];
    [self _clearFbCookie];
    
//    FBSessionLoginBehavior behavior = ([_userDict count]==0)?FBSessionLoginBehaviorWithFallbackToWebView:FBSessionLoginBehaviorForcingWebView;
    FBSessionLoginBehavior behavior = FBSessionLoginBehaviorForcingWebView;
    
    _globalKey++;
    // write _globalKey into NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:_globalKey] forKey:@"FBUserGlobalKey"];
    [defaults synchronize];
    
    FBSession *session = [self _createSessionForUserKey:_globalKey];
    if (_currentSession && [_currentSession isOpen])
        [_currentSession closeAndClearTokenInformation];
    [_currentSession release];
    
    _currentSession = [session retain];
    [FBSession setActiveSession:session];
    
    [session openWithBehavior:behavior
            completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                // this handler is called back whether the login succeeds or fails; in the
                // success case it will also be called back upon each state transition between
                // session-open and session-close
                if (error)
                {
                    if (fBlock)
                        fBlock(error);
                }
                else
                {
                    if ([session isOpen])
                    {
                        FBRequest *me = [[FBRequest alloc] initWithSession:session graphPath:@"me"];
                        [me startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                            if (error)
                            {
                                if (fBlock)
                                    fBlock(error);
                            }
                            else
                            {
                                NSLog(@"%@", result);
                                
                                // write _userDict to disk
                                NSDictionary<FBGraphUser> *user = result;
                                NSString *newUserKey = [NSString stringWithFormat:@"%ld", _globalKey];
                                [_userDict setObject:user.name forKey:newUserKey];
                                
                                NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
                                NSString *userDictPath = [libraryPath stringByAppendingPathComponent:@"FBUsers"];
                                NSLog(@"write _userDict to file %@", [_userDict writeToFile:userDictPath atomically:YES]?@"succeeded":@"failed");

                                // set _currentUserIndex
                                _currentUserIndex = [[_userDict allKeys] indexOfObject:newUserKey];
                                
                                // set _currentUser
                                [_currentUser release];
                                _currentUser = [user retain];
                                
                                [[NSNotificationCenter defaultCenter] postNotificationName:MattFbUserManagerGotUserInfoNotification object:nil];
                                
                                if (sBlock)
                                    sBlock();
                            }
                        }];
                    }
//                    else
//                    {
//                        // TODO: to create and use a corresponding error here
//                        if (fBlock)
//                            fBlock(nil);
//                    }
                }
            }];
}

- (void)removeUserAtIndex:(int)index
{
    if (index == _currentUserIndex)
    {
        [self logOutCurrentUser];
    }
    
    NSString *keyOfUserToRemove = [[_userDict allKeys] objectAtIndex:index];
    [_userDict removeObjectForKey:keyOfUserToRemove];
    
    // write _userDict to disk
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    NSString *userDictPath = [libraryPath stringByAppendingPathComponent:@"FBUsers"];
    NSLog(@"write _userDict to file %@", [_userDict writeToFile:userDictPath atomically:YES]?@"succeeded":@"failed");
}

- (void)logInUserAtIndex:(int)index allowLoginUI:(BOOL)allowUI withSuccessBlock:(void(^)(void))sBlock andFailBlock:(void(^)(NSError*))fBlock
{
    [self logOutCurrentUser];
    
    FBSessionLoginBehavior behavior = FBSessionLoginBehaviorWithFallbackToWebView;

    NSString *keyOfUser = [[_userDict allKeys] objectAtIndex:index];
    FBSession *session = [self _createSessionForUserKey:[keyOfUser intValue]];
    
    if (_currentSession && [_currentSession isOpen])
        [_currentSession closeAndClearTokenInformation];
    [_currentSession release];
    _currentSession = [session retain];
    [FBSession setActiveSession:session];
    
//    [self _clearFbCookie];
    
    if (!allowUI && session.state!=FBSessionStateCreatedTokenLoaded)
        return;
    
    [session openWithBehavior:behavior
            completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                // this handler is called back whether the login succeeds or fails; in the
                // success case it will also be called back upon each state transition between
                // session-open and session-close
                if (error)
                {
                    if (fBlock)
                        fBlock(error);
                }
                else
                {
                    if ([session isOpen])
                    {
                        FBRequest *me = [[FBRequest alloc] initWithSession:session graphPath:@"me"];
                        [me startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
                        {
                            if (error)
                            {
                                if (fBlock)
                                    fBlock(error);
                            }
                            else
                            {
                                NSLog(@"%@", result);
                                
                                _currentUserIndex = index;
                                
                                NSDictionary<FBGraphUser> *user = result;
                                [_currentUser release];
                                _currentUser = [user retain];
                                
                                [[NSNotificationCenter defaultCenter] postNotificationName:MattFbUserManagerGotUserInfoNotification object:nil];
                                
                                if (sBlock)
                                    sBlock();
                            }
                        }];
                    }
//                    else
//                    {
//                        // TODO: to create and use a corresponding error here
//                        if (fBlock)
//                            fBlock(nil);
//                    }
                }
            }];
}

- (void)logOutCurrentUser
{
    [_currentSession closeAndClearTokenInformation];
    [_currentSession release];
    _currentSession = nil;
    [FBSession setActiveSession:nil];
    
    _currentUserIndex = -1;
    
    [_currentUser release];
    _currentUser = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MattFbUserManagerLoggedOutUserNotification object:nil];
}

- (int)loggedInUserIndex
{
    return _currentUserIndex;
}

@end
