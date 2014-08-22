//
//  ViewController.m
//  Toy_NSURLConnection
//
//  Created by Derrick Ho on 7/14/14.
//  Copyright (c) 2014 dnthome. All rights reserved.
//

#import "ViewController.h"

NSString *const kUrlToRequest = @"https://raw.githubusercontent.com/wh1pch81n/ToastMasterTopics/master/TMTopic/BigListOfTableTopics";

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textViewBlock;
@property (weak, nonatomic) IBOutlet UITextView *textViewGet;
@property (weak, nonatomic) IBOutlet UITextView *textViewPost;

@property (strong, nonatomic) NSMutableData *responseDataGet, *responseDataPost; //this will hold the response data when the request finally returns
@property (strong, nonatomic) NSURLConnection *postConnection, *getConnection;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"Do block");
    [self block];
    NSLog(@"Do GET");
    [self getData];
    NSLog(@"DO POST");
    [self postData];
}

- (void)block {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kUrlToRequest]];
    NSOperationQueue *opQueue = [NSOperationQueue new];
    [NSURLConnection sendAsynchronousRequest:request queue:opQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"Error: %@", connectionError);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textViewBlock.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        });
        
        //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
}

- (void)getData {
     //create a request
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:kUrlToRequest]];
    
    //create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [conn setDelegateQueue:[NSOperationQueue new]];
    self.getConnection = conn;
    [conn start];
}

- (void)postData {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]];
    
    //specify that it will be a post request
    //request.HTTPBody = @"POST";
    request.HTTPMethod = @"POST";
    //This is how we set header fields
    [request setValue:@"application/xml; charset=utf-8"
   forHTTPHeaderField:@"Content-Type"];
    
    //Convert your data and set your request's HTTPBody property
    NSString *stringData = @"Some data";
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    //Create url connection and fire
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [conn setDelegateQueue:[NSOperationQueue new]];
    self.postConnection = conn;
    [conn start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSURLConnection data Delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    /*The response has been recieved.  This is a good time to initialize the nsmutabledata variable we made*/
    if (connection == self.getConnection) {
        self.responseDataGet = [NSMutableData new];
    } else if (connection == self.postConnection) {
        self.responseDataPost = [NSMutableData new];
    } else {
        NSLog(@"Problem with didRecieveResponse.  connections do not match");
        abort();
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == self.getConnection) {
        [self.responseDataGet appendData:data];
    } else if (connection == self.postConnection) {
        [self.responseDataPost appendData:data];
    } else {
        NSLog(@"Problem with didRecievedata.  connections do not match");
        abort();
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;  //Set to nill so that it knows that caching is not neccesary
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    /*The request is complete and data has been recieved.  You can now parse the responseData now*/
    dispatch_async(dispatch_get_main_queue(), ^{
        if (connection == self.getConnection) {
            self.textViewGet.text = [[NSString alloc] initWithData:self.responseDataGet encoding:NSUTF8StringEncoding];
        } else if (connection == self.postConnection) {
            self.textViewPost.text = [[NSString alloc] initWithData:self.responseDataPost encoding:NSUTF8StringEncoding];
        } else {
            NSLog(@"Problem with didfinishloading.  connections do not match");
            abort();
        }
        
    });
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    /*The request has failed for some reason.  check the error message*/
    if (error) {
        NSLog(@"Error: %@", error.description);
    }
}

@end
