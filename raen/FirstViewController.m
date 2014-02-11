//
//  FirstViewController.m
//  raen
//
//  Created by Alexey Ivanov on 13.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "FirstViewController.h"
#import "TVCell.h"
@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.tableView setDelegate:self];
    //[self.tableView setDataSource:self];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDatasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
/*
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSArray *sections = @[@"section1",@"section2"];
    return sections;
}
 */
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TVCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"tvCell"];
    cell.label.text = [NSString stringWithFormat:@"Новость %i в секции %i",indexPath.row,indexPath.section];
    
    return cell;
};


#pragma mark - UITableViewDelegate


@end
