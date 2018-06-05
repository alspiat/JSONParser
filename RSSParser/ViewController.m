//
//  ViewController.m
//  RSSParser
//
//  Created by Алексей on 05.06.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSMutableArray<NSString*> *currencyArray;
@property (retain, nonatomic) NSMutableArray<NSString*> *ratesArray;
@property (retain, nonatomic) NSURLSession *urlSession;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    _currencyArray = [[NSMutableArray alloc] init];
    _ratesArray = [[NSMutableArray alloc] init];
    
    NSURLSessionConfiguration *sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration;
    sessionConfiguration.URLCache = nil;
    sessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    _urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    [self fetchData];
}

- (IBAction)refreshButtonAction:(UIBarButtonItem *)sender {
    [self cleanData];
    [self fetchData];
}

-(void)cleanData {
    [_ratesArray removeAllObjects];
    [_currencyArray removeAllObjects];
    
    [self.tableView reloadData];
}

-(void)fetchData {
    
    [self.activityIndicator startAnimating];
    
    NSURL *url = [NSURL URLWithString:@"https://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json"];
    
    [[self.urlSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (data != nil) {
                NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
                
                NSDictionary *list = [jsonDictionary objectForKey:@"list"];
                NSArray *resources = [list objectForKey:@"resources"];
                
                for (NSDictionary *resource in resources) {
                    NSDictionary *data = [resource objectForKey:@"resource"];
                    NSDictionary *fields = [data objectForKey:@"fields"];
                    NSString *symbol = [fields objectForKey:@"symbol"];
                    NSString *rate = [fields objectForKey:@"price"];
                    
                    NSString *currencyName = [symbol substringToIndex:3];
                    
                    if (currencyName != nil && rate != nil) {
                        [self.currencyArray addObject:currencyName];
                        [self.ratesArray addObject:rate];
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [self.activityIndicator stopAnimating];
                });
            }
        });
    }] resume];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currencyArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = [self.currencyArray objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [self.ratesArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
