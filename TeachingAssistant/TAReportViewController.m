//
//  TAReportViewController.m
//  LessonBook
//
//  Created by Michael Toth on 4/4/12.
//  Copyright (c) 2012 Michael Toth. All rights reserved.
//

#import "TAReportViewController.h"
#import "TAAppDelegate.h"
#import "Student.h"
#import "Lesson.h"
#import "Piece.h"
#import "Note.h"
#import "PieceStatus.h"

@interface TAReportViewController () {
    NSString *studentName;
    BOOL allStudentsSelected;
}

@end

@implementation TAReportViewController
@synthesize allStudentsButton;
@synthesize reportWebView;
@synthesize student;
@synthesize lesson;
@synthesize titleLabel;
@synthesize managedObjectContext;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        [titleLabel setHidden:YES];
        reportWebView.frame = CGRectMake(0,0,480,320);
    } else {
        [titleLabel setHidden:NO];
        reportWebView.frame = CGRectMake(0,60,320,420);
    }
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    allStudentsSelected = false;
    NSString *htmlString;
    htmlString = [self makeReport];
    [self.titleLabel setText:student.name];
    // Custom initialization
    [reportWebView loadHTMLString:htmlString baseURL:nil];
	// Do any additional setup after loading the view.
    self.title = student.name;
}

- (void)viewDidUnload
{
    [self setReportWebView:nil];
    [self setTitleLabel:nil];
    [self setAllStudentsButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (NSMutableString *)makeReport {
    NSError *error;
    Student *theStudent;
    NSMutableArray *pieceArray = [[NSMutableArray alloc] init];
    NSMutableArray *pieceNameArray = [[NSMutableArray alloc] init];
    NSMutableArray *pieceTimesArray = [[NSMutableArray alloc] init];
    NSMutableArray *pieceStatusArray = [[NSMutableArray alloc] init];
    NSMutableArray *recordingsArray = [[NSMutableArray alloc] init];
    NSMutableArray *practiceTimesArray = [[NSMutableArray alloc] init];
    int practiceIndex = 0;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [(TAAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Student" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", student.name];
    NSArray *students = [context executeFetchRequest:fetchRequest error:&error];
    
    theStudent = [students objectAtIndex:0];
    for (Lesson *lsn in [theStudent lesson]) {
        [pieceArray addObjectsFromArray:[[lsn piece] allObjects]];
        [pieceStatusArray addObjectsFromArray:[[lsn pieceStatus] allObjects]];
        for (PieceStatus *ps in [lsn pieceStatus]) {
            if ([ps recording]) {
                [recordingsArray addObject:[ps recording]];
            }
        }
    }
    
    // get unique names from pieceArray
    for (Lesson *lsn in [theStudent lesson]) {
        for (Piece *p in [lsn piece]) {
            if (![pieceNameArray containsObject:[p title]]) {
                //NSLog(@"Adding %@",[p title]);
                [pieceNameArray addObject:[p title]];
            }
        }
    }
    
    
    
    for (NSString *ttl in pieceNameArray) {
        entity = [NSEntityDescription entityForName:@"PieceStatus" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"pieceTitle = %@", ttl];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lessonDate" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        NSMutableArray *pieceStatuses = [[context executeFetchRequest:fetchRequest error:&error] mutableCopy];
        NSMutableArray *toRemove = [[NSMutableArray alloc] init];
        //NSLog(@"%d piece statuses retrieved.",[pieceStatuses count]);
        for (PieceStatus *p in pieceStatuses) {
            if (p.lesson.student != self.student) {
                [toRemove addObject:p];
            }
        }
        if ([toRemove count]>0) {
            for (PieceStatus *p in toRemove) {
                [pieceStatuses removeObject:p];
            }
        }
        if ([pieceStatuses count]>0) {
            float accumulatedTime;
            accumulatedTime = 0;
            NSDate *minDate = [[pieceStatuses lastObject] lessonDate];
            NSDate *maxDate = [[pieceStatuses objectAtIndex:0] lessonDate];
            [pieceTimesArray addObject:[[NSDictionary alloc] 
                                        initWithObjectsAndKeys:ttl, @"title", minDate, @"minDate", maxDate, @"maxDate", nil]];
            for (PieceStatus *ps in pieceStatuses) {
                accumulatedTime += [ps.practiceTime floatValue];
            }
            [practiceTimesArray addObject:[NSNumber numberWithFloat:accumulatedTime]];
        }
    }
    ////NSLog(@"piece times array: %@",pieceTimesArray.description);

    
    int nTimes = 0;
    float avgTime = 0;
    //NSLog(@"lessons: %@",lessons.description);
    NSMutableString *report = [[NSMutableString alloc] initWithString:@"<html><body>"];
    [report appendString:@"<ul><li>"];
    [report appendFormat:@"%d lessons, %d pieces, %d recordings</li></ul>",
                        [theStudent.lesson count],[pieceNameArray count],[recordingsArray count]];
    [report appendFormat:@"<table border=1 align=center><tr><th>Piece</th><th>Time (weeks)</th><th>Practice Time</ht></tr>"];
    for (NSDictionary *d in pieceTimesArray) {
        NSDate *dmax = [d objectForKey:@"maxDate"];
        NSDate *dmin = [d objectForKey:@"minDate"];
        NSTimeInterval ti = [dmax timeIntervalSinceDate:dmin]/60/60/24/7;
        avgTime = avgTime + ti;
        nTimes = nTimes + 1;
        [report appendFormat:@"<tr><td>%@</td><td>%0.2f</td><td>%0.2f</td></tr>",[d objectForKey:@"title"],ti,[[practiceTimesArray objectAtIndex:practiceIndex++] floatValue]];
    }
    [report appendString:@"</table>"];
    [report appendString:@"</body></html>"];
    avgTime = avgTime/nTimes;
    [report appendFormat:@"<br/>Average Time per piece = %0.2f weeks",avgTime];
    return report;
}



- (IBAction)reportAllStudents:(id)sender {
    if (!allStudentsSelected) {
        allStudentsSelected = true;
        [self.allStudentsButton setTitle:self.student.name forState:UIControlStateNormal];
        [self.titleLabel setText:@"All Students"];
        [self displayAllStudents:self];
    } else {
        allStudentsSelected = false;
        [self.allStudentsButton setTitle:@"All Students" forState:UIControlStateNormal];
        [self.titleLabel setText:self.student.name];
        [reportWebView loadHTMLString:[self makeReport] baseURL:nil];
    }
}

- (void)displayAllStudents:(id)sender {
    NSString *report = [self allStudentReportBody];
    [reportWebView loadHTMLString:report baseURL:nil];
}

- (NSString *)allStudentReportBody {
    NSMutableSet *pieceSet = [[NSMutableSet alloc] init];
    
    NSMutableString *report = [[NSMutableString alloc] init];
    [report appendString:@"<html><body>"];
    NSError *error = nil;
    NSArray *allStudents;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Student"];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    allStudents = [context executeFetchRequest:fetchRequest error:&error];
    [report appendString:@"<table>"];
    [report appendString:@"<tr><th>Student</th><th>Lessons</th><th>Pieces</th><th>Notes</th></tr>"];
    for (Student *s in allStudents) {
        [report appendString:@"<tr><td>"];
        [report appendString:s.name];
        [report appendString:@"</td><td>"];
        [report appendString:[NSString stringWithFormat:@"%d",[s.lesson count]]];
        [report appendString:@"</td><td>"];
        [pieceSet removeAllObjects];
        for (Lesson* l in s.lesson) {
            [pieceSet addObjectsFromArray:[l.piece allObjects]];
        }
        [report appendString:[NSString stringWithFormat:@"%d",[pieceSet count]]];
        [report appendString:@"</td><td>"];
        [report appendString:[NSString stringWithFormat:@"%@",[s.note text]]];
        [report appendString:@"</td></tr>"];
    }
    [report appendString:@"</table>"];
    [report appendString:@"</body></html>"];
    return report;
}


- (IBAction)printReport:(id)sender {
    UIMarkupTextPrintFormatter  *htmlFormatter;
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    pic.delegate = self;
    
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = @"Lesson";
    pic.printInfo = printInfo;
    
    if (allStudentsSelected) {
        htmlFormatter = [[UIMarkupTextPrintFormatter alloc] initWithMarkupText:[self allStudentReportBody]];
    } else {
        htmlFormatter = [[UIMarkupTextPrintFormatter alloc]
                                                     initWithMarkupText:[self makeReport]];
    }
    
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



- (IBAction)emailReport:(id)sender {
    [self actionEmailComposer];
}

- (IBAction)actionEmailComposer {
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:@"Student Report"];
        //[mailViewController setToRecipients:[NSArray arrayWithObject:[self.student email]]];
        if (allStudentsSelected) {
            [mailViewController setMessageBody:[self allStudentReportBody] isHTML:YES];
        } else {
            [mailViewController setMessageBody:[self makeReport] isHTML:YES];
        }
        [self presentModalViewController:mailViewController animated:YES];       
    } else {
        // NSLog(@"Device is unable to send email.");
    }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller 
         didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
}

@end
