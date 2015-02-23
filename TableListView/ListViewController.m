//
//  ListViewController.m
//  TableListView
//
//  Created by Roger Chee Meng Lee on 24/02/14.
//  Copyright (c) 2014. All rights reserved.
//



#import "ListViewController.h"
#import "UIImageView+WebCache.h"
#import "BrowserController.h"
#import "Reachability.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface ListViewController ()

@end

@implementation ListViewController

@synthesize news;
@synthesize mainTableView = _mainTableView;

@synthesize activityView = activityView;
@synthesize loadingView = loadingView;
@synthesize loadingLabel = loadingLabel;
@synthesize refreshControl = refreshControl;

int pagesize = 10;
bool loadmore = YES;

float cellheight = 2000.0f;
float cellwidth = 300.0f;
float accwidth = 20.0f;
float imagewidthadjust = 90.0f;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Add Table Programatically
    _mainTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    _mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _mainTableView.backgroundColor = [UIColor clearColor];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    self.view = _mainTableView;
    
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
     //Loading Indicator Module
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(screenWidth/2 - 50 , screenHeight/2 - 50, 100, 100)];
    loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    loadingView.clipsToBounds = YES;
    loadingView.layer.cornerRadius = 10.0;
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = CGRectMake(30, 20, activityView.bounds.size.width, activityView.bounds.size.height);
    [loadingView addSubview:activityView];
    [activityView release];
    
    loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 60, 90, 22)];
    loadingLabel.backgroundColor = [UIColor blackColor];
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.adjustsFontSizeToFitWidth = YES;
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.text = @"Loading";
    loadingLabel.font = [UIFont boldSystemFontOfSize:15];
    
    [loadingView addSubview:loadingLabel];
    [loadingLabel release];
    
    //Refresh Control - Pull to Refresh
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refreshControl addTarget:self action:@selector(updateData) forControlEvents:UIControlEventValueChanged];
    [_mainTableView addSubview:refreshControl];
    
    //Refresh Control - Button
    //UIBarButtonItem *refreshButton=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"01-refresh"] style:UIBarButtonItemStyleBordered target:self action:@selector(updateData)];
    //self.navigationItem.rightBarButtonItem = refreshButton;
    
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        // Do any adjustment for ios6 view
        self.view.backgroundColor = [UIColor whiteColor];
    }

    [self updateData];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
}

- (void)viewDidUnload
{
    self.news = nil;
    [loadingView release];
    [_mainTableView release];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.news count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float headlineheight;
    float slugLineheight;
    CGSize cellSizeHead = CGSizeMake(cellwidth-accwidth, 100);
    CGSize cellSizeSlug = CGSizeMake(cellwidth-accwidth-imagewidthadjust, 2000);
    NSString *urlString = [[self.news objectAtIndex:indexPath.row] objectForKey:@"imageHref"];
    if ((urlString==nil) || (urlString == (NSString *)[NSNull null]) || ([urlString isEqualToString:@""]))
    { cellSizeSlug = CGSizeMake(cellwidth-accwidth, 2000);}
    NSString *titleString = [[self.news objectAtIndex:indexPath.row] objectForKey:@"title"];
    NSString *descriptionString = [[self.news objectAtIndex:indexPath.row] objectForKey:@"description"];

    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        if ((titleString==nil) || (titleString == (NSString *)[NSNull null]) || ([titleString isEqualToString:@""]))
        {
            headlineheight = 0;
        }
        else
        {
            headlineheight = [titleString
                           boundingRectWithSize:cellSizeHead
                           options:NSStringDrawingUsesLineFragmentOrigin
                           attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16]}
                           context:nil].size.height;
        }
        
        if ((descriptionString==nil) || (descriptionString == (NSString *)[NSNull null]) || ([descriptionString isEqualToString:@""]))
        {
            slugLineheight = 0;
        }
        else
        {
            slugLineheight = [descriptionString
                          boundingRectWithSize:cellSizeSlug
                          options:NSStringDrawingUsesLineFragmentOrigin
                          attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}
                          context:nil].size.height;
        }
        
    }
    else {
        if ((titleString==nil) || (titleString == (NSString *)[NSNull null]) || ([titleString isEqualToString:@""]))
        {
            headlineheight = 0;
        }
        else
        {
            headlineheight = [titleString sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:cellSizeHead lineBreakMode:NSLineBreakByWordWrapping].height;
        }
        if ((descriptionString==nil) || (descriptionString == (NSString *)[NSNull null]) || ([descriptionString isEqualToString:@""]))
        {
            slugLineheight = 0;
        }
        else
        {
            slugLineheight = [descriptionString sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:cellSizeSlug lineBreakMode:NSLineBreakByWordWrapping].height;
        }
    }
    
    return headlineheight+slugLineheight+100;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellOne";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *lblDate = nil;
    UILabel *lblTitle = nil;
    UILabel *lblslugLine = nil;
    UIImageView *newImageView = nil;
    
    
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
        lblDate = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, cellwidth-accwidth, 15)];
        lblDate.font = [UIFont systemFontOfSize:13];
        lblDate.textColor = [UIColor grayColor];
        lblDate.tag = 1;
        [cell.contentView addSubview:lblDate];
        
        lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 25, cellwidth-accwidth, 100)];
        lblTitle.font = [UIFont boldSystemFontOfSize:16];
        lblTitle.textColor = [UIColor blueColor];
        lblTitle.tag = 2;
        lblTitle.lineBreakMode = NSLineBreakByWordWrapping;
        lblTitle.numberOfLines = 3;
        [cell.contentView addSubview:lblTitle];
        
        
        NSString *urlString = [[self.news objectAtIndex:indexPath.row] objectForKey:@"imageHref"];
   
        lblslugLine = [[UILabel alloc] initWithFrame:CGRectMake(5, 80, cellwidth-accwidth-imagewidthadjust, 2000)];
        if ((urlString==nil) || (urlString == (NSString *)[NSNull null]) || ([urlString isEqualToString:@""]))
                                                                
        { lblslugLine.frame = CGRectMake(5, 80, cellwidth-accwidth, 2000); }
        
        lblslugLine.font = [UIFont systemFontOfSize:13];
        lblslugLine.textColor = [UIColor blackColor];
        lblslugLine.tag = 3;
        lblslugLine.lineBreakMode = NSLineBreakByWordWrapping;
        lblslugLine.numberOfLines = 30;
        if (SYSTEM_VERSION_GREATER_THAN(@"7.0"))
        { lblslugLine.textAlignment = NSTextAlignmentNatural; }
        else
        { lblslugLine.textAlignment = NSTextAlignmentLeft; }
        [cell.contentView addSubview:lblslugLine];
        
        newImageView = [[UIImageView alloc] initWithFrame:CGRectMake(cellwidth-imagewidthadjust, 80, 80, 45)];
        newImageView.tag = 4;
        [cell.contentView addSubview:newImageView];
    
    NSString *titleString = [[self.news objectAtIndex:indexPath.row] objectForKey:@"title"];
    NSString *descriptionString = [[self.news objectAtIndex:indexPath.row] objectForKey:@"description"];

    if ((titleString==nil) || (titleString == (NSString *)[NSNull null]) || ([titleString isEqualToString:@""]))
    {
        lblTitle.text = @"";
    }
    else
    {
        lblTitle.text = titleString;
    }
    
    if ((descriptionString==nil) || (descriptionString == (NSString *)[NSNull null]) || ([descriptionString isEqualToString:@""]))
    {
        lblslugLine.text = @"";
    }
    else
    {
        lblslugLine.text = descriptionString;
    }
    NSString *newurlString = [[self.news objectAtIndex:indexPath.row] objectForKey:@"imageHref"];
    
    //Calculate and adjust size of row
    float headlineheight;
    float slugLineheight;
    CGSize cellSizeHead = CGSizeMake(cellwidth-accwidth, 100);
    CGSize cellSizeSlug = CGSizeMake(cellwidth-accwidth-imagewidthadjust, 2000);
    if ((urlString==nil) || (urlString == (NSString *)[NSNull null]) || ([urlString isEqualToString:@""]))
    { cellSizeSlug = CGSizeMake(cellwidth-accwidth, 2000);}
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        if ((titleString==nil) || (titleString == (NSString *)[NSNull null]) || ([titleString isEqualToString:@""]))
        {
            headlineheight = 0;
        }
        else
        {
            headlineheight = [titleString
                              boundingRectWithSize:cellSizeHead
                              options:NSStringDrawingUsesLineFragmentOrigin
                              attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16]}
                              context:nil].size.height;
        }
        
        if ((descriptionString==nil) || (descriptionString == (NSString *)[NSNull null]) || ([descriptionString isEqualToString:@""]))
        {
            slugLineheight = 0;
        }
        else
        {
            slugLineheight = [descriptionString
                              boundingRectWithSize:cellSizeSlug
                              options:NSStringDrawingUsesLineFragmentOrigin
                              attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}
                              context:nil].size.height;
        }
        
    }
    else {
        if ((titleString==nil) || (titleString == (NSString *)[NSNull null]) || ([titleString isEqualToString:@""]))
        {
            headlineheight = 0;
        }
        else
        {
            headlineheight = [titleString sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:cellSizeHead lineBreakMode:NSLineBreakByWordWrapping].height;
        }
        if ((descriptionString==nil) || (descriptionString == (NSString *)[NSNull null]) || ([descriptionString isEqualToString:@""]))
        {
            slugLineheight = 0;
        }
        else
        {
            slugLineheight = [descriptionString sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:cellSizeSlug lineBreakMode:NSLineBreakByWordWrapping].height;
        }
    }
    
    CGRect titleFrame = lblTitle.frame;
    titleFrame.size.height = headlineheight;
    lblTitle.frame = titleFrame;
    
    CGRect slugLineFrame = lblslugLine.frame;
    slugLineFrame.size.height = slugLineheight;
    slugLineFrame.origin.y = lblTitle.frame.origin.y+headlineheight+10;
    lblslugLine.frame = slugLineFrame;
    
    CGRect newImageViewFrame = newImageView.frame;
    newImageViewFrame.origin.y = lblTitle.frame.origin.y+headlineheight+10;
    newImageView.frame = newImageViewFrame;
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = newImageView.center;
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.hidden = NO;
    [activityIndicator startAnimating];
    
    //Loading image lazily using SDWebImage
    if ((newurlString==nil) || (newurlString == (NSString *)[NSNull null]) || ([newurlString isEqualToString:@""]))
    {
        [activityIndicator stopAnimating]; [activityIndicator removeFromSuperview];
    }
    else
    {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",newurlString]];
        [newImageView setImageWithURL:url
                     placeholderImage:nil
                              success:^(UIImage *image, BOOL dummy) { [activityIndicator stopAnimating]; [activityIndicator removeFromSuperview]; }
                              failure:^(NSError *error) { [activityIndicator stopAnimating]; [activityIndicator removeFromSuperview];}
     ];

    }

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *urlstring = [NSString stringWithFormat:@"%@",[[self.news objectAtIndex:indexPath.row] objectForKey:@"imageHref"]];
    
    BrowserController *bvc = [[BrowserController alloc] initWithLoadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]]];
    [self.navigationController pushViewController:bvc animated:YES];
    [bvc release];
    
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation) fromInterfaceOrientation {
    
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    if (fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        cellwidth = screenWidth;
    } else if (fromInterfaceOrientation == UIInterfaceOrientationPortrait || fromInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        cellwidth = screenHeight;
    } else {
        cellwidth = screenHeight;
    }
    loadingView.center = _mainTableView.center;
    
    [_mainTableView reloadData];
}


-(void)startActivity:(id)sender{
    [self.view addSubview:loadingView];
    [activityView startAnimating];
}

-(void)stopActivity:(id)sender{
    [refreshControl endRefreshing];
    [activityView stopAnimating];
    [loadingView removeFromSuperview];
}



- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    [self stopActivity:nil];
    
    NSError* error = nil;
    NSJSONSerialization *jsondata = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    
    self.news = [jsondata valueForKey:@"items"];
    self.navigationItem.title = [jsondata valueForKey:@"name"];
    
    if (error)
    {
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Some Error occured. Please try again." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [errorView show];
    }
    
    [_mainTableView reloadData];

}


- (void)updateData
{
    
    Reachability * reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    if([reach isReachable])
    {
        [self startActivity:nil];
        
        //Connection URL Fairfax
        //NSURL *url = [NSURL URLWithString:@"http://mobilatr.mob.f2.com.au/services/views/9.json"];
        //Connection URL Telstra Dropbox
        //NSURL *url = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/746330/facts.json"];
        //Connection URL Telstra Other Server
        NSURL *url = [NSURL URLWithString:@"http://acanz.info/bhpbdemo/test.json"];
        
        
        NSLog(@"JSON API is %@",url);
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [connection start];

    }
    else
    {
        [self stopActivity:nil];
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Telstra" message:@"Please make sure you're connected to internet" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [errorView show];
    }
    
   }

#pragma mark - Retrieve data source and indicator

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData
{

    [data appendData:theData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    [self stopActivity:nil];
    
    NSError* error = nil;
    
    NSJSONSerialization *jsondata = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    self.news = [jsondata valueForKey:@"rows"];
    self.navigationItem.title = [jsondata valueForKey:@"title"];
    
    if (error)
    {
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Some Error occured. Please try again." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [errorView show];
    }
    
    [_mainTableView reloadData];
    
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self stopActivity:nil];
    UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Telstra" message:@"Please make sure you're connected to the internet." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [errorView show];
}





@end
