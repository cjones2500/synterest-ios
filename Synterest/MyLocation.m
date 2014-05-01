//
//  MyLocation.m
//  Synterest
//
//  Created by Chris Jones on 13/04/2014.
//  Copyright (c) 2014 Chris Jones. All rights reserved.
//

#import "MyLocation.h"

@implementation MyLocation
@synthesize name = _name;
@synthesize address = _address;
@synthesize coordinate = _coordinate;
@synthesize eventType = _eventType;
@synthesize facebookPic = _facebookPic;
@synthesize fbDescription = _fbDescription;
@synthesize fbLocData = _fbLocData;
@synthesize fbEventDate = _fbEventDate;

- (id)initWithName:(NSString*)name
           address:(NSString*)address
        coordinate:(CLLocationCoordinate2D)coordinate
       typeOfEvent:(int)anEventType
   withFacebookPic:(NSString*)aFacebookPic
   withDescription:(NSString*)aDescription
     withFbLocData:(NSString*)someFbLocData
   withFbEventDate:(NSString*)aFbEventDate
{
    if ((self = [super init])) {
        _name = [name copy];
        _address = [address copy];
        _facebookPic = [aFacebookPic copy];
        _coordinate = coordinate;
        _eventType = [NSNumber numberWithInt:anEventType];
        _fbDescription = [aDescription copy];
        _fbLocData = [someFbLocData copy];
        _fbEventDate = [aFbEventDate copy];
    }
    return self;
}

- (NSString *)title {
    if ([_name isKindOfClass:[NSNull class]])
        return @"Unknown charge";
    else
        return _name;
}

- (NSString *)subtitle {
    return _address;
}

- (NSNumber*) eventCatagory{
    return _eventType;
}

-(NSString*) getFacebookPicURL{
    return _facebookPic;
}

-(NSString*) getFacebookDescription{
    return _fbDescription;
}

@end
