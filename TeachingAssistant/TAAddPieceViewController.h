//
//  TAAddPieceViewController.h
//  LessonBook
//
//  Created by Michael Toth on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Piece.h"
#import "Lesson.h"
@protocol TAAddPieceViewDelegate;

@interface TAAddPieceViewController : UIViewController <UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *piecePickerView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) id<TAAddPieceViewDelegate>delegate;
@property (nonatomic, strong) Lesson *lesson;
@property (nonatomic, strong) NSMutableArray *composersArray;
@property (nonatomic, strong) NSMutableArray *piecesArray;
@property (weak, nonatomic) IBOutlet UITextField *titleTextView;
@property (weak, nonatomic) IBOutlet UITextField *composerTextView;
@property (weak, nonatomic) IBOutlet UITextField *genreTextView;
@property (weak, nonatomic) IBOutlet UITextField *difficultyTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *difficultyControl;
- (IBAction)done:(id)sender;
- (IBAction)clearFields:(id)sender;

@end

@protocol TAAddPieceViewDelegate <NSObject>

@optional
-(void)addPiece:(Piece *)piece;

@end