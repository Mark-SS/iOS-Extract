//
//  ExportAppImage.h
//  Extract
//
//  Created by markss on 15/3/5.
//  Copyright (c) 2015年 GL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExportAppImage : NSObject

+ (NSInteger)exportPath:(NSString *)path
             outputPath:(NSString *)outputDirectoryPath
                  group:(BOOL)group
              exportPDF:(BOOL)exportPDF
              exportPNG:(BOOL)exportPNG
              exportCAR:(BOOL)exportCAR
               callback:(void(^)(CGFloat percent, BOOL isStop))callback ;

@end
