#import "Tweak.h"

%hook FirstViewController
  %property (nonatomic, retain) UITextField *searchBox;
  %property (nonatomic, retain) NSTimer *searchTimer;
  %property (nonatomic, retain) NSMutableArray *allAppList;

  - (void)viewDidLoad {
    %orig;

    self.searchBox = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width - 55, 40)];
    self.searchBox.borderStyle = UITextBorderStyleRoundedRect;
    self.searchBox.font = [UIFont systemFontOfSize:15];
    self.searchBox.placeholder = @"Loading...";
    self.searchBox.keyboardType = UIKeyboardTypeDefault;
    self.searchBox.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBox.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.searchBox.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.searchBox.leftViewMode = UITextFieldViewModeAlways;
    self.searchBox.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search"]];
    [self.searchBox addTarget:self action:@selector(searchBoxTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.searchBox.delegate = self;

    [self.navigationController.navigationBar addSubview:self.searchBox];
  }

  - (void)getInstalledApplist {
    %orig;

    NSMutableArray *newAppsList = MSHookIvar<NSMutableArray *>(self, "newAppsList");
    
    if (!newAppsList || !newAppsList.count) {
      MSHookIvar<NSMutableArray *>(self, "newAppsList") = [@[] mutableCopy];
      self.allAppList = [@[] mutableCopy];
      self.searchBox.placeholder = @"Error...";
      return;
    }

    self.allAppList = [newAppsList ?: @[] mutableCopy];
    self.searchBox.placeholder = @"Search for app name";
  }

  %new
  - (void)searchBoxTextFieldDidChange:(UITextField *)sender {
    if (self.searchTimer != nil) {
      [self.searchTimer invalidate];
      self.searchTimer = nil;
    }

    NSString *keyword = [self.searchBox.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([keyword length] == 0) {
      MSHookIvar<NSMutableArray *>(self, "newAppsList") = self.allAppList;
      [self.tableView reloadData];
      return;
    }

    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(searchTimerEnd:) userInfo:keyword repeats:NO];
  }

  %new
  - (void)searchTimerEnd:(NSTimer *)timer {
    NSString *keyword = (NSString*)timer.userInfo;
    NSMutableArray *result = [@[] mutableCopy];

    if (!self.allAppList || !self.allAppList.count) {
      return;
    }

    for (RPVApplication *app in self.allAppList) {
      NSString *appName = [[app applicationName] stringByReplacingOccurrencesOfString:@" " withString:@""];
      if ([appName rangeOfString:keyword options:NSCaseInsensitiveSearch].location != NSNotFound) {
        [result addObject:app];
      }
    }

    MSHookIvar<NSMutableArray *>(self, "newAppsList") = result;
    [self.tableView reloadData];
  }
%end
