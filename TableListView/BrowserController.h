//
//  BrowserViewController.h
//  

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface BrowserController : UIViewController <UIWebViewDelegate>
{
    UIWebView * _webview;
    NSURLRequest * _loadRequest;
    
    UIActivityIndicatorView *activityView;
    UIView *loadingView;
    UILabel *loadingLabel;
}

@property (nonatomic, retain) IBOutlet UIWebView * webview;
@property (nonatomic, retain) NSURLRequest * loadRequest;

@property (nonatomic, retain) UIActivityIndicatorView * activityView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UILabel *loadingLabel;

- (id)initWithLoadRequest:(NSURLRequest *)request;

- (void)startActivity:(id)sender;
- (void)stopActivity:(id)sender;


@end
