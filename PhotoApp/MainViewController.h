//
//  MainViewController.h
//  PhotoApp
//
//  Created by System Administrator on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (IBAction)chooseButtonClicked:(id)sender;
- (IBAction)cameraButtonClicked:(id)sender;

@end
