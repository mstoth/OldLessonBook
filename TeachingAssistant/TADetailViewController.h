//
//  TADetailViewController.h
//  LessonBook
//
//  Created by Michael Toth on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAEditStudentViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Student.h"

@protocol TADetailViewDelegate;


@interface TADetailViewController : UIViewController <TAEditStudentDelegate, NSFetchedResultsControllerDelegate,MFMailComposeViewControllerDelegate> {
    Student *student;
}

- (IBAction)actionEmailComposer;

@property (weak, nonatomic) Student *student;
@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) id<TADetailViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *pictureView;

-(IBAction)phoneCall:(id)sender;
-(IBAction) sendEmailToStudent;

@end

@protocol TADetailViewDelegate <NSObject>

@optional
-(void)updateDetailItem:(id)detailItem;

@end
