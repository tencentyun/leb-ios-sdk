#import <UIKit/UIKit.h>

@interface UIImage (ARDUtilities)

// Returns an color tinted version for the given image resource.
+ (UIImage *)imageForName:(NSString *)name color:(UIColor *)color;

@end
