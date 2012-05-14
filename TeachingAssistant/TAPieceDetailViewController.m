//
//  TAPieceDetailViewController.m
//  LessonBook
//
//  Created by Michael Toth on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAPieceDetailViewController.h"
#import "PieceStatus.h"
#import "TAAppDelegate.h"
#import "Recording.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioServices.h>

#define kMaxBPM 200
#define kMinBPM 40
#define kDefaultBPM 80

@interface TAPieceDetailViewController () 
@end

@implementation TAPieceDetailViewController
@synthesize practiceTimeLabel;
@synthesize metronomeTextField;
@synthesize saveButton;
@synthesize practiceSwitch;
@synthesize recordingsButton;
@synthesize recordSwitch;
@synthesize goalsLabel;
@synthesize goalsTextView;
@synthesize pieceTitleLabel;
@synthesize duration;
@synthesize metronomeSwitch;
@synthesize metronomeSlider;
@synthesize currentTempoLabel;
@synthesize managedObjectContext;
@synthesize lesson;
@synthesize piece;
@synthesize fetchedResultsController;
@synthesize doneBarButton;
@synthesize practiceTimeAccumulated;
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    // Create and prepare audio players for tick and tock sounds
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSError *error;

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSURL *tickURL = [NSURL fileURLWithPath:[mainBundle pathForResource:@"tick" ofType:@"caf"]];
		
		tickPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:tickURL error:&error];
		if (!tickPlayer) {
			//NSLog(@"no tickPlayer: %@", [error localizedDescription]);	
		}
		[tickPlayer prepareToPlay];
        [self setDuration:60.0];
        //NSLog(@"duration = %f",self.duration);
        [tickPlayer play];
    }
    
    return self;
}
*/
- (void)viewDidLoad
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSError *error = nil;
    [super viewDidLoad];
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;                
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,          
                             sizeof (audioRouteOverride),&audioRouteOverride); 
    
	// Do any additional setup after loading the view.
    [metronomeSlider setMinimumValue:40.0];
    [metronomeSlider setMaximumValue:200.0];
    [metronomeSlider addTarget:self action:@selector(metronomeChanged:) forControlEvents:UIControlEventValueChanged];
    [metronomeSlider setValue:40.0];
    metronomeTextField.text = @"40";
    [UIApplication sharedApplication].idleTimerDisabled = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [metronomeTextField setDelegate:self];
    PieceStatus *ps = [self getPieceStatusFromDatabase];
    
    pieceTitleLabel.text = ps.pieceTitle;
    self.practiceTimeLabel.text = [NSString stringWithFormat:@"%0.2f Hours",[ps.practiceTime floatValue]];
    currentTempoLabel.text = ps.currentTempo;
    
    NSURL *tickURL = [NSURL fileURLWithPath:[mainBundle pathForResource:@"tick" ofType:@"caf"]];
    
    tickPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:tickURL error:&error];
    if (!tickPlayer) {
        //NSLog(@"no tickPlayer: %@", [error localizedDescription]);	
    }
    [tickPlayer prepareToPlay];
    [self setBpm:40];
    
    musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:tickURL error:&error];
    if (!musicPlayer) {
        //NSLog(@"no musicPlayer: %@", [error localizedDescription]);	
    }
    [musicPlayer setDelegate:self];
    [musicPlayer prepareToPlay];

    //Instanciate an instance of the AVAudioSession object.
    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    //Setup the audioSession for playback and record.
    //We could just use record and then switch it to playback leter, but
    //since we are going to do both lets set it up once.
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &error];
    //[audioSession setCategory:AVAudioSessionCategoryPlayback error: &error];
    //Activate the session
    [audioSession setActive:YES error: &error];
     
    recordSwitch.onTintColor = [UIColor redColor];
    recordSwitch.on = NO;
    
    if (!ps.recording) {
        [self.recordingsButton setTitle:@"No Recording" forState:UIControlStateNormal];
        recordedData = nil;
    } else {
        [self.recordingsButton setTitle:@"Play" forState:UIControlStateNormal];
        recordedData = ps.recording.data;
    }
    practiceTimer = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(startPracticeTimer:)
                                                   object:nil];
    timing = TRUE;
    [practiceTimer start];
    
    if (ps.goal) {
        [self.goalsTextView setText:ps.goal];
    }
    [self.goalsTextView setDelegate:self];
}

-(void)keyboardWillShow {
    editing = YES;
}


-(void)keyboardWillHide {
    editing = NO;
}

- (void) metronomeChanged:(id)sender {
    NSNumber *number = [NSNumber numberWithFloat:[metronomeSlider value]];
    metronomeTextField.text = [NSString stringWithFormat:@"%d",[number intValue]] ;
    NSUInteger t;
    t=[metronomeTextField.text intValue];
    [self setBpm:t];
}

- (void)playSound {
    [tickPlayer play];
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.recordingsButton setTitle:@"Play" forState:UIControlStateNormal];
}

- (void)recordOn {
    NSError * error;

    NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];

    NSString *pathComponent = [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"caf"];
    
    recordedTmpFile = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:pathComponent];
    // //NSLog(@"Using File called: %@",recordedTmpFile);
    
    //Setup the recorder to use this file and record to it.
    recorder = [[ AVAudioRecorder alloc] initWithURL:recordedTmpFile settings:recordSetting error:&error];
    [recorder setDelegate:self];
    [recorder prepareToRecord];
    [recorder record];
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)startPracticeTimer:(id)sender {
    BOOL continueTiming = YES;
    PieceStatus *ps = [self getPieceStatusFromDatabase];
    //NSError *error;
    while (continueTiming) {
        NSDate *incrementTime = [[NSDate alloc] initWithTimeIntervalSinceNow:60];
        NSDate *currentTime = [[NSDate alloc] init];
        while (continueTiming && ([currentTime compare:incrementTime] != NSOrderedDescending)) {
            [NSThread sleepForTimeInterval:60];
            currentTime = [[NSDate alloc] init];
            if ([practiceSwitch isOn] == NO) {
                continueTiming = NO;
            } else {
                if (timing) {
                    ps.practiceTime = [NSNumber numberWithFloat:[ps.practiceTime floatValue] + (1/60.0)];
                    self.practiceTimeAccumulated = ps.practiceTime;
                    [self.practiceTimeLabel performSelectorOnMainThread:@selector(setText:) withObject:[NSString stringWithFormat:@"%0.2f Hours",[ps.practiceTime floatValue]] waitUntilDone:NO];
                } else {
                    continueTiming = NO;
                }
            }
        }
    }
}


// This method is invoked from the driver thread
- (void)startDriverTimer:(id)sender {
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Give the sound thread high priority to keep the timing steady.
    [NSThread setThreadPriority:1.0];
    BOOL continuePlaying = YES;
    
    while (continuePlaying) {  // Loop until cancelled.
        // An autorelease pool to prevent the build-up of temporary objects.
        //NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init]; 
        
        [self playSound];
        //NSLog(@"duration=%f",self.duration);
        NSDate *curtainTime = [[NSDate alloc] initWithTimeIntervalSinceNow:self.duration];
        NSDate *currentTime = [[NSDate alloc] init];
        
        // Wake up periodically to see if we've been cancelled.
        while (continuePlaying && ([currentTime compare:curtainTime] != NSOrderedDescending)) { 
            [NSThread sleepForTimeInterval:0.01];
            currentTime = [[NSDate alloc] init];
            if ([metronomeSwitch isOn] == NO) {
                continuePlaying = NO;
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    metronomeSwitch.on = NO;
    [UIApplication sharedApplication].idleTimerDisabled = NO;

    timing=FALSE;
    [tickPlayer stop];
    [musicPlayer stop];
}

- (void)viewDidUnload
{
    [self setCurrentTempoLabel:nil];
    [self setMetronomeSwitch:nil];
    [self setMetronomeSlider:nil];
    [self setGoalsTextView:nil];
    [self setGoalsLabel:nil];
    [self setRecordSwitch:nil];
    [self setRecordingsButton:nil];
    [self setMetronomeSwitch:nil];
    [self setDoneBarButton:nil];
    [self setPieceTitleLabel:nil];
    [self setSaveButton:nil];
    [self setMetronomeTextField:nil];
    [tickPlayer stop];
    [musicPlayer stop];

    timing=FALSE;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self setPracticeTimeLabel:nil];
    [self setPracticeSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)toggleMetronome:(id)sender {
    if ([metronomeSwitch isOn]) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                     selector:@selector(startDriverTimer:)
                                                       object:nil];
        
        [myThread start];  // Actually create the thread
    } else {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        // nothing to do
    }
}

- (void)playerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
	{
        //NSLog(@"ERROR IN DECODE: %@\n", error);
    }

- (IBAction)viewRecordings:(id)sender {
    NSError *error = nil;
    NSData *audioData;
    if ([self.recordingsButton.titleLabel.text isEqualToString:@"Stop"]) {
        [musicPlayer stop];
        [self.recordingsButton setTitle:@"Play" forState:UIControlStateNormal];
    } else if ([self.recordingsButton.titleLabel.text isEqualToString:@"Play"]) {
        if (recordedTmpFile) {
            audioData = [NSData dataWithContentsOfURL:recordedTmpFile];
        } else {
            audioData = recordedData;
        }
        UInt32 doChangeDefaultRoute = 1;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
        (void)[musicPlayer initWithData:audioData error:&error];
        [musicPlayer setDelegate:self];
        ////NSLog(@"volume is %f",[musicPlayer volume]);
        [musicPlayer prepareToPlay];
        [musicPlayer play];
        [self.recordingsButton setTitle:@"Stop" forState:UIControlStateNormal];
    }
}

- (IBAction)toggleRecording:(id)sender {
    if ([recordSwitch isOn]) {
        [self recordOn];
        [self.recordingsButton setTitle:@"Recording" forState:UIControlStateNormal];
        [self.recordingsButton setEnabled:NO];
    } else {
        [recorder stop];
        [self.recordingsButton setTitle:@"Play" forState:UIControlStateNormal];
        [self.recordingsButton setEnabled:YES];
    }
}

- (IBAction)setCurrentTempo:(id)sender {
    currentTempoLabel.text = metronomeTextField.text;
}

#pragma mark -
#pragma mark === bpm ===
#pragma mark -

- (NSUInteger)bpm {
    return lrint(ceil(60.0 / (self.duration)));
}


- (void)setBpm:(NSUInteger)bpm {
    if (bpm >= kMaxBPM) {
        bpm = kMaxBPM;
    } else if (bpm <= kMinBPM) {
        bpm = kMinBPM;
    }    
    self.duration = (60.0 / bpm);
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //NSLog(@"Clicked button %d",buttonIndex);
}

- (PieceStatus *) getPieceStatusFromDatabase {
    NSError *error = nil;
    PieceStatus *status = nil;
    
    NSManagedObjectContext *context = [self.piece managedObjectContext];
    //NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    //NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];

    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"PieceStatus" 
                                   inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:
                              @"pieceTitle = %@", piece.title];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pieceTitle" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];

    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    if (![aFetchedResultsController performFetch:&error]) {
        //NSLog(@"Failed fetch in done:");
    }
    NSArray *psArray = [aFetchedResultsController fetchedObjects];
    for (PieceStatus *ps in psArray) {
        //NSLog(@"ps.lessonDate is %@ and lesson.date is %@",ps.lessonDate,lesson.date);
        if ([ps.lessonDate isEqualToDate:lesson.date]) {
            status = ps;
        }
    }
    if (!status) {
        status = (PieceStatus *)[NSEntityDescription insertNewObjectForEntityForName:@"PieceStatus" inManagedObjectContext:context];
        status.lessonDate = lesson.date;
        status.pieceTitle = piece.title;
        status.currentTempo = @"40";
    }
    return status;
}


- (IBAction)done:(id)sender {
    NSError *error = nil;
    PieceStatus *status = nil;
    
    if (editing) {
        [metronomeTextField resignFirstResponder];
        [goalsTextView resignFirstResponder];
        editing = NO;
        self.navigationItem.rightBarButtonItem.title = @"Save";
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
    } else {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PieceStatus" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:
                              @"pieceTitle = %@", piece.title];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pieceTitle" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];

    if (![aFetchedResultsController performFetch:&error]) {
        //NSLog(@"Failed fetch in done:");
    }
    NSArray *psArray = [aFetchedResultsController fetchedObjects];
    for (PieceStatus *ps in psArray) {
        if ([ps.lessonDate isEqualToDate:lesson.date]) {
            status = ps;
        }
    }
    if (!status) {
        status = (PieceStatus *)[NSEntityDescription insertNewObjectForEntityForName:@"PieceStatus" inManagedObjectContext:self.managedObjectContext];
        status.lessonDate = lesson.date;
        status.pieceTitle = piece.title;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:recordedTmpFile.path]) {
        if (status.recording) {
            [self.managedObjectContext deleteObject:status.recording];
        }
        NSData *soundData = nil;
        soundData = [NSData dataWithContentsOfURL:recordedTmpFile];
        Recording *recording = nil;
        recording = (Recording *)[NSEntityDescription insertNewObjectForEntityForName:@"Recording" inManagedObjectContext:self.managedObjectContext];
        [recording setTitle:piece.title];
        [recording setData:soundData];
        [recording setLesson:lesson];
        [recording setPieceStatus:status];
        status.recording = recording;
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:recordedTmpFile.path error:&error];
    }
    //PieceStatus *status = (PieceStatus *)[NSEntityDescription insertNewObjectForEntityForName:@"PieceStatus" inManagedObjectContext:self.managedObjectContext];
    [status setCurrentTempo:currentTempoLabel.text];
    if (![self.managedObjectContext save:&error]) {
        //NSLog(@"Error saving in done:");
    }
    [status setPieceTitle:piece.title];
    [status setLessonDate:lesson.date];
    [status setGoal:goalsTextView.text];
        [status setPracticeTime:self.practiceTimeAccumulated];
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
    sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];

    // Edit the entity name as appropriate.
    entity = [NSEntityDescription entityForName:@"Lesson" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"date = %@", lesson.date];
    
    aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    //NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    //aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    lesson = [[fetchedResultsController fetchedObjects] objectAtIndex:0];
    [lesson addPieceStatusObject:status];
        NSLog(@"lesson has %d piece statuses.",[lesson.pieceStatus count]);
    if (![managedObjectContext save:&error]) {
        //NSLog(@"Error saving in done:");
    }
        [UIApplication sharedApplication].idleTimerDisabled = NO;

    [metronomeSwitch setOn:NO];
        timing=FALSE;
    [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark textField protocol

-(void) textFieldDidBeginEditing:(UITextField *)textField {
    editing = YES;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor redColor];
    self.navigationItem.rightBarButtonItem.title = @"Done";
    [UIView animateWithDuration:0.3f animations:^ {
        self.view.frame = CGRectMake(0, -280, 320, 480);
    }];
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    editing = NO;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
    self.navigationItem.rightBarButtonItem.title = @"Save";
    [self.metronomeSlider setValue:[self.metronomeTextField.text doubleValue]];
    [UIView animateWithDuration:0.3f animations:^ {
        self.view.frame = CGRectMake(0,0,320,480);
    }];
}

#pragma mark - 
#pragma mark textView protocol methods
- (void) textViewDidBeginEditing:(UITextView *)textView  {
    editing = YES;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor redColor];
    self.navigationItem.rightBarButtonItem.title = @"Done";

    //[self.saveButton setTitle:@"Done"];
}

- (void) textViewDidEndEditing:(UITextView *)textView {
    editing = NO;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
    self.navigationItem.rightBarButtonItem.title = @"Save";

}

- (IBAction)togglePracticing:(id)sender {
    if ([self.practiceSwitch isOn]) {
        practiceTimer = [[NSThread alloc] initWithTarget:self
                                                selector:@selector(startPracticeTimer:)
                                                  object:nil];
        
        [practiceTimer start];
    } else {
        [practiceTimer cancel];
    }
}
@end
