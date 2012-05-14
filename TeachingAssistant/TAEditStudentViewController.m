//
//  TAEditStudentViewController.m
//  LessonBook
//
//  Created by Michael Toth on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Student.h"
#import "TAEditStudentViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "Photo.h"

@interface TAEditStudentViewController  ()

@end

@implementation TAEditStudentViewController 

@synthesize nameTextField = _nameTextField;
@synthesize emailTextField = _emailTextField;
@synthesize phoneTextField = _phoneTextField;
@synthesize delegate = _delegate;
@synthesize pictureView = _pictureView;
@synthesize categoryTextField = _categoryTextField;
@synthesize student;

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
    lastNameFirst = false;
    _nameTextField.text = self.student.name;
    _phoneTextField.text = self.student.phone;
    _emailTextField.text = self.student.email;
    _categoryTextField.text = self.student.category;
    _pictureView.image = self.student.photo.image;
}

- (void)viewDidUnload
{
    [self setNameTextField:nil];
    [self setEmailTextField:nil];
    [self setPhoneTextField:nil];
    [self setPictureView:nil];
    [self setCategoryTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)choosePhoto {
    // Show an image picker to allow the user to choose a new photo.
	
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	[self presentModalViewController:imagePicker animated:YES];
	//[imagePicker release];
}

- (IBAction)done:(id)sender {
    self.student.name = _nameTextField.text;
    self.student.email = _emailTextField.text;
    self.student.phone = _phoneTextField.text;
    self.student.category = _categoryTextField.text;
    self.student.photo.image = [_pictureView.image copy];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)formatName:(id)sender {
    if (lastNameFirst) {
        lastNameFirst = false;
    } else {
        lastNameFirst = true;
    }
}

- (void) updatePhotoInfo {
    _pictureView.image = self.student.photo.image;
}
#pragma mark -
#pragma mark Address Book delegate methods

- (IBAction)showPicker:(id)sender
{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentModalViewController:picker animated:YES];
}

- (void)peoplePickerNavigationControllerDidCancel:

(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker
            shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    [self displayPerson:person];
    [self dismissModalViewControllerAnimated:YES];
    return NO;
    
}



- (BOOL)peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker
                    shouldContinueAfterSelectingPerson:(ABRecordRef)person
                    property:(ABPropertyID)property
                    identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

- (void) displayPerson:(ABRecordRef)person {
    
    NSString* name = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString* lname = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    if (lastNameFirst) {
        NSString* fullName = [NSString stringWithFormat:@"%@, %@",lname,name];
        _nameTextField.text = fullName;
    } else {
        NSString* fullName = [NSString stringWithFormat:@"%@ %@",name,lname];
        _nameTextField.text = fullName;
    }
    
    NSString* email;
    
    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    if (ABMultiValueGetCount(emails) > 0) {
        email = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(emails, 0);
    } else {
        email = @"[None]";
    }
    _emailTextField.text = email;
    
    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phone = (__bridge_transfer NSString*)
        ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    } else {
        phone = @"[None]";
    }
    _phoneTextField.text = phone;
    if(ABPersonHasImageData(person)){
        _pictureView.image = [UIImage imageWithData:(__bridge_transfer NSData *)ABPersonCopyImageData(person)];
    }
    NSManagedObjectContext *context = self.student.managedObjectContext;
    
    if (self.student.photo) {
        [context deleteObject:self.student.photo];
    }
    
    Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
    photo.image = _pictureView.image;
    UIImage *selectedImage = _pictureView.image;
    self.student.photo = photo;
    
    CGSize size = selectedImage.size;
    CGFloat ratio = 0;
    if (size.width > size.height) {
        ratio = 44.0/size.width;
    } else {
        ratio = 44.0/size.height;
    }
    CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    [selectedImage drawInRect:rect];
    self.student.thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSError *error = nil;
    if (![self.student.managedObjectContext save:&error]) {
        // Handle Error
    }
    if (![self.student.photo.managedObjectContext save:&error]) {
        // handle error
    }
	// Update the user interface appropriately.
    [self updatePhotoInfo];

}

#pragma mark -
#pragma mark Image picker delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)selectedImage editingInfo:(NSDictionary *)editingInfo {
	
    NSManagedObjectContext *context = self.student.managedObjectContext;
    
    if (self.student.photo) {
        [context deleteObject:self.student.photo];
    }
    
    Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
    photo.image = selectedImage;
    
    self.student.photo = photo;
    
    CGSize size = selectedImage.size;
    CGFloat ratio = 0;
    if (size.width > size.height) {
        ratio = 44.0/size.width;
    } else {
        ratio = 44.0/size.height;
    }
    CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    [selectedImage drawInRect:rect];
    self.student.thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSError *error = nil;
    if (![self.student.managedObjectContext save:&error]) {
        // Handle Error
    }
    if (![self.student.photo.managedObjectContext save:&error]) {
        // handle error
    }
	// Update the user interface appropriately.
    [self updatePhotoInfo];
    
    [self dismissModalViewControllerAnimated:YES];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	// The user canceled -- simply dismiss the image picker.
	[self dismissModalViewControllerAnimated:YES];
}



@end
