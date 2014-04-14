//
//  MyLocation.h
//  Synterest
//
//  Created by Chris Jones on 13/04/2014.
//  Copyright (c) 2014 Chris Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyLocation : NSObject <MKAnnotation>

//- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate;
- (void)initWithFacebookData:(NSMutableDictionary*)facebookData;
//- (CLLocationCoordinate2D)coordinates;
- (MKMapItem*)mapItem;

@end
