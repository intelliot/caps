//
//  PhotoAppAppDelegate.h
//  PhotoApp
//
//  Created by System Administrator on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WaitingViewController.h"

#define DOCUMENTS_PATH  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define QUOTE_FILE_PATH [NSString stringWithFormat:@"%@/quote.plist", DOCUMENTS_PATH]

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) WaitingViewController *mWaitingViewController;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSMutableArray *mQuoteArray;
@property (nonatomic, copy)   NSString *forcedUpdateURLString;
@property (nonatomic)         BOOL isValidForcedUpdateContent;

- (void)checkForcedAppUpdate;
- (void)getQueryList;
- (void)hideWaitingView;
+ (void)hideWaitingView;
+ (void)showWaitingView:(NSString *)waiting_label;

@end
