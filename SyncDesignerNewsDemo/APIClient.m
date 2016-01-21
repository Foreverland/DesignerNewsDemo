#import "APIClient.h"
@import Sync;
@import UIKit;

static NSString * const HYPBaseURL = @"https://www.designernews.co/?format=json";

@interface APIClient ()

@property (nonatomic, weak) DATAStack *dataStack;

@end

@implementation APIClient

- (void)fetchStoryUsingDataStack:(DATAStack *)dataStack
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:HYPBaseURL]];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

        if (connectionError) {
            NSLog(@"There was an error: %@", connectionError);
        } else {
            NSError *serializationError = nil;
            NSJSONSerialization *JSON = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:NSJSONReadingMutableContainers
                                                                          error:&serializationError];

            if (serializationError) {
                NSLog(@"Error serializing JSON: %@", serializationError);
            } else {
                [Sync changes:[JSON valueForKey:@"stories"]
                inEntityNamed:@"Story"
                    dataStack:dataStack
                   completion:nil];
            }
        }
    }] resume];
}

@end
