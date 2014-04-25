//
//  ViewController.h
//  Synterest
//
//  Created by Chris Jones on 12/04/2014.
//  Copyright (c) 2014 Chris Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <MKMapViewDelegate>{
    BOOL _doneInitialZoom;
}
//@property (weak, nonatomic) IBOutlet MKMapView *_mapView;//This was auto-added by Xcode :]
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *fqlButton;
@property (weak, nonatomic) NSMutableArray *facebookData;

- (void)viewWillAppear:(BOOL)animated;
- (NSMutableArray*) parseFbFqlResult:(id)result;
- (void)plotFacebookData:(NSMutableArray *)responseData;
//- (IBAction)onFbLoginClick:(id)sender;

@end
