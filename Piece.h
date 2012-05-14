//
//  Piece.h
//  LessonBook
//
//  Created by Michael Toth on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Lesson;

@interface Piece : NSManagedObject <NSCoding>

@property (nonatomic, retain) NSString * composer;
@property (nonatomic, retain) NSNumber * difficulty;
@property (nonatomic, retain) NSString * genre;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *lesson;
@end

@interface Piece (CoreDataGeneratedAccessors)

- (void)addLessonObject:(Lesson *)value;
- (void)removeLessonObject:(Lesson *)value;
- (void)addLesson:(NSSet *)values;
- (void)removeLesson:(NSSet *)values;

@end
