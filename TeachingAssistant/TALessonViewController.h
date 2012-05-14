//
//  TALessonViewController.h
//  LessonBook
//
//  Created by Michael Toth on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Student.h"
#import "CoreDataTableViewController.h"
#import "TALessonDetailViewController.h"


@interface TALessonViewController : CoreDataTableViewController  <TALessonDetailViewDelegate>
- (IBAction)addLesson:(id)sender;
@property (nonatomic, retain) NSArray *lessonArray;
@property (nonatomic, retain) Student *student;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end
