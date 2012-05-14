//
//  TADatabaseViewController.h
//  Lesson Book
//
//  Created by Michael Toth on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TATextDocument.h"
@interface TADatabaseViewController : UIViewController
- (IBAction)backupDatabase:(id)sender;
- (IBAction)restoreDatabase:(id)sender;
@property (strong) NSMetadataQuery *query;
@property (strong) TATextDocument *doc;
@property (strong) NSURL *ubiquityURL;
@property (strong) NSURL *documentURL;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
- (void)loadDocument;
@end
