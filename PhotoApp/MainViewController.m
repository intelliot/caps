//
//  MainViewController.m
//  PhotoApp
//
//  Created by System Administrator on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "RenderViewController.h"
#import "FlurryAPI+Extensions.h"

@implementation MainViewController

@synthesize bannerIsVisible;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        if (NSClassFromString(@"ADBannerView")) {
            ADBannerView *adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 50)];
            self.bannerIsVisible = NO;
            adView.delegate = self;
            adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
            [self.view addSubview:adView];
            LOG_EVENT(@"iAd");
        } else{
            LOG_EVENT(@"No iAd");
        }
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    BOOL shouldExecuteAction = YES; //[self allowActionToRun]; // your application implements this method
    if (!willLeave && shouldExecuteAction)
    {
        // insert code here to suspend any services that might conflict with the advertisement
    }
    return shouldExecuteAction;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner {
    
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        // Assumes the banner view is just off the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        [UIView commitAnimations];
        self.bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (self.bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // Assumes the banner view is placed at the bottom of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        [UIView commitAnimations];
        self.bannerIsVisible = NO;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)chooseButtonClicked:(id)sender
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];                
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.navigationBar.barStyle = UIBarStyleBlack;
        picker.delegate = self;
        [self presentModalViewController:picker animated:YES];
        
        LOG_EVENT(@"PhotoLibrary");
    } else {
        LOG_EVENT(@"PhotoLibraryNotAvailable");
    }
}

- (IBAction)cameraButtonClicked:(id)sender
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.navigationBar.barStyle = UIBarStyleBlack;                
        picker.delegate = self;
        picker.allowsEditing = NO;
        [self presentModalViewController:picker animated:YES];
        [picker release];
        
        LOG_EVENT(@"Camera");
    }
    else {
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Camera Unavailable" message:@"Your device must have a camera to use this function." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        [alert release];
        
        LOG_EVENT(@"CameraNotAvailable");
    }
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    UIImage *capturedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    RenderViewController *renderVc = [[RenderViewController alloc] initWithNibName:@"RenderViewController" bundle:nil];
    
    [picker presentModalViewController:renderVc animated:YES];
    [renderVc setRandomQuote];
    
    if ( picker.sourceType == UIImagePickerControllerSourceTypeCamera ) {
        if ( capturedImage.size.height > 480 ) {
            [renderVc setBackImage:capturedImage :YES];
        } else {
            [renderVc setBackImage:capturedImage :NO];
        }
    } else {
        if ( capturedImage.size.height > 480 ) {
            [renderVc setBackImage:capturedImage :YES];
        } else {
            [renderVc setBackImage:capturedImage :NO];
        }
    }
    
    [renderVc release];
    

    //    imgCigarView.image = capturedImage;
    
    LOG_EVENT(@"didFinishPickingMedia");
}

@end
