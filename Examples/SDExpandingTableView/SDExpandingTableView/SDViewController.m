//
//  SDViewController.m
//  SDExpandingTableView
//
//  Created by ricky cancro on 4/23/14.
//  Copyright (c) 2014 SetDirection. All rights reserved.

#import "SDViewController.h"
#import "SDExpandingTableViewController.h"

static NSString const *kIdKey = @"identifier";
static NSString const *kDataKey = @"data";

@interface NSString(SDExpandingTableViewColumnDelegate)<SDExpandingTableViewColumnDelegate>
- (NSString *)identifier;
@end

@implementation NSString(SDExpandingTableViewColumnDelegate)

- (NSString *)identifier
{
    return self;
}

@end

@interface SDViewController ()<SDExpandingTableViewControllerDataSource, SDExpandingTableViewControllerDelegate>
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSDictionary *level0;
@property (strong, nonatomic) IBOutlet UILabel *label;

@property (nonatomic, strong) NSDictionary *level1;
@property (nonatomic, strong) NSDictionary *level2;

@property (nonatomic, strong) NSMutableDictionary *menuData;

@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) SDExpandingTableViewController *expandingVC;
@end

@implementation SDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Note: this data setup is not ideal because as the logic will fail when a there are duplicate entries.  For example, the alubm "A Hard Day's Night" also contains a song called "A Hard Day's night"
    self.menuData = [NSMutableDictionary dictionary];
    // bands
    self.menuData[@"root"] = @[@"The Beatles", @"The Idle Race", @"The Zombies"];
    
    // albums
    self.menuData[@"The Beatles"] = @[@"A Hard Day's Night", @"Rubber Soul", @"Revolver"];
    self.menuData[@"The Idle Race"] = @[@"Birthday"];
    self.menuData[@"The Zombies"] = @[@"Odessey and Oracle", @"I Love you"];
    
    // beatles albums
    self.menuData[@"A Hard Day's Night"] = @[@"A Hard Day's Night.",@"I Should Have Known Better",@"If I Fell",@"I'm Happy Just To Dance With You",@"And I Love Her",@"Tell Me Why",@"Can't Buy Me Love",@"Any Time At All",@"I'll Cry Instead",@"Things We Said Today",@"When I Get Home",@"You Can't Do That",@"I'll Be Back"];
    self.menuData[@"Rubber Soul"] = @[@"Drive My Car",@"Norwegian Wood (This Bird Has Flown)",@"You Won't See Me",@"Nowhere Man",@"Think For Yourself",@"The Word",@"Michelle",@"What Goes On",@"Girl",@"I'm Looking Through You",@"In My Life",@"Wait",@"If I Needed Someone",@"Run For Your Life"];
    self.menuData[@"Revolver"] = @[@"Taxman",@"Eleanor Rigby",@"I'm Only Sleeping",@"Love You To/Here, There And Everywhere",@"Yellow Submarine",@"She Said She Said",@"Good Day Sunshine",@"And Your Bird Can Sing",@"For No One",@"Doctor Robert",@"I Want To Tell You",@"Got To Get You Into My Life",@"Tomorrow Never Knows"];
    
    // zombie albums
    self.menuData[@"Odessey and Oracle"] = @[@"]Care of Cell",@"A Rose for Emily", @"Maybe After He's Gone", @"Beechwood Park", @"Brief Candles", @"Hung Up on a Dream",@"Changes", @"I Want Her, She Wants Me", @"This Will Be Our Year", @"Butcher's Tale (Western Front 1914)", @"Friends of Mine", @"Time of the Season"];
    self.menuData[@"I Love you"] = @[@"The Way I Feel Inside",@"How We Were Before",@"Is This The Dream",@"Whenever You're Ready",@"Woman",@"You Make Me Feel Good",@"Gotta Get A Hold Of Myself",@"Indication",@"Don't Go Away",@"I Love You.", @"Leave Me Be",@"She's Not There"];
    
    // idle race album
    self.menuData[@"Birthday"] = @[@"Skeleton And The Roundabout",@"Happy Birthday (Instrumental)",@"Birthday.",@"I Like My Toys",@"Morning Sunshine",@"Follow Me Follow",@"Sitting In My Tree",@"On With The Show",@"Lucky Man",@"Mrs. Ward",@"Pie In The Sky",@"Lady Who Said She Could Fly",@"End Of The Road"];

    self.menuData[@"A Hard Day's Night."] = @[@"John"];
    self.menuData[@"John"] = @[@"Paul"];
    self.menuData[@"Paul"] = @[@"George"];
    self.menuData[@"George"] = @[@"Ringo"];
    
    
    self.label.preferredMaxLayoutWidth = self.view.frame.size.width - 20;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)tapMeAction:(id)sender
{
    self.expandingVC = [[SDExpandingTableViewController alloc] initWithTableViewStyle:UITableViewStylePlain];
    self.expandingVC.dataSource = self;
    self.expandingVC.delegate = self;
    
    [self.expandingVC presentFromBarButtonItem:self.navigationItem.leftBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

#pragma mark - SDExpandingTableViewControllerDataSource
- (id<SDExpandingTableViewColumnDelegate>)rootColumnIdentifier
{
    return @"root";
}

- (void)setupTableView:(UITableView *)tableView forColumn:(id<SDExpandingTableViewColumnDelegate>)column
{
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath inColumn:(id<SDExpandingTableViewColumnDelegate>)column forTableView:(UITableView *)tableView
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NSArray *data = self.menuData[column.identifier];
    NSString *item = [data objectAtIndex:indexPath.row];
    cell.textLabel.text = item;
    return cell;
}

- (NSInteger)numberOfSectionsInColumn:(id<SDExpandingTableViewColumnDelegate>)table
{
    return 1;
}

- (NSInteger)numberOfRowsInColumn:(id<SDExpandingTableViewColumnDelegate>)column section:(NSInteger)section
{
    NSArray *data = self.menuData[column.identifier];
    return [data count];
}

#pragma mark - SDExpandingTableViewControllerDelegate

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath inColumn:(id<SDExpandingTableViewColumnDelegate>)column forTableView:(UITableView *)tableView
{
    NSArray *data = self.menuData[column.identifier];
    if ([data count] > indexPath.row)
    {
        NSString *columnId = data[indexPath.row];
        
        // make sure there is more data coming
        if (nil == self.menuData[columnId])
        {
            [self.expandingVC dismissAnimated:YES];
            if ([[columnId identifier] isEqualToString:@"Ringo"])
            {
                self.label.text = [NSString stringWithFormat:@"you chose %@.  you have questionable taste.", columnId];
            }
            else
            {
                self.label.text = [NSString stringWithFormat:@"you chose %@.  you have fine taste.", columnId];
            }
        }
        else
        {
            [self.expandingVC navigateToColumn:columnId fromParentColumn:column animated:YES];
        }
    }
}

- (void)didDismissExpandingTables
{
    [self.expandingVC removeFromParentViewController];
    [self.expandingVC.view removeFromSuperview];
    self.expandingVC = nil;
}

@end
