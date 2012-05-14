//
//  ModalAlertView.h
//  Lesson Book
//
//  Created by Michael Toth on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModalAlertView : NSObject <UIAlertViewDelegate>
+(NSUInteger) queryWith: (NSString *)question button1: (NSString *)button1 button2: (NSString *)button2;
+ (BOOL) ask: (NSString *) question;
+ (BOOL) confirm: (NSString *) statement;


@end
