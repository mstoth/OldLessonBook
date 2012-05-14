//
//  TALessonDetailViewController.h
//  LessonBook
//
//  Created by Michael Toth on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lesson.h"
#import "Student.h"
#import <GameKit/GameKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@protocol TALessonDetailViewDelegate;

typedef enum {
    LESSON_UPDATE
} packetCodes;

@interface TALessonDetailViewController : UIViewController <GKPeerPickerControllerDelegate,GKSessionDelegate, UIAlertViewDelegate,
    UITableViewDelegate, MFMailComposeViewControllerDelegate,
    UIPrintInteractionControllerDelegate> {
    NSInteger   peerStatus;
    int packetNumber;
}
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
- (IBAction)emailLesson:(id)sender;
- (IBAction)actionEmailComposer;
- (IBAction)sendLesson:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *printButton;
@property (retain) GKSession* connectionSession;
@property (nonatomic, retain) NSMutableArray *connectionPeers;
@property (nonatomic, retain) GKPeerPickerController* connectionPicker;
- (IBAction)connectBluetooth:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *connectButton;
- (IBAction)printLesson:(id)sender;

//- (IBAction)receiveLesson:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
- (IBAction)deleteLesson:(id)sender;
- (IBAction)changeDate:(id)sender;
@property (nonatomic, strong) Lesson *lesson;
@property (nonatomic, strong) Student *student;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)copyPreviousLesson:(id)sender;
@property (nonatomic, retain) id<TALessonDetailViewDelegate>delegate;
@property(nonatomic, copy)   NSString    *peerId;

@end

@protocol TALessonDetailViewDelegate <NSObject>

@optional
-(void)deleteMe:(Lesson *)lesson;

@end