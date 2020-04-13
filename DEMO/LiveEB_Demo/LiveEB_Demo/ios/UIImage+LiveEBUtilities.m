#import "UIImage+LiveEBUtilities.h"

@implementation UIImage (ARDUtilities)

+ (UIImage *)imageForName:(NSString *)name color:(UIColor *)color {
  UIImage *image = [UIImage imageNamed:name];
  if (!image) {
    return nil;
  }
  UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
  [color setFill];
  CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
  UIRectFill(bounds);
  [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
  UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();

  return coloredImage;
}

@end
