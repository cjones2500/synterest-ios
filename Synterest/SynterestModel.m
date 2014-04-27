//
//  SynterestModel.m
//  Synterest
//
//  Created by Chris Jones on 12/04/2014.
//  Copyright (c) 2014 Chris Jones. All rights reserved.
//

#import "SynterestModel.h"

@implementation SynterestModel

//Save facebook data for synterest to the local phone cache
- (void)saveLocalData:(NSMutableArray*)inputArray
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:inputArray];
    [userDefaults setObject:data forKey:@"facebookData"];
}

//Load facebook data for synterest to the local phone cache
-(NSMutableArray*)loadLocalData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [userDefaults objectForKey:@"facebookData"];
    NSMutableArray *facebookData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return facebookData;
}

- (NSMutableArray*) parseFbFqlResult:(id)result
{
    NSMutableArray* facebookResults = [[NSMutableArray alloc] init];
    
    // result is the json response from a successful request
    NSDictionary *dictionary = (NSDictionary *)result;
    
    NSString *text;
    // we pull the name property out, if there is one, and display it
    text = (NSString *)[dictionary objectForKey:@"data"];
    
    //NSLog(@"json dictionary %@",[[[dictionary objectForKey:@"data"] objectAtIndex:0] objectForKey:@"eid"]);
    
    unsigned int i = 0;
    //count the number of objects in the request
    unsigned int cnt = [[dictionary objectForKey:@"data"] count];
    
    //eid, name,location,description, venue, start_time, update_time, end_time, pic
    
    for(i =0;i<cnt;i++){
        
        NSMutableDictionary* singleResult = [[NSMutableDictionary alloc] init];
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"eid"] forKey:@"eid"];
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"name"] forKey:@"name"];
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"description"] forKey:@"description"];
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"start_time"] forKey:@"start_time"];
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"end_time"] forKey:@"end_time"];
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"pic"] forKey:@"pic"];
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"venue"] forKey:@"venue"];
        //NSLog(@" venue data %@\n",[singleResult objectForKey:@"venue"]);
        [facebookResults addObject:singleResult];
    }
    
    return facebookResults;
    
}


@end
