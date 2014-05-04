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
    //[self geocodeLocationValue];
    
    //[[UISearchDisplayController alloc] initWithSearchBar:self.placeSearchBar contentsController:self];
    //[self setSearchDisplayController:self];
    //[searchDisplayController setDelegate:self];
    //[searchDisplayController setSearchResultsDataSource:self];
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
            //NSLog(@"placemarks count %i",[placemarks count]);
            //[__arrayInBlock insertObject:placemarks atIndex:0];
            //NSLog(@"array %@",__arrayInBlock);
            //NSLog(@"array1 %@",placemarks);
            //NSLog(@"array2 %@",placemarkersFromSearch);
            self.locationValueArray = placemarks;
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            //CLLocation *location = placemark.location;
            //CLLocationCoordinate2D coordinateReverse = location.coordinate;
            self.locationValue = placemark.location;
            //NSLog(@"coordinate %f",coordinateReverse.latitude);
            //NSLog(@" array %@",returnArray);
            //[self.mapView setCenterCoordinate:coordinate animated:YES];
            [self callbackFromSearchBar];
        } else {
            //occurs if there are no placemarks
            searchValues = [NSArray arrayWithArray:nil];
            NSLog(@"error: %@",error);
            //_searchBar.text = nil;
            //currentSearchViewInformation = [NSMutableArray arrayWithArray:nil];
            //placemarks = [NSArray arrayWithObject:nil];
            //[self.synterestTableView reloadData];
            //[self viewDidLoad];
        }
        //finished = YES;
        //return placemarks;
        
    }];
    
    //NSArray * returnArray = [NSArray arrayWithObject:[__arrayInBlock objectAtIndex:0]];
    //NSLog(@"placemarks %@");
    //while ([self.locationLoader isEqual:nil]) {
        //Do Nothing
        //[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        //NSLog(@"return array %@",placemarkersFromSearch);
    //}
    //while (!finished);
    //NSLog(@"locationValue %@",self.locationValueArray);
}

-(void)callbackFromSearchBar
{
    //NSLog(@"locationValue %@",self.locationValueArray);
    searchValues = [NSArray arrayWithObjects:nil];
    //reinitialise the current information
    currentSearchViewInformation = [NSMutableArray arrayWithObjects:nil];
    
    @try{
        //currentSearchViewInformation = [[NSMutableArray alloc] initWithCapacity:100];
        NSMutableArray *mutablePlacemarkArrayToFill = [[NSMutableArray alloc] initWithCapacity:100];
        int numberOfMembers = [self.locationValueArray count];
        NSLog(@" no of members %i",numberOfMembers);
        for(int i=0;i < numberOfMembers;i++){
            CLPlacemark *placemark = [self.locationValueArray objectAtIndex:i];
            //NSLog(@"placemark %@",placemark);
            NSString *placemarkLocality = [NSString stringWithString:placemark.locality];
            NSString *placemarkCountry = [NSString stringWithString:placemark.country];
            NSString *stringToPrint;
            //NSLog(@"stringToPrint %@",stringToPrint);
            if( (placemarkLocality == NULL) && (placemarkCountry == NULL)){
                //NSLog(@"no locality or country");
                //stringToPrint = [NSString stringWithFormat:nil];
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
                //NSLog(@"placemark: %i %i",[placemarkCountry length],[placemarkLocality length]);
                //NSLog(@"stringToPrint %@",stringToPrint);
                //NSString *testString = [NSString stringWithString:placemark];
                //NSLog(@"placemark %@",placemark.thoroughfare);
                stringToPrint = [NSString stringWithFormat:@"%@, %@",placemarkLocality,placemarkCountry];
            }
            else{
                NSLog(@"Error: Unknown location");
            }
            
            [mutablePlacemarkArrayToFill setObject:stringToPrint atIndexedSubscript:i];
            [currentSearchViewInformation setObject:placemark atIndexedSubscript:i];
        }
        
        NSArray *placemarkArrayToFill = [NSArray arrayWithArray:mutablePlacemarkArrayToFill];
        NSLog(@"arrray %@",mutablePlacemarkArrayToFill);
        searchValues = [NSArray arrayWithArray:placemarkArrayToFill];
        //[self performSelector:@selector(reloadData) withObject:self.synterestTableView afterDelay:0.01];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Error %@",exception);
    }
    @finally{
        [self.synterestTableView reloadData];
    }
    //CLPlacemark *placemark = [placemarks objectAtIndex:0];
    //NSLog(@"array %@",self.locationValueArray);
}


-(void)reverseGeocodeLocation
{
    CLGeocoder *geocoder2 = [[CLGeocoder alloc] init];
    [geocoder2 reverseGeocodeLocation:self.locationValue completionHandler:^(NSArray *placemarks, NSError *error){
        //CLPlacemark *placemark = placemarks[0];
        NSLog(@"Found %@", placemarks);
    }];
}


/*-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)
searchString {
    NSLog(@"being called here");
    [self.geocoder22 geocodeAddressString:searchString completionHandler:^(NSArray *placemarks, NSError *error) {
        self.placemark22 = [placemarks objectAtIndex:0];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
    return NO;
}*/

//[self viewDidLoad];

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

//called when a cell is selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"@indexPath: %i",indexPath.row);
    inforamtionToSendBacktoMainView = [NSArray arrayWithObject:[currentSearchViewInformation objectAtIndexedSubscript:indexPath.row]];
    [self performSegueWithIdentifier:@"back_from_search" sender:inforamtionToSendBacktoMainView];
    
    /*UIAlertView *messageAlert = [[UIAlertView alloc]
                                 initWithTitle:@"Row Selected" message:@"You've selected a row" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    // Display Alert Message
    [messageAlert show];*/
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"back_from_search"]) {
        if(inforamtionToSendBacktoMainView != nil){
            CLPlacemark *placemarkToSend = [inforamtionToSendBacktoMainView objectAtIndex:0];
            NSMutableArray *arrayToSend = [[NSMutableArray alloc] initWithCapacity:100];
            [arrayToSend addObject:placemarkToSend];
            [[segue destinationViewController] setZoomLocation:arrayToSend];
            NSNumber *numberToSend = [NSNumber numberWithBool:YES];
            [[segue destinationViewController] setLoadFacebookDataFlag:numberToSend];
        }
        else{
            NSLog(@"normal go back");
            CLPlacemark *placemarkToSend = [currentSearchViewInformation objectAtIndex:0];
            NSMutableArray *arrayToSend = [[NSMutableArray alloc] initWithCapacity:100];
            [arrayToSend addObject:placemarkToSend];
            [[segue destinationViewController] setZoomLocation:arrayToSend];
            NSNumber *numberToSend = [NSNumber numberWithBool:NO];
            [[segue destinationViewController] setLoadFacebookDataFlag:numberToSend];
        }
    }
}

@end
