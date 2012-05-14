//
//  TATextDocument.h
//  Lesson Book
//
//  Created by Michael Toth on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TADocumentDelegate;

@interface TATextDocument : UIDocument
@property (copy, nonatomic) NSData* documentData;
@property (weak, nonatomic) id<TADocumentDelegate> delegate;
@end

@protocol TADocumentDelegate <NSObject>
@optional
- (void)documentContentsDidChange:(TATextDocument*)document;
@end
