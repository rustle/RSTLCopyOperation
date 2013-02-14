//
//  main.m
//
//  Created by Doug Russell on 2/12/13.
//  Copyright (c) 2013 Doug Russell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSTLCopyOperation.h"

@interface Delegate : NSObject <RSTLCopyOperationDelegate>

@end

@implementation Delegate

- (void)copyOperationWillStart:(RSTLCopyOperation *)copyOperation
{
	NSLog(@"%s", __func__);
}

- (void)copyOperationDidFinish:(RSTLCopyOperation *)copyOperation
{
	NSLog(@"%s - Result Code: %i", __func__, copyOperation.resultCode);
}

@end

int main(int argc, const char * argv[])
{
    NSString *fromPath = [@"~/Desktop/Copy1" stringByExpandingTildeInPath];
    NSString *toPath = [@"~/Desktop/Copy2" stringByExpandingTildeInPath];
    
	RSTLCopyOperation *copyOperation = [[RSTLCopyOperation alloc] initWithFromPath:fromPath toPath:toPath];
	Delegate *delegate = [Delegate new];
	copyOperation.delegate = delegate;
    
    NSOperationQueue *queue = [NSOperationQueue new];
    [queue addOperation:copyOperation];
    [queue waitUntilAllOperationsAreFinished];
    
    return copyOperation.resultCode;
}

