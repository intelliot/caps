//
//  MainViewController.h
//  PhotoApp
//
//  Created by System Administrator on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifndef PRO
    #import <iAd/iAd.h>
#endif

@interface MainViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate
#ifndef PRO
    , ADBannerViewDelegate
#endif
>

@property BOOL bannerIsVisible;

- (IBAction)chooseButtonClicked:(id)sender;
- (IBAction)cameraButtonClicked:(id)sender;

@end
