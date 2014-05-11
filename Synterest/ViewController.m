//
//  ViewController.m
//  Synterest
//
//  Created by Chris Jones on 12/04/2014.
//  Copyright (c) 2014 Chris Jones. All rights reserved.
//

//appDelegate.session.accessTokenData.accessToken - this is the accessor for the accessToken 

#import "AppDelegate.h"
#import "ViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <AddressBook/AddressBook.h>
#import <MapKit/MapKit.h>
#import "MyLocation.h"
#import "SynterestModel.h"
#import <CoreLocation/CoreLocation.h>
#import "SearchViewController.h"

@interface ViewController ()



@property (strong, nonatomic) IBOutlet UIButton *buttonLoginLogout;
@property (weak, nonatomic) IBOutlet UIButton *quitButton;
@property (strong, nonatomic) NSMutableDictionary *placeDictionary;

- (IBAction)buttonClickHandler:(id)sender;
- (void)updateView;
- (IBAction)fqlQueryAction:(id)sender;
- (void)queryButtonAction;
- (IBAction)quitButtonAction:(id)sender;
- (IBAction)goToLocationAction:(id)sender;

@end

//#define METERS_PER_MILE 1609.344
#define METERS_PER_MILE 10000.0


@implementation ViewController{
    BOOL finishedLoadingExtraData;
}

@synthesize facebookData,
currentCity,
dataToLoadToAnnotationView,
loadFacebookDataFlag,
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

-(IBAction)goBackFromAnnotationViewAction:(id)sender
{
    [self hideAnnotationView];
}


//called at the beginning of loading a view
- (void)loadView{
    
    if(_zoomLocation == nil){
        NSLog(@"zoomLocation is nil");
        locationToZoom.latitude = 51.50722;
        locationToZoom.longitude = -0.12750;
    }
    else{
        //unpack the zoomLocation variable
        @try{
            CLPlacemark * recievedPlacemark = [_zoomLocation objectAtIndex:0];
            locationToZoom.latitude = recievedPlacemark.location.coordinate.latitude;
            locationToZoom.longitude = recievedPlacemark.location.coordinate.longitude;
        }
        @catch(NSException *error){
            NSLog(@"Error: %@",error);
            NSLog(@"Unreadable location. Moving to London");
            //locationToZoom.latitude = 51.50722;
            //locationToZoom.longitude = -0.12750;
        }
    }
    
    //call the normal method of loadView (before override)
    [super loadView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

//fires when the mapview center is changed (includes zooming in and out)
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    //need to fix this such that there is no random increasing of this value
    //[self reverseGeocodeLocation];
    
    //[self reverseGeocodeLocation];
    //check to see how many icons are in the view
    //increase this to a certain value when the uses changes where they are
    
    //this is implemented to stop the search function firing when the user zooms in but only when they move
    /*NSLog(@"mapview changed");
    double longitudeLimit = 0.02;
    double latitudeLimit = 0.02;
    //CLPlacemark * centerPlacemark = [_zoomLocation objectAtIndex:0];
    double currentCenterLongitude = self.mapView.centerCoordinate.longitude;
    double currentCenterLatitude = self.mapView.centerCoordinate.latitude;
    NSLog(@" currentLatitude %f",currentCenterLatitude);
    NSLog(@" currentPlacemarkLatitude %f",locationToZoom.latitude);
    if( (currentCenterLongitude > locationToZoom.longitude + longitudeLimit) ||(currentCenterLongitude < locationToZoom.longitude - longitudeLimit)){
        NSLog(@"in here");
        //[self plotFacebookData:nil];
        //[self queryButtonAction];
        [NSThread detachNewThreadSelector:@selector(queryButtonAction) toTarget:self withObject:nil];
    }
    else if((currentCenterLatitude > locationToZoom.latitude + latitudeLimit) ||(currentCenterLatitude < locationToZoom.latitude - latitudeLimit)){
        //[self plotFacebookData:nil];
        //[self queryButtonAction];
        [NSThread detachNewThreadSelector:@selector(queryButtonAction) toTarget:self withObject:nil];
    }
    else{
        //do nothing
    }*/
}

//- (void)mapView:(MKMapView *)aMapView didAddAnnotationViews:(NSArray *)views{
//    NSLog(@"getting called here");
//    [self queryButtonAction];
//}


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
    self.listViewAnnotations = [NSMutableArray arrayWithCapacity:1];
    for (id value in self.mapView.annotations){
        MyLocation *annotation = value;
        [self.listViewAnnotations addObject:annotation];
        [self.listTableView reloadData];
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
        NSLog(@"annotation: %@",anAnnotation.fbDescription);
        [self loadAnnotationView:anAnnotation];
        [self unHideAnnotationView];
        //[self hideListView];
    }
    @catch(NSException *e){
        NSLog(@"MyLocation assignment error %@",e);
    }
}

-(void)loadAnnotationView:(MyLocation*)anAnnotation{
    @try{
        self.fbEventAddress.text = [anAnnotation fbLocData];
        self.fbEventDate.text = [anAnnotation fbEventDate];
        self.fbEventDescription.text = [anAnnotation fbDescription];
        self.fbEventTitle.text = [anAnnotation name];
        [NSThread detachNewThreadSelector:@selector(loadFacebookPicture:) toTarget:self withObject:[anAnnotation facebookPic]];
    }
    @catch(NSException *e){
        NSLog(@"Parsing Error %@",e);
    }
}

-(void)unHideAnnotationView
{
    //remove the data from any exsisting subview
    /*self.fbEventTitle.text = nil;
    self.fbEventDate.text = nil;
    self.fbEventDescription.text = nil;
    self.fbEventAddress.text = nil;*/
    //Remove all the subviews
    for(UIView *subview in self.facebookImageSubView.subviews)
    {
        [subview removeFromSuperview];
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
    [self updateTableView];
    //NSLog(@"self.listViewAnnotations: %@",self.listViewAnnotations);
    //[self updateTableView];
    [self.listTableView reloadData];
    NSLog(@"listView frame height : %f",self.listView.frame.size.height);
    
    //add a delay to make sure this happens
    //[self unHideFirstTime];
    //[self performSelector:@selector(unHideFirstTime) withObject:nil afterDelay:.1];
    
    
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
    CLLocationCoordinate2D newLocation = self.mapView.userLocation.location.coordinate;
    NSLog(@"center of Map %f",newLocation.latitude);
    NSLog(@"center of Map %f",newLocation.longitude);
    
    //TODO:Add the ability to prompt location services if not activated
    
    //Don't move unless there are real values
    if( (self.mapView.userLocation.location.coordinate.latitude == 0.0) || (self.mapView.userLocation.location.coordinate.latitude == 0.0)){
        NSLog(@"No Real Location Given or location not simulated");
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
    //[self performSegueWithIdentifier:@"search_screen_segue" sender:self];
}


//This overrides the current clicking function that occurs here
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"clicked on an annotation");
    [self unHideAnnotationView];
    MyLocation* anAnnotation =[view annotation];
    [NSThread detachNewThreadSelector:@selector(loadFacebookPicture:) toTarget:self withObject:[anAnnotation facebookPic]];
    self.fbEventAddress.text = [anAnnotation fbLocData];
    self.fbEventDate.text = [anAnnotation fbEventDate];
    self.fbEventDescription.text = [anAnnotation fbDescription];
    self.fbEventTitle.text = [anAnnotation name];
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
            annotationView.image=[UIImage imageNamed:@"yellow.png"];
        }
        else if ([[annotation eventType] intValue] == 1){
            //party event
            annotationView.image=[UIImage imageNamed:@"green.png"];
        }
        else if ([[annotation eventType] intValue] == 2){
            //sport event
            annotationView.image=[UIImage imageNamed:@"orange.png"];
        }
        else if ([[annotation eventType] intValue] == 3){
            //music event
            annotationView.image=[UIImage imageNamed:@"white.png"];
        }
        else if ([[annotation eventType] intValue] == 4){
            //intellectual event
            annotationView.image=[UIImage imageNamed:@"pink2.png"];
        }
        else if ([[annotation eventType] intValue] == 5){
            //food event
            annotationView.image=[UIImage imageNamed:@"blue.png"];
        }
        else{
            //use the default value
        }
        
        return annotationView;
    }
    
    return nil;
}

/*- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation  {
    
    CLLocationCoordinate2D loc = [newLocation coordinate];
    //if this is initial view then do this
    if([firstViewFlag boolValue] == YES){
        NSLog(@"First View");
        [self.mapView setCenterCoordinate:loc];
    }
    
}*/

-(IBAction)clickOnFacebook:(id)sender{
    
    //NSArray *arrayOfKeywords = [NSArray arrayWithObjects:@"music",@"gig",@"food",@"drink",@"band", nil];
    NSArray *arrayOfKeywords = [NSArray arrayWithObjects:@"music", nil];
    for (id keyword in arrayOfKeywords){
        // Set the flag to YES
        __block BOOL waitingForBlock = YES;
        NSLog(@"keyword: %@",keyword);
        [self extendAnnotationsOnMap:keyword withCompletion:^(BOOL finished) {
            if(finished){
                NSLog(@"success");
                NSLog(@"completion value");
                waitingForBlock = NO;
                //do somestuff
                //[self addNewDataToMap:self.extraFacebookData];
                // Assert the truth
                //finished = YES;
            }
        }];
    
        // Run the loop
        while(waitingForBlock) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate dateWithTimeIntervalSinceNow:10.0]];
        }
    }
    
    //[NSThread detachNewThreadSelector:@selector(extendAnnotationsOnMap) toTarget:self withObject:nil];
}

//changes when the user location is updated or changed
/*-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self.mapView setCenterCoordinate: userLocation.location.coordinate animated: NO];
    [self reverseGeocodeLocation];
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init] ;
    self.locationManager.delegate = self;
    //[self.locationManager startUpdatingLocation];
    
    self.mapView.showsUserLocation=YES;
    /*CLLocationCoordinate2D loc = [self.locationManager.location coordinate];
    if([firstViewFlag boolValue] == YES){
        NSLog(@"First View");
        [self.mapView setCenterCoordinate:loc];
    }*/
    
    //Start the location Manager
    //locationManager = [[CLLocationManager alloc] init];
    
    //self.listTableView.delegate = self;
    
    //need to add the subviews first
    [self.view addSubview:self.sideBarView];
    [self.view addSubview:self.searchButtonSubView];
    [self.view addSubview:self.annotationBarView];
    [self.view addSubview:self.listView];
    
    [self.view insertSubview:self.sideBarView atIndex:2];
    [self.view insertSubview:self.searchButtonSubView atIndex:3];
    [self.view insertSubview:self.annotationBarView atIndex:4];
    [self.view insertSubview:self.listView atIndex:4];
    //be very careful with the indexes as they might prevent gesture functions from working
    
    //keeps items within the view
    self.annotationBarView.layer.masksToBounds = YES;
    
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
    
    
    
    //start the sidebar in the deactivated state
    [self toggleSideBarView];
    
    //Set up behaviour if for the imageView
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnSearchDetected)];
    singleTap.numberOfTapsRequired = 1;
    _searchButtonSubView.userInteractionEnabled = YES;
    [_searchButtonSubView addGestureRecognizer:singleTap];
    
    /*_searchButton.backgroundColor = [UIColor whiteColor];
    _searchButton.layer.borderColor = [UIColor blackColor].CGColor;
    _searchButton.layer.borderWidth = 0.5f;
    _searchButton.layer.cornerRadius = 10.0f;*/
    
    //Magic line that makes the mapView call the annotation script
    _mapView.delegate=self;
    
    self.loadingDataWheel.color = [UIColor blackColor];
    
    [self updateView];
    
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
                [self updateView];
            }];
        }
    }
    
}

// FBSample logic
// main helper method to update the UI to reflect the current state of the session.
- (void)updateView {
    // get the app delegate, so that we can reference the session property
    /*AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (appDelegate.session.isOpen) {
        // valid account UI is shown whenever the session is open
        [self.buttonLoginLogout setTitle:@"Log out" forState:UIControlStateNormal];
    } else {
        // login-needed account UI is shown whenever the session is closed
        [self.buttonLoginLogout setTitle:@"Log in" forState:UIControlStateNormal];
    }*/
    
    //Get the synterest Model
    SynterestModel *aSynterestModel = [[SynterestModel alloc] init];
    //Place Data on the screen if any is stored in Memory
    NSMutableArray* savedFacebookData =[aSynterestModel loadLocalData];
    //NSLog(@"savedFacebookData: %@",savedFacebookData);
    //check to see if there is actually some facebook data
    if(savedFacebookData != NULL){
        //NSLog(@"loading data...");
        [self plotFacebookData:savedFacebookData];
    }
    
    [self updateTableView];
}

-(void)setUpListView
{
    NSLog(@"unhide listView");
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

- (IBAction)fqlQueryAction:(id)sender
{
    //[NSThread detachNewThreadSelector:@selector(queryButtonAction) toTarget:self withObject:nil];
    
    [self queryButtonAction];
}

- (IBAction)searchButtonAction:(id)sender
{
    
    [self performSegueWithIdentifier:@"search_screen_segue" sender:self];
}

- (IBAction)quitButtonAction:(id)sender
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
    //finishedLoadingExtraData = NO;
    self.extraFacebookData = [[NSMutableArray alloc] initWithCapacity:100];
    NSLog(@"keyword %@",keywordString);
    //[self performSelector:@selector(queryFacebookDb:) withObject:keyword];
    [self performSelectorOnMainThread:@selector(queryFacebookDb:) withObject:keywordString waitUntilDone:YES];
    compblock(YES);
    
}

-(void)queryFacebookDb:(NSString*)queryString
{
    NSString *query;
    @try{
        if(self.currentCity != nil){
            query = [NSString stringWithFormat:@"SELECT eid, name,location,description, venue, start_time, update_time, end_time, pic FROM event WHERE contains('%@ %@') ORDER BY rand() LIMIT 100",self.currentCity,queryString];
        }
        else{
            query =@"SELECT eid, name,location,description, venue, start_time, update_time, end_time, pic FROM event WHERE contains('London') ORDER BY rand() LIMIT 3";
            NSLog(@"self.currentCity = null string");
        }
    }
    @catch(NSException *e){
        NSLog(@"Error appending string: %@",e);
        query =@"SELECT eid, name,location,description, venue, start_time, update_time, end_time, pic FROM event WHERE contains('London') ORDER BY rand() LIMIT 3";
    }
    //AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    //[FBSession setActiveSession:appDelegate.session];
    //SynterestModel *aSynterestModel = [[SynterestModel alloc] init];
    NSDictionary *queryParam = @{ @"q": query };
    
    
    //NSLog(@"in here with query string %@",query);
    // Make the API request that uses FQL
    [FBRequestConnection startWithGraphPath:@"/fql"
                                 parameters:queryParam
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result,
                                              NSError *error) {
                              if (error) {
                                  NSLog(@"Error: %@", [error localizedDescription]);
                              } else {
                                  NSLog(@"in here extending the view");
                                  [self.extraFacebookData addObject:result];
                                  //self.extraFacebookData =[aSynterestModel performSelector:@selector(parseFbFqlResult:) withObject:result];
                                  [self addNewDataToMap:self.extraFacebookData];
                                  /*[aSynterestModel performSelector:@selector(saveAdditionalLocalData:) withObject:facebookData];
                                  NSMutableArray* savedFacebookData =[aSynterestModel loadLocalData];
                                  [self plotFacebookData:savedFacebookData];*/
                                  //[self addNewDataToMap:self.extraFacebookData];
                              }
                          }];
}

-(void)addNewDataToMap:(NSMutableArray*)newFacebookData
{
    NSLog(@"add data to map");
    NSLog(@"new facebook data: %@",newFacebookData);
    SynterestModel *aSynterestModel = [[SynterestModel alloc] init];
    self.additionalFacebookData =[aSynterestModel performSelector:@selector(parseFbFqlResult:) withObject:self.extraFacebookData[0]];
     
     [aSynterestModel performSelector:@selector(saveAdditionalLocalData:) withObject:self.additionalFacebookData];
     NSMutableArray* savedFacebookData =[aSynterestModel loadLocalData];
     [self plotFacebookData:savedFacebookData];
}


- (void)queryButtonAction
{
    [loadingDataWheel startAnimating];
    //Get the synterest Model
    SynterestModel *aSynterestModel = [[SynterestModel alloc] init];

    NSString *query;// = [[NSString alloc] init];
    //Standard Location query of facebook FQL
    @try{
        //avoid using null values of currentCity
        if(self.currentCity != nil){
            query = [NSString stringWithFormat:@"SELECT eid, name,location,description, venue, start_time, update_time, end_time, pic FROM event WHERE contains('%@') ORDER BY rand() LIMIT 3",self.currentCity];
            NSLog(@" string in question %@",self.currentCity);
        }
        else{
            query =@"SELECT eid, name,location,description, venue, start_time, update_time, end_time, pic FROM event WHERE contains('London') ORDER BY rand() LIMIT 3";
            NSLog(@"self.currentCity = null string");
        }
    }
    @catch(NSException *e){
        NSLog(@"Error appending string: %@",e);
        //NSLog(@" string in question %@",self.currentCity);
        //default the automatic search to London if there is uncertainty
        query =@"SELECT eid, name,location,description, venue, start_time, update_time, end_time, pic FROM event WHERE contains('London') ORDER BY rand() LIMIT 3";
    }
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    [FBSession setActiveSession:appDelegate.session];
    
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
                                  
                                  NSLog(@"Error: %@", [error localizedDescription]);
                                  
                              } else {
                                  //do things with the result here
                                  //NSLog(@"Result: %@",[connection description]);
                                  
                                  // result is the json response from a successful request
                                  //NSDictionary *dictionary = (NSDictionary *)result;
                                  
                                  //NSString *text;
                                  // we pull the name property out, if there is one, and display it
                                  //text = (NSString *)[dictionary objectForKey:@"data"];
                                  
                                  //@try{
                                  //NSLog(@"in here before facebookData assigned");
                                  //NSLog(@"connection %@",connection);
                                  //NSLog(@"result %@",result);
                                  
                                  //this required the selection to wait
                                  self.facebookData =[aSynterestModel performSelector:@selector(parseFbFqlResult:) withObject:result];
                                  
                                  //self.facebookData = [aSynterestModel parseFbFqlResult:result];
                                  //NSLog(@"facebookData : %@",[aSynterestModel parseFbFqlResult:result]);
                                  //NSLog(@"facebookData : %@",self.facebookData);
                                  //self.facebookData = [aSynterestModel parseFbFqlResult:result];
                                  //}
                                  //NSLog(@"after parseFbFqlResult call");
                                  //@catch (NSException *exception) {
                                     // NSLog(@"Exception Post annotation:%@ ",exception);
                                  //}
                                  //@finally {
                                      //continue
                                  //}
                                  
                                  //place a thread in here
                                  
                                  //Save the facebook Data
                                  [aSynterestModel saveLocalData:facebookData];
                                  //NSLog(@"after saveLocalData call");
                                  
                                  //Load back the saved facebook Data
                                  NSMutableArray* savedFacebookData =[aSynterestModel loadLocalData];
                                  //NSLog(@"after loadLocalData call");
                                  [self plotFacebookData:savedFacebookData];
                                  //NSLog(@"after plotFacebookData call");
                                  //NSLog(@"json dictionary %@",[[[dictionary objectForKey:@"data"] objectAtIndex:0] objectForKey:@"eid"]);
                                  
                              }
                          }];
    
    if (!appDelegate.session.isOpen) {
        NSLog(@"Session Not Open in FQL Query");
    }
    else{
        //do nothing all is good
        //NSLog(@"Access token is here %@",appDelegate.session.accessTokenData);
    }
    
}

- (void)plotFacebookData:(NSMutableArray *)responseData
{
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        [_mapView removeAnnotation:annotation];
    }
    
    NSLog(@"num of dataPoints %u",[responseData count]);
    
    for (NSMutableDictionary *singlePoint in responseData)
    {

        //NSLog(@"latitude : %@",[[singlePoint objectForKey:@"venue"] objectForKey:@"latitude"]);
        //NSLog(@"descp. :%@",singlePoint);

        
        //this is for events that have no start time
        /*if([singlePoint objectForKey:@"start_time"] == NULL){
            continue;
        }*/
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
                //NSLog(@"start_time : %@",[singlePoint objectForKey:@"start_time"]);
                //NSLog(@"latitude : %@",[[singlePoint objectForKey:@"venue"] objectForKey:@"latitude"]);
                CLLocationCoordinate2D coordinates;
                coordinates.latitude = latitude;
                coordinates.longitude = longitude;
                //NSLog(@"logging...");
                //NSLog(@" coordinates %f",coordinates.latitude);
                //InitWithName gives a description
                //NSLog(@" pic value %@",[singlePoint objectForKey:@"venue"]);
            
                
                NSString *fbAdress = [self buildAddressToShow:[singlePoint objectForKey:@"venue"]];
            
                MyLocation *annotation = [[MyLocation alloc] initWithName:[singlePoint objectForKey:@"name"]
                                                               address:nil
                                                            coordinate:coordinates
                                                           typeOfEvent:eventType
                                                       withFacebookPic:[singlePoint objectForKey:@"pic"]
                                                       withDescription:[singlePoint objectForKey:@"description"]
                                                        withFbLocData:fbAdress
                                                      withFbEventDate:facebookDateString];
            
                [_mapView addAnnotation:annotation];
        
            }
            @catch (NSException *exception) {
                NSLog(@"Exception Post annotation:%@ ",exception);
            }
            @finally {
                //[loadingDataWheel stopAnimating];
                continue;
            }
        }//end of main outer try loop
    }
    [loadingDataWheel stopAnimating];
}


//Convert the Facebook Date String into a human-readable format
-(NSString*)getDateInfoFromFb:(NSString*)isoFacebookDateString
{
    //NSLog(@"date value:%@",isoFacebookDateString);
    //NSLog(@"date value:%i",[isoFacebookDateString length]);
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
    //NSLog(@" test: %@",[venueInfo objectForKey:@"name"]);
    NSString *addressAsAString = [[NSString alloc] init];
    NSString *nameString;
    nameString = [venueInfo objectForKey:@"name"];
    
    //@try{
    //see if the name field is present, if so add this
    if(nameString != nil){
        addressAsAString = [addressAsAString stringByAppendingString:nameString];
    }

    //see if the street field if present
    if([venueInfo objectForKey:@"street"] != nil){
        if(addressAsAString != nil){
            //add an end line if the string is empty
            //addressAsAString = [addressAsAString stringByAppendingFormat:@",\n"];
            //add the street information
            addressAsAString = [addressAsAString stringByAppendingFormat:@"%@",[venueInfo objectForKey:@"street"]];
        }
        else{
            //add the street information
            addressAsAString = [addressAsAString stringByAppendingFormat:@"%@",[venueInfo objectForKey:@"street"]];
        }
    }
    
    //see if the city field if present
    if([venueInfo objectForKey:@"city"] != nil){
        if(addressAsAString != nil){
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
    if([venueInfo objectForKey:@"zip"] != nil){
        if(addressAsAString != nil){
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
    if([venueInfo objectForKey:@"country"] != nil){
        if(addressAsAString != nil){
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
    //}//end of try statement
    //@catch (NSException *exception) {
    //    NSLog(@"Exception fbAddress annotation:%@ ",exception);
    ///}
    //@finally {
    //    return nil;
    //}
    
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
    // Return YES for supported orientations
    /*if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }*/
    return NO;
}

-(void)reverseGeocodeLocation
{
    @try{
        double latitudeValue = self.mapView.centerCoordinate.latitude;
        double longitudeValue = self.mapView.centerCoordinate.longitude;
        CLLocation *testLocation = [[CLLocation alloc] initWithLatitude:latitudeValue longitude:longitudeValue];
        self.reverseGeocodeLocationValue = testLocation;
        CLGeocoder *reverseGeocoder = [[CLGeocoder alloc] init];
        [reverseGeocoder reverseGeocodeLocation:self.reverseGeocodeLocationValue completionHandler:^(NSArray *placemarks, NSError *error){
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
            }
            //NSLog(@"current city inside block: %@",self.currentCity);
        }];
        //NSLog(@"current city outside block: %@",self.currentCity);
    }
    @catch(NSException *e){
        NSLog(@"Error in reverse Geocoder: %@",e);
    }
    
}

- (void)setMapCenterWithCoords:(CLLocationCoordinate2D)coords{
    //MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    //[_mapView setRegion:viewRegion animated:YES];
    
    self.mapView.centerCoordinate = coords;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    //CLLocationCoordinate2D setZoomLocation;
    // 1
    //setZoomLocation.latitude = 51.50722;
    //setZoomLocation.longitude= -0.12750;
    //NSLog(@"location to zoom %f",locationToZoom.latitude);
    //self.mapView. = locationToZoom;
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(locationToZoom, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    // 3
    [_mapView setRegion:viewRegion animated:YES];
    
    [self reverseGeocodeLocation];
    [self updateTableView];
    
}


@end
