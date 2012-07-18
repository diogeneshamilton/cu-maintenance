#import "MaintenanceDialog.h"
#import "OAuthConsumer.h"

@interface MaintenanceDialog ()

@property (strong, nonatomic) OAToken *requestToken;
@property (strong, nonatomic) OAToken *accessToken;

@end

@implementation MaintenanceDialog

@synthesize requestToken;
@synthesize accessToken;

- (void)getUnauthorizedToken {
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:@""
                                                    secret:@""];
    
    NSURL *url = [NSURL URLWithString:@"http://www.tumblr.com/oauth/request_token"];
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:nil   // we don't have a Token yet
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    [request setHTTPMethod:@"POST"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
    
    //TODO: put in Error delegate method.
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    if (ticket.didSucceed) {
        requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        [self getAuthorizedToken];
        
    }
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    
    NSLog(@"%@", error);
}


- (void)getAuthorizedToken {
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:@""
                                                    secret:@""];
    
//    NSURL *url = [NSURL URLWithString:@"http://example.com/get_request_token"];
    NSURL *url = [NSURL URLWithString:@"http://api.tumblr.com/v2/blog/awkwardsportsphotos.tumblr.com/post?type=text&body=helloworld"];

    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:requestToken 
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
    
    [request setHTTPMethod:@"POST"];
    
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
    
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    if (ticket.didSucceed) {

        accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        
        
        [accessToken storeInUserDefaultsWithServiceProviderName:@"CUMaintenance" prefix:@"CUMaintenance"];
        
    }
}

@end
