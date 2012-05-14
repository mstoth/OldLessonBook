//
//  TARemovePieceViewController.h
//  LessonBook
//
//  Created by Michael Toth on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lesson.h"

@interface TARemovePieceViewController : UIViewController <UIPickerViewDelegate>
- (IBAction)switchSource:(id)sender;
@property (weak, nonatomic) IBOutlet UIPickerView *piecePickerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *lessonOrDatabaseSegmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *composerTextField;
@property (weak, nonatomic) IBOutlet UITextField *genreTextField;
@property (nonatomic, strong) NSMutableArray *composersArray;

- (IBAction)removePiece:(id)sender;
@property (nonatomic, strong) NSMutableArray *piecesArray;
@property (nonatomic, strong) Lesson *lesson;

@end
