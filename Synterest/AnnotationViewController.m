//
//  AnnotationViewController.m
//  Synterest
//
//  Created by Chris Jones on 28/04/2014.
//  Copyright (c) 2014 Chris Jones. All rights reserved.
//

#import "AnnotationViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface AnnotationViewController ()
@property (weak, nonatomic) IBOutlet UITextView *eventTitle;
@property (weak, nonatomic) IBOutlet UILabel *eventDateLabel;

@end

@implementation AnnotationViewController

@synthesize eventTitleText,
eventDate,
eventFbImageView,
eventAdressTextView,
eventTitleScrollView,
eventDescriptionView,
eventDescription,
eventDescriptionTextView,
eventAddress,
eventFbPic,
eventTitle,
eventType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //load the eventTitle information into the UITextView
    eventTitle.text = eventTitleText;
    
    //Load a separate thread that pulls the facebook picture
    [NSThread detachNewThreadSelector:@selector(loadFacebookPicture) toTarget:self withObject:nil];
    
    //load the eventDescription information into the eventDescriptionTextView (UITextView)
    self.eventDescriptionTextView.text = eventDescription;
    
    //load the eventAddress information into the eventAddressTextView (UITextView)
    self.eventAdressTextView.text = eventAddress;
    
    //load the eventDate information
    self.eventDateLabel.text =eventDate;
}

-(void)loadFacebookPicture
{
    UIImage *facebookImage;
    if(eventFbPic == nil){
        //Add the synterest Image
        facebookImage = [UIImage imageNamed:@"logo_mini"];
    }
    else{
        //Add a subview Image of the facebook picture (from the URL)
        facebookImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:eventFbPic]]];
    }
    UIImageView *facebookImageSubView = [[UIImageView alloc] initWithImage:facebookImage];
    facebookImageSubView.layer.cornerRadius = facebookImage.size.width / 2;
    facebookImageSubView.layer.masksToBounds = YES;
    [self.eventFbImageView addSubview:facebookImageSubView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)clickOnGoBackAction:(id)sender
{
    [self performSegueWithIdentifier:@"go_back_from_annotation" sender:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
