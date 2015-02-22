//
//  BrowserViewController.m
// 



#import "BrowserController.h"

@implementation BrowserController

@synthesize webview = _webview;
@synthesize loadRequest = _loadRequest;
@synthesize activityView = activityView;
@synthesize loadingView = loadingView;
@synthesize loadingLabel = loadingLabel;


- (id)initWithLoadRequest:(NSURLRequest *)request{
    if (self) {
        self.loadRequest = request;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
    self.view.backgroundColor = [UIColor whiteColor];
    
}

- (void)dealloc{
    
    [self.webview setDelegate:nil];
    [self.webview stopLoading];
    self.webview = nil;

}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    //Add Webview Programatically
    _webview = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    _webview.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _webview.backgroundColor = [UIColor clearColor];
    _webview.delegate = self;
    self.view = _webview;
    
    if (self.loadRequest!=nil) {
        [_webview loadRequest:self.loadRequest];
        self.title = @"";
     }
      
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    

    
     CGRect screenRect = self.view.frame;
     CGFloat screenWidth = screenRect.size.width;
     CGFloat screenHeight = screenRect.size.height;
     
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/2 - 50 , screenHeight/2 - 50, 100, 100)];
    loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    loadingView.clipsToBounds = YES;
    loadingView.layer.cornerRadius = 10.0;
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = CGRectMake(30, 20, activityView.bounds.size.width, activityView.bounds.size.height);
    [loadingView addSubview:activityView];
    
    loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 60, 90, 22)];
    loadingLabel.backgroundColor = [UIColor blackColor];
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.adjustsFontSizeToFitWidth = YES;
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.text = @"Loading";
    loadingLabel.font = [UIFont boldSystemFontOfSize:15];

    [loadingView addSubview:loadingLabel];
    
    [_webview addSubview:loadingView];
    
    
}


-(void)startActivity:(id)sender{
    //Send startAnimating message to the view
    [activityView startAnimating];
}

-(void)stopActivity:(id)sender{
    //Send stopAnimating message to the view
    [activityView stopAnimating];
    [loadingView removeFromSuperview];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
     return YES;
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopActivity:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [self startActivity:nil];
}



@end
