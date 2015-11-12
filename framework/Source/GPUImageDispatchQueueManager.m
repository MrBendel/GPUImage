//
//  GPUImageDispatchQueueManager.m
//  GPUImage
//
//  Created by Andrew Poes on 4/22/15.
//  Copyright (c) 2015 Brad Larson. All rights reserved.
//

#import "GPUImageDispatchQueueManager.h"

@interface GPUImageDispatchQueueWrapper : NSObject

@property (nonatomic, assign, getter=isAvailable) BOOL available;
@property (nonatomic, assign) NSUInteger index;
#if OS_OBJECT_HAVE_OBJC_SUPPORT == 1
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;
#else
@property (nonatomic, assign) dispatch_queue_t dispatchQueue;
#endif

- (instancetype)initWithIndex:(NSInteger)index;
- (void)prepareForReuse;

@end

@implementation GPUImageDispatchQueueWrapper

- (instancetype)initWithIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        self.index = index;
        [self prepareForReuse];
    }
    return self;
}

- (void)prepareForReuse
{
    if (self.dispatchQueue) {
#if OS_OBJECT_HAVE_OBJC_SUPPORT == 0
        dispatch_release(self.dispatchQueue);
#endif
        self.dispatchQueue = nil;
    }
    
    self.available = YES;
    const char *dispatchQueueName = [NSString stringWithFormat:@"com.sunsetlakesoftware.GPUImage.dispatchQueueManager_%lu", (unsigned long)self.index].UTF8String;
    self.dispatchQueue = dispatch_queue_create(dispatchQueueName, DISPATCH_QUEUE_SERIAL);
}

@end

#pragma mark -

@interface GPUImageDispatchQueueManager()

@property (nonatomic, assign) NSInteger queueIndex;
@property (nonatomic, strong) NSMutableArray *wrappers;

@end

@implementation GPUImageDispatchQueueManager

+ (GPUImageDispatchQueueManager *)sharedDispatchQueueManager
{
    static GPUImageDispatchQueueManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [GPUImageDispatchQueueManager new];
    });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.queueIndex = 0;
        self.wrappers = [NSMutableArray new];
    }
    return self;
}

- (dispatch_queue_t)dequeueDispatchQueue
{
    __block GPUImageDispatchQueueWrapper *wrapper = nil;
    [self.wrappers enumerateObjectsUsingBlock:^(GPUImageDispatchQueueWrapper *potential, NSUInteger idx, BOOL *stop) {
        if (potential.isAvailable) {
            wrapper = potential;
            *stop = YES;
        }
    }];
    if (!wrapper) {
        wrapper = [[GPUImageDispatchQueueWrapper alloc] initWithIndex:self.queueIndex++];
        [self.wrappers addObject:wrapper];
    }
    wrapper.available = NO;
    return wrapper.dispatchQueue;
}

- (void)releaseDispatchQueue:(dispatch_queue_t)dispatchQueue
{
    NSString *queueDescriptor = [NSString stringWithUTF8String:dispatch_queue_get_label(dispatchQueue)];
    if (queueDescriptor) {
        [self.wrappers enumerateObjectsUsingBlock:^(GPUImageDispatchQueueWrapper *potential, NSUInteger idx, BOOL *stop) {
            NSString *potentialDescriptor = [NSString stringWithUTF8String:dispatch_queue_get_label(potential.dispatchQueue)];
            if (potentialDescriptor && [potentialDescriptor isEqualToString:queueDescriptor]) {
                [potential prepareForReuse];
                *stop = YES;
            }
        }];
    }
}

@end
