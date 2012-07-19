//
//  OptionalOrForcedUpdate.m
//  PhotoApp
//
//  Created by Elliot Michael Lee on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OptionalOrForcedUpdate.h"

@implementation OptionalOrForcedUpdate

static BOOL isValidForcedUpdateContent;
static NSString *forcedUpdateURLString;

+ (void)start
{
    // see +initialize, which is called automatically when +start is called
}

+ (void)checkForAppUpdate
{
    NSString *currAppVer = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSString *updateCheckUrl = [NSString stringWithFormat:@"http://www.greengar.info/updates/%@%@.txt", bundleID, currAppVer];
    
    DLog(@"%@", updateCheckUrl);
    
    // we need to use NSURLRequestReloadIgnoringLocalCacheData to prevent invalid or old data from being used!
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:updateCheckUrl]
                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                          timeoutInterval:60.0];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
    [conn release];
}

+ (void)initialize
{
    [self checkForAppUpdate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkForAppUpdate) name:UIApplicationWillEnterForegroundNotification object:nil];
}

// This SHOULD be called 2nd
+ (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    DLog(@"data received");
    if (isValidForcedUpdateContent)
    {
        forcedUpdateURLString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        // WARNING: make sure this URL string does not have any newlines in it,
        //          or the openURL: call won't work! (it will do nothing)
        DLog(@" ------------- FORCE APP UPDATE URL: %@", forcedUpdateURLString);
        
        // If we want to check that the user is on the menu screen, use:
        //   if (self.rootViewController.mainViewController.view.superview)
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Free Update" message:@"A new version of this app has been released. You should update to continue." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        // TODO: split test other button titles
        [alert show];
        [alert release];
    }
}

#pragma mark -
#pragma mark NSURLConnection Delegate Methods

// This is called 1st
+ (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        int status = [httpResponse statusCode];
        
        if (status/100 != 2)
        {
            // cancel the connection. we got what we want from the response,
            // no need to download the response data.
            [connection cancel];
            isValidForcedUpdateContent = NO;
            DLog(@"received status %d (NOT VALID)", status);
        }
        else
        {
            isValidForcedUpdateContent = YES;
            DLog(@"received status %d (valid)", status);
        }
    }
}

+ (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:BUTTON_TITLE_YES]) {
    //        LOG_EVENT(@"PlayBT2");
    //        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:BT2_URL_SCHEME]];
    //    } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:BUTTON_TITLE_NO]) {
    //        LOG_EVENT(@"PlayBT1");
    //        // do nothing
    //    } else {
    
    if ([alertView firstOtherButtonIndex] == buttonIndex)
    {
        if (forcedUpdateURLString)
        {
            DLog(@"forced update url %@", forcedUpdateURLString);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:forcedUpdateURLString]];
        }
    }
    
    //    }
}

@end
