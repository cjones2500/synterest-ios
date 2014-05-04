//
//  ViewController.h
//  Synterest
//
//  Created by Chris Jones on 12/04/2014.
//  Copyright (c) 2014 Chris Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LoginViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "SearchViewController.h"


@interface ViewController : UIViewController <CLLocationManagerDelegate,MKMapViewDelegate>{
    BOOL _doneInitialZoom;
    NSMutableArray *_zoomLocation;
    CLLocationCoordinate2D locationToZoom;
}
//@property (weak, nonatomic) IBOutlet MKMapView *_mapView;//This was auto-added by Xcode :]
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *fqlButton;
@property (weak, nonatomic) NSMutableArray *facebookData;
@property (weak, nonatomic) NSString *currentCity;
@property (weak, nonatomic) NSString *sideBarActivationState;
@property (weak, nonatomic) NSMutableArray *dataToLoadToAnnotationView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIImageView *searchButtonSubView;
@property (weak, nonatomic) IBOutlet UIView *sideBarView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (copy) NSMutableArray *zoomLocation;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingDataWheel;
@property (nonatomic, retain) CLLocation *reverseGeocodeLocationValue;
@property (weak,nonatomic) NSNumber *loadFacebookDataFlag;
@property (weak,nonatomic) NSNumber *firstViewFlag;



//- (id) initWithCoords:(NSMutableArray*)zoomLocation;
- (void)viewWillAppear:(BOOL)animated;
- (void)plotFacebookData:(NSMutableArray *)responseData;
- (NSString*)getDateInfoFromFb:(NSString*)isoFacebookDateString;
- (NSString*)buildAddressToShow:(NSMutableDictionary*)venueInfo;
- (void)toggleSideBarView;
- (void)setMapCenterWithCoords:(CLLocationCoordinate2D)coords;

@end
