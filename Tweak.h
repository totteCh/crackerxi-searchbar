#import <Foundation/Foundation.h>
#import <libhdev/HUtilities/HCommon.h>

@interface RPVApplication : NSObject
- (NSString *)applicationName;
@end

@interface FirstViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (nonatomic) UITableView *tableView;
@property (nonatomic, retain) UITextField *searchBox;
@property (nonatomic, retain) NSTimer *searchTimer;
@property (nonatomic, retain) NSMutableArray *allAppList;
@end