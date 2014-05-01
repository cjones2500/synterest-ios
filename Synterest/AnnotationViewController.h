//
//  AnnotationViewController.h
//  Synterest
//
//  Created by Chris Jones on 28/04/2014.
//  Copyright (c) 2014 Chris Jones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnnotationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *eventAdressTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *eventAddressScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *eventTitleScrollView;
@property (weak, nonatomic) IBOutlet UITextView *eventDescriptionTextView;
@property (weak, nonatomic) IBOutlet UIScrollView *eventDescriptionView;
@property (weak, nonatomic) IBOutlet UIImageView *eventFbImageView;
@property (nonatomic, weak) NSString *eventTitleText;
@property (nonatomic, weak) NSNumber *eventType;
@property (nonatomic, weak) NSString *eventFbPic;
@property (nonatomic, weak) NSString *eventDescription;
@property (nonatomic, weak) NSString *eventAddress;
@property (nonatomic, weak) NSString *eventDate;
@property (weak, nonatomic) IBOutlet UIButton *goBackFromAnnotationButton;

@end
