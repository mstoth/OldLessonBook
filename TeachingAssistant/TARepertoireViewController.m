//
//  TARepertoireViewController.m
//  LessonBook
//
//  Created by Michael Toth on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TARepertoireViewController.h"
#import "TAAppDelegate.h"
#import "Lesson.h"
#import "Piece.h"
@interface TARepertoireViewController ()

@end

@implementation TARepertoireViewController {
    NSMutableSet *pieceNamesSet;
}
@synthesize student, managedObjectContext;
@synthesize pieceNames,composerNames;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSError *error;
    Student *theStudent;
    pieceNamesSet = [[NSMutableSet alloc] init ];
    [super viewDidLoad];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [(TAAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Student" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", student.name];
    NSArray *students = [context executeFetchRequest:fetchRequest error:&error];
    
    //NSLog(@"Number of Students = %d", [students count]);
    //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", student.name];
    theStudent = [students objectAtIndex:0];
    NSArray *lessons = [[theStudent lesson] allObjects];
    self.composerNames = [[NSMutableArray alloc] init];
    self.pieceNames = [[NSMutableArray alloc] init];
    for (Lesson *lsn in lessons) {
        for (Piece *p in [lsn piece]) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:p.title,@"title",p.composer,@"composer", nil];
            [pieceNamesSet addObject:dict];
        }
    }
    self.pieceNames = [[pieceNamesSet allObjects] mutableCopy];
    NSSortDescriptor *aSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    [self.pieceNames sortUsingDescriptors:[NSArray arrayWithObject:aSortDescriptor]];

    //[self.pieceNames sortUsingSelector:@selector(compare:)];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.pieceNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RepertoireCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    NSDictionary *dict = [pieceNames objectAtIndex:indexPath.row];
    
    NSString *pieceTitle = [dict objectForKey:@"title"];
    cell.textLabel.text = pieceTitle;
    cell.detailTextLabel.text = [dict objectForKey:@"composer"];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
