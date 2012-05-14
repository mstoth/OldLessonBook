//
//  SLAddStudentViewController.h
//  StudentLessons
//
//  Created by Michael Toth on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SLStudent.h"

@protocol SLAddStudentViewDelegate;

@interface SLAddStudentViewController : UIViewController
- (IBAction)doneAddingStudent:(id)sender;
- (IBAction)cancel:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *studentNameInput;
@property (weak, nonatomic) IBOutlet UITextField *studentPhoneInput;
@property (weak, nonatomic) IBOutlet UILabel *studentNameLabel;
@property (strong, nonatomic) IBOutlet SLStudent *student;
@property (weak, nonatomic) IBOutlet UITextField *studentEmailInput;
@property (weak, nonatomic) id<SLAddStudentViewDelegate> delegate;
@end

@protocol SLAddStudentViewDelegate <NSObject>

@optional 
- (void)addStudent:(NSString*)name phone:(NSString*)phone email:(NSString *)email ;

@end