//
//  RenderViewController.h
//  PhotoApp
//
//  Created by System Administrator on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <Twitter/TWTweetComposeViewController.h>

@interface RenderViewController : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIGestureRecognizerDelegate>
{
    IBOutlet UIImageView    *mBackImageView;
    IBOutlet UILabel        *mOverlayLabel;
    IBOutlet UIToolbar      *mTopBar;
    IBOutlet UIToolbar      *mBottomBar;
}

- (IBAction)backButtonClicked:(id)sender;
- (IBAction)shareButtonClicked:(id)sender;

- (void)setBackImage : (UIImage *) image;
- (void)setRandomQuote;
- (UIImage *) getShareImage;

@end
