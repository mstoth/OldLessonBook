//
//  Student.m
//  LessonBook
//
//  Created by Michael Toth on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Student.h"
#import "Lesson.h"
#import "Note.h"
#import "Photo.h"
#import "UIImageToDataTransformer.h"

@implementation Student

@dynamic email;
@dynamic name;
@dynamic phone;
@dynamic thumbnail;
@dynamic category;
@dynamic lesson;
@dynamic photo;
@dynamic note;

+ (void)initialize {
	if (self == [Student class]) {
		UIImageToDataTransformer *transformer = [[UIImageToDataTransformer alloc] init];
		[NSValueTransformer setValueTransformer:transformer forName:@"UIImageToDataTransformer"];
	}
}

@end
