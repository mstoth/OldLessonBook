//
//  TARemovePieceViewController.m
//  LessonBook
//
//  Created by Michael Toth on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TARemovePieceViewController.h"
#import "TAAppDelegate.h"
#import "Piece.h"
#import "Lesson.h"
#import "PieceStatus.h"
#import "Recording.h"

@interface TARemovePieceViewController () {
    Piece *selectedPiece;
}

@end

@implementation TARemovePieceViewController
@synthesize piecePickerView;
@synthesize lessonOrDatabaseSegmentedControl;
@synthesize titleTextField;
@synthesize composerTextField;
@synthesize genreTextField;
@synthesize piecesArray, lesson, composersArray;

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
    NSMutableSet *composers;
    composers = [[NSMutableSet alloc] init];
    composersArray = [[NSMutableArray alloc] init];
    [self getPiecesForLesson];
    [piecePickerView setDelegate:self];
    if ([self.piecesArray count] > 0) {
        Piece *p = [self.piecesArray objectAtIndex:0];
        self.titleTextField.text = p.title;
        self.composerTextField.text = p.composer;
        self.genreTextField.text = p.genre;
        for (Piece *piece in self.piecesArray) {
            [composers addObject:piece.composer];
        }
        [composersArray addObjectsFromArray:[composers allObjects]] ;
        [composersArray sortUsingSelector:@selector(compare:)];
        [composersArray insertObject:@"All" atIndex:0];
    }

	// Do any additional setup after loading the view.
    //[self getPiecesForLesson];
}

- (void)viewDidUnload
{
    [self setPiecePickerView:nil];
    [self setLessonOrDatabaseSegmentedControl:nil];
    [self setTitleTextField:nil];
    [self setComposerTextField:nil];
    [self setGenreTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (void)getPieces {
    NSMutableSet *composers;
    composers = [[NSMutableSet alloc] init];
    
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity;
    NSManagedObjectContext *context = [(TAAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSSortDescriptor *sortDescriptor;
    entity = [NSEntityDescription entityForName:@"Piece" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSArray *pieces = [context executeFetchRequest:fetchRequest error:&error];
    self.piecesArray = [pieces mutableCopy];
    
    NSMutableArray *copyOfPieces = [self.piecesArray mutableCopy];
    if ([piecePickerView selectedRowInComponent:1] > 0) {
        NSString *composer = [self.composersArray objectAtIndex:[self.piecePickerView selectedRowInComponent:1]];
        for (Piece *p in copyOfPieces) {
            if (![p.composer isEqualToString:composer]) {
                [self.piecesArray removeObject:p];
            }
        }
    } 
    [self.piecesArray sortUsingSelector:@selector(comparePieces:)];
}




-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 2;
}
//PickerViewController.m
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (component == 0) {
        return [self.piecesArray count];
    } else {
        return [self.composersArray count];
    }
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    Piece *p = nil;
    if (component == 0) {
        p = [self.piecesArray objectAtIndex:row];
        return p.title;
    } else {
        NSString *c = [self.composersArray objectAtIndex:row];
        return c;
    }
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    Piece *p = nil;

    switch (component) {
        case 0:
            [self refreshPicker];
            if ([piecesArray count]>0) {
                p = [piecesArray objectAtIndex:[self.piecePickerView selectedRowInComponent:0]];
                titleTextField.text = p.title;
                composerTextField.text = p.composer;
                genreTextField.text = p.genre;
            }
            break;
        case 1:
            [self refreshPicker];
            p = [piecesArray objectAtIndex:[self.piecePickerView selectedRowInComponent:0]];
            titleTextField.text = p.title;
            composerTextField.text = p.composer;
            genreTextField.text = p.genre;
            break;
        default:
            break;
    }
}
- (void)refreshPicker {
    [self switchSource:self];
}

- (void) getSelectedPiece {
   // NSError *error = nil;
    for (Piece *p in self.piecesArray) {
        if ([p.title isEqualToString:titleTextField.text]&&
            [p.composer isEqualToString:composerTextField.text] &&
            [p.genre isEqualToString:genreTextField.text]) {
            
            selectedPiece = p;
        }
    }
}

- (void) getPiecesForLesson {
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSManagedObjectContext *context = [(TAAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Piece" inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSArray *pieces = [context executeFetchRequest:fetchRequest error:&error];
    
    self.piecesArray = [pieces mutableCopy];
    NSMutableArray *newPieceArray = [[NSMutableArray alloc] init];
    for (Piece *p in self.piecesArray) {
        if ([lesson.piece containsObject:p]) {
            // keep it
            if ([self.piecePickerView selectedRowInComponent:1] == 0) {
                [newPieceArray addObject:p];
            } else {
                NSString *composer = [composersArray objectAtIndex:[self.piecePickerView selectedRowInComponent:1]];
                if ([p.composer isEqualToString:composer]) {
                    [newPieceArray addObject:p];
                }
            }
        } else {
            // don't add it
        }
    }
    self.piecesArray = newPieceArray;
    [self.piecesArray sortUsingSelector:@selector(comparePieces:)];
    //NSLog(@"Number of Pieces in piecesArray = %d",[self.piecesArray count]);
}

- (void) getAllPieces {
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [(TAAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Piece" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"date = %@", lesson.date];
    NSArray *pieces = [context executeFetchRequest:fetchRequest error:&error];
    
    //NSLog(@"Number of Pieces = %d", [pieces count]);
    //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", student.name];
    self.piecesArray = [pieces mutableCopy];
    //NSLog(@"Number of Pieces in piecesArray = %d",[self.piecesArray count]);
    [self.piecesArray sortUsingSelector:@selector(comparePieces:)];
    Piece *p = [self.piecesArray objectAtIndex:0];
    self.titleTextField.text = p.title;
    self.composerTextField.text = p.composer;
    self.genreTextField.text = p.genre;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)removePiece:(id)sender {
    NSError *error = nil;
    NSManagedObjectContext *context = [(TAAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    [self getSelectedPiece];

    if ([lessonOrDatabaseSegmentedControl selectedSegmentIndex] == 0) {
        //NSLog(@"Remove Piece From Lesson");
        
        // remove pieceStatus if it exists
        NSMutableSet *pset = [lesson.piece mutableCopy];
        [pset removeObject:selectedPiece];
        for (PieceStatus *ps in lesson.pieceStatus) {
            if ([ps.pieceTitle isEqualToString:selectedPiece.title]) {
                Recording *r = ps.recording;
                if ([[r data] length] > 0) {
                    [context deleteObject:(NSManagedObject *)ps.recording];
                }
                [context deleteObject:ps];
            }
        }
        
        [lesson setPiece:pset];
        if (![context save:&error]) {
            //NSLog(@"failed save in removePiece");
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if (![context save:&error]) {
            //NSLog(@"failed save in removePiece");
        }
        [context deleteObject:selectedPiece];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)switchSource:(id)sender {
    if ([lessonOrDatabaseSegmentedControl selectedSegmentIndex] == 0) {
        [self getPiecesForLesson];
    } else {
        [self getPieces];
    }
    [piecePickerView reloadAllComponents];
}
@end
