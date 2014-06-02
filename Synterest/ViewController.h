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


@interface ViewController : UIViewController <CLLocationManagerDelegate,MKMapViewDelegate,UITableViewDelegate,UITableViewDataSource,UIPickerViewDataSource,UIPickerViewDelegate,UISearchBarDelegate,UIWebViewDelegate>{
    BOOL _doneInitialZoom;
    NSMutableArray *_zoomLocation;
    NSMutableArray *_locationToSend;
    CLLocationCoordinate2D locationToZoom;
}

//AnnotationView information
@property (weak, nonatomic) IBOutlet UIButton *goBackToMapFromAnnotation;
@property (weak, nonatomic) IBOutlet UIImageView *facebookImageSubView;
@property (weak, nonatomic) IBOutlet UIScrollView *fbEventDescriptionScroll;
@property (weak, nonatomic) IBOutlet UILabel *fbEventDate;
@property (weak, nonatomic) IBOutlet UIScrollView *fbEventTitleScroll;
@property (weak, nonatomic) IBOutlet UITextView *fbEventAddress;
@property (weak, nonatomic) IBOutlet UITextView *fbEventDescription;
@property (weak, nonatomic) IBOutlet UITextView *fbEventTitle;




//@property (weak, nonatomic) IBOutlet MKMapView *_mapView;//This was auto-added by Xcode :]
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *fqlButton;
@property (weak, nonatomic) NSMutableArray *facebookData;
@property (weak, nonatomic) NSString *fbEidText;
@property (weak, nonatomic) NSMutableArray *additionalFacebookData;
@property (strong, nonatomic) NSMutableArray *extraFacebookData;
@property (strong, nonatomic) NSMutableArray *listViewAnnotations;
@property (weak, nonatomic) NSString *currentCity;
@property (weak, nonatomic) NSString *sideBarActivationState;
@property (weak, nonatomic) NSMutableArray *dataToLoadToAnnotationView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIImageView *searchButtonSubView;
@property (weak, nonatomic) IBOutlet UIView *annotationBarView;
@property (weak, nonatomic) IBOutlet UIView *sideBarView;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (copy) NSMutableArray *zoomLocation;
@property (copy) NSMutableArray *locationToSend;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingDataWheel;
@property (nonatomic, retain) CLLocation *reverseGeocodeLocationValue;
@property (weak,nonatomic) NSNumber *loadFacebookDataFlag;
@property (weak,nonatomic) NSNumber *firstViewFlag;

//List view of events
@property (weak, nonatomic) IBOutlet UIImageView *listImageView;
@property (weak, nonatomic) IBOutlet UIView *listView;
@property (weak, nonatomic) IBOutlet UIButton *goBackFromListView;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *listViewSearchBar;

//Calender view icon
@property (weak, nonatomic) IBOutlet UIImageView *calenderImageView;
@property (weak, nonatomic) IBOutlet UIView *calenderMainView;
@property (weak, nonatomic) IBOutlet UIDatePicker *eventDatePicker;


@property (weak, nonatomic) NSArray *dateOptionsArray;
@property (weak, nonatomic) IBOutlet UIButton *nextTwoDaysButton;
@property (weak, nonatomic) IBOutlet UIButton *nextWeekButton;
@property (weak, nonatomic) IBOutlet UIButton *nextDateButton;

@property (weak, nonatomic) IBOutlet UIImageView *calenderStaticImage;

//facebook Page View
@property (weak, nonatomic) IBOutlet UIView *fbPageView;
@property (weak, nonatomic) IBOutlet UIWebView *fbWebView;
@property (weak, nonatomic) IBOutlet UIButton *gotoEvappa;


//- (id) initWithCoords:(NSMutableArray*)zoomLocation;
- (void)viewWillAppear:(BOOL)animated;
- (void)plotFacebookData:(NSMutableArray *)responseData withReset:(BOOL)resetValue;
- (NSString*)getDateInfoFromFb:(NSString*)isoFacebookDateString;
- (NSString*)buildAddressToShow:(NSMutableDictionary*)venueInfo;
- (void)toggleSideBarView;
- (void)setMapCenterWithCoords:(CLLocationCoordinate2D)coords;
- (void)unHideFirstTime;
typedef void(^myCompletion)(BOOL);
typedef void(^myCompletion2)(BOOL);

@end
