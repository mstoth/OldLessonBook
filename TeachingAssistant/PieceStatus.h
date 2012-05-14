//
//  PieceStatus.h
//  Lesson Book
//
//  Created by Michael Toth on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Lesson, Recording;

@interface PieceStatus : NSManagedObject <NSCoding>

@property (nonatomic, retain) NSString * currentTempo;
@property (nonatomic, retain) NSString * goal;
@property (nonatomic, retain) NSDate * lessonDate;
@property (nonatomic, retain) NSString * pieceTitle;
@property (nonatomic, retain) NSNumber * practiceTime;
@property (nonatomic, retain) Lesson *lesson;
@property (nonatomic, retain) Recording *recording;

@end
