//
//  DragDropView.m
//  Extract
//
//  Created by markss on 15/3/5.
//  Copyright (c) 2015年 GL. All rights reserved.
//

#import "DragDropView.h"

@implementation DragDropView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        //register
        [self registerForDraggedTypes:@[NSFilenamesPboardType]];
    }
    return self;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
    // 1）、get paste board
    NSPasteboard *zPasteboard = [sender draggingPasteboard];
    // 2）、get nsfilenames
    NSArray *list = [zPasteboard propertyListForType:NSFilenamesPboardType];
    // 3）、call back
    if(self.delegate && [self.delegate respondsToSelector:@selector(dragDropViewFileList:)])
        [self.delegate dragDropViewFileList:list];
    return YES;
}

@end
