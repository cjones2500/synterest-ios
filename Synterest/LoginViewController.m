//
//  LoginViewController.m
//  Synterest
//
//  Created by Chris Jones on 27/04/2014.
//  Copyright (c) 2014 Chris Jones. All rights reserved.
//

#import "LoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"


@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startUpButton;
@property (strong, nonatomic) IBOutlet UIButton *buttonLoginLogout;
- (IBAction)startUpButtonAction:(id)sender;
- (IBAction)buttonClickHandler:(id)sender;
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //custom initialisation
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateView];
    
    //Magic line that makes the mapView call the annotation script
    //_mapView.delegate=self;
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startUpButtonAction:(id)sender
{
    ViewController *mainMapView = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil]
                                    instantiateViewControllerWithIdentifier:@"ViewController"];
    [self.navigationController pushViewController:mainMapView animated:YES];
    
    
    //[self performSegueWithIdentifier:@"showWebServiceViewController" sender:nil];
    
    //This works quite well
    //[self performSegueWithIdentifier:@"login_sucess" sender:self];
}

// FBSample logic
// handler for button click, logs sessions in or out
- (IBAction)buttonClickHandler:(id)sender {
    
    // get the app delegate so that we can access the session property
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
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

// FBSample logic
// main helper method to update the UI to reflect the current state of the session.
- (void)updateView {
    // get the app delegate, so that we can reference the session property
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (appDelegate.session.isOpen) {
        
        // valid account UI is shown whenever the session is open
        [self.buttonLoginLogout setTitle:@"Log out" forState:UIControlStateNormal];
        //[self performSegueWithIdentifier:@"login_sucess" sender:self];
        
    } else {
        // login-needed account UI is shown whenever the session is closed
        [self.buttonLoginLogout setTitle:@"Log in" forState:UIControlStateNormal];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    // get the app delegate, so that we can reference the session property
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (appDelegate.session.isOpen) {
        [self performSegueWithIdentifier:@"login_sucess" sender:self];
    }
}

//#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"login_sucess"])
    {
        ViewController *yourVC = [segue destinationViewController];
    }
    NSLog(@"in prepare segue");
    if ([segue.identifier isEqualToString:@"login_sucess"]) {
        ViewController *mapViewController = [[ViewController alloc] init];
        mapViewController =[segue destinationViewController];
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    
    //if ([[segue identifier] isEqualToString:@"login_sucess"]) {
        
        // Get destination view
    //ViewController *mapViewController = [[ViewController alloc] init];
    //mapViewController =[segue destinationViewController];
        
        // Get button tag number (or do whatever you need to do here, based on your object
        //NSInteger tagIndex = [(UIButton *)sender tag];
        
        // Pass the information to your destination view
        //[vc setSelectedButton:tagIndex];
    //}
    
}*/


@end
