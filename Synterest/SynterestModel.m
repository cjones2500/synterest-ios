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

- (int)assignEventType:(NSMutableDictionary*)inputArray
{
    //Add the Name and Description strings together
    NSString *description = [inputArray objectForKey:@"description"];
    NSString *name = [inputArray objectForKey:@"name"];
    NSString *stringToSearch = [NSString stringWithFormat:@"%@%@'",description,name];
    //NSLog(@"string to search %@",stringToSearch);
    
    
    //NSNumber *randomValue =[NSNumber numberWithInt:0];
    NSNumber *musicValue = [NSNumber numberWithInt:0];
    //int value = [musicValue intValue];
    //musicValue = [NSNumber numberWithInt:value +1];
    NSNumber *intellectualValue = [NSNumber numberWithInt:0];
    NSNumber *partyValue = [NSNumber numberWithInt:0];
    NSNumber *sportValue = [NSNumber numberWithInt:0];
    NSNumber *culturalValue = [NSNumber numberWithInt:0];
    NSNumber *foodValue = [NSNumber numberWithInt:0];
    
    
    //A nil is given at the beginning for random events (not assigned a value)
    NSMutableArray *eventValueArray = [NSMutableArray arrayWithObjects:musicValue,intellectualValue,partyValue,sportValue,culturalValue,foodValue, nil];
    
    //Array of keywords for each catagory
    //NSMutableArray *randomKeywords = [NSMutableArray arrayWithObjects:@"synterest",nil];
    NSMutableArray *musicKeywords = [NSMutableArray arrayWithObjects:@"gig",@"music",@"band",nil];
    NSMutableArray *intellectualKeywords =[NSMutableArray arrayWithObjects:@"talk",@"seminar",@"convention",@"conference",nil];
    NSMutableArray *partyKeywords = [NSMutableArray arrayWithObjects:@"party",@"festival",@"club",nil];
    NSMutableArray *sportKeywords = [NSMutableArray arrayWithObjects:@"sport",@"football",@"tennis",nil];
    NSMutableArray *culturalKeywords = [NSMutableArray arrayWithObjects:@"theatre",@"art",@"museum",nil];
    NSMutableArray *foodKeywords = [NSMutableArray arrayWithObjects:@"food",@"drink",@"dinner",nil];
    
    
    //Make an array for each of the different catagory
    NSMutableDictionary *keyWordsByTopic = [[NSMutableDictionary alloc] init];
    //[keyWordsByTopic setObject:randomKeywords forKey:@"random"];
    [keyWordsByTopic setObject:musicKeywords forKey:@"music"];
    [keyWordsByTopic setObject:partyKeywords forKey:@"party"];
    [keyWordsByTopic setObject:foodKeywords forKey:@"food"];
    [keyWordsByTopic setObject:culturalKeywords forKey:@"culture"];
    [keyWordsByTopic setObject:sportKeywords forKey:@"sport"];
    [keyWordsByTopic setObject:intellectualKeywords forKey:@"intellectual"];
 
    
    //NSLog(@"logging here..");
    //NSLog(@"currentArray %@",foodKeywords);
    //Loop through all topics with associated keywords
    
    //counter to keep track of the number
    unsigned int counter = 0;
    
    for (id key in keyWordsByTopic){
        //NSLog(@"currentArray %@",key);
        id currentArray = [keyWordsByTopic objectForKey:key];
    
        for(NSString* keyWordString2 in currentArray){
            //NSLog(@"keyword %@",keyWordString2);
            //NSLog(@"stringTosearch %@",stringToSearch);
            /*NSRange searchResult = [stringToSearch rangeOfString:keyWordString2 options:NSCaseInsensitiveSearch];
            if (searchResult.location == NSNotFound) {
                //NSLog(@"didn't work");
                //do nothing as the result isn't found
            }
            else{
                NSLog(@" searchResult: %i",searchResult.length);
                NSLog(@"%i - ",[[eventValueArray objectAtIndex:counter] intValue]);
                [eventValueArray replaceObjectAtIndex:counter withObject:[NSNumber numberWithInt:[[eventValueArray objectAtIndex:counter]intValue]+1]];
                NSLog(@"%i - ",[[eventValueArray objectAtIndex:counter] intValue]);
            }
            counter = counter +1;*/
            
            NSUInteger count = 0, length = [stringToSearch length];
            NSRange range = NSMakeRange(0, length);
            while(range.location != NSNotFound)
            {
                range = [stringToSearch rangeOfString:keyWordString2 options:NSCaseInsensitiveSearch range:range];
                if(range.location != NSNotFound)
                {
                    range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
                    count++; 
                }
            }
            //NSLog(@"counter %i",count);
            [eventValueArray replaceObjectAtIndex:counter withObject:[NSNumber numberWithInt:[[eventValueArray objectAtIndex:counter]intValue]+count]];
        }
        
        counter = counter +1;
    }
    
    
    
    //NSLog(@"logging here..2");
    unsigned int eventSizeLoopCounter = 0;
    int indexOfLargestValue = 0;
    
    //find the largest value within the eventValueArray
    for(NSNumber *iterationValue in eventValueArray){
        //NSLog(@" eventSizeLoopCounter: %i",eventSizeLoopCounter);
        int currentValue,currentLargestValue = 0;
        //assign the value of the current item in the iteration
        currentValue =[iterationValue intValue];
        //check to see if this is the first member in the loop
        if(eventSizeLoopCounter == 0){
            currentLargestValue = [iterationValue intValue];
        }
        else{
            if(currentValue > currentLargestValue){
                //assign the information for the largest value in the eventArray
                indexOfLargestValue = eventSizeLoopCounter;
                currentLargestValue = [iterationValue intValue];
            }
        }
        
        //assign a value to an
        
        eventSizeLoopCounter = eventSizeLoopCounter + 1;
    }
    
    
    //outputString = [keyWordsByTopic
    //NSLog(@"index %i",indexOfLargestValue);
    //NSLog(@"eventValueArray : %@",eventValueArray);
    return indexOfLargestValue;
    
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
        
        //NSLog(@"event_type %i",[self assignEventType:[[dictionary objectForKey:@"data"] objectAtIndex:i]]);
        int eventTypeIntValue = [self assignEventType:[[dictionary objectForKey:@"data"] objectAtIndex:i]];
        NSNumber *eventType = [NSNumber numberWithInt:eventTypeIntValue];
        
        NSMutableDictionary* singleResult = [[NSMutableDictionary alloc] init];
        
        //NSLog(@"event_type %i",v);
        
        //NSLog(@"NAME: %@",[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"name"]);
        //NSLog(@"DESCRIPTION: %@",[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"description"]);
        
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"eid"] forKey:@"eid"];
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"name"] forKey:@"name"];
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"description"] forKey:@"description"];
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"start_time"] forKey:@"start_time"];
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"end_time"] forKey:@"end_time"];
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"pic"] forKey:@"pic"];
        [singleResult setObject:[[[dictionary objectForKey:@"data"] objectAtIndex:i] objectForKey:@"venue"] forKey:@"venue"];
        [singleResult setObject:eventType forKey:@"event_type"];
        [facebookResults addObject:singleResult];
            
    }
    
    return facebookResults;
    
}


@end
