//
//  PieceStatus.m
//  Lesson Book
//
//  Created by Michael Toth on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PieceStatus.h"
#import "Lesson.h"
#import "Recording.h"


@implementation PieceStatus

@dynamic currentTempo;
@dynamic goal;
@dynamic lessonDate;
@dynamic pieceTitle;
@dynamic practiceTime;
@dynamic lesson;
@dynamic recording;

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:self.lessonDate forKey:@"lessonDate"];
    [coder encodeObject:self.currentTempo forKey:@"currentTempo"];
    [coder encodeObject:self.pieceTitle forKey:@"pieceTitle"];
    [coder encodeObject:self.goal forKey:@"goal"];
    [coder encodeObject:self.practiceTime forKey:@"practiceTime"];
    [coder encodeObject:self.recording forKey:@"recording"];
}

- (id)initWithCoder:(NSCoder*)coder {
    self.currentTempo = [coder decodeObjectForKey:@"currentTempo"];
    self.lessonDate = [coder decodeObjectForKey:@"lessonDate"];
    self.pieceTitle = [coder decodeObjectForKey:@"pieceTitle"];
    self.practiceTime = [coder decodeObjectForKey:@"practiceTime"];
    self.goal = [coder decodeObjectForKey:@"goal"];
    self.recording = [coder decodeObjectForKey:@"recording"];
    return self;
}

@end
