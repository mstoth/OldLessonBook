//
//  Piece.m
//  LessonBook
//
//  Created by Michael Toth on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Piece.h"
#import "Lesson.h"


@implementation Piece

@dynamic composer;
@dynamic difficulty;
@dynamic genre;
@dynamic title;
@dynamic lesson;

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.composer forKey:@"composer"];
    [coder encodeObject:self.difficulty forKey:@"difficulty"];
    [coder encodeObject:self.genre forKey:@"genre"];
    [coder encodeObject:self.title forKey:@"title"];
}

- (id)initWithCoder:(NSCoder*)coder {
    self.composer = [coder decodeObjectForKey:@"composer"];
    self.difficulty = [coder decodeObjectForKey:@"difficulty"];
    self.genre = [coder decodeObjectForKey:@"genre"];
    self.title = [coder decodeObjectForKey:@"title"];
    return self;
}

- (NSComparisonResult)comparePieces:(Piece *)otherObject {
    return [self.title compare:otherObject.title];
}

@end
