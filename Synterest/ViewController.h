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

@interface ViewController : UIViewController <MKMapViewDelegate>{
    BOOL _doneInitialZoom;
}
//@property (weak, nonatomic) IBOutlet MKMapView *_mapView;//This was auto-added by Xcode :]
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *fqlButton;
@property (weak, nonatomic) NSMutableArray *facebookData;
@property (weak, nonatomic) NSMutableArray *dataToLoadToAnnotationView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

- (void)viewWillAppear:(BOOL)animated;
- (void)plotFacebookData:(NSMutableArray *)responseData;
- (NSString*)getDateInfoFromFb:(NSString*)isoFacebookDateString;
- (NSString*)buildAddressToShow:(NSMutableDictionary*)venueInfo;

@end
