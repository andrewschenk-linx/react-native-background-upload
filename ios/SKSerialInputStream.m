//
//  SKSerialInputStream.m
//  inputstream
//
//  Created by Soroush Khanlou on 11/4/18.
//  Copyright © 2018 Soroush Khanlou. All rights reserved.
//

#import "SKSerialInputStream.h"

@interface SKSerialInputStream ()

@property NSInteger currentIndex;
@property (readwrite) NSStreamStatus streamStatus;
@property (readwrite, copy) NSError *streamError;

@end

@implementation SKSerialInputStream

@synthesize streamError;
@synthesize streamStatus;
@synthesize delegate;

- (instancetype)initWithInputStreams:(NSArray<NSInputStream *> *)inputStreams {
    self = [super init];
    if (!self) return nil;
    
    _inputStreams = inputStreams;
    _currentIndex = 0;
    
    return self;
}

#pragma mark - NSInputStream

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)maxLength {
    if ([self streamStatus] == NSStreamStatusClosed) {
        return 0;
    }
    
    NSInteger totalNumberOfBytesRead = 0;
    
    while (totalNumberOfBytesRead < maxLength) {
        if (self.currentIndex == self.inputStreams.count) {
            [self close];
            break;
        }
        
        NSInputStream *currentInputStream = self.inputStreams[self.currentIndex];
        
        if (currentInputStream.streamStatus != NSStreamStatusOpen) {
            [currentInputStream open];
        }

        if (!currentInputStream.hasBytesAvailable) {
            self.currentIndex += 1;
            continue;
        }
        
        NSUInteger remainingLength = maxLength - totalNumberOfBytesRead;
        
        NSInteger numberOfBytesRead = [currentInputStream read:&buffer[totalNumberOfBytesRead] maxLength:remainingLength];
        
        if (numberOfBytesRead == 0) {
            self.currentIndex += 1;
            continue;
        }
        
        if (numberOfBytesRead == -1) {
            self.streamError = currentInputStream.streamError;
            return -1;
        }
        
        totalNumberOfBytesRead += numberOfBytesRead;

    }
    
    return totalNumberOfBytesRead;
}

- (BOOL)getBuffer:(uint8_t * _Nullable *)buffer length:(NSUInteger *)length {
    if (self.currentIndex == self.inputStreams.count) {
        return NO;
    }
    return [self.inputStreams[self.currentIndex] getBuffer:buffer length:length];
}

- (BOOL)hasBytesAvailable {
    return YES; // ideally would be self.currentIndex != self.inputStreams.count;
}

#pragma mark - NSStream

- (void)open {
    if (self.streamStatus == NSStreamStatusOpen) {
        return;
    }
    
    self.streamStatus = NSStreamStatusOpen;
}

- (void)close {
    self.streamStatus = NSStreamStatusClosed;
}

- (id)propertyForKey:(__unused NSString *)key {
    return nil;
}

- (BOOL)setProperty:(__unused id)property forKey:(__unused NSString *)key {
    return NO;
}

- (void)scheduleInRunLoop:(__unused NSRunLoop *)runLoop forMode:(__unused NSString *)mode {
    
}

- (void)removeFromRunLoop:(__unused NSRunLoop *)runLoop forMode:(__unused NSString *)mode {
    
}

@end
