//
//  GPUImageDispatchQueueManager.h
//  GPUImage
//
//  Created by Andrew Poes on 4/22/15.
//  Copyright (c) 2015 Brad Larson. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GPUImageSharedDispatchQueueManager ([GPUImageDispatchQueueManager sharedDispatchQueueManager])

@interface GPUImageDispatchQueueManager : NSObject

+ (GPUImageDispatchQueueManager *)sharedDispatchQueueManager;
- (dispatch_queue_t)dequeueDispatchQueue;
- (void)releaseDispatchQueue:(dispatch_queue_t)dispatchQueue;

@end
