//
//  Student.h
//  LessonBook
//
//  Created by Michael Toth on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Lesson, Note, Photo;

@interface Student : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) id thumbnail;
@property (nonatomic, retain) NSSet *lesson;
@property (nonatomic, retain) Photo *photo;
@property (nonatomic, retain) Note *note;
@end

@interface Student (CoreDataGeneratedAccessors)

- (void)addLessonObject:(Lesson *)value;
- (void)removeLessonObject:(Lesson *)value;
- (void)addLesson:(NSSet *)values;
- (void)removeLesson:(NSSet *)values;

@end
