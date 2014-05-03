//
//  SearchViewController.m
//  Synterest
//
//  Created by Chris Jones on 27/04/2014.
//  Copyright (c) 2014 Chris Jones. All rights reserved.
//

#import "SearchViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface SearchViewController ()
@property (strong, nonatomic) NSMutableDictionary *placeDictionary;
-(void)geocodeLocationValue;

@end

@implementation SearchViewController

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
    
    [self geocodeLocationValue];
    // Do any additional setup after loading the view.
    
    //self.location = [[CLLocation alloc] init] ;
    //self.location.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)reverseGeocode:(id)sender
{
    [self reverseGeocodeLocation];
}

-(IBAction)goBacktoMap:(id)sender
{
    //[self geocodeLocationValue];
    [self performSegueWithIdentifier:@"back_from_search" sender:self];
}

-(void)geocodeLocationValue
{
    
    
    //beginnings of a geocoder...
    self.placeDictionary = [[NSMutableDictionary alloc] init];
    [self.placeDictionary setValue:nil forKey:@"Street"];
    [self.placeDictionary setValue:@"london"  forKey:@"City"];
    [self.placeDictionary setValue:@"UK" forKey:@"State"];
    [self.placeDictionary setValue:nil forKey:@"ZIP"];
    
    
    //CLLocationCoordinate2D coordinatesOfPosition;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressDictionary:self.placeDictionary completionHandler:^(NSArray *placemarks, NSError *error) {
        if([placemarks count]) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CLLocation *location = placemark.location;
            CLLocationCoordinate2D coordinateReverse = location.coordinate;
            self.locationValue = placemark.location;
            NSLog(@"coordinate %f",coordinateReverse.latitude);
            //[self.mapView setCenterCoordinate:coordinate animated:YES];
        } else {
            NSLog(@"error");
        }
        
    }];
    
    

    
}

-(void)reverseGeocodeLocation
{
    CLGeocoder *geocoder2 = [[CLGeocoder alloc] init];
    //CLLocationCoordinate2D coordinateReverse;
    //coordinateReverse.latitude = self.locationValue.coordinate.latitude;
    //coordinateReverse.longitude = self.locationValue.coordinate.longitude;
    [geocoder2 reverseGeocodeLocation:self.locationValue completionHandler:^(NSArray *placemarks, NSError *error){
        CLPlacemark *placemark = placemarks[0];
        NSLog(@"Found %@", placemark);
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    
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
