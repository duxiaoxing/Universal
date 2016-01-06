//
//  UIImage+Extension.m
//  Universal
//
//  Created by emiaobao on 15/9/1.
//  Copyright (c) 2015年 emiaobao. All rights reserved.
//

#import "UIImage+Extension.h"
#import "PodHeaders.h"

#import <Accelerate/Accelerate.h>


#define kMaxWidth   1080.0
#define kMaxHeight  1920.0

@implementation UIImage (Extension)


- (UIImage *)redrawWithSize:(CGSize)size
{
    CGSize imageSize = self.size;
    CGSize drawSize = size;
    if (imageSize.width < kMaxWidth && imageSize.height < kMaxHeight) {
        NSLog(@"图片不需要压缩");
        drawSize.width = imageSize.width;
        drawSize.height = imageSize.height;
    }
    else if (imageSize.width > kMaxWidth && imageSize.height < kMaxHeight) {
        NSLog(@"图片比较宽，需要纵向压缩");
        CGFloat scale = kMaxWidth / imageSize.width;
        drawSize.width = kMaxWidth;
        drawSize.height = imageSize.height / scale;
    }
    else if (imageSize.width < kMaxWidth && imageSize.height > kMaxHeight) {
        NSLog(@"图片比较高，需要纵向压缩");
        CGFloat scale = kMaxHeight / imageSize.height;
        drawSize.height = kMaxHeight;
        drawSize.width = imageSize.width / scale;
    }
    else
    {
        NSLog(@"图片宽高都需要压缩");
        CGFloat wScale = imageSize.width/kMaxWidth;
        CGFloat hScale = imageSize.height/kMaxHeight;
        
        CGFloat maxScale = MAX(wScale, hScale);
        
        drawSize.width = imageSize.width/maxScale;
        drawSize.height = imageSize.height/maxScale;
        
    }
    CGRect rect = CGRectMake(0.0f, 0.0f,drawSize.width, drawSize.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, self.scale);
    CGContextRef c = UIGraphicsGetCurrentContext();
    [self drawInRect:rect];
    CGContextFillRect(c, rect);
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

- (void)writeToSavedPhotosAlbum
{
    UIImageWriteToSavedPhotosAlbum(self, nil, nil, nil);
}

+ (UIImage*)noCacheWithName:(NSString*)imageFullName
{
    UIImage  *resultImage = nil ;
    NSString *imageName = nil;
    NSString *imageType = nil;
    NSString *filePath = nil;
    
    if ([imageFullName isContainsString:@"."]) {
        
        imageName = [[imageFullName componentsSeparatedByString:@"."]firstObject];
        imageType = [[imageFullName componentsSeparatedByString:@"."]lastObject];
        
        filePath = [[NSBundle mainBundle]pathForResource:imageName ofType:imageType];
    }
    else
    {
        filePath = [[NSBundle mainBundle]pathForResource:imageFullName ofType:@"png"];
    }
    
    resultImage = [UIImage imageWithContentsOfFile:filePath];
    
    return resultImage;
}

+ (UIImage*)QRCodeImageWithString:(NSString*)string imageWeight:(CGFloat)w imageHeight:(CGFloat)h
{
    
    if ([UIDevice systemVersion] > 8.0) {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding]; // NSISOLatin1StringEncoding 编码
        
        CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [filter setValue:data forKey:@"inputMessage"];
        
        CIImage *outputImage = filter.outputImage;
        CGSize CIImageSize = outputImage.extent.size;
        CGAffineTransform transform = CGAffineTransformMakeScale(w/CIImageSize.width, h/CIImageSize.height); // scale 为放大倍数
        CIImage *transformImage = [outputImage imageByApplyingTransform:transform];
        
        // 保存
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef imageRef = [context createCGImage:transformImage fromRect:transformImage.extent];
        
        UIImage *qrCodeImage = [UIImage imageWithCGImage:imageRef];
        //    [UIImagePNGRepresentation(qrCodeImage) writeToFile:path atomically:NO];
        
        CGImageRelease(imageRef);
        
        return qrCodeImage;
    }
    
    else
    {
        NSError *error = nil;
        ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
        ZXBitMatrix* result = [writer encode:string
                                      format:kBarcodeFormatQRCode
                                       width:w
                                      height:h
                                       error:&error];
        
        CGImageRef image = [[ZXImage imageWithMatrix:result] cgimage];
        UIImage *qrImage = [UIImage imageWithCGImage:image];
        
        if (error) {
            NSLog(@"生成条码图片错误:%@",[error localizedDescription]);
            
            return nil;
        }
        else
        {
            return qrImage;
        }
    }
}
- (UIImage*)blurPercent:(CGFloat)blurPercent
{
    NSData *imageData = UIImageJPEGRepresentation(self, 1); // convert to jpeg
    UIImage* destImage = [UIImage imageWithData:imageData];
    
    
    if (blurPercent < 0.f || blurPercent > 1.f) {
        blurPercent = 0.5f;
    }
    int boxSize = (int)(blurPercent * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = destImage.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    
    vImage_Error error;
    
    void *pixelBuffer;
    
    
    //create vImage_Buffer with data from CGImageRef
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    // Create a third buffer for intermediate processing
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}

@end
