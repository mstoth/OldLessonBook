//
//  TAEditStudentViewController.h
//  LessonBook
//
//  Created by Michael Toth on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>
#import "Student.h"

@protocol TAEditStudentDelegate;
@class Student;

@interface TAEditStudentViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    BOOL lastNameFirst;
}

//@property (strong, nonatomic) id detailItem;
@property (nonatomic, retain) Student *student;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) id<TAEditStudentDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *pictureView;
@property (weak, nonatomic) IBOutlet UITextField *categoryTextField;

- (IBAction)choosePhoto;
- (void)updatePhotoInfo;
- (IBAction)showPicker:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)formatName:(id)sender;

@end

@protocol TAEditStudentDelegate <NSObject>

@optional
-(void)updateStudent:(NSString*)name email:(NSString*)email phone:(NSString*)phone picture:(UIImage*)picture;

@end