//
//  SKSerialInputStream.h
//  inputstream
//
//  Created by Soroush Khanlou on 11/4/18.
//  Copyright © 2018 Soroush Khanlou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKSerialInputStream : NSInputStream

- (instancetype)initWithInputStreams:(NSArray<NSInputStream *> *)inputStreams;

@property (nonatomic, readonly) NSArray<NSInputStream *> *inputStreams;

@end

