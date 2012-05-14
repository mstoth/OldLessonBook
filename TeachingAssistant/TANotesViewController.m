//
//  TANotesViewController.m
//  LessonBook
//
//  Created by Michael Toth on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TANotesViewController.h"
#import "Note.h"

@interface TANotesViewController () {
    BOOL editing;
}

@end

@implementation TANotesViewController
@synthesize textView,student,managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)keyboardWillShow {
    // Animate the current view out of the way
    [UIView animateWithDuration:0.3f animations:^ {
        self.view.frame = CGRectMake(0, 0, 320, 200);
    }];
    editing = YES;
}

-(void)keyboardWillHide {
    // Animate the current view back to its original position
    [UIView animateWithDuration:0.3f animations:^ {
        self.view.frame = CGRectMake(0, 0, 320, 480);
    }];
    editing = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    self.textView.text = self.student.note.text;
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self setTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)saveNote:(id)sender {
    NSError *error = nil;
    Student *theStudent;
    NSManagedObjectContext *context;
    if (!editing) {
        context = self.managedObjectContext;
        //Set up to get the thing you want to update
        NSFetchRequest * request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Student" inManagedObjectContext:context]];
        [request setPredicate:[NSPredicate predicateWithFormat:@"name=%@",student.name]];
        
        //Ask for it
        theStudent = [[context executeFetchRequest:request error:&error] lastObject];

        Note *note = (Note *)[NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:context];

        [note setText:self.textView.text];
        //NSLog(@"Note text is %@",[note text]);
        
        if (theStudent.note) {
            [context deleteObject:theStudent.note];
        }
        theStudent.note = note;
        
        [context save:&error];
        if (error) {
            //NSLog(@"Error in save note. %@",error.description);
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        editing = NO;
        [self.textView resignFirstResponder];
    }
}
@end
