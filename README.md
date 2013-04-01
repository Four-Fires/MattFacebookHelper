MattFacebookHelper
==================

A helper class based on Facebook iOS SDK to make switching user happen.

SwitchUserSample came with the SDK does not quite work for me, and I saw quite a few stackoverflow threads talking about FB logout issue, so I'm just putting my work here hoping it may help others a little bit.

How to use
==================

1. Setup the project with Facebook (refer to http://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/).
2. Implement the callbacks(application:openURL:sourceApplication:annotation:, applicationDidBecomeActive: and applicationWillTerminate:) in application delegate (use AppDelegate here as an example). 
3. Alloc init a MattFbUserManager object and assign it to iVar of appDelegate in application:didFinishLaunchingWithOptions:.
4. Want it to automatically login the user from previous session, call logInUserAtIndex:0 allowLoginUI:NO withSuccessBlock:nil andFailBlock:nil on the MattFbUserManager iVar  in application:didFinishLaunchingWithOptions:.
5. Refer to SecondViewController for how to add new user, change user, logout user. Currently it's still single user, I tried to make it support multiple but seems when switching between sessions it can mess up, say you switched to the session of user A but are given the data of user B. I've seen this with Facebook's SwitchUserSample so it could be on Facebook side. So right now I'll just make the sample single user.
6. Refer to UserDetailViewController for how to catch the user switch and update UI.
