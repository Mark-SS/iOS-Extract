//
//  CARExportor.m
//  Extract
//
//  Created by markss on 15/3/5.
//  Copyright (c) 2015年 GL. All rights reserved.
//

#import "CARExportor.h"

#pragma Private Frameworks

@interface CUICommonAssetStorage : NSObject

-(NSArray *)allAssetKeys;
-(NSArray *)allRenditionNames;

-(id)initWithPath:(NSString *)p;

-(NSString *)versionString;

@end

@interface CUINamedImage : NSObject

-(CGImageRef)image;
@property(readonly) double scale;
- (int)idiom;
@property(readonly) struct CGSize { double x1; double x2; } size;

@end

@interface CUIRenditionKey : NSObject
@end

@interface CUIThemeFacet : NSObject

+ (NSInteger)themeWithContentsOfURL:(NSURL *)urlString error:(NSError **)error;
+ (void)_invalidateArtworkCaches;

@end

@interface CUICatalog : NSObject


-(id)initWithName:(NSString *)n fromBundle:(NSBundle *)b;
-(id)allKeys;
- (NSArray *)allImageNames;
- (id)imagesWithName:(id)arg1;
- (CUINamedImage *)imageWithName:(NSString *)n scaleFactor:(CGFloat)s;

- (CUINamedImage *)imageWithName:(NSString *)n scaleFactor:(CGFloat)s deviceIdiom:(int)idiom;
- (CUINamedImage *)imageWithName:(NSString *)n scaleFactor:(CGFloat)s deviceIdiom:(int)arg3 deviceSubtype:(NSUInteger)arg4;

- (CUINamedImage *)imageWithName:(NSString *)n
                     scaleFactor:(CGFloat)s
                     deviceIdiom:(int)arg3
                   deviceSubtype:(NSUInteger)arg4
             sizeClassHorizontal:(NSInteger)arg5
               sizeClassVertical:(NSInteger)arg6;

- (id)_resolvedRenditionKeyForName:(id)arg1
                       scaleFactor:(double)arg2
                       deviceIdiom:(long long)arg3
                     deviceSubtype:(unsigned long long)arg4
               sizeClassHorizontal:(long long)arg5
                 sizeClassVertical:(long long)arg6
                       memoryClass:(unsigned long long)arg7
                     graphicsClass:(unsigned long long)arg8;


@end


@implementation CARExportor

#define kCoreThemeIdiomPhone 1
#define kCoreThemeIdiomPad 2

#pragma mark Export Image

void CGImageWriteToFile(CGImageRef image, NSString *path)
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path.stringByDeletingLastPathComponent])
        [[NSFileManager defaultManager] createDirectoryAtPath:path.stringByDeletingLastPathComponent withIntermediateDirectories:true attributes:nil error:nil];
    
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
    CGImageDestinationAddImage(destination, image, nil);
    
    if (!CGImageDestinationFinalize(destination)) {
        //NSLog(@"Failed to write image to %@", path);
    }
    
    CFRelease(destination);
}

#pragma mark 

+ (void)exportCarFileAtPath:(NSString *)carPath outputDirectoryPath:(NSString *)outputDirectoryPath {
    NSError *error = nil;
    
    NSUInteger facet = [CUIThemeFacet themeWithContentsOfURL:[NSURL fileURLWithPath:carPath] error:&error];
    //NSLog(@"facet = %lu", facet);
    
    CUICatalog *catalog = [[CUICatalog alloc] init];
    [catalog setValue:@(facet) forKey:@"_storageRef"];
    CUICommonAssetStorage *storage = [[NSClassFromString(@"CUICommonAssetStorage") alloc] initWithPath:carPath];
    
    for (NSString *key in [storage allRenditionNames])
    {
        NSLog(@" Writing Image: %@", key);        
        for (int i = 1; i <= 3; i++) {
            CUINamedImage *phoneNameImage = [catalog imageWithName:key scaleFactor:i deviceIdiom:kCoreThemeIdiomPhone];
            CUINamedImage *padNameImage = [catalog imageWithName:key scaleFactor:i deviceIdiom:kCoreThemeIdiomPad];
            CUINamedImage *ohterNameImage = [catalog imageWithName:key scaleFactor:i];
            if (phoneNameImage) {
                NSUInteger width = phoneNameImage.size.x1 * phoneNameImage.scale;
                NSUInteger height = phoneNameImage.size.x2 * phoneNameImage.scale;
                CGImageWriteToFile(phoneNameImage.image, [outputDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@~%lu*%lu.png", key, width, height]]);
            }
            if (padNameImage) {
                CGImageWriteToFile(padNameImage.image, [outputDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@~iPad.png", key]]);
            }
            if (ohterNameImage) {
                CGImageWriteToFile(ohterNameImage.image, [outputDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", key]]);
            }
        }
    }
}


@end
