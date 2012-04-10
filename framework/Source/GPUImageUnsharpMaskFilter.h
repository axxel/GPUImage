#import "GPUImageFilterGroup.h"

@class GPUImageGaussianBlurFilter;

@interface GPUImageUnsharpMaskFilter : GPUImageFilterGroup
{
    GPUImageGaussianBlurFilter *blurFilter;
    GPUImageFilter *unsharpMaskFilter;
}
// A multiplier for the underlying blur size, ranging from 0.0 on up, with a default of 1.0
@property(readwrite, nonatomic) CGFloat radius;

// The strength of the sharpening, from 0.0 on up, with a default of 1.0
@property(readwrite, nonatomic) CGFloat amount;

// The threshold for the application of the mask, from 0.0 to 1.0, with a default of 0.0
@property(readwrite, nonatomic) CGFloat threshold;

@end
