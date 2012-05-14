//
//  TARepertoireViewController.h
//  LessonBook
//
//  Created by Michael Toth on 4/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Student.h"

@interface TARepertoireViewController : UITableViewController
@property (nonatomic, retain) Student *student;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *pieceNames,*composerNames;
@end
