//
//  TADetailViewController.m
//  LessonBook
//
//  Created by Michael Toth on 3/28/12.
//  Copyright (c) 2012 Michael Toth. All rights reserved.
//
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "TADetailViewController.h"
#import "Student.h"
#import "Photo.h"

@interface TADetailViewController ()
- (void)configureView;
@end

@implementation TADetailViewController

@synthesize detailItem = _detailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize phoneLabel = _phoneLabel;
@synthesize emailLabel = _emailLabel;
@synthesize nameLabel = _nameLabel;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize delegate = _delegate;
@synthesize pictureView = _pictureView;
@synthesize student = _student;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self configureView];
}

- (void)configureView
{
    // Update the user interface for the detail item.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"flare.png"]];

    if (self.student) {
        self.nameLabel.text = self.student.name;
        self.phoneLabel.text = self.student.phone;
        self.emailLabel.text = self.student.email;
        
        if (self.student.photo) {
            self.pictureView.image = self.student.photo.image;
        }
    }
}

-(IBAction) sendEmailToStudent {
    [self sendEmailTo:self.emailLabel.text withSubject:@"Music Lesson" withBody:@"Hi"];
}

-(void) sendEmailTo:(NSString *)to withSubject:(NSString *)subject withBody:(NSString *)body {
    NSString *mailString = [NSString stringWithFormat:@"mailto:?to=%@&subject=%@&body=%@",
                            [to stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                            [subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                            [body stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"RepertoireView"]) {
        [[segue destinationViewController] setStudent:self.student];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    }
    if ([[segue identifier] isEqualToString:@"NoteView"]) {
        [[segue destinationViewController] setStudent:self.student];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    }
    if ([[segue identifier] isEqualToString:@"ReportView"]) {
        [[segue destinationViewController] setStudent:self.student];
        [[segue destinationViewController] setLesson:self.student.lesson];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    }
    if ([[segue identifier] isEqualToString:@"RecordingsView"]) {
        [[segue destinationViewController] setStudent:self.student];
    }
    if ([[segue identifier] isEqualToString:@"EditDetail"]) {
        [[segue destinationViewController] setStudent:self.student];
    }
    if ([[segue identifier] isEqualToString:@"LessonTableView"]) {
        [[segue destinationViewController] setTitle:student.name];
        [[segue destinationViewController] setFetchedResultsController:self.fetchedResultsController];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        [[segue destinationViewController] setStudent:self.student];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self configureView];
}

- (void)viewDidUnload
{
    [self setPhoneLabel:nil];
    [self setEmailLabel:nil];
    [self setNameLabel:nil];
    [self setPictureView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.detailDescriptionLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (UIInterfaceOrientationIsPortrait(interfaceOrientation));
}

- (void)updateStudent:(NSString *)name email:(NSString *)email phone:(NSString *)phone picture:(UIImage*)picture {
    student.name = name;
    student.phone = phone;
    student.email = email;
    
    UIImage *image = student.photo.image;
        _pictureView.image = image;
}

-(IBAction)phoneCall:(id)sender;
{
    if (_phoneLabel.text) {
        NSString *onlyNumbers = [[_phoneLabel.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];

        NSString *URLString = [@"tel://" stringByAppendingString:onlyNumbers];
        NSURL *URL = [NSURL URLWithString:URLString];
        [[UIApplication sharedApplication] openURL:URL];
    }
}


- (IBAction)actionEmailComposer {
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Lesson Book Message."];
        [mailViewController setMessageBody:@"" isHTML:NO];
        if ([_student email] == nil) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Email Error" message:@"Student has no email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            return;
        }
        [mailViewController setToRecipients:[NSArray arrayWithObject:[_student email]]];
        
        [self presentModalViewController:mailViewController animated:YES];
        
    }
    else {
        //NSLog(@"Device is unable to send email in its current state.");
    }
    
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult :(MFMailComposeResult)result error:(  NSError*)error {

[self dismissModalViewControllerAnimated:YES];

}

@end
