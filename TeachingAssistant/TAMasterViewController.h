//
//  TAMasterViewController.h
//  LessonBook
//
//  Created by Michael Toth on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
#import "TADetailViewController.h"

@interface TAMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, TADetailViewDelegate, UIGestureRecognizerDelegate>

- (IBAction)help:(id)sender;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
-(IBAction)updateDetailItem:(id)detailItem;
-(void)addStudent;
@end
