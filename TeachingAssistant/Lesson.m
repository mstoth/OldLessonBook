//
//  Lesson.m
//  LessonBook
//
//  Created by Michael Toth on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Lesson.h"
#import "Piece.h"
#import "PieceStatus.h"
#import "Recording.h"
#import "Student.h"


@implementation Lesson

@dynamic date;
@dynamic location;
@dynamic piece;
@dynamic pieceStatus;
@dynamic student;
@dynamic recording;

- (void)encodeWithCoder:(NSCoder *)coder {
    //[super encodeWithCoder:coder];
    [coder encodeObject:self.date forKey:@"date"];
    [coder encodeObject:self.location forKey:@"location"];
    [coder encodeObject:self.piece forKey:@"piece"];
    [coder encodeObject:self.pieceStatus forKey:@"pieceStatus"];
    [coder encodeObject:self.recording forKey:@"recording"];
}

- (id)initWithCoder:(NSCoder*)coder {
    self.date = [coder decodeObjectForKey:@"date"];
    self.location = [coder decodeObjectForKey:@"location"];
    self.piece = [coder decodeObjectForKey:@"piece"];
    self.pieceStatus = [coder decodeObjectForKey:@"pieceStatus"];
    self.recording = [coder decodeObjectForKey:@"recording"];
    return self;
}

- (NSComparisonResult)compareLessons:(Lesson *)otherObject {
    return [otherObject.date compare:self.date];
}

@end
