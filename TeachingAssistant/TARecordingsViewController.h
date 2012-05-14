//
//  TARecordingsViewController.h
//  LessonBook
//
//  Created by Michael Toth on 4/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h> 

#import "Student.h"

@interface TARecordingsViewController : UITableViewController <AVAudioPlayerDelegate> {
    AVAudioPlayer *musicPlayer;
}
@property (nonatomic, retain) Student *student;
@property (nonatomic, retain) NSMutableArray *recordingsArray;
@end
