//
//  WaitingViewController.h
//  NewsGTA5
//
//  Created by System Administrator on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaitingViewController : UIViewController
{
    UIActivityIndicatorView *waitingActivity;
}
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *waitingActivity;
@end
