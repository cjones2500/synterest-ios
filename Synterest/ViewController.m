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
#import "AnnotationViewController.h"

@interface ViewController ()



@property (strong, nonatomic) IBOutlet UIButton *buttonLoginLogout;
@property (weak, nonatomic) IBOutlet UIButton *quitButton;

- (IBAction)buttonClickHandler:(id)sender;
- (void)updateView;
- (IBAction)fqlQueryAction:(id)sender;
- (void)queryButtonAction;
- (IBAction)quitButtonAction:(id)sender;
- (IBAction)goToLocationAction:(id)sender;

@end

//#define METERS_PER_MILE 1609.344
#define METERS_PER_MILE 10000.0


@implementation ViewController 

@synthesize facebookData,
dataToLoadToAnnotationView,
sideBarActivationState;

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

- (IBAction)goToLocationAction:(id)sender
{
    //locationManager.delegate = self;
    //locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //[locationManager startUpdatingLocation];
    //[_mapView removeAnnotations:_mapView.annotations];
    //self.mapView.centerCoordinate = self.mapView.userLocation.location.coordinate;
    //CLLocation *location = [locationManager location];
    //CLLocationCoordinate2D coordinateVal = [location coordinate];
    //CLLocationCoordinate2D newLocation = self.mapView.userLocation.location.coordinate;
    //NSLog(@"center of Map %f",coordinateVal.latitude);
    //NSLog(@"center of Map %f",coordinateVal.longitude);
    
    //[self updateView];
}

-(void)tapOnSearchDetected{
    
    [self toggleSideBarView];
    //[self performSegueWithIdentifier:@"search_screen_segue" sender:self];
}


//This overrides the current clicking function that occurs here
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [self performSegueWithIdentifier:@"annotation_selected" sender:view];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"annotation_selected"]) {
        MyLocation* anAnnotation =[sender annotation];
        //Pipe all the information for a given annotation across to the annotationViewController
        [[segue destinationViewController] setEventType:[anAnnotation eventType]];
        [[segue destinationViewController] setEventTitleText:[anAnnotation name]];
        [[segue destinationViewController] setEventFbPic:[anAnnotation facebookPic]];
        [[segue destinationViewController] setEventDescription:[anAnnotation fbDescription]];
        [[segue destinationViewController] setEventAddress:[anAnnotation fbLocData]];
        [[segue destinationViewController] setEventDate:[anAnnotation fbEventDate]];
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
        annotationView.canShowCallout = YES;
        
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Start the location Manager
    //locationManager = [[CLLocationManager alloc] init];
    
    //need to add the subviews first
    [self.view addSubview:self.sideBarView];
    [self.view addSubview:self.searchButtonSubView];
    [self.view insertSubview:self.sideBarView atIndex:2];
    [self.view insertSubview:self.searchButtonSubView atIndex:3];
    //[self insertSubview:(UIView *)view atIndex:(NSInteger)index;
    
    //Format the search button subView
    _searchButtonSubView.layer.masksToBounds = YES;
    _searchButtonSubView.backgroundColor = [UIColor whiteColor];
    _searchButtonSubView.layer.borderColor = [UIColor blackColor].CGColor;
    _searchButtonSubView.layer.borderWidth = 1.5;
    _searchButtonSubView.layer.cornerRadius = 19.0f;
    //[self.eventFbImageView addSubview:facebookImageSubView];
    
    //Format the sideBarView
    _sideBarView.layer.masksToBounds = YES;
    _sideBarView.layer.cornerRadius = 19.0f;
    //_sideBarView.backgroundColor = [UIColor whiteColor];
    _sideBarView.layer.borderColor = [UIColor blackColor].CGColor;
    _sideBarView.layer.borderWidth = 1.5f;
    
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

- (void)queryButtonAction
{
    //Get the synterest Model
    SynterestModel *aSynterestModel = [[SynterestModel alloc] init];

    //Standard Location query of facebook FQL
    NSString *query =@"SELECT eid, name,location,description, venue, start_time, update_time, end_time, pic FROM event WHERE contains('london') ORDER BY rand() LIMIT 200";
    
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
                                  NSDictionary *dictionary = (NSDictionary *)result;
                                  
                                  NSString *text;
                                  // we pull the name property out, if there is one, and display it
                                  text = (NSString *)[dictionary objectForKey:@"data"];
                                  
                                  //@try{
                                  facebookData = [aSynterestModel parseFbFqlResult:result];
                                  //}
                                  //NSLog(@"after parseFbFqlResult call");
                                  //@catch (NSException *exception) {
                                     // NSLog(@"Exception Post annotation:%@ ",exception);
                                  //}
                                  //@finally {
                                      //continue
                                  //}
                                  
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
                //continue;
            }
        }//end of main outer try loop
    }
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // 1
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = 51.50722;
    zoomLocation.longitude= -0.12750;
    
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    // 3
    [_mapView setRegion:viewRegion animated:YES];
   
}

@end
