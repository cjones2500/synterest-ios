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
    //[self assignEventType:nil];
}

- (NSMutableArray*)assignEventType:(NSMutableArray*)inputArray
{
    NSString *car = @"Maserati GranCabrio";
    NSRange searchResult = [car rangeOfString:@"Cabrio"];
    if (searchResult.location == NSNotFound) {
        NSLog(@"Search string was not found");
    } else {
        NSLog(@"'Cabrio' starts at index %i and is %i characters long",
              searchResult.location,        // 13
              searchResult.length);         // 6
    }
    
    return inputArray;
    
}

//Load facebook data for synterest to the local phone cache
-(NSMutableArray*)loadLocalData
{
    NSMutableArray *facebookData;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [userDefaults objectForKey:@"facebookData"];
    if(data != NULL){
        facebookData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    else{
        facebookData = nil;
    }
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
    unsigned long cnt = [[dictionary objectForKey:@"data"] count];
    
    //eid, name,location,description, venue, start_time, update_time, end_time, pic
    
    for(i =0;i<cnt;i++){
        
        //skip if there is no start date 
        /*if([[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"start_time"] == nil){
            continue;
        }
        
        //skip if there is no longitude
        if([[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"venue"] objectForKey:@"longitude"] == nil){
            continue;
        }
        
        //skip if there is no latitude
        if([[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"venue"] objectForKey:@"latitude"] == nil){
            continue;
        }*/
        
        //If the facebook entry is empty then continue
        /*if([[[[[dictionary objectForKey:@"data"] objectAtIndex:i]  objectForKey:@"venue"]description] isEqualToString: @"0 objects"]){
            NSLog(@"skipped %@",[[dictionary objectForKey:@"data"] objectAtIndex:i]);
            continue;
        }*/
        
        //NSMutableDictionary* singleResult = [[NSMutableDictionary alloc] init];
       
        
        NSMutableDictionary* singleResult = [[NSMutableDictionary alloc] init];
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"eid"] forKey:@"eid"];
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"name"] forKey:@"name"];
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"description"] forKey:@"description"];
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"start_time"] forKey:@"start_time"];
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"end_time"] forKey:@"end_time"];
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"pic"] forKey:@"pic"];
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"venue"] forKey:@"venue"];
        [facebookResults addObject:singleResult];
            
    }
    
    return facebookResults;
    
}


@end
