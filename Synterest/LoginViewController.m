//
//  LoginViewController.m
//  Synterest
//
//  Created by Chris Jones on 27/04/2014.
//  Copyright (c) 2014 Chris Jones. All rights reserved.
//

#import "LoginViewController.h"


@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startUpButton;
- (IBAction)startUpButtonAction:(id)sender;
@end

@implementation LoginViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startUpButtonAction:(id)sender
{
    ViewController *mainMapView = [[UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil]
                                    instantiateViewControllerWithIdentifier:@"MainViewController"];
    [self.navigationController pushViewController:mainMapView animated:YES];
    
    
    //[self performSegueWithIdentifier:@"showWebServiceViewController" sender:nil];
    
    //[self performSegueWithIdentifier:@"login_sucess" sender:self];
}

//#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ViewController *mapViewController = [[ViewController alloc] init];
    //[segue];
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}*/


@end
