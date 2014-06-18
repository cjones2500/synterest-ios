		//
//  SearchViewController.m
//  Synterest
//
//  Created by Chris Jones on 27/04/2014.
//  Copyright (c) 2014 Chris Jones. All rights reserved.
//

#import "SearchViewController.h"
#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface SearchViewController ()
@property (strong, nonatomic) NSMutableDictionary *placeDictionary;
@property (strong, nonatomic) CLGeocoder *geocoder22;
@property (strong, nonatomic) CLPlacemark *placemark22;

-(void)geocodeLocationValue:(NSString*)aCityToSearch;
-(void)callbackFromSearchBar;

@end


@implementation SearchViewController

@synthesize currentSearchViewInformation;

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
    
    //magic line that delegates the functionality to the searchBar itself
    _searchBar.delegate = self;
    self.synterestTableView.delegate =self;
    //initialise the array of searchValue
    searchValues = [NSArray arrayWithObjects:nil];
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

-(void)geocodeLocationValue:(NSString*)aCityToSearch
{
    //aCityToSearch = [aCityToSearch stringByAppendingString:@""];
    //beginnings of a geocoder...
    self.placeDictionary = [[NSMutableDictionary alloc] init];

    [self.placeDictionary setValue:nil forKey:@"Street"];
    [self.placeDictionary setValue:aCityToSearch  forKey:@"City"];
    [self.placeDictionary setValue:nil forKey:@"State"];
    [self.placeDictionary setValue:nil forKey:@"ZIP"];
    
    
    //CLLocationCoordinate2D coordinatesOfPosition;
    
    //dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressDictionary:self.placeDictionary completionHandler:^(NSArray *placemarks, NSError *error) {
        if([placemarks count]) {
            self.locationValueArray = placemarks;
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            self.locationValue = placemark.location;

            [self callbackFromSearchBar];
        } else {
            //occurs if there are no placemarks
            searchValues = [NSArray arrayWithArray:nil];
            NSLog(@"error: %@",error);

        }
        
    }];
}

-(void)callbackFromSearchBar
{
    searchValues = [NSArray arrayWithObjects:nil];
    //reinitialise the current information
    
    @try{
        self.freshSearchViewInformation = [[NSMutableArray alloc] initWithCapacity:100];
        //currentSearchViewInformation = [[NSMutableArray alloc] initWithCapacity:100];
        NSMutableArray *mutablePlacemarkArrayToFill = [[NSMutableArray alloc] initWithCapacity:100];
        int numberOfMembers = [self.locationValueArray count];
        NSLog(@" no of members %i",numberOfMembers);
        for(int i=0;i < numberOfMembers;i++){
            CLPlacemark *placemark = [self.locationValueArray objectAtIndex:i];
            NSString *placemarkLocality = [NSString stringWithString:placemark.locality];
            NSString *placemarkCountry = [NSString stringWithString:placemark.country];
            NSString *stringToPrint;
            if( (placemarkLocality == NULL) && (placemarkCountry == NULL)){
                continue;//both items are NULL, meaningless result
            }
            else if( ([placemarkLocality length] == 0) && ([placemarkCountry length] == 0)){
                //NSLog(@"no locality");
                stringToPrint = [NSString stringWithFormat:@"%@",placemarkLocality];
            }
            else if( ([placemarkLocality length] == 0) && ([placemarkCountry length] != 0)){
                //stringToPrint = [NSString stringWithFormat:nil];
                continue; //meaningless if only the country is visible
            }
            else if( ([placemarkLocality length] != 0) && ([placemarkCountry length] != 0)){
                stringToPrint = [NSString stringWithFormat:@"%@, %@",placemarkLocality,placemarkCountry];
            }
            else{
                NSLog(@"Error: Unknown location");
            }
            
            [mutablePlacemarkArrayToFill setObject:stringToPrint atIndexedSubscript:i];
            [_freshSearchViewInformation setObject:placemark atIndexedSubscript:i];
        }
        
        NSArray *placemarkArrayToFill = [NSArray arrayWithArray:mutablePlacemarkArrayToFill];
        NSLog(@"arrray %@",mutablePlacemarkArrayToFill);
        searchValues = [NSArray arrayWithArray:placemarkArrayToFill];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Error %@",exception);
    }
    @finally{
        [self.synterestTableView reloadData];
    }
}


-(void)reverseGeocodeLocation
{
    CLGeocoder *geocoder2 = [[CLGeocoder alloc] init];
    [geocoder2 reverseGeocodeLocation:self.locationValue completionHandler:^(NSArray *placemarks, NSError *error){
        //CLPlacemark *placemark = placemarks[0];
        NSLog(@"Found %@", placemarks);
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] != 0) {
        [self geocodeLocationValue:[_searchBar text]];
    }
    else{
        //do nothing
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if ([searchBar.text length] != 0) {
        [self geocodeLocationValue:[_searchBar text]];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [searchValues count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.textLabel.text = [searchValues objectAtIndex:indexPath.row];
    
    //format the image with the cell
    UIImage *logoImage = [UIImage imageNamed:@"logo_mini.png"];
    cell.imageView.layer.cornerRadius = 30.0;
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.image = logoImage;
    return cell;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

//called when a cell is selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
    inforamtionToSendBacktoMainView = [NSArray arrayWithObject:[_freshSearchViewInformation objectAtIndexedSubscript:indexPath.row]];
    [self performSegueWithIdentifier:@"back_from_search" sender:inforamtionToSendBacktoMainView];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSNumber *numberToSend = [NSNumber numberWithBool:YES];
    [[segue destinationViewController] setBackFromSearch:numberToSend];
    
    NSMutableArray *arrayToSend = [[NSMutableArray alloc] initWithCapacity:100];
    if ([[segue identifier] isEqualToString:@"back_from_search"]) {
        if(inforamtionToSendBacktoMainView != nil){
            CLPlacemark *placemarkToSend = [inforamtionToSendBacktoMainView objectAtIndex:0];
            
            [arrayToSend addObject:placemarkToSend];
            [[segue destinationViewController] setZoomLocation:arrayToSend];
            NSNumber *numberToSend = [NSNumber numberWithBool:YES];
            [[segue destinationViewController] setLoadFacebookDataFlag:numberToSend];
        }
        else{
            NSLog(@"normal go back");
            //need to get the coordiates of the current location sent to the SearchViewController
            
            if(currentSearchViewInformation != nil){
                CLPlacemark *placemarkToSend = [currentSearchViewInformation objectAtIndex:0];
                [arrayToSend addObject:placemarkToSend];
                [[segue destinationViewController] setZoomLocation:arrayToSend];
            }
            NSNumber *numberToSend = [NSNumber numberWithBool:NO];
            [[segue destinationViewController] setLoadFacebookDataFlag:numberToSend];
        }
    }
}

@end
