#import "Tweak.h"

%hook FirstViewController
  %property (nonatomic, retain) UITextField *searchBox;
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

    // Sort apps alphabetically.
    newAppsList = [[newAppsList sortedArrayUsingComparator:^(RPVApplication* obj1, RPVApplication* obj2) {
      return [[obj1 applicationName] compare:[obj2 applicationName]];
    }] mutableCopy];
    MSHookIvar<NSMutableArray *>(self, "newAppsList") = newAppsList;
    self.allAppList = [newAppsList ?: @[] mutableCopy];
    self.searchBox.placeholder = @"Search for app name";
  }

  %new
  - (void)searchBoxTextFieldDidChange:(UITextField *)sender {
    NSString *keyword = [self.searchBox.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([keyword length] == 0) {
      MSHookIvar<NSMutableArray *>(self, "newAppsList") = self.allAppList;
      [self.tableView reloadData];
      return;
    }

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
