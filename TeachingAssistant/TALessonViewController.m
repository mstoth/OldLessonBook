//
//  TALessonViewController.m
//  LessonBook
//
//  Created by Michael Toth on 3/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TALessonViewController.h"
#import "TAAppDelegate.h"
#import "Lesson.h"
#import "PieceStatus.h"
#import "TALessonDetailViewController.h"
#import "Note.h"

@interface TALessonViewController ()

@end

@implementation TALessonViewController {
    
}
@synthesize lessonArray;
@synthesize student;
//@synthesize fetchedResultsController;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;




- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        NSSet *lessonSet = [[NSSet alloc] initWithSet:student.lesson];
        self.lessonArray = [lessonSet allObjects];
    }
    self.title = student.name;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.lessonArray = [student.lesson allObjects];
    [self setTitle:student.name];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setDelegate:self];
    self.parentViewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"flare.png"]];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [self setTitle:student.name];
    [self reloadStudents];
}

- (void)reloadStudents {
    NSError *error=nil;
    
    /*
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [(TAAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Lesson" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    //NSLog(@"number of lessons = %d", [items count]);
     */
    //NSFetchRequest *fetchRequest = __fetchedResultsController.fetchRequest;
    // Edit the entity name as appropriate.
    //NSEntityDescription *entity = [NSEntityDescription entityForName:@"Lesson" inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [(TAAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Student" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", student.name];
    NSArray *students = [context executeFetchRequest:fetchRequest error:&error];
    
    //NSLog(@"Number of Students = %d", [students count]);
    //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", student.name];
    self.student = [students objectAtIndex:0];
    
    // [self.student addLesson:[NSSet setWithArray:[student.lesson allObjects]]];
    //NSLog(@"Student has %d lessons.",[self.student.lesson count]);
    NSArray *la = [[NSArray alloc] initWithArray:[self.student.lesson allObjects]];
    //NSLog(@"la has %d objects",[la count]);
    [self setLessonArray:[la sortedArrayUsingSelector:@selector(compareLessons:)]];
    //NSLog(@"lesson array has %d objects",[self.lessonArray count]);
    if (![context save:&error]) {
        // handle error
        //NSLog(@"Error in save for reloadStudents");
    }
    [self.tableView reloadData];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    //NSLog(@"Number of sections = 1");
    return 1;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[NSArray alloc] initWithObjects:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    ////NSLog(@"Number of Rows = %d",[self.lessonArray count]);
    ////NSLog(@"First lesson location is %@",[[self.lessonArray objectAtIndex:0] location]);
    ////NSLog(@"LessonArray: %@",[self.lessonArray description]);
    return[self.lessonArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LessonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    ////NSLog(@"Number of Rows = %d",[self.lessonArray count]);
    ////NSLog(@"LessonArray: %@",[self.lessonArray description]);

    ////NSLog(@"First lesson location is %@",[[self.lessonArray objectAtIndex:0] location]);

    Lesson *lesson = [self.lessonArray objectAtIndex:[indexPath row]];
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"EEEE, MMMM dd, yyyy"];
    
    cell.textLabel.text = [df stringFromDate:lesson.date];   
    [df setDateFormat:@"hh:mma"];
    cell.detailTextLabel.text = [df stringFromDate:lesson.date];
    return cell;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"LessonDetailView"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Lesson *lesson = [self.lessonArray objectAtIndex:[indexPath row]];
        [[segue destinationViewController] setStudent:student];
        [(TALessonDetailViewController*)[segue destinationViewController] setLesson:lesson];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        [[segue destinationViewController] setDelegate:self];
    }
}

#pragma mark - Table view delegate
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    *//*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     *//*
}
*/
- (IBAction)addLesson:(id)sender {

    NSError *error;
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSDate *date = [[NSDate alloc] init];
    Lesson *lesson = (Lesson *)[NSEntityDescription insertNewObjectForEntityForName:@"Lesson" inManagedObjectContext:context];
    
    [lesson setDate:date];
    [lesson setLocation:@"Room 101"];
    if (![__managedObjectContext save:&error]) {
        //handle error
        //NSLog(@"Error saving in addLesson");
    }

    ////NSLog(@"Student has %d lessons before add.",[student.lesson count]);
    [self.student addLessonObject:lesson];
    ////NSLog(@"Student has %d lessons after add.",[student.lesson count]);

    if (![context save:&error]) {
        //handle error
        //NSLog(@"Error saving in addLesson");
    }
    
    ////NSLog(@"Student has %d lessons after save.",[student.lesson count]);
    [self reloadStudents];
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Lesson *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [object.date description];
}

- (void) deleteMe:(Lesson *)lesson {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSSet *piecesInLesson;
    piecesInLesson = lesson.piece;
    // get the status and recording objects deleted 
    for (PieceStatus *pStatus in lesson.pieceStatus) {
        if (pStatus.recording) {
            [context deleteObject:(NSManagedObject *)pStatus.recording];
        }
        [context deleteObject:pStatus];
    }
    [context deleteObject:lesson];
    //[self.managedObjectContext deleteObject:lesson];
    NSError *error = nil;
    [context save:&error];
    if (error) {
        //NSLog(@"Error saving in deleteMe");
    }
    [self.navigationController popViewControllerAnimated:YES];
    [self reloadStudents];
/*
    NSFetchRequest *fetchRequest = __fetchedResultsController.fetchRequest;
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Student" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", student.name];
    
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    student = [self.fetchedResultsController objectAtIndexPath:0];
    NSSet *lessonSet = [[NSSet alloc] initWithSet:student.lesson];
    self.lessonArray = [lessonSet allObjects];
 */
}

@end
