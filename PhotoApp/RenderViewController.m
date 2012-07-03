//
//  RenderViewController.m
//  PhotoApp
//
//  Created by System Administrator on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RenderViewController.h"
#import "PhotoAppAppDelegate.h"
#import "FlurryAPI+Extensions.h"

@implementation RenderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    mTopBar.alpha = 0.0;
    mBottomBar.alpha = 0.0;
    
    UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)] autorelease];
    [tapGesture setNumberOfTapsRequired:1];
    [tapGesture setDelegate:self];
    [mBackImageView addGestureRecognizer:tapGesture];
    
    mOverlayLabel.layer.shadowOffset = CGSizeMake(1, 1);
    mOverlayLabel.layer.shadowRadius = 2;
    mOverlayLabel.layer.shadowOpacity = 1;
    mOverlayLabel.layer.masksToBounds = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [mBackImageView release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) tapped : (id) sender
{
    [UIView beginAnimations:nil context:Nil];
    [UIView setAnimationDuration:.5];
    
    if ( mTopBar.alpha == 0.0 || mBottomBar.alpha == 0.0 ) {
        mTopBar.alpha = 1.0;
        mBottomBar.alpha = 1.0;
    } else {
        mTopBar.alpha = 0.0;
        mBottomBar.alpha = 0.0;
    }
    
    [UIView commitAnimations];
}

- (IBAction)backButtonClicked:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#define kSaveToLibrary @"Save to Library"
#define kTweet @"Tweet"
#define kMail @"Mail"

//- (IBAction)shareButtonClicked:(id)sender
//{
//    UIActionSheet *action;
//    
//    if (NSClassFromString(@"TWTweetComposeViewController") == nil) {
//        action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:kSaveToLibrary, kMail, nil];
//    } else {
//        action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:kSaveToLibrary, kTweet, kMail, nil];
//    }
//    
//    [action showInView:self.view];
//    [action release];
//}

- (IBAction)saveTapped:(id)sender
{
    UIImage * image = [self getShareImage];
    [PhotoAppAppDelegate showWaitingView:@""];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    NSDictionary *quoteParameters = [NSDictionary dictionaryWithObjectsAndKeys:mOverlayLabel.text, @"Quote", nil];
    LOG_EVENT_PARAMS(@"SaveToLibrary", quoteParameters);
}

- (IBAction)tweetTapped:(id)sender {
    if (NSClassFromString(@"TWTweetComposeViewController") == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Supported" message:@"Tweet requires iOS 5 or higher" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else
    {
        [self shareViaTwitter];
        
        NSDictionary *quoteParameters = [NSDictionary dictionaryWithObjectsAndKeys:mOverlayLabel.text, @"Quote", nil];
        LOG_EVENT_PARAMS(@"Tweet", quoteParameters);
    }
}

- (IBAction)mailTapped:(id)sender
{
    [self shareViaEmail];
    
    NSDictionary *quoteParameters = [NSDictionary dictionaryWithObjectsAndKeys:mOverlayLabel.text, @"Quote", nil];
    LOG_EVENT_PARAMS(@"Mail", quoteParameters);
}

#pragma mark User definitive function

- (void)setBackImage : (UIImage *) image : (BOOL) overed
{
    mBackImageView.image = image;
    
	CGSize maxSize = CGSizeMake(290, MAXFLOAT);
	CGSize newSize = [mOverlayLabel.text sizeWithFont:mOverlayLabel.font
									   constrainedToSize:maxSize
										   lineBreakMode:mOverlayLabel.lineBreakMode];
	
	mOverlayLabel.frame = CGRectMake(mOverlayLabel.frame.origin.x,
										mOverlayLabel.frame.origin.y,
										newSize.width,
										newSize.height);
    
    if ( overed == YES ) {
        
        mOverlayLabel.frame = CGRectMake(15, 400 - mOverlayLabel.frame.size.height, 290, mOverlayLabel.frame.size.height);

        
    } else {

        mOverlayLabel.frame = CGRectMake(15, self.view.frame.size.height / 2 + image.size.height / 2 - mOverlayLabel.frame.size.height, 290, mOverlayLabel.frame.size.height);

        
    }
    
    
//    mOverlayLabel.frame = CGRectMake(15, self.view.frame.size.height / 2 + image.size.height / 5, mOverlayLabel.frame.size.width, mOverlayLabel.frame.size.height);
}

- (void)setRandomQuote {
    
    PhotoAppAppDelegate *appDelegate = (PhotoAppAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    NSInteger nCount = [appDelegate.mQuoteArray count];
    
    NSInteger randIndex = arc4random() % nCount;
    
    NSString *quote = [appDelegate.mQuoteArray objectAtIndex:randIndex];
    
    mOverlayLabel.text = quote;
}

- (UIImage *) getShareImage
{   
    [mTopBar setHidden:YES];
    [mBottomBar setHidden:YES];

    CGFloat width, height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    width = (CGFloat)self.view.bounds.size.width * scale;
    height = (CGFloat)460.0 * scale;
    
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, width * 8, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGContextScaleCTM(context, scale, scale);
    CGColorSpaceRelease(colorSpace);
    
    CGContextClipToRect(context, CGRectMake(0, 0, width, height));
    
    CGAffineTransform flipVertical;
    
    flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, 460.0);
    
    CGContextConcatCTM(context, flipVertical);
    
    [self.view.layer setContentsScale:scale];
    [self.view.layer renderInContext:context];
    
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    [mTopBar setHidden:NO];
    [mBottomBar setHidden:NO];
    
    UIImage *_image = [[UIImage alloc] initWithCGImage:image];
    return _image;
}

- (void) imageSaveCompleted {
    
}

- (void) shareViaEmail {
    
    UIImage *image = [self getShareImage];
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    
    if( picker == nil )
    {
        // No Mail Accounts
        return;
    }
    
    picker.mailComposeDelegate = self;
    
    [picker setSubject:[NSString stringWithFormat:@""]];
	[picker setMessageBody:@"" isHTML:YES];
    
    NSData *myData = UIImageJPEGRepresentation(image, 1.0);
    
    [picker addAttachmentData:myData mimeType:@"image/jpg" fileName:@"pic"];
    
    [self presentModalViewController:picker animated:YES];
    [picker release];

}

- (void) shareViaTwitter {

    TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
    
    [twitter setInitialText:@"#CleanCaps"];
    
    
    UIImage *tempImage = [self getShareImage];
    
    [twitter addImage:tempImage];
    
    [twitter addURL:[NSURL URLWithString:@""]];
    
    [self presentViewController:twitter animated:YES completion:nil];
    
    twitter.completionHandler = ^(TWTweetComposeViewControllerResult res) {
        
        if(res == TWTweetComposeViewControllerResultDone)
        {
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Tweet posted" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
            
            [self dismissModalViewControllerAnimated:YES];
            
        }else if(res == TWTweetComposeViewControllerResultCancelled)
        {
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Tweet not posted" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
        }
        [self dismissModalViewControllerAnimated:YES];
    };

    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo
{
    [PhotoAppAppDelegate hideWaitingView];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Saved to Library" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

//#pragma mark UIActionSheet Delegate
//
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    NSString *button = [actionSheet buttonTitleAtIndex:buttonIndex];
//    
//    if ([button isEqualToString:kSaveToLibrary]) {
//        
//        UIImage * image = [self getShareImage];
//        
//        [PhotoAppAppDelegate showWaitingView:@""];
//        
//        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
//        
//        LOG_EVENT(@"SaveToLibrary");
//        
//    } else if ([button isEqualToString:kTweet]) {
//        
//        [self shareViaTwitter];
//        
//        LOG_EVENT(@"Tweet");
//        
//    } else if ([button isEqualToString:kMail]) {
//        
//        [self shareViaEmail];
//        
//        LOG_EVENT(@"Mail");
//    }
//}

#pragma mark MFMailComposeView Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{

	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			//flagFromPicker = TRUE;
			//[HaikuAppDelegate showAlertTitle:@"Result" message:@"Mail sending canceled."];			
			break;
		case MFMailComposeResultSaved: {
			UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"Result: Mail Saved" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			break;
		}
		case MFMailComposeResultSent: {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"Mail sent" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			break;
		}
		case MFMailComposeResultFailed: {
			UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"Result: Mail sending failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			break;
		}
		default: {
			UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"Result: Mail Not Sent" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			break;
		}
	}
    
	[self dismissModalViewControllerAnimated:YES];
}


@end
