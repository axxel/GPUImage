#import "GPUImageUnsharpMaskFilter.h"
#import "GPUImageFilter.h"
#import "GPUImageGaussianBlurFilter.h"

NSString *const kGPUImageUnsharpMaskFragmentShaderString = SHADER_STRING
( 
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; 
 
 uniform highp float amount;
 uniform highp float threshold;
 
 void main()
 {
     lowp vec4 originalImageColor = texture2D(inputImageTexture, textureCoordinate);
     lowp vec3 blurredImageColor = texture2D(inputImageTexture2, textureCoordinate).rgb;
     lowp vec3 mask = originalImageColor.rgb - blurredImageColor;

     // standard USM with disabled threshold (equivalent to threshold == 0), fastest and probably most common
//     gl_FragColor.rgb = originalImageColor.rgb + amount * mask;
     
     // standard USM with hard threshold cutoff
//     gl_FragColor.rgb = originalImageColor.rgb + amount * mask * step(vec3(threshold), abs(mask));

     // randomly smoothstepping the threshold to make the parameter at least 'usable'
     gl_FragColor.rgb = originalImageColor.rgb + amount * mask * smoothstep(vec3(0), vec3(threshold), abs(mask));

     gl_FragColor.a = originalImageColor.a;
 }
);

@implementation GPUImageUnsharpMaskFilter

@synthesize amount = _amount;
@synthesize threshold = _threshold;

- (id)init;
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
    // First pass: apply a variable Gaussian blur
    blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    [self addFilter:blurFilter];
        
    // Second pass: combine the blurred image with the original sharp one
    unsharpMaskFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromString:kGPUImageUnsharpMaskFragmentShaderString];
    [self addFilter:unsharpMaskFilter];
    
    // Texture location 0 needs to be the sharp image for both the blur and the second stage processing
    [blurFilter addTarget:unsharpMaskFilter atTextureLocation:1];
    
    // To prevent double updating of this filter, disable updates from the sharp image side
    targetToIgnoreForUpdates = unsharpMaskFilter;
//    unsharpMaskFilter.shouldIgnoreUpdatesToThisTarget = YES;
    
    self.initialFilters = [NSArray arrayWithObjects:blurFilter, unsharpMaskFilter, nil];
    self.terminalFilter = unsharpMaskFilter;
    
    self.radius = 1.0;
    self.amount = 1.0;
    self.threshold = 0.0;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setRadius:(CGFloat)newValue;
{
    blurFilter.blurSize = newValue;
}

- (CGFloat)radius;
{
    return blurFilter.blurSize;
}

- (void)setAmount:(CGFloat)newValue;
{
    _amount = newValue;
    [unsharpMaskFilter setFloat:newValue forUniform:@"amount"];
}

- (void)setThreshold:(CGFloat)newValue;
{
    _threshold = newValue;
    [unsharpMaskFilter setFloat:newValue forUniform:@"threshold"];
}

@end