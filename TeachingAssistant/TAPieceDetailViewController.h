//
//  TAPieceDetailViewController.h
//  LessonBook
//
//  Created by Michael Toth on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h> 
#import "PieceStatus.h"
#import "Lesson.h"
#import "Piece.h"

@interface TAPieceDetailViewController : UIViewController <UIAlertViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITextViewDelegate,
    UITextFieldDelegate> {
    NSURL * recordedTmpFile;
	AVAudioRecorder * recorder;
    NSData *recordedData;
    AVAudioPlayer *musicPlayer;
    AVAudioPlayer *tickPlayer;
        NSThread *practiceTimer;
    BOOL editing;
        BOOL timing;
}
- (IBAction)togglePracticing:(id)sender;
@property (nonatomic, retain) NSNumber *practiceTimeAccumulated;
@property (weak, nonatomic) IBOutlet UITextField *metronomeTextField;
- (IBAction)viewRecordings:(id)sender;
- (IBAction)toggleMetronome:(id)sender;
- (IBAction)toggleRecording:(id)sender;
- (IBAction)setCurrentTempo:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *practiceTimeLabel;
- (IBAction)done:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UISwitch *practiceSwitch;


- (void)startDriverTimer:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *pieceTitleLabel;
@property CGFloat duration;
@property (weak, nonatomic) IBOutlet UILabel *goalsLabel;
@property (weak, nonatomic) IBOutlet UITextView *goalsTextView;
@property (weak, nonatomic) IBOutlet UIButton *recordingsButton;
@property (weak, nonatomic) IBOutlet UISwitch *recordSwitch;
@property (weak, nonatomic) IBOutlet UILabel *currentTempoLabel;
@property (weak, nonatomic) IBOutlet UISwitch *metronomeSwitch;
@property (weak, nonatomic) IBOutlet UISlider *metronomeSlider;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@property (nonatomic, strong) Piece *piece;
@property (nonatomic, strong) Lesson *lesson;
@end
