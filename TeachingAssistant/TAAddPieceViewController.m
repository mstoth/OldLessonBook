//
//  TAAddPieceViewController.m
//  LessonBook
//
//  Created by Michael Toth on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAAddPieceViewController.h"
#import "Piece.h"
#import "PieceStatus.h"
#import "TAAppDelegate.h"

@interface TAAddPieceViewController ()

@end

@implementation TAAddPieceViewController {
    NSNumber *difficulty;
}
@synthesize piecesArray,composersArray;
@synthesize piecePickerView;
@synthesize titleTextView;
@synthesize composerTextView;
@synthesize genreTextView;
@synthesize difficultyTextField;
@synthesize lesson;
@synthesize difficultyControl;
@synthesize fetchedResultsController, managedObjectContext;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self getPieces];
        [piecePickerView setDelegate:self];
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
    [self getPieces];
    [piecePickerView setDelegate:self];
    
    difficulty = [NSNumber numberWithInt:-1];

    if ([self.piecesArray count] > 0) {
        Piece *p = [self.piecesArray objectAtIndex:0];
        self.titleTextView.text = p.title;
        self.composerTextView.text = p.composer;
        self.genreTextView.text = p.genre;
        self.difficultyTextField.text = [p.difficulty stringValue];
        difficulty = p.difficulty;
        for (Piece *piece in self.piecesArray) {
            [composers addObject:piece.composer];
        }
        [composersArray addObjectsFromArray:[composers allObjects]] ;
        [composersArray sortUsingSelector:@selector(compare:)];
        [composersArray insertObject:@"All" atIndex:0];
    }
    
    [difficultyControl addTarget:self action:@selector(pickDifficulty:) forControlEvents:UIControlEventValueChanged];
	// Do any additional setup after loading the view.
    
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 2;
}
//PickerViewController.m
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    ////NSLog(@"%d pieces",[self.piecesArray count]);
    if (component == 0) {
        NSLog(@"%d rows for component %d.",[self.piecesArray count], component);
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
            if ([piecesArray count]>0) {
                p = [piecesArray objectAtIndex:row];
                titleTextView.text = p.title;
                composerTextView.text = p.composer;
                genreTextView.text = p.genre;
                difficultyTextField.text = [p.difficulty stringValue];
            }
            break;
        case 1:
            [self refreshPicker];
            if ([piecesArray count]>0) {
                p = [piecesArray objectAtIndex:[self.piecePickerView selectedRowInComponent:0]];
                titleTextView.text = p.title;
                composerTextView.text = p.composer;
                genreTextView.text = p.genre;
                difficultyTextField.text = [p.difficulty stringValue];
            }
            break;
        default:
            break;
    }
    [self refreshPicker];
}

- (void)refreshPicker {
    
    [self getPieces];
    [self.piecePickerView reloadAllComponents];
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
    
    if ([difficultyControl selectedSegmentIndex] != -1) {
        for (Piece *p in copyOfPieces) {
            NSLog(@"difficulty is %d and %d",[p.difficulty intValue],[difficulty intValue]);
            if (![p.difficulty isEqualToNumber:difficulty]) {
                [self.piecesArray removeObject:p];
            }
        }
    }
    [self.piecesArray sortUsingSelector:@selector(comparePieces:)];
    
}

- (void) pickDifficulty:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl*)sender;
    difficulty = [NSNumber numberWithInt:([segmentedControl selectedSegmentIndex]+1)];
    [difficultyTextField setText:[difficulty stringValue]];
    [self refreshPicker];
}

- (void)viewDidUnload
{
    [self setTitleTextView:nil];
    [self setComposerTextView:nil];
    [self setGenreTextView:nil];
    [self setDifficultyControl:nil];
    [self setPiecePickerView:nil];
    [self setDifficultyTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)done:(id)sender {
    NSError *error = nil;
    Piece *newPiece = nil;
    difficulty = [NSNumber numberWithInt:[difficultyTextField.text intValue]];
    NSManagedObjectContext *context = self.managedObjectContext;
    for (Piece *p in self.piecesArray) {
        if ([p.title isEqualToString:titleTextView.text]) {
            if ([p.composer isEqualToString:composerTextView.text]) {
                if ([p.genre isEqualToString:genreTextView.text]) {
                    if ([p.difficulty isEqualToNumber:difficulty]) {
                        newPiece = p;
                    }
                }
            }
        }
    }
    if (newPiece == nil) {
        newPiece = (Piece *)[NSEntityDescription insertNewObjectForEntityForName:@"Piece" inManagedObjectContext:context];
    }
    
    [newPiece setTitle:titleTextView.text];
    [newPiece setComposer:composerTextView.text];
    [newPiece setGenre:genreTextView.text];
    [newPiece setDifficulty:[NSNumber numberWithInt:[difficultyTextField.text intValue]]];
    [self.lesson addPieceObject:newPiece];
    if (![context save:&error]) {
        NSLog(@"Error saving in done:");
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clearFields:(id)sender {
    [titleTextView setText:@""];
    [composerTextView setText:@""];
    [genreTextView setText:@""];
    [difficultyTextField setText:@""];
    [difficultyControl setSelectedSegmentIndex:-1];
    //[piecePickerView selectRow:0 inComponent:1 animated:YES];
    [self refreshPicker];
}
@end
