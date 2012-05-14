//
//  Recording.h
//  LessonBook
//
//  Created by Michael Toth on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Lesson, PieceStatus;

@interface Recording : NSManagedObject <NSCoding>

@property (nonatomic, retain) id data;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Lesson *lesson;
@property (nonatomic, retain) PieceStatus *pieceStatus;

@end
