//
//  TATextDocument.m
//  Lesson Book
//
//  Created by Michael Toth on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TATextDocument.h"

@implementation TATextDocument

@synthesize documentData = _documentData;
@synthesize delegate = _delegate;

- (void)setDocumentData:(NSData *)newData {
    NSData *oldData = _documentData;
    _documentData = [newData copy];
    
    // Register the undo operation.
    [self.undoManager setActionName:@"Data Change"];
    [self.undoManager registerUndoWithTarget:self
                                    selector:@selector(setDocumentData:)
                                      object:oldData];    
}

- (id)contentsForType:(NSString *)typeName error:(NSError **)outError {
    
    if (!self.documentData) {
        NSURL *dbURL = [self applicationDocumentsDirectory];
        NSString *dbString = [[dbURL path] stringByAppendingPathComponent:@"Documents"];
        dbString = [dbString stringByAppendingPathComponent:@"LessonBook.sqlite"];
        NSData *dbData = [NSData dataWithContentsOfFile:dbString];
        return dbData;
    }
    return self.documentData;
    
}


- (BOOL)loadFromContents:(id)contents
                  ofType:(NSString *)typeName
                   error:(NSError **)outError {
    if ([contents length] > 0)
        self.documentData = [[NSData alloc] initWithData:contents];
    else
        self.documentData = [[NSData alloc] initWithContentsOfURL:[self dbURL]];
    // Tell the delegate that the document contents changed.
    
    if (self.delegate && [self.delegate respondsToSelector:
                          @selector(documentContentsDidChange:)])   
        [self.delegate documentContentsDidChange:self];

    return YES;
}


#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *) dbURL {
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Documents/LessonBook.sqlite"];
}

@end
