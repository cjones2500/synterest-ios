//
//  ViewController.m
//  Synterest
//
//  Created by Chris Jones on 12/04/2014.
//  Copyright (c) 2014 Chris Jones. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <AddressBook/AddressBook.h>
#import <MapKit/MapKit.h>
#import "MyLocation.h"
#import "SynterestModel.h"
#import <CoreLocation/CoreLocation.h>
#import "SearchViewController.h"
#import <EventKit/EventKit.h>

@interface ViewController ()



@property (strong, nonatomic) IBOutlet UIButton *buttonLoginLogout;
@property (weak, nonatomic) IBOutlet UIButton *quitButton;
@property (strong, nonatomic) NSMutableDictionary *placeDictionary;

- (IBAction)buttonClickHandler:(id)sender;
- (void)updateView;
- (void)queryButtonAction;
- (IBAction)quitButtonAction:(id)sender;
- (IBAction)goToLocationAction:(id)sender;

@end

//#define METERS_PER_MILE 1609.344
#define METERS_PER_MILE 10000.0
#define MAXIMUM_NUMBER_ANNOTATIONS 3000


@implementation ViewController{
    BOOL finishedLoadingExtraData;
    BOOL stopExtraFacebookDataFlag;
    BOOL firstLoad;
    BOOL hasInitialFacebookDataBeenSource;
    BOOL datePickerIsOpen;
    BOOL todayIsActive;
    BOOL tomorrowIsActive;
    BOOL customDateIsActive;
    BOOL firstDisplayOfEventPicker;
    BOOL userTriggerRefresh;
    BOOL anotherSearchInProgress;
    BOOL userChosenLocation;
    BOOL accessToCalenderGranted;
    NSDate *currentSelectedEventPickerDate;
}

@synthesize facebookData,
currentCity,
dataToLoadToAnnotationView,
loadFacebookDataFlag,
backFromSearch,
additionalFacebookData,
firstViewFlag,
loadingDataWheel,
sideBarActivationState;
@synthesize locationManager = _locationManager;
@synthesize zoomLocation = _zoomLocation;
@synthesize locationToSend = _locationToSend;


-(id)init
{
    self = [super init];
    return self;
}

- (void) stopExtraFacebookData{
    anotherSearchInProgress = YES;
    stopExtraFacebookDataFlag = YES;
}

-(IBAction)goBackFromAnnotationViewAction:(id)sender
{
    [self hideAnnotationView];
}

-(void)moveToCalender
{
    [self performSegueWithIdentifier:@"move_to_calender" sender:self];
}

- (void)showEventPicker
{
    [self.view insertSubview:self.eventDatePicker atIndex:5];
}

-(void)hideEventPicker
{
    [self.view insertSubview:self.eventDatePicker atIndex:-1];
}

-(void) setInitialLocationIfNull
{
    locationToZoom.latitude = 51.50722;
    locationToZoom.longitude = -0.12750;
}

//displays information about the date on the datepicker
- (IBAction)displayDay:(id)sender {
    
    NSDate *chosen = [self.eventDatePicker date];
    currentSelectedEventPickerDate = chosen;
    
    if(firstDisplayOfEventPicker == YES){
        //don't call this value
    }
    else{
        tomorrowIsActive = YES; //this causes the annotations to be added back
        customDateIsActive = NO;
        [self firedCustomEventChoice];
    }
}

-(void)getCurrentLocation
{
    @try{
        CLLocationCoordinate2D newLocation = self.mapView.userLocation.location.coordinate;

        CLPlacemark * recievedPlacemark = [_zoomLocation objectAtIndex:0];
        locationToZoom.latitude = recievedPlacemark.location.coordinate.latitude;
        locationToZoom.longitude = recievedPlacemark.location.coordinate.longitude;
    }
    @catch(NSException *error){
        NSLog(@"Error: %@",error);
        NSLog(@"Unreadable location. Moving to London");
    }
}

//called at the beginning of loading a view
- (void)loadView{
    firstDisplayOfEventPicker = YES;
    self.eventDatePicker.minimumDate = [NSDate date];
    currentSelectedEventPickerDate = [NSDate date];
    
    datePickerIsOpen = NO;
    firstLoad = YES;
    hasInitialFacebookDataBeenSource = NO;
    
    [self performSelectorOnMainThread:@selector(getCurrentLocation) withObject:nil waitUntilDone:YES];
    
    if(_zoomLocation == nil){
        NSLog(@"zoomLocation is nil");
        //[self loadView];
        [self performSelectorOnMainThread:@selector(setInitialLocationIfNull) withObject:nil waitUntilDone:YES];
    }
    else{
        //unpack the zoomLocation variable
        [self getCurrentLocation];
    }
    [super loadView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)toggleSideBarView
{
    
    CGRect sideBarFrame = self.sideBarView.frame;
    double maxSideBarFrameWidth = 244.0;
    if(sideBarFrame.size.width == maxSideBarFrameWidth){
        sideBarFrame.size.width = 20.0; //brings the bar back
    }
    else{
        sideBarFrame.size.width = maxSideBarFrameWidth;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    self.sideBarView.frame = sideBarFrame;
    [UIView commitAnimations];
    
}

-(void) updateTableView{
    if(self.listViewAnnotations != nil){
        [self.listViewAnnotations removeAllObjects];
        [self.listTableView reloadData];
    }
    self.listViewAnnotations = [ NSMutableArray arrayWithCapacity:1];
    
    for (id<MKAnnotation> annotation in _mapView.annotations)
    {
        MyLocation *anAnnotation = annotation;
        [self.listViewAnnotations addObject:anAnnotation];
    }
    
    
    @try{
        NSMutableArray *checkEidArray = [[NSMutableArray alloc] initWithCapacity:0];
    
        for (id<MKAnnotation> annotation in _mapView.annotations)
        {
            MyLocation *anAnnotation = annotation;
            [checkEidArray addObject:[anAnnotation fbEid]];
        }
    
    
        for (id<MKAnnotation> annotation in _mapView.annotations)
        {
            MyLocation *anAnnotation = annotation;
            int counter = 0;
            //loop through the current eid array
            for(id item in checkEidArray){
                if([item isEqualToString:[anAnnotation fbEid]]){
                    counter = counter + 1;
                }
            }
            if(counter > 1){
                //do not add this to the list
            }
            else{
                [self.listViewAnnotations addObject:anAnnotation];
            
            }
        
        }
        [self.listTableView reloadData];
    }
    @catch(NSException *e){
        NSLog(@"Error: %@",e);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    @try{
        cell.textLabel.text = [[self.listViewAnnotations objectAtIndex:indexPath.row] name];
    }
    @catch(NSException *e){
        NSLog(@"Cell assignment error %@",e);
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listViewAnnotations count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try{
        MyLocation* anAnnotation =[self.listViewAnnotations objectAtIndex:indexPath.row];
        [self.view endEditing:YES];
        [self loadAnnotationView:anAnnotation];
        [self unHideAnnotationView];
    }
    @catch(NSException *e){
        NSLog(@"MyLocation assignment error %@",e);
    }
}

-(void)loadAnnotationView:(MyLocation*)anAnnotation{
    @try{
        self.fbEidText = [anAnnotation fbEid];
        self.fbEventAddress.text = [anAnnotation fbLocData];
        self.fbEventDate.text = [anAnnotation fbEventDate];
        self.fbEventDescription.textColor = [UIColor blackColor];
        
        self.fbEventDescription.text = [anAnnotation fbDescription];
        self.fbEventTitle.text = [anAnnotation name];
        [NSThread detachNewThreadSelector:@selector(loadFacebookPicture:) toTarget:self withObject:[anAnnotation facebookPic]];
    }
    @catch(NSException *e){
        NSLog(@"Parsing Error %@",e);
    }
}

-(void)hideFacebookView
{
    self.fbPageView.hidden = YES;
}

-(void)unhideFacebookView
{
    self.fbPageView.hidden = NO;
}

-(void)unHideAnnotationView
{

    //Remove all the subviews
    for(UIView *subview in self.facebookImageSubView.subviews)
    {
        [subview removeFromSuperview];
    }
    
    for(UIView *subview in self.fbEventDescriptionScroll.subviews)
    {
        [subview clearsContextBeforeDrawing];
    }
    
    //initial responder
    if(self.annotationBarView.frame.size.width > 0){
        CGRect annotationBarViewFrameFix = self.annotationBarView.frame;
        annotationBarViewFrameFix.size.width = 0.0;
        self.annotationBarView.frame = annotationBarViewFrameFix;
    }
    
    //unhide the sideBar
    self.annotationBarView.hidden = NO;
    CGRect annotationBarViewFrame = self.annotationBarView.frame;
    annotationBarViewFrame.size.width = self.view.frame.size.width;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    self.annotationBarView.frame = annotationBarViewFrame;
    [UIView commitAnimations];

}

-(void)unHideFirstTime
{
    if(self.listView.frame.size.height > 0){
        CGRect listViewFrameFix = self.annotationBarView.frame;
        listViewFrameFix.size.height = 0.0;
        self.listView.frame = listViewFrameFix;
    }
}

-(void)unhideListView
{
    self.listView.hidden = NO;
    CGRect listViewFrame = self.listView.frame;
    listViewFrame.size.height = self.view.frame.size.height;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    self.listView.frame = listViewFrame;
    [UIView commitAnimations];
}



-(void)hideListView
{
    [self.listViewSearchBar resignFirstResponder];
    
    //when the first hide annotation view is called. It will go to being 0.0 in width but not hidden.
    //this was implemented in this way so I could see what was going on when I moved between annotations in storyboard
    CGRect listViewFrame = self.listView.frame;
    listViewFrame.size.height = 0.0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    self.listView.frame = listViewFrame;
    [UIView commitAnimations];
}

-(void)hideAnnotationView
{
    //when the first hide annotation view is called. It will go to being 0.0 in width but not hidden.
    //this was implemented in this way so I could see what was going on when I moved between annotations in storyboard
    
    self.fbEventDescriptionScroll.contentOffset = CGPointZero;
    
    [self.fbEventDescriptionScroll setContentOffset:CGPointMake(0.0,0.0)  animated:NO];
    [self.fbEventDescription setContentOffset:CGPointMake(0.0,0.0)  animated:NO];
    [self.fbEventTitleScroll setContentOffset:CGPointMake(0.0,0.0)  animated:NO];
    [self.fbEventTitle setContentOffset:CGPointMake(0.0,0.0)  animated:NO];
    
    CGRect annotationBarViewFrame = self.annotationBarView.frame;
    annotationBarViewFrame.size.width = 0.0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    self.annotationBarView.frame = annotationBarViewFrame;
    [UIView commitAnimations];
    
    
    [self.annotationBarView resignFirstResponder];
}

- (IBAction)goToLocationAction:(id)sender
{
    [self stopExtraFacebookData];
    CLLocationCoordinate2D newLocation = self.mapView.userLocation.location.coordinate;
    NSLog(@"center of Map %f",newLocation.latitude);
    NSLog(@"center of Map %f",newLocation.longitude);
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Service Disabled"
                                                        message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    //Don't move unless there are real values
    if( (self.mapView.userLocation.location.coordinate.latitude == 0.0) || (self.mapView.userLocation.location.coordinate.latitude == 0.0)){
        NSLog(@"No Real Location Given or location not simulated");
        self.mapView.centerCoordinate = locationToZoom;
        [_mapView removeAnnotations:_mapView.annotations];
        [self reverseGeocodeLocation];
    }
    else{
        [_mapView removeAnnotations:_mapView.annotations];
        self.mapView.centerCoordinate = self.mapView.userLocation.location.coordinate;
        locationToZoom = self.mapView.userLocation.location.coordinate;
        [self reverseGeocodeLocation];
    }
    
}

-(void)tapOnSearchDetected{
    
    [self toggleSideBarView];
}


//This overrides the current clicking function that occurs here
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    //remove the data from any exsisting subview
    self.fbEventTitle.text = nil;
    self.fbEventDate.text = nil;
    self.fbEventDescription.text = @"";
    self.fbEventAddress.text = @"";
    self.fbEidText = nil;
    
    MyLocation* anAnnotation =[view annotation];
    self.fbEidText = [anAnnotation fbEid];
    [NSThread detachNewThreadSelector:@selector(loadFacebookPicture:) toTarget:self withObject:[anAnnotation facebookPic]];
    self.fbEventAddress.text = [anAnnotation fbLocData];
    self.fbEventDate.text = [anAnnotation fbEventDate];
    self.fbEventDescription.text = [anAnnotation fbDescription];
    self.fbEventTitle.text = [anAnnotation name];
    [self unHideAnnotationView];
}

//click on the annotation event date
-(void)onClickAnnotationEventDate
{
    @try{
        __block BOOL waitingForEventBlock = YES;

        EKEventStore *eventStore = [[EKEventStore alloc] init];
        EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
        BOOL needsToRequestAccessToEventStore = (authorizationStatus ==EKAuthorizationStatusNotDetermined);
        
        if (needsToRequestAccessToEventStore) {
            [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                if (granted) {
                    // Access granted
                    accessToCalenderGranted = YES;
                    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                    event.calendar  = [eventStore defaultCalendarForNewEvents];
                    event.title     = self.fbEventTitle.text;
                    event.location  = self.fbEventAddress.text;
                    event.notes     = self.fbEventDescription.text;
                    
                    NSDateFormatter *formatFb = [[NSDateFormatter alloc] init];
                    [formatFb setDateFormat:@"dd/MM/yyyy bHH:mm"];
                    NSLog(@"start date %@",self.fbEventDate.text);
                    NSDate *formattedFacebookEventDate = [formatFb dateFromString:self.fbEventDate.text];
                    NSDate *endTimeOfEvent = [formattedFacebookEventDate dateByAddingTimeInterval:3600];
                    NSLog(@" after format start date %@",formattedFacebookEventDate);
                    event.startDate = formattedFacebookEventDate;
                    event.endDate = endTimeOfEvent;
                    [eventStore saveEvent:event span:EKSpanThisEvent error:nil];
                    
                    waitingForEventBlock = NO;
                } else {
                    // Denied
                    accessToCalenderGranted = NO;
                    NSLog(@"Access to store not granted");
                    waitingForEventBlock = NO;
                }
            }];
        } else {
            BOOL granted = (authorizationStatus == EKAuthorizationStatusAuthorized);
            if (granted) {
                // Access granted
                accessToCalenderGranted = YES;
                EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                event.calendar  = [eventStore defaultCalendarForNewEvents];
                event.title     = self.fbEventTitle.text;
                event.location  = self.fbEventAddress.text;
                event.notes     = self.fbEventDescription.text;
                
                NSDateFormatter *formatFb = [[NSDateFormatter alloc] init];
                [formatFb setDateFormat:@"dd/MM/yyyy HH:mm"];
                NSLog(@"start date %@",self.fbEventDate.text);
                NSDate *formattedFacebookEventDate = [formatFb dateFromString:self.fbEventDate.text];
                NSDate *endTimeOfEvent = [formattedFacebookEventDate dateByAddingTimeInterval:3600];
                NSLog(@" after format start date %@",formattedFacebookEventDate);
                event.startDate = formattedFacebookEventDate;
                event.endDate = endTimeOfEvent;
                [eventStore saveEvent:event span:EKSpanThisEvent error:nil];
                
                waitingForEventBlock = NO;
            } else {
                // Denied
                accessToCalenderGranted = NO;
                NSLog(@"Access to store not granted");
                waitingForEventBlock = NO;
            }
        }
        
        while(waitingForEventBlock) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        
        if(accessToCalenderGranted == YES){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event Added"
                                                        message:[NSString stringWithFormat:@"%@ has been added to your Calender",self.fbEventTitle.text]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
            [alert show];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event Not Added"
                                                            message:[NSString stringWithFormat:@"Please give Evappa access to the Calendar"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        
    }
    @catch(NSException *e){
        NSLog(@"iCal Error %@",e);
    }
    
}


-(void)loadFacebookPicture:(NSString*)eventFbPic
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
    UIImageView *facebookImageSubViewer = [[UIImageView alloc] initWithImage:facebookImage];
    facebookImageSubViewer.layer.cornerRadius = facebookImage.size.width / 2;
    facebookImageSubViewer.layer.masksToBounds = YES;
    [self.facebookImageSubView addSubview:facebookImageSubViewer];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"search_screen_segue"]) {
        [[segue destinationViewController] setCurrentSearchViewInformation:self.locationToSend];
    
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(MyLocation*)annotation {
    
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[MyLocation class]]) {
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = NO;
        
        if([[annotation eventType] intValue] == 0){
            //culture event
            UIImage * annotationImage = [UIImage imageNamed:@"lightbluetake2v2.png"];
            CGSize newSize = CGSizeMake(26*1.2, 48*1.2);  //whaterver size
            UIGraphicsBeginImageContext(newSize);
            [annotationImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            annotationView.image= newImage;
            
        }
        else if ([[annotation eventType] intValue] == 1){
            //party event
            UIImage * annotationImage = [UIImage imageNamed:@"greentake2v2.png"];
            CGSize newSize = CGSizeMake(26*1.2, 48*1.2);  //whaterver size
            UIGraphicsBeginImageContext(newSize);
            [annotationImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            annotationView.image= newImage;
        }
        else if ([[annotation eventType] intValue] == 2){
            //sport event
            UIImage * annotationImage = [UIImage imageNamed:@"orange2v2.png"];
            CGSize newSize = CGSizeMake(26*1.2, 48*1.2);  //whaterver size
            UIGraphicsBeginImageContext(newSize);
            [annotationImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            annotationView.image= newImage;
        }
        else if ([[annotation eventType] intValue] == 3){
            //music event
            UIImage * annotationImage = [UIImage imageNamed:@"white2v2.png"];
            CGSize newSize = CGSizeMake(26*1.2, 48*1.2);  //whaterver size
            UIGraphicsBeginImageContext(newSize);
            [annotationImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            annotationView.image= newImage;
        }
        else if ([[annotation eventType] intValue] == 4){
            //intellectual event
            UIImage * annotationImage = [UIImage imageNamed:@"pink2v2.png"];
            CGSize newSize = CGSizeMake(26*1.2, 48*1.2);  //whaterver size
            UIGraphicsBeginImageContext(newSize);
            [annotationImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            annotationView.image= newImage;
        }
        else if ([[annotation eventType] intValue] == 5){
            //food event
            UIImage * annotationImage = [UIImage imageNamed:@"yellow2v2.png"];
            CGSize newSize = CGSizeMake(26*1.2, 48*1.2);  //whaterver size
            UIGraphicsBeginImageContext(newSize);
            [annotationImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            annotationView.image= newImage;
        }
        else{
            //use the default value
        }
        
        return annotationView;
    }
    
    return nil;
}

-(IBAction)clickOnFacebook:(id)sender{

    userTriggerRefresh = YES;
    stopExtraFacebookDataFlag = YES;
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        
        @try{
            MyLocation* anAnnotation = annotation;
            [_mapView removeAnnotation:annotation];
        }
        @catch(NSException *e){
            NSLog(@"Parse Error for removing annotation: %@",e);
        }
    }
    [self refreshSearch];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    NSLog(@"did load annotations being fired!");
    //if(firstLoad == YES){
        if(hasInitialFacebookDataBeenSource == YES){
            firstLoad = NO;
            hasInitialFacebookDataBeenSource = NO;
            stopExtraFacebookDataFlag = NO;
            anotherSearchInProgress = NO;
            NSLog(@"loading here");
            [self performHugeFacebookSearch];
        }
    //}
}
- (IBAction)onClickEvappaAction:(id)sender
{
    [self hideFacebookView];
    UIWebView *tempWebview = [[UIWebView alloc]initWithFrame:self.fbWebView.frame];
    NSString * urlStringToFb = [NSString stringWithFormat:@"http:www.google.com"];
    NSURL *url = [NSURL URLWithString:urlStringToFb];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.fbWebView loadRequest:requestObj];
    self.fbWebView = tempWebview;
}


-(void)goToFacebookEventPage
{
    [loadingDataWheel stopAnimating];
    //open up a browser with the facebook event page
    @try{
        NSString * urlStringToFb = [NSString stringWithFormat:@"https://www.facebook.com/events/%@",self.fbEidText];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStringToFb]];
    }
    @catch(NSException *e)
    {
        NSLog(@"Error opening link : %@",e);
    }

}


-(void)refreshSearch
{
    [loadingDataWheel startAnimating];
    //have a counter that adds the facebook events at a certain point
    int facebookEventLoadCounter = 0;

    NSArray *arrayOfKeywords;
    
    
    if(userTriggerRefresh == YES){
        arrayOfKeywords= [NSArray arrayWithObjects:@"",@"music",@"society",@"night",@"band",@"experience",@"tickets",@"food",@"people",@"social",@"meeting",@"drink",@"gig",@"talk",@"party",@"club",@"sport",@"event",@"society",@"group",@"art",@"business",@"food",@"dinner",@"culture",@"festival",@"dance",@"jazz",@"tour",@"exhibition",@"show",@"theatre",@"football",@"time",@"well",@"student",@"new",@"old",@"live",@"book",@"fair",@"big",@"little",nil];
        userTriggerRefresh = NO;
    }
    else{
        arrayOfKeywords= [NSArray arrayWithObjects:@"music",@"society",@"night",@"band",@"experience",@"tickets",@"food",@"people",@"social",@"meeting",@"drink",@"gig",@"talk",@"party",@"club",@"sport",@"event",@"society",@"group",@"art",@"business",@"food",@"dinner",@"culture",@"festival",@"dance",@"jazz",@"tour",@"exhibition",@"show",@"theatre",@"time",@"well",@"student",@"new",@"old",@"live",@"book",@"fair",@"big",@"little",nil];
    }
    
    for(id keyword in arrayOfKeywords){
        
        if(facebookEventLoadCounter > 4){
            //add events
            SynterestModel *aSynterestModel = [[SynterestModel alloc] init];
            NSMutableArray* savedFacebookData =[aSynterestModel loadLocalData];
            [self plotFacebookData:savedFacebookData withReset:NO];
            
            //reset the facebookCounter
            facebookEventLoadCounter = 0;
        }
        
        facebookEventLoadCounter = facebookEventLoadCounter + 1;
        
        NSLog(@"keyword outer: %@",keyword);
        if(anotherSearchInProgress == YES){
            anotherSearchInProgress = NO;
            break;
        }
        
        
        [self performFacebookSearch:keyword];
    }
    
}



-(void) performHugeFacebookSearch
{
    //have a counter that adds the facebook events at a certain point
    int facebookEventLoadCounter = 0;

    NSArray *arrayOfKeywords;
    
    
    if(userTriggerRefresh == YES){
        arrayOfKeywords= [NSArray arrayWithObjects:@"",@"music",@"society",@"night",@"band",@"experience",@"tickets",@"food",@"people",@"social",@"meeting",@"drink",@"gig",@"talk",@"party",@"club",@"sport",@"event",@"society",@"group",@"art",@"business",@"food",@"dinner",@"culture",@"festival",@"dance",@"cafe",@"jazz",@"tour",@"exhibition",@"show",@"bar",@"class",@"theatre",@"football",@"hockey",@"tournament",@"match",@"college",@"time",@"well",@"student",@"new",@"old",@"live",@"book",@"fair",@"big",@"little",@"project",@"happy",nil];
        userTriggerRefresh = NO;
    }
    else{
        arrayOfKeywords= [NSArray arrayWithObjects:@"",@"music",@"society",@"night",@"band",@"experience",@"tickets",@"food",@"people",@"social",@"meeting",@"drink",@"gig",@"talk",@"party",@"club",@"sport",@"event",@"society",@"group",@"art",@"business",@"food",@"dinner",@"culture",@"festival",@"dance",@"cafe",@"jazz",@"tour",@"exhibition",@"show",@"bar",@"class",@"theatre",@"football",@"hockey",@"tournament",@"match",@"college",@"time",@"well",@"student",@"new",@"old",@"live",@"book",@"fair",@"big",@"little",@"project",@"happy",nil];
    }
    
    for(id keyword in arrayOfKeywords){
        
        if(facebookEventLoadCounter > 7){
            [loadingDataWheel stopAnimating];
            //add events
            SynterestModel *aSynterestModel = [[SynterestModel alloc] init];
            NSMutableArray* savedFacebookData =[aSynterestModel loadLocalData];
            [self plotFacebookData:savedFacebookData withReset:NO];
            
            //reset the facebookCounter
            facebookEventLoadCounter = 0;
        }
        
        facebookEventLoadCounter = facebookEventLoadCounter + 1;

        NSLog(@"keyword outer: %@",keyword);
        if(stopExtraFacebookDataFlag == YES){
            stopExtraFacebookDataFlag = NO;
            break;
        }
        
        [self performFacebookSearch:keyword];
    }
}

- (void) performFacebookSearch:(NSString*)keyword
{
    __block BOOL waitingForBlock = YES;
        // Set the flag to YES
        [self extendAnnotationsOnMap:keyword withCompletion:^(BOOL finished) {
            if(finished){
                waitingForBlock = NO;
            }
        }];
        
        // Run the loop
        while(waitingForBlock) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
}

-(IBAction)onChooseADate:(id)sender
{
    if(datePickerIsOpen == NO){
        self.eventDatePicker.hidden = NO;
        datePickerIsOpen = YES;
    }
    else if (datePickerIsOpen == YES){
        self.eventDatePicker.hidden = YES;
        datePickerIsOpen = NO;
    }
    else{
        NSLog(@"Date Picker error");
    }
}

-(IBAction)onClickCustomDate:(id)sender
{
    if(firstDisplayOfEventPicker == YES){
        firstDisplayOfEventPicker = NO;
    }
    else if (firstDisplayOfEventPicker == NO){
        firstDisplayOfEventPicker = YES;
    }
    else{
        NSLog(@"FirstDisplayOfEventPicker Flag error");
    }
    [self firedCustomEventChoice];
}

-(void) firedCustomEventChoice
{
    NSDateFormatter *formatFb = [[NSDateFormatter alloc] init];
    [formatFb setDateFormat:@"dd/MM/yyyy HH:mm"];
    NSDate *sourceDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24 * 60];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    float timeZoneOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate] / 3600.0;
    [formatFb setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:timeZoneOffset]];
    //TODO: These dates don't properly take GMT shifts into account :(
    
    NSDate *todayDate = [NSDate date];
    
    
    if(customDateIsActive == NO){
        
        self.eventDatePicker.hidden = NO;
        
        if((todayIsActive == YES) || (tomorrowIsActive == YES)){
            //firing when switching between tomorrow to today
            todayIsActive = NO;
            tomorrowIsActive = NO;
            customDateIsActive = NO;
            self.nextWeekButton.backgroundColor = [UIColor whiteColor];
            self.nextDateButton.backgroundColor = [UIColor whiteColor];
            self.nextTwoDaysButton.backgroundColor = [UIColor whiteColor];
            @try{
                SynterestModel *aSynterestModel = [[SynterestModel alloc] init];
                NSMutableArray* savedFacebookData =[aSynterestModel loadLocalData];
                if(savedFacebookData != NULL){
                    [self plotFacebookData:savedFacebookData withReset:YES];
                }
            }
            @catch(NSException *e){
                NSLog(@"Parse Error for Date Filter %@",e);
            }
        }
        todayIsActive = NO;
        tomorrowIsActive = NO;
        customDateIsActive = YES;
        self.nextWeekButton.backgroundColor = [UIColor whiteColor];
        self.nextDateButton.backgroundColor = [UIColor lightGrayColor];
        self.nextTwoDaysButton.backgroundColor = [UIColor whiteColor];
        
        NSDate *customDatePlusOneDay = [currentSelectedEventPickerDate dateByAddingTimeInterval:60.0*60.0*24.0*1.0];
        NSLog(@"customDateplusOneDay : %@",customDatePlusOneDay);
        
        
        
        //implement a mask for this
        //search for extra data and start spinning wheel
        for (id<MKAnnotation> annotation in _mapView.annotations) {
            
            @try{
                MyLocation* anAnnotation = annotation;
                NSDate *setDate = [formatFb dateFromString:[anAnnotation fbEventDate]];
                NSComparisonResult result1;
                result1 = [setDate compare:customDatePlusOneDay];
                
                NSComparisonResult result2;
                result2 = [setDate compare:currentSelectedEventPickerDate];
                
                if(result1 != NSOrderedDescending){
                    if(result2 != NSOrderedAscending){
                        //do not remove
                    }
                    else{
                        [_mapView removeAnnotation:annotation];
                    }
                }
                else{
                    [_mapView removeAnnotation:annotation];
                }
                
            }
            @catch(NSException *e){
                NSLog(@"Parse Error for Date Filter %@",e);
            }
        }
        
    }
    else if (customDateIsActive == YES){
        
        self.eventDatePicker.hidden = YES;
        
        todayIsActive = NO;
        tomorrowIsActive = NO;
        customDateIsActive = NO;
        self.nextWeekButton.backgroundColor = [UIColor whiteColor];
        self.nextDateButton.backgroundColor = [UIColor whiteColor];
        self.nextTwoDaysButton.backgroundColor = [UIColor whiteColor];
        @try{
            SynterestModel *aSynterestModel = [[SynterestModel alloc] init];
            NSMutableArray* savedFacebookData =[aSynterestModel loadLocalData];
            if(savedFacebookData != NULL){
                [self plotFacebookData:savedFacebookData withReset:YES];
            }
        }
        @catch(NSException *e){
            NSLog(@"Parse Error for Date Filter %@",e);
        }
    }
    else{
        NSLog(@"TodayIsActive Flag not set");
    }
    //[self updateTableView];
}

-(IBAction)onClickTomorrowAction:(id)sender
{
    NSDateFormatter *formatFb = [[NSDateFormatter alloc] init];
    [formatFb setDateFormat:@"dd/MM/yyyy HH:mm"];
    NSDate *sourceDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24 * 60];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    float timeZoneOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate] / 3600.0;
    [formatFb setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:timeZoneOffset]];
    //TODO: These dates don't properly take GMT shifts into account :(
    
    NSDate *todayDate = [NSDate date];
    NSLog(@"Current Date: %@",todayDate);
    
    if(customDateIsActive == YES){
        //toggle the date picker
        self.eventDatePicker.hidden = YES;
        //firstDisplayOfEventPicker = NO;
    }
    
    if(tomorrowIsActive == NO){
        
        //change the profile of the button
        //self.nextWeekButton.backgroundColor = [UIColor lightGrayColor];
        self.nextWeekButton.backgroundColor = [UIColor lightGrayColor];
        self.nextDateButton.backgroundColor = [UIColor whiteColor];
        self.nextTwoDaysButton.backgroundColor = [UIColor whiteColor];
        
        
        if( (todayIsActive == YES) || (customDateIsActive == YES)){
            //firing when switching between tomorrow to today
            todayIsActive = NO;
            tomorrowIsActive = NO;
            customDateIsActive = NO;
            
            
            @try{
                SynterestModel *aSynterestModel = [[SynterestModel alloc] init];
                NSMutableArray* savedFacebookData =[aSynterestModel loadLocalData];
                if(savedFacebookData != NULL){
                    [self plotFacebookData:savedFacebookData withReset:YES];
                }
            }
            @catch(NSException *e){
                NSLog(@"Parse Error for Date Filter %@",e);
            }
        }
        todayIsActive = NO;
        tomorrowIsActive = YES;
        customDateIsActive = NO;
        NSDate *nextWeek = [todayDate dateByAddingTimeInterval:60.0*60.0*24.0*7.0];
        
        //implement a mask for this
        //search for extra data and start spinning wheel
        for (id<MKAnnotation> annotation in _mapView.annotations) {
            
            @try{
                MyLocation* anAnnotation = annotation;
                
                NSDate *setDate = [formatFb dateFromString:[anAnnotation fbEventDate]];
                
                NSComparisonResult result;
                result = [setDate compare:nextWeek];
                if(result==NSOrderedAscending){
                    //do nothing
                }
                else if(result==NSOrderedDescending){
                    [_mapView removeAnnotation:annotation];
                }
                else{
                    //do nothing
                }
            }
            @catch(NSException *e){
                NSLog(@"Parse Error for Date Filter %@",e);
            }
        }
        
    }
    else if (tomorrowIsActive == YES){
        
        self.nextWeekButton.backgroundColor = [UIColor whiteColor];
        todayIsActive = NO;
        tomorrowIsActive = NO;
        customDateIsActive = NO;
        @try{
            SynterestModel *aSynterestModel = [[SynterestModel alloc] init];
            NSMutableArray* savedFacebookData =[aSynterestModel loadLocalData];
            if(savedFacebookData != NULL){
                [self plotFacebookData:savedFacebookData withReset:YES];
            }
        }
        @catch(NSException *e){
            NSLog(@"Parse Error for Date Filter %@",e);
        }
    }
    else{
        NSLog(@"TodayIsActive Flag not set");
    }
    //[self updateTableView];
}

-(IBAction)onClickTodayAction:(id)sender
{
    NSDateFormatter *formatFb = [[NSDateFormatter alloc] init];
    [formatFb setDateFormat:@"dd/MM/yyyy HH:mm"];
    NSDate *sourceDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24 * 60];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    float timeZoneOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate] / 3600.0;
    [formatFb setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:timeZoneOffset]];
    //TODO: These dates don't properly take GMT shifts into account :(
    
    NSDate *todayDate = [NSDate date];
    NSLog(@"Current Date: %@",todayDate);
    
    if(customDateIsActive == YES){
        //toggle the date picker
        self.eventDatePicker.hidden = YES;
        //firstDisplayOfEventPicker = NO;
    }
    
    if(todayIsActive == NO){

        self.nextWeekButton.backgroundColor = [UIColor whiteColor];
        self.nextDateButton.backgroundColor = [UIColor whiteColor];
        self.nextTwoDaysButton.backgroundColor = [UIColor lightGrayColor];
        
        if( (tomorrowIsActive == YES) || (customDateIsActive == YES)){
            //firing when switching between tomorrow to today
            todayIsActive = NO;
            tomorrowIsActive = NO;
            customDateIsActive = NO;
            
            
            @try{
                SynterestModel *aSynterestModel = [[SynterestModel alloc] init];
                NSMutableArray* savedFacebookData =[aSynterestModel loadLocalData];
                if(savedFacebookData != NULL){
                    [self plotFacebookData:savedFacebookData withReset:YES];
                }
            }
            @catch(NSException *e){
                NSLog(@"Parse Error for Date Filter %@",e);
            }
        }
        
        todayIsActive = YES;
        tomorrowIsActive = NO;
        customDateIsActive = NO;
        
        NSDate *tomorrowDate = [todayDate dateByAddingTimeInterval:60.0*60.0*24.0*2.0];
    
        //implement a mask for this
        //search for extra data and start spinning wheel
        for (id<MKAnnotation> annotation in _mapView.annotations) {
        
            @try{
                MyLocation* anAnnotation = annotation;
        
                NSDate *setDate = [formatFb dateFromString:[anAnnotation fbEventDate]];

                NSComparisonResult result;
                result = [setDate compare:tomorrowDate];
                if(result==NSOrderedAscending){
                    //do nothing
                }
                else if(result==NSOrderedDescending){
                    [_mapView removeAnnotation:annotation];
                }
                else{
                    //do nothing
                }
            }
            @catch(NSException *e){
                NSLog(@"Parse Error for Date Filter %@",e);
            }
        }

    }
    else if (todayIsActive == YES){
        todayIsActive = NO;
        tomorrowIsActive = NO;
        customDateIsActive = NO;
        
        self.nextWeekButton.backgroundColor = [UIColor whiteColor];
        self.nextDateButton.backgroundColor = [UIColor whiteColor];
        self.nextTwoDaysButton.backgroundColor = [UIColor whiteColor];
        
        @try{
            SynterestModel *aSynterestModel = [[SynterestModel alloc] init];
            NSMutableArray* savedFacebookData =[aSynterestModel loadLocalData];
            if(savedFacebookData != NULL){
                [self plotFacebookData:savedFacebookData withReset:YES];
            }
        }
        @catch(NSException *e){
            NSLog(@"Parse Error for Date Filter %@",e);
        }
    }
    else{
        NSLog(@"TodayIsActive Flag not set");
    }
    
    //[self updateTableView];
}

//only updates location if the user has changed position by over 500m
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* updateLocation = [locations lastObject];
    
    
    if([backFromSearch boolValue] == YES){
        [self performSelectorOnMainThread:@selector(initReverseGeocodeLocation) withObject:nil waitUntilDone:YES];
        [self setBackFromSearch:[NSNumber numberWithBool:NO]];
    }
    else{
        [self stopExtraFacebookData];
        locationToZoom.latitude = updateLocation.coordinate.latitude;
        locationToZoom.longitude = updateLocation.coordinate.longitude;
        self.mapView.centerCoordinate = updateLocation.coordinate;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(locationToZoom, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
        [_mapView setRegion:viewRegion animated:YES];
        [self performSelectorOnMainThread:@selector(initReverseGeocodeLocation) withObject:nil waitUntilDone:YES];
        [self updateTableView];
    }
}

- (void)viewDidLoad
{
    self.dateOptionsArray = [NSArray arrayWithObjects:@"today",@"tomorrow",@"this week",nil];
    self.locationManager = [[CLLocationManager alloc] init] ;
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = 500;
    [self.locationManager startUpdatingLocation];
    [super viewDidLoad];
    self.mapView.showsUserLocation=YES;
    
    //need to add the subviews first
    [self.view addSubview:self.sideBarView];
    [self.view addSubview:self.searchButtonSubView];
    [self.view addSubview:self.annotationBarView];
    [self.view addSubview:self.listView];
    [self.view addSubview:self.fbPageView];
    [self.view addSubview:self.helperView];
    
    [self.view insertSubview:self.sideBarView atIndex:2];
    [self.view insertSubview:self.searchButtonSubView atIndex:3];
    [self.view insertSubview:self.annotationBarView atIndex:4];
    [self.view insertSubview:self.listView atIndex:4];
    [self.view insertSubview:self.listImageView atIndex:2];
    [self.view insertSubview:self.questionImageView atIndex:2];
    [self.view insertSubview:self.calenderMainView atIndex:2];
    [self.view insertSubview:self.helperView atIndex:6];
    
    [self.view insertSubview:self.eventDatePicker atIndex:5];
    [self.view insertSubview:self.fbPageView atIndex:10];
    
    self.annotationBarView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    
    self.eventDatePicker.hidden = YES;
    self.fbPageView.hidden = YES;
    self.fbPageView.layer.masksToBounds = YES;
    
    //be very careful with the indexes as they might prevent gesture functions from working
    
    //keeps items within the view
    self.annotationBarView.layer.masksToBounds = YES;
    
    self.helperView.hidden = YES;
    self.helperView.layer.masksToBounds = YES;
    self.helperView.layer.borderColor = [UIColor blackColor].CGColor;
    self.helperView.layer.borderWidth = 2.0;
    self.helperView.layer.cornerRadius = 25.0f;
    
    //Set up behaviour if for the listImageView
    UITapGestureRecognizer *singleTapOnHelperImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickToLeaveLegend)];
    singleTapOnHelperImageView.numberOfTapsRequired = 1;
    self.helperView.userInteractionEnabled = YES;
    [self.helperView addGestureRecognizer:singleTapOnHelperImageView];
    
    
    //Format the search button subView
    _searchButtonSubView.layer.masksToBounds = YES;
    _searchButtonSubView.backgroundColor = [UIColor whiteColor];
    _searchButtonSubView.layer.borderColor = [UIColor blackColor].CGColor;
    _searchButtonSubView.layer.borderWidth = 1.5;
    _searchButtonSubView.layer.cornerRadius = 19.0f;
    
    //Format the list icon button
    _listImageView.layer.masksToBounds = YES;
    _listImageView.backgroundColor = [UIColor whiteColor];
    _listImageView.layer.borderColor = [UIColor blackColor].CGColor;
    _listImageView.layer.borderWidth = 1.5;
    _listImageView.layer.cornerRadius = 19.0f;
    
    //Set up behaviour if for the listImageView
    UITapGestureRecognizer *singleTapOnListImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setUpListView)];
    singleTapOnListImageView.numberOfTapsRequired = 1;
    _listImageView.userInteractionEnabled = YES;
    [_listImageView addGestureRecognizer:singleTapOnListImageView];
    
    //Format the list icon button
    _questionImageView.layer.masksToBounds = YES;
    _questionImageView.backgroundColor = [UIColor whiteColor];
    _questionImageView.layer.borderColor = [UIColor blackColor].CGColor;
    _questionImageView.layer.borderWidth = 1.5;
    _questionImageView.layer.cornerRadius = 19.0f;
    
    //Set up behaviour if for the questionImageView
    UITapGestureRecognizer *singleTapOnQuestionImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickQuestionButton)];
    singleTapOnQuestionImageView.numberOfTapsRequired = 1;
    _questionImageView.userInteractionEnabled = YES;
    [_questionImageView addGestureRecognizer:singleTapOnQuestionImageView];
    
    //Format the ListView
    _listView.layer.masksToBounds = YES;
    
    //Format the sideBarView
    _sideBarView.layer.masksToBounds = YES;
    _sideBarView.layer.cornerRadius = 19.0f;
    //_sideBarView.backgroundColor = [UIColor whiteColor];
    _sideBarView.layer.borderColor = [UIColor blackColor].CGColor;
    _sideBarView.layer.borderWidth = 1.5f;
    
    //appears to control the sharpness of the gradient in the sideBarView
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:5.0];
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
    
    //add a gradient to the sideBarView
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = _sideBarView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:(186/255.0) green:(255/255.0) blue:(141/255.0) alpha:1],(id)[[UIColor whiteColor] CGColor],nil];
    gradient.locations = locations;
    [_sideBarView.layer insertSublayer:gradient atIndex:0];
    
    
    //add a gradient to the calenderView
    CAGradientLayer *gradientCalView = [CAGradientLayer layer];
    gradientCalView.frame = self.calenderMainView.bounds;
    gradientCalView.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:(186/255.0) green:(255/255.0) blue:(141/255.0) alpha:1],(id)[[UIColor whiteColor] CGColor],nil];
    gradientCalView.locations = locations;
    [self.calenderMainView.layer insertSublayer:gradientCalView atIndex:0];
    
    self.eventDatePicker.backgroundColor = [UIColor whiteColor];

    //button views in Calender View Controls
    self.nextWeekButton.layer.cornerRadius = 5;
    self.nextTwoDaysButton.layer.cornerRadius = 5;
    self.nextDateButton.layer.cornerRadius = 5;
    self.nextWeekButton.backgroundColor = [UIColor whiteColor];
    self.nextTwoDaysButton.backgroundColor = [UIColor whiteColor];
    self.nextDateButton.backgroundColor = [UIColor whiteColor];
    
    //delegate listViewSearchBar to itself
    self.listViewSearchBar.delegate = self;
    
    //Set up behaviour if for the imageView
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnSearchDetected)];
    singleTap.numberOfTapsRequired = 1;
    _searchButtonSubView.userInteractionEnabled = YES;
    [_searchButtonSubView addGestureRecognizer:singleTap];
    
    //Set up behaviour of the annotationView
    UISwipeGestureRecognizer *swipeBackAnnotation = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideAnnotationView)];
    [swipeBackAnnotation setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.annotationBarView addGestureRecognizer:swipeBackAnnotation];
    
    //Respond to tap click on the UILabel for calender
    UITapGestureRecognizer *tapGestureRecognizerCal = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickAnnotationEventDate)];
    tapGestureRecognizerCal.numberOfTapsRequired = 1;
    [self.fbEventDate addGestureRecognizer:tapGestureRecognizerCal];
    self.fbEventDate.userInteractionEnabled = YES;
    
    
   
    //Respond to clicking on the photo or event title or facebook symbol
    UITapGestureRecognizer *tapToFacebookEventLink = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToFacebookEventPage)];
    tapToFacebookEventLink.numberOfTapsRequired = 1;
    
    [self.facebookImageSubView addGestureRecognizer:tapToFacebookEventLink];
    self.facebookImageSubView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapToFacebookEventLink2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToFacebookEventPage)];
    tapToFacebookEventLink2.numberOfTapsRequired = 1;
    [self.fbEventTitle addGestureRecognizer:tapToFacebookEventLink2];
    self.fbEventTitle.userInteractionEnabled = YES;
    
    //Magic line that makes the mapView call the annotation script
    _mapView.delegate=self;
    
    self.loadingDataWheel.color = [UIColor blackColor];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (!appDelegate.session.isOpen) {
        // create a fresh session object
        appDelegate.session = [[FBSession alloc] init];
        
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
        if (appDelegate.session.state == FBSessionStateCreatedTokenLoaded) {
            // even though we had a cached token, we need to login to make the session usable
            [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                             FBSessionState status,
                                                             NSError *error) {
                // we recurse here, in order to update buttons and labels
                //[self updateView];
            }];
        }
    }
    
}

-(void) onClickQuestionButton
{
    //make the icon information view visible
    self.helperView.hidden = NO;
}

-(void) onClickToLeaveLegend
{
    self.helperView.hidden = YES;
}


- (IBAction)onGoBackAction:(id)sender
{
    [self hideAnnotationView];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
    
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return [self.dateOptionsArray count];
    
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    
    return [self.dateOptionsArray objectAtIndex:row];
    
}

// FBSample logic
// main helper method to update the UI to reflect the current state of the session.
- (void)updateView {
    // get the app delegate, so that we can reference the session property
    //Get the synterest Model
    SynterestModel *aSynterestModel = [[SynterestModel alloc] init];
    //Place Data on the screen if any is stored in Memory
    NSMutableArray* savedFacebookData =[aSynterestModel loadLocalData];
    //NSLog(@"savedFacebookData: %@",savedFacebookData);
    //check to see if there is actually some facebook data
    if(savedFacebookData != NULL){
        //NSLog(@"loading data...");
        [self plotFacebookData:savedFacebookData withReset:YES];
    }
    
    //[self updateTableView];
}

-(void)setUpListView
{
    NSLog(@"unhide listView");
    [self performSelectorOnMainThread:@selector(updateTableView) withObject:self waitUntilDone:YES];
    //[self updateTableView];
    [self unhideListView];
}

-(IBAction)goBackFromListView:(id)sender
{
    [self hideListView];
    
}

// FBSample logic
// handler for button click, logs sessions in or out
- (IBAction)buttonClickHandler:(id)sender {
    // get the app delegate so that we can access the session property
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    // this button's job is to flip-flop the session from open to closed
    if (appDelegate.session.isOpen) {
        // if a user logs out explicitly, we delete any cached token information, and next
        // time they run the applicaiton they will be presented with log in UX again; most
        // users will simply close the app or switch away, without logging out; this will
        // cause the implicit cached-token login to occur on next launch of the application
        [appDelegate.session closeAndClearTokenInformation];

        
    } else {
        if (appDelegate.session.state != FBSessionStateCreated) {
            // Create a new, logged out session.
            
            appDelegate.session = [[FBSession alloc] init];
        }
        
        // if the session isn't open, let's open it now and present the login UX to the user
        [appDelegate.session openWithCompletionHandler:^(FBSession *session,
                                                         FBSessionState status,
                                                         NSError *error) {
            // and here we make sure to update our UX according to the new session state
            [self updateView];
        }];
        
        
        
    }
}

- (IBAction)searchButtonAction:(id)sender
{
    
    [self performSegueWithIdentifier:@"search_screen_segue" sender:self];
    [self stopExtraFacebookData];
}

- (IBAction)quitButtonAction:(id)sender
{
    [self quitApplication];
}

-(void)quitApplication
{
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (appDelegate.session.isOpen) {
        // if a user logs out explicitly, we delete any cached token information, and next
        // time they run the applicaiton they will be presented with log in UX again; most
        // users will simply close the app or switch away, without logging out; this will
        // cause the implicit cached-token login to occur on next launch of the application
        [appDelegate.session closeAndClearTokenInformation];
        
        [self performSegueWithIdentifier:@"logout_sucess" sender:self];
    }
    else{
        NSLog(@"Error - Facebook Session is Closed but map is visible");
    }
}

- (void)extendAnnotationsOnMap:(NSString*)keywordString withCompletion:(myCompletion) compblock{
    self.extraFacebookData = [[NSMutableArray alloc] initWithCapacity:100];
    NSLog(@"keyword %@",keywordString);
    __block BOOL waitingForInnerBlock = YES;
    [self queryFacebookDb:keywordString withCompletion:^(BOOL finished) {
        if(finished == YES){
            NSLog(@"success inner");
            NSLog(@"completion value inner");
            waitingForInnerBlock = NO;
        }
    }];
    
    // Run the loop
    while(waitingForInnerBlock) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }

    compblock(YES);
}

-(void)queryFacebookDb:(NSString*)queryString withCompletion:(myCompletion2) compblock2{
    NSString *query;
    @try{
        //remove any accents from words
        NSData *dataCurrent = [self.currentCity dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *newStr = [[NSString alloc] initWithData:dataCurrent encoding:NSASCIIStringEncoding];
        
        if(self.currentCity != nil){
            query = [NSString stringWithFormat:@"SELECT eid, name,location,description, venue, start_time, update_time, end_time, pic FROM event WHERE contains('%@ %@') AND (venue.city = '%@') AND (venue.street != '') AND start_time > now() ORDER BY rand() LIMIT 100",newStr,queryString,newStr];
        }
        else{
            query =[NSString stringWithFormat:@"SELECT eid, name,location,description, venue, start_time, update_time, end_time, pic FROM event WHERE contains('London %@') AND (venue.city = 'London') AND (venue.street != '') AND start_time > now() ORDER BY rand() LIMIT 100",queryString];
            NSLog(@"self.currentCity = null string");
        }
    }
    @catch(NSException *e){
        NSLog(@"Error appending string: %@",e);
        query =[NSString stringWithFormat:@"SELECT eid, name,location,description, venue, start_time, update_time, end_time, pic FROM event WHERE contains('London') AND (venue.city = 'London') AND (venue.street != '') AND start_time > now() ORDER BY rand() LIMIT 100"];
    }
    NSDictionary *queryParam = @{ @"q": query };
    
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (error) {
                                  NSLog(@"Query Used: %@",query);
                                  NSLog(@"Query Error: %@", [error localizedDescription]);
                              } else {
                                  NSLog(@"in here extending the view");
                                  [self.extraFacebookData addObject:result];
                                  [self addNewDataToMap:self.extraFacebookData];
                                  compblock2(YES);
                              }
                          }];
    
    
}

-(void)addNewDataToMap:(NSMutableArray*)newFacebookData
{
    NSLog(@"add data to map");
    SynterestModel *aSynterestModel = [[SynterestModel alloc] init];

    self.additionalFacebookData =[aSynterestModel performSelector:@selector(parseFbFqlResult:) withObject:self.extraFacebookData[0]];

    [aSynterestModel performSelector:@selector(saveAdditionalLocalData:) withObject:self.additionalFacebookData];
    
    NSMutableArray* savedFacebookData =[aSynterestModel loadLocalData];
    self.extraFacebookData = nil;
}


- (void)queryButtonAction
{
    [loadingDataWheel startAnimating];
    //Get the synterest Model
    SynterestModel *aSynterestModel = [[SynterestModel alloc] init];

    NSString *query;// = [[NSString alloc] init];
    //Standard Location query of facebook FQL
    @try{
        
        NSData *dataCurrent = [self.currentCity dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *newStr = [[NSString alloc] initWithData:dataCurrent encoding:NSASCIIStringEncoding];
        
        //avoid using null values of currentCity
        if(self.currentCity != nil){
            query = [NSString stringWithFormat:@"SELECT eid, name,location,description, venue, start_time, update_time, end_time, pic FROM event WHERE contains('%@') AND (venue.city = '%@') AND (venue.street != '') AND start_time > now() ORDER BY rand() LIMIT 500",newStr,newStr];
        }
        else{
            query =[NSString stringWithFormat:@"SELECT eid, name,location,description, venue, start_time, update_time, end_time, pic FROM event WHERE contains('London') AND (venue.city = 'London') AND (venue.street != '') AND start_time > now() ORDER BY rand() LIMIT 100"];
            NSLog(@"self.currentCity = null string");
        }
    }
    @catch(NSException *e){
        NSLog(@"Error appending string: %@",e);
        //default the automatic search to London if there is uncertainty
        query =[NSString stringWithFormat:@"SELECT eid, name,location,description, venue, start_time, update_time, end_time, pic FROM event WHERE contains('London') AND (venue.city = 'London') AND (venue.street != '') AND start_time > now() ORDER BY rand() LIMIT 100"];
    }
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    [FBSession setActiveSession:appDelegate.session];
    
    
    if (appDelegate.session.isOpen) {
        NSLog(@"state: %@",[appDelegate.session description]);
    }
    
    // Set up the query parameter
    NSDictionary *queryParam = @{ @"q": query };
    
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (error) {
                                  
                                  NSLog(@"Query Used: %@",query);
                                  NSLog(@"Query Error: %@", [error localizedDescription]);
                                  
                                  @try{
                                      UIAlertView *fbAlert = [[UIAlertView alloc] initWithTitle:@"Network/Facebook Error"
                                                                                    message:[NSString stringWithFormat:@"%@",[error localizedDescription]]
                                                                                   delegate:self
                                                                          cancelButtonTitle:@"OK"
                                                                          otherButtonTitles:nil];
                                      [fbAlert show];
                                  }
                                  @catch(NSException *e){
                                      NSLog(@"Error showing alert screen");
                                  }
                                  
                              } else {
                                  //this required the selection to wait
                                  self.facebookData =[aSynterestModel performSelector:@selector(parseFbFqlResult:) withObject:result];

                                  //Save the facebook Data
                                  [aSynterestModel saveLocalData:facebookData];
                                  
                                  //Load back the saved facebook Data
                                  NSMutableArray* savedFacebookData =[aSynterestModel loadLocalData];
                                  hasInitialFacebookDataBeenSource = YES;
                                  [self plotFacebookData:savedFacebookData withReset:YES];
                                  
                              }
                          }];
    
    if (!appDelegate.session.isOpen) {
        NSLog(@"Session Not Open in FQL Query");
    }
    else{
        //do nothing all is good
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        //cancel clicked ...do your action
        [self quitApplication];
    }
}

//Control for the List View (Search by event)


- (void)searchAnnotationsForKeyword:(NSString*)keyword
{
    
    NSMutableArray *newListObjects = [[NSMutableArray alloc] initWithCapacity:100];
    
    //loop through all the annotations
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        
        @try{
            MyLocation* anAnnotation = annotation;
            //combine the different string sections of the annotation together
            NSString *stringToSearch = [NSString stringWithFormat:@"%@ %@'",[anAnnotation fbDescription],[anAnnotation name]];
            
            //search through the combined string
            NSUInteger count = 0, length = [stringToSearch length];
            NSRange range = NSMakeRange(0, length);
            while(range.location != NSNotFound){
             range = [stringToSearch rangeOfString:keyword options:NSCaseInsensitiveSearch range:range];
             if(range.location != NSNotFound){
                 range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
                 count++;
             }
            }
            
            if(count > 1){
                //if the event is detected then keep it on the list
                [newListObjects addObject:anAnnotation];
            }
            else{
                //if the event isn't detected then remove it from the list
            }
            
        }
        @catch(NSException *e){
            NSLog(@"searchAnnotationsForKeyword Error: %@",e);
        }
    }
    
    self.listViewAnnotations = newListObjects;
    [self.listTableView reloadData];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] != 0) {
        [self searchAnnotationsForKeyword:searchText];
        //text changed
    }
    else{
        //do nothing
    }
    
    if([searchText length] ==0){
        [self updateTableView];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if ([searchBar.text length] != 0) {
         //begin editing
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"cancelled button called");
    //this adds back any missing items from the
    [self updateTableView];
}


- (void)addUserTriggeredData
{
    //add points to the plot based on what users searched
}

- (void)plotFacebookData:(NSMutableArray *)responseData withReset:(BOOL)resetValue
{
    if(resetValue == YES){
        for (id<MKAnnotation> annotation in _mapView.annotations) {
            [_mapView removeAnnotation:annotation];
        }
    }
    else{
        //ignore this and don't reset the current map
    }

    int annotationCount = 0;
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        annotationCount = annotationCount + 1;
    }
    
    if(annotationCount > MAXIMUM_NUMBER_ANNOTATIONS){
        NSLog(@"exceeded maximum annotations in view");
        [self stopExtraFacebookData];
        return;
    }
    
    NSLog(@"num of dataPoints %u",[responseData count]);
    
    for (NSMutableDictionary *singlePoint in responseData)
    {
        int eventType;
        double latitude,longitude;
        NSString *facebookDateString;
        @try{
            latitude = [[[singlePoint objectForKey:@"venue"] objectForKey:@"latitude"] doubleValue];
            longitude = [[[singlePoint objectForKey:@"venue"] objectForKey:@"longitude"] doubleValue];
            facebookDateString = [self getDateInfoFromFb:[singlePoint objectForKey:@"start_time"]];
            eventType = [[singlePoint objectForKey:@"event_type"] intValue];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception Coordinates:%@ ",exception);
        }
        @finally {
            @try{
                CLLocationCoordinate2D coordinates;
                coordinates.latitude = latitude;
                coordinates.longitude = longitude;

                NSString *fbAdress = [self buildAddressToShow:[singlePoint objectForKey:@"venue"]];
            
                MyLocation *annotation = [[MyLocation alloc] initWithName:[singlePoint objectForKey:@"name"]
                                                               address:nil
                                                            coordinate:coordinates
                                                           typeOfEvent:eventType
                                                       withFacebookPic:[singlePoint objectForKey:@"pic"]
                                                       withDescription:[singlePoint objectForKey:@"description"]
                                                        withFbLocData:fbAdress
                                                      withFbEventDate:facebookDateString
                                                            withFbEid:[singlePoint objectForKey:@"eid"]];
            
                if(todayIsActive == YES){
                    
                    //respect the today active filter
                    @try{
                        NSDate *todayDate = [NSDate date];
                        NSDate *tomorrowDate = [todayDate dateByAddingTimeInterval:60.0*60.0*24.0*2.0];
                        NSDateFormatter *formatFb = [[NSDateFormatter alloc] init];
                        [formatFb setDateFormat:@"dd/MM/yyyy HH:mm"];
                        NSDate *sourceDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24 * 60];
                        NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
                        float timeZoneOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate] / 3600.0;
                        [formatFb setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:timeZoneOffset]];
                        NSDate *setDate = [formatFb dateFromString:[annotation fbEventDate]];
                        
                        NSComparisonResult result;
                        result = [setDate compare:tomorrowDate];
                        if(result==NSOrderedAscending){
                            [_mapView addAnnotation:annotation];
                        }
                        else if(result==NSOrderedDescending){
                            [_mapView removeAnnotation:annotation];
                        }
                        else{
                            [_mapView addAnnotation:annotation];
                        }
                    }
                    @catch(NSException *e){
                        NSLog(@"Parse Error for Date Filter %@",e);
                    }
                    
                } //end of today filter
                else if(tomorrowIsActive == YES){
                    
                    //respect the next week filter
                    @try{
                        NSDate *todayDate = [NSDate date];
                        NSDate *tomorrowDate = [todayDate dateByAddingTimeInterval:60.0*60.0*24.0*7.0];
                        NSDateFormatter *formatFb = [[NSDateFormatter alloc] init];
                        [formatFb setDateFormat:@"dd/MM/yyyy HH:mm"];
                        NSDate *sourceDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24 * 60];
                        NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
                        float timeZoneOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate] / 3600.0;
                        [formatFb setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:timeZoneOffset]];
                        NSDate *setDate = [formatFb dateFromString:[annotation fbEventDate]];
                        
                        NSComparisonResult result;
                        result = [setDate compare:tomorrowDate];
                        if(result==NSOrderedAscending){
                            [_mapView addAnnotation:annotation];
                        }
                        else if(result==NSOrderedDescending){
                            [_mapView removeAnnotation:annotation];
                        }
                        else{
                            [_mapView addAnnotation:annotation];
                        }
                    }
                    @catch(NSException *e){
                        NSLog(@"Parse Error for Date Filter %@",e);
                    }
                    
                } //end of tomorrow filter
                else if(customDateIsActive == YES){
                    [self firedCustomEventChoice];
                }
                else{
                    [_mapView addAnnotation:annotation];
                }
        
            }
            @catch (NSException *exception) {
                NSLog(@"Exception Post annotation:%@ ",exception);
            }
            @finally {
                continue;
            }
        }//end of main outer try loop
    }
    [loadingDataWheel stopAnimating];
}


//Convert the Facebook Date String into a human-readable format
-(NSString*)getDateInfoFromFb:(NSString*)isoFacebookDateString
{
    NSString * stringToReturn = [[NSString alloc] init];
    
    //fix for facebook dates that are in non-ISO format and non-null
    if([isoFacebookDateString length] == 10){
        return isoFacebookDateString;
    }

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
    NSDate *dateFromString = [dateFormatter dateFromString:isoFacebookDateString];
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit units = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSDateComponents *components = [calendar components:units fromDate:dateFromString];
    
    //Add the date (dd:mm:yyyy)
    if([components day] < 10){
      stringToReturn = [stringToReturn stringByAppendingString:[NSString stringWithFormat:@"0%d",[components day]]];
    }
    
    else{
        stringToReturn = [stringToReturn stringByAppendingString:[NSString stringWithFormat:@"%d",[components day]]];
    }
    
    stringToReturn = [stringToReturn stringByAppendingString:@"/"];
    
    if([components month] < 10){
        stringToReturn = [stringToReturn stringByAppendingString:[NSString stringWithFormat:@"0%d",[components month]]];
    }
    
    else{
        stringToReturn = [stringToReturn stringByAppendingString:[NSString stringWithFormat:@"%d",[components month]]];
    }
    stringToReturn = [stringToReturn stringByAppendingString:@"/"];
    stringToReturn = [stringToReturn stringByAppendingString:[NSString stringWithFormat:@"%d",[components year]]];
    
    //Add the time in 24 hr (hour:minute)
    stringToReturn = [stringToReturn stringByAppendingString:@" "];
    if([components hour] < 10){
        stringToReturn = [stringToReturn stringByAppendingString:[NSString stringWithFormat:@"0%d",[components hour]]];
    }
    
    else{
        stringToReturn = [stringToReturn stringByAppendingString:[NSString stringWithFormat:@"%d",[components hour]]];
    }
    stringToReturn = [stringToReturn stringByAppendingString:@":"];
    if([components minute] < 10){
        stringToReturn = [stringToReturn stringByAppendingString:[NSString stringWithFormat:@"0%d",[components minute]]];
    }
    
    else{
        stringToReturn = [stringToReturn stringByAppendingString:[NSString stringWithFormat:@"%d",[components minute]]];
    }
    
    return stringToReturn;
}

- (NSString*)buildAddressToShow:(NSMutableDictionary*)venueInfo
{
    NSString *addressAsAString = [[NSString alloc] init];
    NSString *nameString;
    nameString = [venueInfo objectForKey:@"name"];
    if( nameString != nil){
        addressAsAString = [addressAsAString stringByAppendingString:nameString];
    }
    

    //see if the street field if present
    if(([venueInfo objectForKey:@"street"] != nil) || ((![[venueInfo objectForKey:@"street"] isEqual:@""]))){
        
        NSString *streetString = [venueInfo objectForKey:@"street"];
        if ([streetString rangeOfString:@","].location == NSNotFound) {
            //a comma is not present
            addressAsAString = [addressAsAString stringByAppendingFormat:@"%@",[venueInfo objectForKey:@"street"]];
        } else {
            //a comma is present!!
            NSString * newString = [[venueInfo objectForKey:@"street"] stringByReplacingOccurrencesOfString:@", " withString:@"\n"];
            addressAsAString = [addressAsAString stringByAppendingFormat:@"%@",newString];
        }
    }
    
    //see if the city field if present
    if( ([venueInfo objectForKey:@"city"] != nil) || ((![[venueInfo objectForKey:@"city"] isEqual:@""]))){
        if([venueInfo objectForKey:@"street"] != nil){
            //add an end line if the string is empty
            addressAsAString = [addressAsAString stringByAppendingFormat:@"\n"];
            //add the city information
            addressAsAString = [addressAsAString stringByAppendingFormat:@"%@",[venueInfo objectForKey:@"city"]];
        }
        else{
            //add the city information
            addressAsAString = [addressAsAString stringByAppendingFormat:@"%@",[venueInfo objectForKey:@"city"]];
        }
    }
    
    //see if the zip field if present
    if(([venueInfo objectForKey:@"zip"] != nil) || ([[venueInfo objectForKey:@"zip"] isEqual:@""])){
        if([venueInfo objectForKey:@"city"] != nil){
            //add an end line if the string is empty
            addressAsAString = [addressAsAString stringByAppendingFormat:@"\n"];
            //add the zip information
            addressAsAString = [addressAsAString stringByAppendingFormat:@"%@",[venueInfo objectForKey:@"zip"]];
        }
        else{
            //add the zip information
            addressAsAString = [addressAsAString stringByAppendingFormat:@"%@",[venueInfo objectForKey:@"zip"]];
        }
    }
    
    //see if the country field if present
    if(([venueInfo objectForKey:@"country"] != nil) || ([[venueInfo objectForKey:@"country"] isEqual:@""])){
        if([venueInfo objectForKey:@"zip"] != nil){
            //add an end line if the string is empty
            addressAsAString = [addressAsAString stringByAppendingFormat:@"\n"];
            //add the country information
            addressAsAString = [addressAsAString stringByAppendingFormat:@"%@",[venueInfo objectForKey:@"country"]];
        }
        else{
            //add the country information
            addressAsAString = [addressAsAString stringByAppendingFormat:@"%@",[venueInfo objectForKey:@"country"]];
        }
    }
    return addressAsAString;
    
}

- (void)viewDidUnload
{
    self.buttonLoginLogout = nil;
    [super viewDidUnload];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

-(void)reverseGeocodeLocation
{
    @try{
        double latitudeValue = self.mapView.centerCoordinate.latitude;
        double longitudeValue = self.mapView.centerCoordinate.longitude;
        CLLocation *rgLocation = [[CLLocation alloc] initWithLatitude:latitudeValue longitude:longitudeValue];
        self.reverseGeocodeLocationValue = rgLocation;
        CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
        [reverseGeocoder reverseGeocodeLocation:self.reverseGeocodeLocationValue completionHandler:^(NSArray *placemarks, NSError *error){
            if(error){
                NSLog(@"Geocode error: %@",error);
            }
            CLPlacemark *placemark = placemarks[0];
            NSLog(@"Found here %@", placemark.locality);
            [self setCurrentCity:placemark.locality];
            self.locationToSend = [NSMutableArray arrayWithObject:placemark];
            //only call the queryFunction if the data has changed
            if([loadFacebookDataFlag boolValue] == YES){
                if(self.currentCity != nil){
                    NSLog(@"calling query action from changed location");
                    [self queryButtonAction];
                }
                else{
                    [self queryButtonAction];
                }
            }
        }];
    }
    @catch(NSException *e){
        NSLog(@"Error in reverse Geocoder: %@",e);
    }
    
}

-(void)initReverseGeocodeLocation
{
    @try{
        double latitudeValue = self.mapView.centerCoordinate.latitude;
        double longitudeValue = self.mapView.centerCoordinate.longitude;
        CLLocation *rgLocation = [[CLLocation alloc] initWithLatitude:latitudeValue longitude:longitudeValue];
        self.reverseGeocodeLocationValue = rgLocation;
        CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
        NSLog(@"reverse Geolocator %@",self.reverseGeocodeLocationValue);
        [reverseGeocoder reverseGeocodeLocation:self.reverseGeocodeLocationValue completionHandler:^(NSArray *placemarks, NSError *error){
            if(error){
                NSLog(@"Geocode error: %@",error);
            }
            CLPlacemark *placemark = placemarks[0];
            NSLog(@"placemarks %@",placemarks);
            if(placemark.locality !=nil){
                NSLog(@"Found here %@", placemark.locality);
                [self setCurrentCity:placemark.locality];
                self.locationToSend = [NSMutableArray arrayWithObject:placemark];
            
                //only call the queryFunction if the data has changed
                if([loadFacebookDataFlag boolValue] == YES){
                    if(self.currentCity != nil){
                        NSLog(@"calling query action from changed location");
                        [self queryButtonAction];
                    }
                    else{
                        [self queryButtonAction];
                    }
                }
            }
            else{
                NSLog(@"Placemark is nil");
                [self initReverseGeocodeLocation];
            }
        }];
    }
    @catch(NSException *e){
        NSLog(@"Error in reverse Geocoder: %@",e);
    }
    
}

- (void)initLocationFind{
    @try{
        self.mapView.centerCoordinate = self.mapView.userLocation.location.coordinate;
        locationToZoom = self.mapView.userLocation.location.coordinate;
    }
    @catch(NSException *e){
        NSLog(@"Error in initialising %@",e);
    }
    
}

- (void)setMapCenterWithCoords:(CLLocationCoordinate2D)coords{
    self.mapView.centerCoordinate = coords;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"location to Zoom: %f",locationToZoom.latitude);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(locationToZoom, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
   
    [_mapView setRegion:viewRegion animated:YES];

    
    if((locationToZoom.longitude == -0.12750) || (locationToZoom.latitude== 51.50722)){
        if((firstLoad != YES) || ([backFromSearch boolValue] == YES)){
            [self performSelectorOnMainThread:@selector(initReverseGeocodeLocation) withObject:nil waitUntilDone:YES];
            [self updateTableView];
        }
    }
    
    if((firstLoad != YES) || ([backFromSearch boolValue] == YES)){
        [self performSelectorOnMainThread:@selector(initReverseGeocodeLocation) withObject:nil waitUntilDone:YES];
        [self updateTableView];
    }

    
    
}


@end
