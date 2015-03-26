//
//  CARExportor.h
//  Extract
//
//  Created by markss on 15/3/5.
//  Copyright (c) 2015年 GL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CARExportor : NSObject

+ (void)exportCarFileAtPath:(NSString *)carPath outputDirectoryPath:(NSString *)outputDirectoryPath;

@end
