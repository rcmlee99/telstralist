//
//  ListViewController.h
//  TableListView
//
//  Created by Roger Chee Meng Lee on 24/02/14.
//  Copyright (c) 2014. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

{
    UITableView *mainTableView;
    NSMutableData *data;
    NSArray *news;
    
    UIActivityIndicatorView *activityView;
    UIView *loadingView;
    UILabel *loadingLabel;
    
    UIRefreshControl *refreshControl;
    
  
}

@property (nonatomic, retain) NSArray* news;
@property (nonatomic, retain) UITableView *mainTableView;

@property (nonatomic, retain) UIActivityIndicatorView * activityView;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UILabel *loadingLabel;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end
