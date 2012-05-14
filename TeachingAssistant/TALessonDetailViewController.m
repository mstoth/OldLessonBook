//
//  TALessonDetailViewController.m
//  LessonBook
//
//  Created by Michael Toth on 4/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TALessonDetailViewController.h"
#import "Piece.h"
#import "Recording.h"
#import "PieceStatus.h"
#import "TAAddPieceViewController.h"
#import "TAAppDelegate.h"
#import "TAPieceDetailViewController.h"
#import "ModalAlertView.h"

typedef enum {
    kServer,
    kClient
} gameNetwork;

#define kMaxPacketSize 1024




@interface TALessonDetailViewController ()

@end

@implementation TALessonDetailViewController {
    NSArray *pieceArray;
    NSArray *pieceStatusArray;
    BOOL sendRecording,sendRecordingResponded;
}
@synthesize instructionLabel;
@synthesize activityIndicator;
@synthesize emailButton;
@synthesize connectButton;

@synthesize sendButton;
@synthesize printButton;
@synthesize dateButton;
@synthesize datePicker;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize student;
@synthesize lesson;
@synthesize tableView;
@synthesize delegate;
@synthesize connectionPeers,connectionPicker,connectionSession, peerId;

- (IBAction)deleteLesson:(id)sender {
    
    // Show the confirmation.
    UIAlertView *alert = [[UIAlertView alloc] 
                          initWithTitle: NSLocalizedString(@"Delete Lesson",nil)
                          message: NSLocalizedString(@"Are you sure you want to delete this lesson?",nil)
                          delegate: self
                          cancelButtonTitle: NSLocalizedString(@"Cancel",nil)
                          otherButtonTitles: NSLocalizedString(@"Delete",nil), nil];
    [alert setTag:100];
    [alert show];
}

- (IBAction)changeDate:(id)sender {
    if ([self.dateButton.titleLabel.text isEqualToString:@"Change Date"]) {
        [self.datePicker setHidden:NO];
        [self.connectButton setHidden:YES];
        [self.printButton setHidden:YES];
        [self.emailButton setHidden:YES];
        [self.instructionLabel setHidden:NO];
        [self.datePicker setDate:self.lesson.date];
        [self.dateButton setTitle:@"Save" forState:UIControlStateNormal];
    } else {
        lesson.date = [self.datePicker date];
        for (PieceStatus *p in lesson.pieceStatus) {
            p.lessonDate = lesson.date;
        }
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setFormatterBehavior:NSDateFormatterMediumStyle];
        self.title = [df stringFromDate:lesson.date];
        [self.datePicker setHidden:YES];
        [self.connectButton setHidden:NO];
        [self.instructionLabel setHidden:YES];
        [self.printButton setHidden:NO];
        [self.emailButton setHidden:NO];
        [self.dateButton setTitle:@"Change Date" forState:UIControlStateNormal];
    }
}

// Called when an alertview button is touched
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch ([alertView tag]) {
        case 100:
            switch (buttonIndex) { // verifying delete lesson
                case 0: 
                {       
                    //NSLog(@"Delete was cancelled by the user");
                }
                    break;
                    
                case 1: 
                {
                    [delegate deleteMe:self.lesson];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                    break;
            }
            break;
        case 101: // choice of sending the recording on bluetooth
            switch (buttonIndex) {
                case 0:
                    sendRecording = false;
                    break;
                case 1:
                    sendRecording = true;
                    break;
                default:
                    break;
            }
            sendRecordingResponded = true;
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [(TAAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    [context save:&error];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Lesson" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"date = %@", self.lesson.date];
    NSArray *lessons = [context executeFetchRequest:fetchRequest error:&error];
    
    //NSLog(@"Number of Lessons = %d", [lessons count]);
    //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", student.name];
    self.lesson = [lessons objectAtIndex:0];
    
    pieceArray = [[NSArray alloc] initWithArray:[[self.lesson piece] allObjects]];
    //NSLog(@"pieceArray has %d objects.",[pieceArray count]);
    pieceStatusArray = [[NSArray alloc] initWithArray:[[self.lesson pieceStatus] allObjects]];
    NSLog(@"lesson has %d piece statuses in lesson detail.",[lesson.pieceStatus count]);

    [self.tableView reloadData];
}


- (void)getPieces {
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [(TAAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Lesson" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"date = %@", self.lesson.date];
    NSArray *lessons = [context executeFetchRequest:fetchRequest error:&error];
    
    //NSLog(@"Number of Lessons = %d", [lessons count]);
    //fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", student.name];
    self.lesson = [lessons objectAtIndex:0];
    
    pieceArray = [[NSArray alloc] initWithArray:[[self.lesson piece] allObjects]];
    //NSLog(@"pieceArray has %d objects.",[pieceArray count]);
    [self.tableView reloadData];
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    connectionPicker = [[GKPeerPickerController alloc] init];
    connectionPicker.delegate = self;
    //NOTE - GKPeerPickerConnectionTypeNearby is for Bluetooth connection, you can do the same thing over Wi-Fi with different type of connection
    connectionPicker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    connectionPeers = [[NSMutableArray alloc] init];
    
	// Do any additional setup after loading the view.
    // pieceArray = [[NSArray alloc] initWithArray:[[self.lesson piece] allObjects]];
    [self.tableView setDelegate:self];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"flare.png"]];
    [self.instructionLabel setHidden:YES];
    [self.datePicker setHidden:YES];
    [self.sendButton setHidden:YES];
    [self.connectButton setHidden:NO];
    [self getPieces];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterShortStyle];
    [self setTitle:[df stringFromDate:self.lesson.date]];
    [self.activityIndicator stopAnimating];
    sendRecordingResponded = false;
    
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setDatePicker:nil];
    [self setDateButton:nil];
    [self setSendButton:nil];
    [self setConnectButton:nil];
    [self setPrintButton:nil];
    [self setEmailButton:nil];
    [self setActivityIndicator:nil];
    [self setInstructionLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ////NSLog([NSString stringWithFormat:@"%@",[segue identifier]]);
    if ([[segue identifier] isEqualToString:@"AddPieceView"]) {
        [[segue destinationViewController] setDelegate:self];
        [(TAAddPieceViewController *)[segue destinationViewController] setLesson:self.lesson];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        [[segue destinationViewController] setFetchedResultsController:self.fetchedResultsController];
        //[[segue destinationViewController] setDelegate:self];
    }
    if ([[segue identifier] isEqualToString:@"PieceDetailView"]) {
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        [[segue destinationViewController] setFetchedResultsController:self.fetchedResultsController];
        NSIndexPath *ip = [tableView indexPathForSelectedRow];
        Piece *piece = [pieceArray objectAtIndex:[ip row]];
        [(TAPieceDetailViewController *)[segue destinationViewController] setPiece:piece];
        [(TAPieceDetailViewController *)[segue destinationViewController] setLesson:self.lesson];
    }
    if ([[segue identifier] isEqualToString:@"RemovePieceView"]) {
        //[[segue destinationViewController] setDelegate:self];
        [(TAAddPieceViewController *)[segue destinationViewController] setLesson:self.lesson];
        //[[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        //[[segue destinationViewController] setFetchedResultsController:self.fetchedResultsController];
        //[[segue destinationViewController] setDelegate:self];
    }
    
}

#pragma mark - GKPeerPickerControllerDelegate


//Method for sending data that can be used anywhere in your app
- (void)sendData:(NSArray*)data {
    NSData* encodedArray = [NSKeyedArchiver archivedDataWithRootObject:data];
    [self.connectionSession sendDataToAllPeers:encodedArray withDataMode:GKSendDataReliable error:nil];
}

#pragma mark - GKSessionDelegate

/*
 // Function to receive data when sent from peer
 - (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
 NSArray *receivedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
 //Handle the data received in the array
 }
 */

/*
 - (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
 if (state == GKPeerStateConnected) {
 // Add the peer to the Array
 [connectionPeers addObject:peerID];
 
 // Used to acknowledge that we will be sending data
 [session setDataReceiveHandler:self withContext:nil];
 
 //In case you need to do something else when a peer connects, do it here
 }
 else if (state == GKPeerStateDisconnected) {
 [self.connectionPeers removeObject:peerID];
 //Any processing when a peer disconnects
 }
 }
 */

- (void)connectToPeers:(id)sender {
    [self.connectionPicker show];
}

- (void)disconnect:(id)sender {
    [self.connectionSession disconnectFromAllPeers];
    [self.connectionPeers removeAllObjects];
}




- (void)addPiece:(Piece *)aPiece {
    //NSError *error;
    
    pieceArray = [[NSArray alloc] initWithArray:[[self.lesson piece] allObjects]];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    //NSLog(@"Number of sections = 1");
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //NSLog(@"Number of Rows = %d",[pieceArray count]);
    ////NSLog(@"First lesson location is %@",[[self.lessonArray objectAtIndex:0] location]);
    ////NSLog(@"LessonArray: %@",[self.lessonArray description]);
    return[pieceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LessonDetailCell";
    UITableViewCell *cell = [atableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //NSLog(@"Number of Rows in cellForRow... = %d",[pieceArray count]);
    ////NSLog(@"LessonArray: %@",[self.lessonArray description]);
    
    ////NSLog(@"First lesson location is %@",[[self.lessonArray objectAtIndex:0] location]);
    Piece *piece = [pieceArray objectAtIndex:[indexPath row]];
    
    BOOL pieceStatusMade = false;
    for (PieceStatus *ps in pieceStatusArray) {
        if ([ps.pieceTitle isEqualToString:piece.title]) {
            pieceStatusMade = true;
        }
    }
    
    cell.textLabel.text = piece.title;  
    cell.detailTextLabel.text = piece.composer;
    if (!pieceStatusMade) {
        cell.textLabel.textColor = [UIColor redColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    return cell;
}
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void) writeLessonToFile:(Lesson *)alesson {
    NSData *lessonData = [NSKeyedArchiver archivedDataWithRootObject:alesson];
    NSString *filePath = [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"lesson"];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:lessonData attributes:nil];
    
}


- (IBAction)copyPreviousLesson:(id)sender {
    Lesson *previousLesson = nil;
    int index;
    NSMutableSet *mutableLessonSet;
    mutableLessonSet = [student.lesson mutableCopy];
    NSMutableArray *lessons = [[mutableLessonSet allObjects] mutableCopy];
    [lessons sortUsingSelector:@selector(compareLessons:)];
    //NSLog(@"lesson description is %@",lesson.description);
    //NSLog(@"lessons description is %@",lessons.description);
    
    index = [lessons indexOfObject:self.lesson];
    if ([lessons count]>1) {
        previousLesson = [lessons objectAtIndex:index+1];
    }
    [self.lesson setPiece:previousLesson.piece];
    pieceArray = [self.lesson.piece allObjects];
    [self.tableView reloadData];
}


- (IBAction)connectBluetooth:(id)sender {
    [self startPicker];
    
}



#pragma mark -
#pragma mark Peer Picker Related Methods

-(void)startPicker {
    GKPeerPickerController *picker;
    
    picker = [[GKPeerPickerController alloc] init]; // note: picker is released in various picker delegate methods when picker use is done.
    picker.delegate = self;
    [picker show]; // show the Peer Picker
}

#pragma mark GKPeerPickerControllerDelegate Methods

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker { 
    // Peer Picker automatically dismisses on user cancel. No need to programmatically dismiss.
    
    // autorelease the picker. 
    picker.delegate = nil;
    
    // invalidate and release game session if one is around.
    if(self.connectionSession != nil) {
        [self invalidateSession:self.connectionSession];
        self.connectionSession = nil;
    }
    [self.sendButton setHidden:YES];
    [self.connectButton setHidden:NO];
    
} 

/*
 *  Note: No need to implement -peerPickerController:didSelectConnectionType: delegate method since this app does not support multiple connection types.
 *      - see reference documentation for this delegate method and the GKPeerPickerController's connectionTypesMask property.
 */

//
// Provide a custom session that has a custom session ID. This is also an opportunity to provide a session with a custom display name.
//
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type { 
    GKSession *session = [[GKSession alloc] initWithSessionID:@"gkmta" displayName:nil sessionMode:GKSessionModePeer]; 
    return session;
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session { 
    // Remember the current peer.
    self.peerId = peerID;  // copy
    
    // Make sure we have a reference to the game session and it is set up
    self.connectionSession = session; // retain
    self.connectionSession.delegate = self; 
    [self.connectionSession setDataReceiveHandler:self withContext:NULL];
    [self.sendButton setHidden:NO];
    [self.connectButton setHidden:YES];
    //[self.activityIndicator startAnimating];
    // Done with the Peer Picker so dismiss it.
    [picker dismiss];
    picker.delegate = nil;
} 

#pragma mark -
#pragma mark Session Related Methods

//
// invalidate session
//
- (void)invalidateSession:(GKSession *)session {
    if(session != nil) {
        [session disconnectFromAllPeers]; 
        session.available = NO; 
        [session setDataReceiveHandler: nil withContext: NULL]; 
        session.delegate = nil; 
    }
}

#pragma mark Data Send/Receive Methods

/*
 * Getting a data packet. This is the data receive handler method expected by the GKSession. 
 * We set ourselves as the receive data handler in the -peerPickerController:didConnectPeer:toSession: method.
 */
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session 
            context:(void *)context { 
    NSError *error = nil;
    [self.activityIndicator startAnimating];
    NSArray *receivedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //NSArray *keys = [receivedData allKeys];
    //NSLog(@"receivedData is %@",receivedData.description);
    NSDictionary *lessonDictionary = [receivedData objectAtIndex:0];
    NSArray *pieceDictionaryArray = [receivedData objectAtIndex:1];
    NSArray *pieceStatusDictionaryArray = [receivedData objectAtIndex:2];
    Lesson *newLesson = (Lesson *)[NSEntityDescription insertNewObjectForEntityForName:@"Lesson" inManagedObjectContext:self.managedObjectContext];
    //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *newDate = [lessonDictionary objectForKey:@"date"];
    //NSLog(@"Date is %@",newDate.description);
    [newLesson setDate:newDate];
    [newLesson setLocation:[lessonDictionary objectForKey:@"location"]];
    
    for (NSDictionary *d in pieceDictionaryArray) {
        NSString *title = [d objectForKey:@"title"];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        // check to see if this piece exists.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Piece" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"title = %@",title];
        NSArray *fetchedPieces = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ([fetchedPieces count]==0) {
            Piece *newPiece = (Piece *)[NSEntityDescription insertNewObjectForEntityForName:@"Piece" inManagedObjectContext:self.managedObjectContext];
            newPiece.title = [d objectForKey:@"title"];
            newPiece.composer = [d objectForKey:@"composer"];
            newPiece.difficulty = [d objectForKey:@"difficulty"];
            newPiece.genre = [d objectForKey:@"genre"];
            [newLesson addPieceObject:newPiece];
        } else {
            [newLesson addPieceObject:[fetchedPieces lastObject]];
        }
    }
    
    // save piece statuses
    for (NSDictionary *d in pieceStatusDictionaryArray) {
        PieceStatus *newPieceStatus = (PieceStatus *)[NSEntityDescription insertNewObjectForEntityForName:@"PieceStatus" inManagedObjectContext:self.managedObjectContext];
        //NSLog(@"piece status: %@",d.description);
        newPieceStatus.currentTempo = [d objectForKey:@"currentTempo"];
        newPieceStatus.goal = [d objectForKey:@"goal"];
        NSDate *newDate = [d objectForKey:@"lessonDate"];
        newPieceStatus.lessonDate = newDate;
        //newPieceStatus.practiceTime = [d objectForKey:@"practiceTime"];
        newPieceStatus.pieceTitle = [d objectForKey:@"pieceTitle"];
        if ([d valueForKey:@"data"]) {
            // a recording was associated with this pieceStatus
            Recording *newRecording = (Recording *)[NSEntityDescription insertNewObjectForEntityForName:@"Recording" inManagedObjectContext:self.managedObjectContext];
            newRecording.data = [d valueForKey:@"data"];
            newRecording.title = [d valueForKey:@"title"];
            [newPieceStatus setRecording:newRecording];
        }
        [newLesson addPieceStatusObject:newPieceStatus];
    }
    
    [self.student addLessonObject:newLesson];
    
    if (![self.managedObjectContext save:&error]) {
        //NSLog(@"error saving new data. %@",error.description);
    }
    [self.activityIndicator stopAnimating];
    [self.navigationController popViewControllerAnimated:YES];
}







#pragma mark GKSessionDelegate Methods

// we've gotten a state change in the session
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state { 
    if (state == GKPeerStateConnected) {
        // Add the peer to the Array
        [connectionPeers addObject:peerID];
        
        // Used to acknowledge that we will be sending data
        [session setDataReceiveHandler:self withContext:nil];
        [self.sendButton setHidden:NO];
        [self.connectButton setHidden:YES];
        [self.activityIndicator stopAnimating];
        //In case you need to do something else when a peer connects, do it here
    }
    else if (state == GKPeerStateDisconnected) {
        [self.connectionPeers removeObject:peerID];
        //Any processing when a peer disconnects
        [self.sendButton setHidden:YES];
        [self.connectButton setHidden:NO];
        [self.activityIndicator stopAnimating];
        
    }
} 

- (IBAction)sendLesson:(id)sender {
    //NSLog(@"In Send Lesson");
    NSMutableArray *keys = [self.lesson.entity.attributesByName.allKeys mutableCopy];
    
    NSDictionary *lessonDictionary = [self.lesson dictionaryWithValuesForKeys:keys];
    NSMutableArray *pieceDictionaryArray = [[NSMutableArray alloc] init];
    NSMutableArray *pieceStatusDictionaryArray = [[NSMutableArray alloc] init];
    
    for (Piece *p in self.lesson.piece) {
        [pieceDictionaryArray addObject:[p dictionaryWithValuesForKeys:p.entity.attributesByName.allKeys]];
    }
    for (PieceStatus *ps in self.lesson.pieceStatus) {
        NSString *message;
        NSMutableDictionary *pdict = [[ps dictionaryWithValuesForKeys:ps.entity.attributesByName.allKeys] mutableCopy];
        if (ps.recording) {
            Recording *r = ps.recording;
            keys = [r.entity.attributesByName.allKeys mutableCopy];
            message = [[NSString alloc] initWithFormat:@"Include recording for %@?",ps.pieceTitle];
            BOOL includeRecording = [ModalAlertView ask:message];
            if (includeRecording) {
                [pdict addEntriesFromDictionary:[r dictionaryWithValuesForKeys:keys]];
            }
        }
        [pieceStatusDictionaryArray addObject:pdict];
    }
    //[pieceDictionaryArray addObject:lessonDictionary];
    NSMutableArray *dataToSend = [[NSMutableArray alloc] init];
    [dataToSend addObject:lessonDictionary];
    [dataToSend addObject:pieceDictionaryArray];
    [dataToSend addObject:pieceStatusDictionaryArray];
    NSData* encodedArray = [NSKeyedArchiver archivedDataWithRootObject:dataToSend];
    
    [self.connectionSession sendDataToAllPeers:encodedArray withDataMode:GKSendDataReliable error:nil];
    [self.activityIndicator startAnimating];
}


- (NSMutableString *)lessonBodyForPrint {
    NSMutableString *body = [[NSMutableString alloc] initWithString:@"<html><body>"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    
    [body appendFormat:@"<h1>%@</h1>",[df stringFromDate:self.lesson.date]];
    for (PieceStatus *p in self.lesson.pieceStatus) {
        [body appendFormat:@"<h2>%@</h2>",p.pieceTitle];
        [body appendFormat:@"<p>%@</p><p>Current Tempo: %@</p>",p.goal,p.currentTempo];
    }
    [body appendString:@"</body></html>"];
    return body;
}


- (IBAction)printLesson:(id)sender {
    
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    pic.delegate = self;
    
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = @"Lesson";
    pic.printInfo = printInfo;
    
    UIMarkupTextPrintFormatter *htmlFormatter = [[UIMarkupTextPrintFormatter alloc]
                                                 initWithMarkupText:[self lessonBodyForPrint]];
    
    htmlFormatter.startPage = 0;
    htmlFormatter.contentInsets = UIEdgeInsetsMake(72.0, 72.0, 72.0, 72.0); // 1 inch margins
    htmlFormatter.maximumContentWidth = 6 * 72.0;
    pic.printFormatter = htmlFormatter;
    
    pic.showsPageRange = YES;
    
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if (!completed && error) {
            //NSLog(@"Printing could not complete because of error: %@", error);
        }
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [pic presentFromBarButtonItem:sender animated:YES completionHandler:completionHandler];
    } else {
        [pic presentAnimated:YES completionHandler:completionHandler];
    }
}







#pragma mark -
#pragma mark Mail 



- (IBAction)emailLesson:(id)sender {
    [self actionEmailComposer];
}

- (IBAction)actionEmailComposer {
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Lesson"];
        if ([self.student email] == nil) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Email Error." message:@"Student has no email." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [av show];
            return;
        }
        [mailViewController setToRecipients:[NSArray arrayWithObject:[self.student email]]];
        [mailViewController setMessageBody:[self lessonBodyForPrint] isHTML:YES];
        for (PieceStatus *ps in self.lesson.pieceStatus) {
            if ((ps.recording != nil) && (ps.recording.data != nil)) {
                NSString *message;
                message = [[NSString alloc] initWithFormat:@"Include Recording for %@?",ps.pieceTitle];
                BOOL includeRecording = [ModalAlertView ask:message];
                NSString *fileName = [ps.pieceTitle stringByAppendingString:@".caf"];
                if (includeRecording) {
                    NSString *path = [[self applicationDocumentsDirectory] absoluteString];
                    path = [path stringByAppendingPathComponent:fileName];
                    [[NSFileManager defaultManager] createFileAtPath:path contents:ps.recording.data attributes:nil];
                    [mailViewController addAttachmentData:ps.recording.data mimeType:@"audio/x-caf" fileName:fileName];
                }
            }
        }
        [self presentModalViewController:mailViewController animated:YES];       
    } else {
        // NSLog(@"Device is unable to send email.");
    }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller 
         didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    for (PieceStatus *ps in self.lesson.pieceStatus) {
        NSString *path = [[self applicationDocumentsDirectory] absoluteString];
        NSString *fileName = [ps.pieceTitle stringByAppendingString:@".caf"];
        path = [path stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    }
    [self dismissModalViewControllerAnimated:YES];
}

@end
