//
//  Lesson.h
//  LessonBook
//
//  Created by Michael Toth on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Piece, PieceStatus, Recording, Student;

@interface Lesson : NSManagedObject <NSCoding>

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSSet *piece;
@property (nonatomic, retain) NSSet *pieceStatus;
@property (nonatomic, retain) Student *student;
@property (nonatomic, retain) Recording *recording;
@end

@interface Lesson (CoreDataGeneratedAccessors)

- (void)addPieceObject:(Piece *)value;
- (void)removePieceObject:(Piece *)value;
- (void)addPiece:(NSSet *)values;
- (void)removePiece:(NSSet *)values;

- (void)addPieceStatusObject:(PieceStatus *)value;
- (void)removePieceStatusObject:(PieceStatus *)value;
- (void)addPieceStatus:(NSSet *)values;
- (void)removePieceStatus:(NSSet *)values;

@end
