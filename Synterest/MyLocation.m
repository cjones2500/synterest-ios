//
//  MyLocation.m
//  Synterest
//
//  Created by Chris Jones on 13/04/2014.
//  Copyright (c) 2014 Chris Jones. All rights reserved.
//

#import "MyLocation.h"
#import <AddressBook/AddressBook.h>

@interface MyLocation ()
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, retain) NSMutableDictionary *facebookData;
@property (nonatomic, assign) CLLocationCoordinate2D theCoordinates;
@end

@implementation MyLocation

/*- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        if ([name isKindOfClass:[NSString class]]) {
            self.name = name;
        } else {
            self.name = @"Unknown charge";
        }
        self.address = address;
        self.theCoordinate = coordinate;
    }
    return self;
}*/

- (void)initWithFacebookData:(NSMutableDictionary*)loadedFacebookData
{
    self.facebookData = loadedFacebookData;
    self.theCoordinates = [self coordinate];
    NSLog(@" coords %@",self.facebookData);
}

- (CLLocationCoordinate2D)coordinate {
    
    double longitudeValue = [[[self.facebookData objectForKey:@"venue"] objectForKey:@"longitude"] doubleValue];
    double latitudeValue = [[[self.facebookData objectForKey:@"venue"] objectForKey:@"latitude"] doubleValue];
    
    //NSLog(@"before longitude: %f\n",longitudeValue);
    //NSLog(@"before latitude: %f\n",latitudeValue);
    
    //catch strange values pulled from facebook 
    /*if(longitudeValue < 51.5 || longitudeValue > 52.5){
        longitudeValue = 51.50722;
    }
    
    if(latitudeValue < -0.13 || latitudeValue > -0.12){
            latitudeValue = -0.12750;
    }*/
    
    
    NSLog(@"longitude: %f\n",longitudeValue);
    NSLog(@"latitude: %f\n",latitudeValue);
    
    _theCoordinates.latitude = longitudeValue;
    _theCoordinates.longitude = latitudeValue;
    
    
    //NSLog(@"longitude: %@",[[[self.facebookData objectForKey:@"venue"] objectForKey:@"longitude"] doubleValue]);
   //NSLog(@"latitude: %@",[[[self.facebookData objectForKey:@"venue"] objectForKey:@"latitude"] doubleValue]);
    return _theCoordinates;
}

- (MKMapItem*)mapItem {
    NSDictionary *addressDict = nil;
    
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:self.coordinate
                              addressDictionary:addressDict];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
    
    return mapItem;
}

@end