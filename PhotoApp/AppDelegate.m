//
//  PhotoAppAppDelegate.m
//  PhotoApp
//
//  Created by System Administrator on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "FlurryAnalytics.h"

#if PRO
    #define quoteFile (@"quotePro")
#else
    #define quoteFile (@"quote")
#endif

#define checkIntervalSeconds (60*60*12)

@implementation AppDelegate

@synthesize window = _window;
@synthesize mQuoteArray;
@synthesize mWaitingViewController;
@synthesize forcedUpdateURLString;
@synthesize isValidForcedUpdateContent;

- (void)dealloc
{
    [mQuoteArray release];
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FlurryAnalytics startSession:@"6XN3TBYBZBJSVYJZNH97"];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
    self.window.clipsToBounds = NO;
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self getQueryList];
    
    MainViewController *mainVc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    [self.window addSubview:mainVc.view];
    
    self.mWaitingViewController = [[WaitingViewController alloc] initWithNibName:@"WaitingViewController" bundle:nil];
    
    [self.window makeKeyAndVisible];
    
    [self checkForcedAppUpdate];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    [self checkForcedAppUpdate];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)getQueryList
{   
    
    NSString *filepath = [[NSBundle mainBundle] pathForResource:quoteFile ofType:@"txt"];
    NSString *quoteStr = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];

    self.mQuoteArray = (NSMutableArray *) [quoteStr componentsSeparatedByString:@"\n"];
    /*
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"quote.plist"];
    
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:plistPath] )
    {
        plistPath = [[NSBundle mainBundle] pathForResource:@"quote" ofType:@"plist"];
    }
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSDictionary *temp = (NSDictionary *) [NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
     */
    
//    self.mQuoteArray = [NSMutableArray arrayWithArray:[temp objectForKey:@"Quote"]];

}

+ (void) showWaitingView:(NSString *)waiting_label {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];	
    
    UIView *parentView = [appDelegate.window.subviews objectAtIndex:0];
    [appDelegate.mWaitingViewController.view setFrame:parentView.bounds];
	[parentView addSubview:appDelegate.mWaitingViewController.view];
    
    [appDelegate.mWaitingViewController.waitingActivity startAnimating];
	[appDelegate.window setUserInteractionEnabled:NO];
}

+ (void) hideWaitingView {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideWaitingView];
}

- (void) hideWaitingView {    
	[mWaitingViewController.view removeFromSuperview];
	[mWaitingViewController.waitingActivity stopAnimating];
	[self.window setUserInteractionEnabled:YES];
}

- (void)checkForcedAppUpdate
{
    // only check at most once every 12 hours
    // relieves some strain on my server, yet makes it likely that the user will see the alert quickly
    // also enables hits to be spread out over a timeframe, so that I have time to analyze split test results
    
    NSString *currAppVer = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *key = [NSString stringWithFormat:@"%@%@lastCheckTime", bundleID, currAppVer];
    double lastCheckTime = [[NSUserDefaults standardUserDefaults] doubleForKey:key];
    double time = [NSDate timeIntervalSinceReferenceDate];
    if (time - lastCheckTime > checkIntervalSeconds) {
        NSString *updateCheckUrl = [NSString stringWithFormat:@"http://www.greengar.info/updates/%@%@.php", bundleID, currAppVer];
        // example: http://www.greengar.info/updates/com.tinyterabyte.cleancaps1.2.php
        // we're using PHP so we can split test and track hits
        
        // we need to use NSURLRequestReloadIgnoringLocalCacheData to prevent invalid or old data from being used!
        NSURLRequest *theRequest =
        [NSURLRequest requestWithURL:
         [NSURL URLWithString:updateCheckUrl]
                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                     timeoutInterval:60.0];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:YES];
        [conn release];
        
        [[NSUserDefaults standardUserDefaults] setDouble:time forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark -
#pragma mark NSURLConnection Delegate Methods

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        int status = [httpResponse statusCode];
        if (status/100 != 2) {
            // cancel the connection. we got what we want from the response,
            // no need to download the response data.
            [connection cancel];
            self.isValidForcedUpdateContent = NO;
        } else {
            self.isValidForcedUpdateContent = YES;
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // format:
    //  - alert title
    //  - alert message
    //  - alert cancel button title
    //  - alert other button title
    //  - destination URL
    // this enables split testing
    NSArray *components = [response componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    // exclude empty strings from components
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:5];
    for (NSString *component in components) {
        if ([component isEqualToString:@""] == NO && component != nil) {
            [array addObject:component];
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[array objectAtIndex:0] message:[array objectAtIndex:1] delegate:self cancelButtonTitle:[array objectAtIndex:2] otherButtonTitles:[array objectAtIndex:3], nil];
    [alert show];
    [alert release];
    self.forcedUpdateURLString = [array objectAtIndex:4];
    
    // track with Flurry
    // (can also track on the server side)
    [FlurryAnalytics logEvent:@"showed alert" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[array objectAtIndex:0], @"title", [array objectAtIndex:4], @"URL", nil]];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.firstOtherButtonIndex == buttonIndex) {
        if (self.forcedUpdateURLString) {
            NSLog(@"forced update url %@", self.forcedUpdateURLString);
            [FlurryAnalytics logEvent:@"clicked alert" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.forcedUpdateURLString, @"URL", nil]];
            [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:forcedUpdateURLString]];
        }
    }
}

@end
