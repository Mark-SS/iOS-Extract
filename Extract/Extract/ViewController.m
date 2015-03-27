//
//  ViewController.m
//  Extract
//
//  Created by markss on 15/3/5.
//  Copyright (c) 2015年 GL. All rights reserved.
//

#import "ViewController.h"
#import "ExportAppImage.h"

@interface ViewController ()

@property (strong, nonatomic) NSString *temDir;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

#pragma mark - DragDropViewDelegate
- (void)dragDropViewFileList:(NSArray *)fileList {
    //NSLog(@"fileList = %@", fileList);
    NSString *filePath = [fileList firstObject];
    NSURL *searchURL = [NSURL fileURLWithPath:filePath];
    if ([searchURL.pathExtension.uppercaseString isEqualToString:@"IPA"]) {
        NSLog(@"ipa YES");
        [self unzip:filePath];
    }
}

#pragma mark iPA unzip
- (void)unzip:(NSString *)file {
    ZipArchive *ziparchive = [ZipArchive new];
    ziparchive.delegate = self;
    [ziparchive UnzipOpenFile:file];
    [ziparchive getZipFileContents];
    NSString *outPutDir = [file stringByReplacingOccurrencesOfString:@".ipa" withString:@"unzip"];
    _temDir = outPutDir;
    [ziparchive UnzipFileTo:outPutDir overWrite:YES];
    
    NSString *docPath = [outPutDir stringByAppendingString:@"/Payload"];
    NSString *inputPath = [docPath stringByAppendingPathComponent:[self getFilenamelistOfType:@"app" fromDirPath:docPath][0]];
    NSString *outputPath = [file stringByReplacingOccurrencesOfString:@".ipa" withString:@"images"];
    [self exportImageAtInputPath:inputPath outPutPath:outputPath];
}

- (NSArray *)getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath
{
    NSMutableArray *filenamelist = [NSMutableArray arrayWithCapacity:10];
    NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    
    for (NSString *filename in tmplist) {
        NSString *fullpath = [dirPath stringByAppendingPathComponent:filename];
        if ([self isFileExistAtPath:fullpath]) {
            if ([[filename pathExtension] isEqualToString:type]) {
                [filenamelist  addObject:filename];
            }
        }
    }
    return filenamelist;
}

- (BOOL)isFileExistAtPath:(NSString*)fileFullPath {
    BOOL isExist = NO;
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileFullPath];
    return isExist;
}

- (void)exportImageAtInputPath:(NSString *)inputPath
                    outPutPath:(NSString *)outputPath {
    if (!inputPath || !outputPath) {
        NSLog(@"Please make sure to specify input and output paths.");
        return ;
    }
    
    BOOL group = YES;
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"g"]) {
        group = YES;
    }
    
    BOOL exportPDF = YES;
    BOOL exportPNG = YES;
    BOOL exportCAR = YES;
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"t"]) {
        exportPDF = NO;
        exportPNG = NO;
        exportCAR = NO;
        
        NSArray *allowedTypes = [[[[NSUserDefaults standardUserDefaults] stringForKey:@"t"].uppercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@","];
        
        for (NSString *type in allowedTypes) {
            if ([type isEqualToString:@"PDF"]) {
                exportPDF = YES;
            }
            if ([type isEqualToString:@"PNG"]) {
                exportPNG = YES;
            }
            if ([type isEqualToString:@"CAR"]) {
                exportCAR = YES;
            }
        }
    }
    
    [ExportAppImage exportPath:inputPath
                    outputPath:outputPath
                         group:group
                     exportPDF:exportPDF
                     exportPNG:exportPNG
                     exportCAR:exportCAR
                      callback:^(CGFloat percent, BOOL isStop) {
                          if (isStop) {
                              [[NSFileManager defaultManager] removeItemAtPath:_temDir error:nil];
                          }
                      }];
}

#pragma mark zipArchiveDelegate
- (BOOL) OverWriteOperation:(NSString*) file {
    NSLog(@"[ziparchive unzippedFiles] = %@", file);
    return YES;
}

@end
