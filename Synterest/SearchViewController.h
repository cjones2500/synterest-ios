//
//  SearchViewController.h
//  Synterest
//
//  Created by Chris Jones on 27/04/2014.
//  Copyright (c) 2014 Chris Jones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SearchViewController : UIViewController<CLLocationManagerDelegate,UISearchBarDelegate,UITableViewDelegate, UITableViewDataSource>{
    IBOutlet UISearchBar *_searchBar;
    NSArray *searchValues;
    NSMutableArray *currentSearchViewInformation;
}
@property (weak, nonatomic) IBOutlet UITableView *synterestTableView;
@property (weak, nonatomic) IBOutlet UIButton *goBackButton;
@property (nonatomic, retain) CLLocation *locationValue;
@property (nonatomic, retain) NSArray *locationValueArray;
@end
