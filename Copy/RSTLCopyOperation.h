//
//  RSTLCopyOperation.h
//
//  Created by Doug Russell on 2/12/13.
//  Copyright (c) 2013 Doug Russell. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int8_t, RSTLCopyState) {
    RSTLCopyNotStarted,
    RSTLCopyInProgress,
    RSTLCopyFinished,
};

@protocol RSTLCopyOperationDelegate;

@interface RSTLCopyOperation : NSOperation

@property (copy, nonatomic, readonly) NSString *fromPath;
@property (copy, nonatomic, readonly) NSString *toPath;
@property (nonatomic, readonly) int resultCode;

@property (weak, nonatomic) id<RSTLCopyOperationDelegate> delegate;

- (instancetype)initWithFromPath:(NSString *)fromPath toPath:(NSString *)toPath;

@end

@protocol RSTLCopyOperationDelegate <NSObject>

@end
