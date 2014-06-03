//
//  SynterestModel.h
//  Synterest
//
//  Created by Chris Jones on 12/04/2014.
//  Copyright (c) 2014 Chris Jones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SynterestModel : NSObject

-(void)saveLocalData:(NSMutableArray*)inputArray;
-(NSMutableArray*)loadLocalData;
-(NSMutableArray*) parseFbFqlResult:(id)result;
-(int)assignEventType:(NSMutableDictionary*)inputArray;
-(void)saveAdditionalLocalData:(NSMutableArray*)inputArray;

@property (strong, nonatomic) NSMutableArray *checkEidList;

@end
