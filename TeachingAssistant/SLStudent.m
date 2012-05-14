//
//  SLStudent.m
//  StudentLessons
//
//  Created by Michael Toth on 3/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SLStudent.h"

@implementation SLStudent
@synthesize nameOfStudent = _nameOfStudent;
@synthesize phoneNumberOfStudent = _phoneNumberOfStudent;
@synthesize emailOfStudent = _emailOfStudent;

-(id)init {
    if (self=[super init]) {
    }
    return self;
}
@end
