//
//  Recording.m
//  LessonBook
//
//  Created by Michael Toth on 4/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Recording.h"
#import "Lesson.h"
#import "PieceStatus.h"


@implementation Recording

@dynamic data;
@dynamic title;
@dynamic lesson;
@dynamic pieceStatus;

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.data forKey:@"data"];
}

- (id)initWithCoder:(NSCoder*)coder {
    self.title = [coder decodeObjectForKey:@"title"];
    self.data = [coder decodeObjectForKey:@"data"];
    return self;
}

@end
