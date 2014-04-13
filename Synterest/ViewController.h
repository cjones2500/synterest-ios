//
//  ViewController.h
//  Synterest
//
//  Created by Chris Jones on 12/04/2014.
//  Copyright (c) 2014 Chris Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *fqlButton;

- (void)viewWillAppear:(BOOL)animated;
//- (IBAction)onFbLoginClick:(id)sender;

@end
