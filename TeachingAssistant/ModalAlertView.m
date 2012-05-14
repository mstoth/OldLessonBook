//
//  ModalAlertView.m
//  Lesson Book
//
//  Created by Michael Toth on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModalAlertView.h"


@interface ModalAlertDelegate : NSObject <UIAlertViewDelegate>
{
CFRunLoopRef currentLoop;
NSUInteger index;
}

@property (readonly) NSUInteger index;
@end


@implementation ModalAlertDelegate
@synthesize index;
-(id) initWithRunLoop: (CFRunLoopRef)runLoop
{
    if (self = [super init]) currentLoop = runLoop;
    return self;
}

-(void) alertView: (UIAlertView*)aView clickedButtonAtIndex: (NSInteger)anIndex
{
    index = anIndex;
    CFRunLoopStop(currentLoop);
}
@end


@implementation ModalAlertView

+(NSUInteger) queryWith: (NSString *)question button1: (NSString *)button1 button2: (NSString *)button2
{
    CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
    ModalAlertDelegate *madelegate = [[ModalAlertDelegate alloc] initWithRunLoop:currentLoop];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:question message:nil delegate:madelegate cancelButtonTitle:button1 otherButtonTitles:button2, nil];
    [alertView show];
    CFRunLoopRun();
    NSUInteger answer = madelegate.index;
    return answer;
}
+ (BOOL) ask: (NSString *) question
{
    return ([ModalAlertView queryWith:question button1: @"Yes" button2: @"No"] == 0);
}
+ (BOOL) confirm: (NSString *) statement
{
    return [ModalAlertView queryWith:statement button1: @"Cancel" button2: @"OK"];
}
@end