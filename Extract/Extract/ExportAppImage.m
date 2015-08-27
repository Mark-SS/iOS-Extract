//
//  ExportAppImage.m
//  Extract
//
//  Created by markss on 15/3/5.
//  Copyright (c) 2015年 GL. All rights reserved.
//

#import "ExportAppImage.h"
#import "CARExportor.h"

@implementation ExportAppImage

+ (NSString *)outputPathForFile:(NSString *)fileDirectory
                     exprotPath:(NSString *)exportPath
                          group:(BOOL)group {
    if (!group) {
        //Just place the file in the root of the output folder.
        return exportPath;
    } else {
        return [NSString stringWithFormat:@"%@-%@", [exportPath stringByAppendingPathComponent:fileDirectory.lastPathComponent.stringByDeletingPathExtension], fileDirectory.pathExtension];
    }
}

+ (void)copyFileAtPath:(NSString *)path
        exportLocation:(NSString *)exportLocation
                 group:(BOOL)group {
    
    NSString *ouputPath = [[self outputPathForFile:path.stringByDeletingLastPathComponent exprotPath:exportLocation group:group] stringByAppendingPathComponent:path.lastPathComponent];
    
    NSLog(@"    Moving file: %@", ouputPath);
    
    //Create the intermediate directories if necessary
    NSError *error;
    [[NSFileManager defaultManager] createDirectoryAtPath:ouputPath.stringByDeletingLastPathComponent withIntermediateDirectories:true attributes:nil error:&error];
    if (error) {
        NSLog(@"    An Error Occured: %@", error.localizedDescription);
    }
    
    if (!error) {
        error = nil;
        //Copy the file
        [[NSFileManager defaultManager] copyItemAtPath:path toPath:ouputPath error:&error];
        if (error && [error.localizedDescription rangeOfString:@"already exists"].location == NSNotFound) {
            NSLog(@"    An Error Occured: %@", error.localizedDescription);
        }
    }
}

#pragma mark processing
+ (NSInteger)exportPath:(NSString *)path
             outputPath:(NSString *)outputDirectoryPath
                  group:(BOOL)group
              exportPDF:(BOOL)exportPDF
              exportPNG:(BOOL)exportPNG
              exportCAR:(BOOL)exportCAR
               callback:(void(^)(CGFloat percent, BOOL isStop))callback {
    NSLog(@"Searching for files...");
    //Setup the directory enumerator
    BOOL isDirectory;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    
    NSLog(@"isDirectory = %d, exists = %d", isDirectory, exists);
    
    NSMutableArray *validFiles;
    if (exists && !isDirectory) {
        //Only have to extract one file
        validFiles = [@[path] mutableCopy];
        
    } else if (exists && isDirectory) {
        //Search for files to extract.
        NSURL *searchURL = [NSURL fileURLWithPath:path];
        NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:searchURL includingPropertiesForKeys:@[NSURLIsDirectoryKey] options:0 errorHandler:^BOOL(NSURL *url, NSError *error) {
            NSLog(@"    An Error Occured: %@", error.localizedDescription);
            return true;
        }];
        
        //Do we have a valid enumerator
        if (!enumerator) {
            NSLog(@"    Failure: Unable to enumerate file structure.");
            return 1;
        }
        
        //Loop through the enumerator, and collect all the valid files.
        validFiles = [NSMutableArray array];
        for (NSURL *url in enumerator) {
            NSError *error;
            NSNumber *isDirectory;
            
            if (![url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
                //Handle error
                NSLog(@"    An Error Occured: %@", error.localizedDescription);
                
            } else if (![isDirectory boolValue]) {
                //Is it a valid file type?
                if ([url.pathExtension.uppercaseString isEqualToString:@"PNG"] || [url.pathExtension.uppercaseString isEqualToString:@"PNG"] || [url.pathExtension.uppercaseString isEqualToString:@"CAR"]) {
                    [validFiles addObject:url.path];
                }
            }
        }
    }
    
    //-----------------------------------------------
    //Notify that we are finished searching for files
    //-----------------------------------------------
    
    NSLog(@"Finished searching for files...");
    
    //Enumerate over all the files
    NSUInteger count = validFiles.count;
    
    [validFiles enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
        //Is this a file type we should process?
        NSString *extension = path.lastPathComponent.pathExtension;
        if ([extension.uppercaseString isEqualToString:@"CAR"] && exportCAR) {
            // NSLog(@"Processing file: %li/%li, %@", idx, count, path);
            [CARExportor exportCarFileAtPath:path outputDirectoryPath:[self outputPathForFile:path.stringByDeletingLastPathComponent exprotPath:outputDirectoryPath group:group]];
            
        } else if ([extension.uppercaseString isEqualToString:@"PDF"] && exportPDF) {
            //NSLog(@"Processing file: %li/%li, %@", idx, count, path);
            //Extract the PDF file
            [self copyFileAtPath:path exportLocation:outputDirectoryPath group:group];
        } else if ([extension.uppercaseString isEqualToString:@"PNG"] && exportPNG) {
            //NSLog(@"Processing file: %li/%li, %@", idx, count, path);
            //Extract the PNG file
            [self copyFileAtPath:path exportLocation:outputDirectoryPath group:group];
        }
        
        if (idx == count - 1) {
            if (callback) {
                NSLog(@"============================ \n finished %@", path);
                callback(1, YES);
            }
        } else {
            if (callback) {
                callback((CGFloat)idx/(count - 1), NO);
            }
        }
    }];
    
    return 0;
    
}

@end
