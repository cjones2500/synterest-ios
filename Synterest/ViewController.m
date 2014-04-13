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

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIButton *buttonLoginLogout;

- (IBAction)buttonClickHandler:(id)sender;
- (void)updateView;
- (void) fqlRequest:(NSString*)fqlQuery;
- (IBAction)fqlQueryAction:(id)sender;
- (void)queryButtonAction;

@end

#define METERS_PER_MILE 1609.344

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
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
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (appDelegate.session.isOpen) {
        // valid account UI is shown whenever the session is open
        [self.buttonLoginLogout setTitle:@"Log out" forState:UIControlStateNormal];
    } else {
        // login-needed account UI is shown whenever the session is closed
        [self.buttonLoginLogout setTitle:@"Log in" forState:UIControlStateNormal];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)queryButtonAction
{

    //Standard Location query of facebook FQL
    NSString *query =@"SELECT eid, name,location,description, venue, start_time, update_time, end_time, pic FROM event WHERE contains('London') ORDER BY rand() LIMIT 25 ";
    
    NSLog(@"before session active %@\n",[FBSession activeSession]);
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    
    NSLog(@"after session active %@\n",[FBSession activeSession]);
    NSLog(@"after session active %@\n",appDelegate.session);
    
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
                                  NSLog(@"Result: %@", result);
                              }
                          }];
    
    if (!appDelegate.session.isOpen) {
        NSLog(@"Session Not Open in FQL Query");
    }
    else{
        NSLog(@"Access token is here %@",appDelegate.session.accessTokenData);
    }
    
}

- (void) fqlRequest:(NSString*)fqlQuery
{
    //Facebook* facebook = [[Facebook alloc] initWithAppId:@&quot;YOUR_APP_ID&quot;];
    
    NSString *query = [NSString stringWithString:fqlQuery];  //begins from SELECT........
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    query, @"q",
                                    nil];
    
    FBRequest *request = [FBRequest requestWithGraphPath:@"/fql" parameters:params HTTPMethod:@"GET"];
    
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        //do your stuff
        NSLog(@"connection %@\n",connection);
        NSLog(@"error %@\n",error);
        NSLog(@"results %@\n",result);
        
    }];
    
    //or you can do it also with the following class method:
    
    /*[FBRequestConnection startWithGraphPath:@"/fql" parameters:params HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection,id result,NSError *error) {
        //do your stuff
        
        
    }];*/
    
    //return result;
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
    zoomLocation.latitude = 39.281516;
    zoomLocation.longitude= -76.580806;
    
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    // 3
    [_mapView setRegion:viewRegion animated:YES];
}

@end
