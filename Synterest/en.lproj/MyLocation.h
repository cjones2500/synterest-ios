//
//  MyLocation.h
//  Synterest
//
//  Created by Chris Jones on 13/04/2014.
//  Copyright (c) 2014 Chris Jones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyLocation : NSObject <MKAnnotation> {
    NSString *_name;
    NSString *_address;
    NSString *_facebookPic;
    NSNumber *_eventType;
    NSString *_fbDescription;
    NSString *_fbLocData;
    CLLocationCoordinate2D _coordinate;
}

@property (copy) NSString *name;
@property (copy) NSString *address;
@property (copy) NSString *facebookPic;
@property (copy) NSNumber *eventType;
@property (copy) NSString *fbDescription;
@property (copy) NSString *fbLocData;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithName:(NSString*)name
           address:(NSString*)address
        coordinate:(CLLocationCoordinate2D)coordinate
       typeOfEvent:(int)anEventType
   withFacebookPic:(NSString*)aFacebookPic
   withDescription:(NSString*)aDescription
     withFbLocData:(NSString*)someFbLocData;
@end


