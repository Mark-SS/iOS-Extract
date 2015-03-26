//
//  DragDropView.h
//  Extract
//
//  Created by markss on 15/3/5.
//  Copyright (c) 2015年 GL. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol DragDropViewDelegate;

@interface DragDropView : NSView
@property (assign) IBOutlet id<DragDropViewDelegate> delegate;
@end

@protocol DragDropViewDelegate <NSObject>
-(void)dragDropViewFileList:(NSArray*)fileList;
@end