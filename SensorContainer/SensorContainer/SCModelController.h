//
//  SCModelController.h
//  SensorContainer
//
//  Created by Daniel Yuen on 13-01-10.
//  Copyright (c) 2013 Daniel Yuen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCDataViewController;

@interface SCModelController : NSObject <UIPageViewControllerDataSource>

- (SCDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(SCDataViewController *)viewController;

@end
