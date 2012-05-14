//
//  SLAddStudentViewController.m
//  StudentLessons
//
//  Created by Michael Toth on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLAddStudentViewController.h"
#import "SLStudent.h"

@interface SLAddStudentViewController ()

@end

@implementation SLAddStudentViewController {
}
@synthesize studentNameInput = _studentNameInput;
@synthesize studentPhoneInput = _studentPhoneInput;
@synthesize studentNameLabel = _studentNameLabel;
@synthesize student = _student;
@synthesize studentEmailInput = _studentEmailInput;
@synthesize delegate = _delegate;

- (void)setStudent:(id)newStudent {
    _student = newStudent;
}

- (void)setDelegate:(id<SLAddStudentViewDelegate>)aDelegate {
    _delegate = aDelegate;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setStudentNameLabel:nil];
    [self setStudentNameInput:nil];
    [self setStudentPhoneInput:nil];
    [self setStudentEmailInput:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
/*
- (void)setStudent:(NSString*)name phone:(NSString*)phone {
    _student.nameOfStudent = name;
    _student.phoneNumberOfStudent = phone;
}
*/

- (IBAction)doneAddingStudent:(id)sender {
    [_delegate addStudent:_studentNameInput.text phone:_studentPhoneInput.text email:_studentEmailInput.text];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
