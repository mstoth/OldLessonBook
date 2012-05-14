//
//  TAReportViewController.h
//  LessonBook
//
//  Created by Michael Toth on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Student.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface TAReportViewController : UIViewController <MFMailComposeViewControllerDelegate,UIPrintInteractionControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *allStudentsButton;
@property (weak, nonatomic) IBOutlet UIWebView *reportWebView;
@property (nonatomic, retain) Student *student;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
- (IBAction)emailReport:(id)sender;
- (IBAction)printReport:(id)sender;
- (IBAction)reportAllStudents:(id)sender;
@property (nonatomic, retain) NSArray *lesson;
@end
