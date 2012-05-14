//
//  TADatabaseViewController.m
//  Lesson Book
//
//  Created by Michael Toth on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define kFILENAME @"LessonBook.sqlite"
#define UBIQUITY_CONTAINER_URL @"9E7Y9QZC52.com.virtualpianist.Lesson-Book"

#import "TADatabaseViewController.h"
#import "TAAppDelegate.h"
#import "ModalAlertView.h"
#import "TATextDocument.h"

@interface TADatabaseViewController ()

@end

@implementation TADatabaseViewController

@synthesize query = _query;
@synthesize doc = _doc;
@synthesize ubiquityURL = _ubiquityURL;
@synthesize documentURL = _documentURL;
@synthesize activityIndicatorView = _activityIndicatorView;


- (void)viewDidLoad
{
    [super viewDidLoad];
    _ubiquityURL = [[[NSFileManager defaultManager] 
                     URLForUbiquityContainerIdentifier:UBIQUITY_CONTAINER_URL]     
                    URLByAppendingPathComponent:@"Documents"];

    NSArray *dirPaths = 
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                        NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *dataFile = [docsDir 
                          stringByAppendingPathComponent: @"LessonBook.sqlite"];
    _documentURL = [NSURL fileURLWithPath:dataFile];

	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setActivityIndicatorView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)backupDatabase:(id)sender {
    BOOL backup = [ModalAlertView ask:@"Back up database?"];
    if (backup) {
        [self.activityIndicatorView startAnimating];
        [self saveDB];
        // do nothing yet
    }
}

- (IBAction)restoreDatabase:(id)sender {
    BOOL restore = [ModalAlertView ask:@"Restore database?"];
    if (restore) {
        [self loadDocument];
    }
}

- (void)saveDocument {
    BOOL saveDB = [ModalAlertView ask:@"Save Database?"];
    if (saveDB) {
        [self saveDB];
    }
}

- (void)saveDB {
    NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
    _query = query;
    [query setSearchScopes:[NSArray arrayWithObject:
                            NSMetadataQueryUbiquitousDocumentsScope]];
    NSPredicate *pred = [NSPredicate predicateWithFormat: 
                         @"%K == %@", NSMetadataItemFSNameKey, @"LessonBook.sqlite"];
    [query setPredicate:pred];
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
     selector:@selector(queryDidFinishGatheringForSave:) 
     name:NSMetadataQueryDidFinishGatheringNotification 
     object:query];
    
    [query startQuery];

}

-(void) saveData:(NSMetadataQuery *)query {
    NSError *error;
    if ([query resultCount] == 1) {
        NSURL *ubiq = [[NSFileManager defaultManager] 
                       URLForUbiquityContainerIdentifier:nil];
        NSURL *ubiquitousPackage = [ubiq URLByAppendingPathComponent:@"Documents/LessonBook.sqlite"];
        
        TATextDocument *dbdoc = [[TATextDocument alloc] initWithFileURL:ubiquitousPackage];
        _doc = dbdoc;

        NSMetadataItem *item = [query resultAtIndex:0];
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        NSLog(@"url for save is %@",url.description);
        
        NSData *dbData = [NSData dataWithContentsOfURL:_documentURL];
        /*
        [_doc openWithCompletionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"File open.");
            }
        }];
        */
        [_doc loadFromContents:dbData ofType:nil error:&error];

        /*
        [_doc closeWithCompletionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"File Closed.");
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"File Closed" message:@"file closed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
            } else {
                NSLog(@"Failed File Close");
            }
        }];
        */
        
        [_doc saveToURL:[_doc fileURL] forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            if (success) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Database Saved" message:@"Database saved to iCloud" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [av show];
                NSLog(@"Save OK");
            } else {
                NSLog(@"Save Not OK");
            }
        }];
        
        
 /*
        [_doc saveToURL:[_doc fileURL] forSaveOperation:UIDocumentSaveForOverwriting
                                      completionHandler:^(BOOL success) { 
                                          if (success) {
                                              UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Database Saved" message:@"Database saved to iCloud" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                              [av show];
                                              NSLog(@"db saved to iCloud");                
                                          } else {
                                              UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Database not saved" message:@"Failure to save database" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                              [av show];
                                          }
        }];
  */
        //NSLog(@"%d",[_doc documentState]);
        /*
        [_doc openWithCompletionHandler:^(BOOL success) { 
            if (success) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Database Saved" message:@"Database saved to iCloud" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
                NSLog(@"db saved to iCloud");                
            } else {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Database not saved" message:@"Failure to save database" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [av show];
            }
        }];   
         */

	} else {
        
        NSURL *ubiq = [[NSFileManager defaultManager] 
                       URLForUbiquityContainerIdentifier:nil];
        NSURL *ubiquitousPackage = [ubiq URLByAppendingPathComponent:@"Documents/LessonBook.sqlite"];
        
        TATextDocument *dbdoc = [[TATextDocument alloc] initWithFileURL:ubiquitousPackage];
        _doc = dbdoc;
        
        //NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"LessonBook.sqlite"];
        NSData *dbaseData = [NSData dataWithContentsOfURL:_documentURL];
        [_doc loadFromContents:dbaseData ofType:@"sqlite" error:&error];
        [_doc saveToURL:[_doc fileURL] forSaveOperation:UIDocumentSaveForCreating
      completionHandler:^(BOOL success) {            
          if (success) {
              [_doc openWithCompletionHandler:^(BOOL success) {                
                  NSLog(@"new document created on iCloud");
                  UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Database Saved" message:@"Database saved on iCloud" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                  [av show];
                  
              }];                
          }
      }];
    }
    [self.activityIndicatorView stopAnimating];
}

- (void)loadDocument {
    NSArray *dirPaths = 
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                        NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *dataFile = [docsDir 
                          stringByAppendingPathComponent: @"LessonBook.sqlite"];
    self.documentURL = [NSURL fileURLWithPath:dataFile];
    _ubiquityURL = [[[NSFileManager defaultManager] 
                    URLForUbiquityContainerIdentifier:UBIQUITY_CONTAINER_URL]     
                   URLByAppendingPathComponent:@"Documents"];
    NSMetadataQuery *query = [[NSMetadataQuery alloc] init];

    _query = query;
    [query setSearchScopes:[NSArray arrayWithObject:
                            NSMetadataQueryUbiquitousDocumentsScope]];
    NSPredicate *pred = [NSPredicate predicateWithFormat: 
                         @"%K == %@", NSMetadataItemFSNameKey, @"LessonBook.sqlite"];
    [query setPredicate:pred];
    
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
     selector:@selector(queryDidFinishGathering:) 
     name:NSMetadataQueryDidFinishGatheringNotification 
     object:query];
    
    [query startQuery];
    
}

- (void)loadData:(NSMetadataQuery *)query {
    NSError *error = nil;
    NSData *dbaseData;
    if ([query resultCount] == 1) {
        
        NSMetadataItem *item = [query resultAtIndex:0];
        NSURL *url = [item valueForAttribute:NSMetadataItemURLKey];
        dbaseData = [[NSData alloc] initWithContentsOfURL:url]; 
        if ([dbaseData length] > 0) {   
            if ([[NSFileManager defaultManager] createFileAtPath:_documentURL.path contents:dbaseData attributes:nil]) {
                NSLog(@"File Restored");
            }
        } else {
            [[NSFileManager defaultManager] removeItemAtPath:[url path] error:&error];  
        }
        
        
        /*
         dbase = [self applicationDocumentsDirectory];
        dbase = [NSURL URLWithString:[[dbase path] stringByAppendingPathComponent:@"LessonBook.sqlite"]];
        dbaseData = [NSData dataWithContentsOfFile:[dbase path]];
        [_doc loadFromContents:dbaseData ofType:nil error:&error];
        [_doc saveToURL:[_doc fileURL] forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {                
            NSLog(@"document opened and updated from iCloud");                
        }];
         */

	} else {
        
        NSURL *ubiq = [[NSFileManager defaultManager] 
                       URLForUbiquityContainerIdentifier:nil];
        NSURL *ubiquitousPackage = [ubiq URLByAppendingPathComponent:@"Documents/LessonBook.sqlite"];
        _doc  = [[TATextDocument alloc] initWithFileURL:ubiquitousPackage];
        NSData *dbaseData = [NSData dataWithContentsOfURL:_documentURL];
        [_doc loadFromContents:dbaseData ofType:@"sqlite" error:&error];
        [_doc saveToURL:[_doc fileURL] forSaveOperation:UIDocumentSaveForCreating 
                                      completionHandler:^(BOOL success) {            
         if (success) {
             [_doc openWithCompletionHandler:^(BOOL success) {                
                 NSLog(@"new document opened from iCloud");                
             }];                
         }
     }];
    }
}

- (void)queryDidFinishGatheringForSave:(NSNotification *)notification {
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    [query stopQuery];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:query];
    _query = nil;
    [self saveData:query];
}

- (void)queryDidFinishGathering:(NSNotification *)notification {
    
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    [query stopQuery];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:NSMetadataQueryDidFinishGatheringNotification 
                                                  object:query];
    
    _query = nil;
    
    [self loadData:query];
    
}


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *) dbURL {
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Documents/LessonBook.sqlite"];
}



@end

