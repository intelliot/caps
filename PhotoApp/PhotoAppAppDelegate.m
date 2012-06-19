//
//  PhotoAppAppDelegate.m
//  PhotoApp
//
//  Created by System Administrator on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoAppAppDelegate.h"
#import "MainViewController.h"

@implementation PhotoAppAppDelegate

@synthesize window = _window;
@synthesize mQuoteArray;
@synthesize mWaitingViewController;

- (void)dealloc
{
    [mQuoteArray release];
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self getQueryList];
    
    MainViewController *mainVc = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    [self.window addSubview:mainVc.view];
    
    self.mWaitingViewController = [[WaitingViewController alloc] initWithNibName:@"WaitingViewController" bundle:nil];
    
    [self.window makeKeyAndVisible];
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
    
    self.mQuoteArray = [NSMutableArray arrayWithArray:[temp objectForKey:@"Quote"]];

}

+ (void) showWaitingView:(NSString *)waiting_label {
	PhotoAppAppDelegate *appDelegate = (PhotoAppAppDelegate *)[[UIApplication sharedApplication] delegate];	
    
    UIView *parentView = [appDelegate.window.subviews objectAtIndex:0];
    [appDelegate.mWaitingViewController.view setFrame:parentView.bounds];
	[parentView addSubview:appDelegate.mWaitingViewController.view];
    
    [appDelegate.mWaitingViewController.waitingActivity startAnimating];
	[appDelegate.window setUserInteractionEnabled:NO];
}

+ (void) hideWaitingView {
	PhotoAppAppDelegate *appDelegate = (PhotoAppAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate hideWaitingView];
}

- (void) hideWaitingView {    
	[mWaitingViewController.view removeFromSuperview];
	[mWaitingViewController.waitingActivity stopAnimating];
	[self.window setUserInteractionEnabled:YES];
}


@end
