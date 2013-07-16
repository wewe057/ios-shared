//
//  SDMockService.h
//
//  Created by Steven Woolgar on 06/27/2013.
//  Copyright 2011-2013 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG

@interface SDMockRequestResult : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, assign) SDWebServiceResult result;
@property (nonatomic, strong) NSURLRequest *request;

@end

@interface SDMockService : NSObject

/**
 The timeout, in seconds, for calls made to this service. Default is `60.0`.
 */
@property (nonatomic, assign) NSUInteger timeout;

/**
 Returns the singleton for the web service class.
 */
+ (instancetype)sharedInstance;

/**
 Initializes the instance with a plist specification included in the bundle and named using the string in `specificationName` and of type .plist.
 */
- (instancetype)initWithSpecification:(NSString *)specificationName;

/**
 Initializes the instance with a plist specification included in the bundle and named using the string in `specificationName` and of type .plist.
 Overrides the `baseHost` and `basePath` with the parameters `defaultHost` and `defaultPath`.
 */
- (instancetype)initWithSpecification:(NSString *)specificationName host:(NSString *)defaultHost path:(NSString *)defaultPath;

/**
 Returns the base scheme in the service specification.
 */
- (NSString *)baseSchemeInServiceSpecification;

/**
 Returns the base host in the service specification.
 */
- (NSString *)baseHostInServiceSpecification;

/**
 Returns the base path in the service specification.
 */
- (NSString *)basePathInServiceSpecification;

/**
 Returns `YES` if there is reachability to the Internet. `NO` otherwise.
 @warning `showError` is currently ignored.
 */
- (BOOL)isReachable:(BOOL)showError;

/**
 Returns `YES` if there is reachability to `hostName`. `NO` otherwise.
 @warning `showError` is currently ignored.
 */
- (BOOL)isReachableToHost:(NSString *)hostName showError:(BOOL)showError;

/**
 Removes all cached responses.
 */
- (void)clearCache;

/**
 Returns a data processing block for converting JSON data into a dictionary or array.
 */
+ (SDWebServiceDataCompletionBlock)defaultJSONProcessingBlock;

/**
 Returns a data processing block for converting JSON data into a mutable dictionary or array.
 */
+ (SDWebServiceDataCompletionBlock)defaultMutableJSONProcessingBlock;

/**
 Returns a data processing block for converting JSON data into an array.
 */
+ (SDWebServiceDataCompletionBlock)defaultArrayJSONProcessingBlock;

/**
 Returns a data processing block for converting JSON data into a mutable array.
 */
+ (SDWebServiceDataCompletionBlock)defaultMutableArrayJSONProcessingBlock;

/**
 Returns a data processing block for converting JSON data into a dictionary.
 */
+ (SDWebServiceDataCompletionBlock)defaultDictionaryJSONProcessingBlock;

/**
 Returns a data processing block for converting JSON data into a mutable dictionary.
 */
+ (SDWebServiceDataCompletionBlock)defaultMutableDictionaryJSONProcessingBlock;

/**
 Calls performRequestWithMethod:routeReplacements:dataProcessingBlock:uiUpdateBlock:shouldRetry: with `shouldRetry` set to `YES`.
 */
- (SDMockRequestResult *)performRequestWithMethod:(NSString *)requestName
                                routeReplacements:(NSDictionary *)replacements
                              dataProcessingBlock:(SDWebServiceDataCompletionBlock)dataProcessingBlock
                                    uiUpdateBlock:(SDWebServiceUICompletionBlock)uiUpdateBlock;

/**
 Calls performRequestWithMethod:headers:routeReplacements:dataProcessingBlock:uiUpdateBlock:shouldRetry: with `shouldRetry` set to `YES`.
 */
- (SDMockRequestResult *)performRequestWithMethod:(NSString *)requestName
                                          headers:(NSDictionary *)headers
                                routeReplacements:(NSDictionary *)replacements
                              dataProcessingBlock:(SDWebServiceDataCompletionBlock)dataProcessingBlock
                                    uiUpdateBlock:(SDWebServiceUICompletionBlock)uiUpdateBlock;

/**
 Calls performRequestWithMethod:headers:routeReplacements:dataProcessingBlock:uiUpdateBlock:shouldRetry: with `headers` set to `nil`.
 */
- (SDMockRequestResult *)performRequestWithMethod:(NSString *)requestName
                                routeReplacements:(NSDictionary *)replacements
                              dataProcessingBlock:(SDWebServiceDataCompletionBlock)dataProcessingBlock
                                    uiUpdateBlock:(SDWebServiceUICompletionBlock)uiUpdateBlock
                                      shouldRetry:(BOOL)shouldRetry;


/**
 Creates and initiates a request to the web service.
 @return An SDRequestResult object to indicate the success of the method (not the call) and to provide a unique identifier for cancelRequestForIdentifier:.
 @param requestName The name of the request as specified in the plist.
 @param replacements Route replacements if any for the routeFormat as well as the postFormat in the request spec.
 @param dataProcessingBlock The block to execute after the request completes to process the response in a background thread.
 @param uiUpdateBlock The block to execute after the dataProcessingBlock completes to update the UI on the main thread.
 @param shouldRetry Set to `YES` to retry the request once after a time out.
 */
- (SDMockRequestResult *)performRequestWithMethod:(NSString *)requestName
                                          headers:(NSDictionary *)headers
                                routeReplacements:(NSDictionary *)replacements
                              dataProcessingBlock:(SDWebServiceDataCompletionBlock)dataProcessingBlock
                                    uiUpdateBlock:(SDWebServiceUICompletionBlock)uiUpdateBlock
                                      shouldRetry:(BOOL)shouldRetry;

/**
 Cancels the request that matches the `identifier`.
 */
- (void)cancelRequestForIdentifier:(NSString *)identifier;

#pragma mark - Suggested overrides for subclasses

/**
 Override in subclass as so:
    SDWebServiceUICompletionBlock uiBlock = ^(id dataObject, NSError *error)
        {
            if ([self handledError:error dataObject:dataObject])
            {
                // do your *ERROR UI*
            }
            else
            {
                // do your *SUCCESS UI*
                // You may still need to do some error checking here.
                // Think of handledError: as kind of a global error handling for your app.
                // If this service call has possible error conditions that no other
                // service call would have, you'll want to look for those here as well.
            }
        }
 */
- (BOOL)handledError:(NSError *)error dataObject:(id)dataObject;

/**
 Implement in subclass for specific behavior in case a request is undergoing a 302 redirect.
 */
- (void)will302RedirectToUrl:(NSURL *)argUrl;

/**
 Implement in subclass for specific behavior in case a request times out.
 */
- (void)serviceCallDidTimeoutForUrl:(NSURL*)url;

/**
 Implement in subclass to do what's needed when network activity starts.
 */
- (void)showNetworkActivity;

/**
 Implement in subclass to do what's needed when network activity ends.
 */
- (void)hideNetworkActivity;


@end

#endif

