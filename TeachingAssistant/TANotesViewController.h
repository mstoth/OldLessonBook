//
//  TANotesViewController.h
//  LessonBook
//
//  Created by Michael Toth on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "Lesson.h"
#import "Student.h"

@interface TANotesViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) Student *student;
- (IBAction)saveNote:(id)sender;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
