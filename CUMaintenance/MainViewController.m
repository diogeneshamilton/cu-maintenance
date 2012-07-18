#import "MainViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>
#import "QMultilineElement.h"
#import "QMultilineTextViewController.h"

#import "MaintenanceDialog.h"

@interface MainViewController () 

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *deviceLocation;



@end

@implementation MainViewController

@synthesize locationManager;
@synthesize deviceLocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Welcome";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *submitButton = [[UIButton alloc] initWithFrame:CGRectMake(110.0f, 100.0f, 100.0f, 20.0f)];
    [submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    submitButton.backgroundColor = [UIColor blueColor];
    
    [submitButton addTarget:self action:@selector(submitAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *viewExistingButton = [[UIButton alloc] initWithFrame:CGRectMake(60.0f, 200.0f, 200.0f, 20.0f)];
    [viewExistingButton setTitle:@"View Current Problems" forState:UIControlStateNormal];
    viewExistingButton.backgroundColor = [UIColor redColor];
    
    [viewExistingButton addTarget:self action:@selector(loadWebsite) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:submitButton];
    [self.view addSubview:viewExistingButton];
    [self startUpdatingLocation];

}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Main Control Actions

- (void)submitAction {
    UIActionSheet *submitActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take A Picture", @"Use From Library", nil];
    
    [submitActionSheet showInView:self.view];
}

- (void)loadWebsite {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://cu-maintenance.tumblr.com"]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self takePicture];
    }
    else if (buttonIndex == 1) {
        [self loadPicture];
    }
}

#pragma mark - Image Loading Methods

- (void)loadPicture {
    [self startCameraControllerFromViewController:self usingDelegate:self mode:UIImagePickerControllerSourceTypePhotoLibrary];
    
}

- (void)takePicture {
    [self startCameraControllerFromViewController:self usingDelegate:self mode:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate mode:(UIImagePickerControllerSourceType)mode {
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) 
        || (delegate == nil) || (controller == nil)) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = mode;
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        
        // Save the new image (original or edited) to the Camera Roll, if it was taken by camera.
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
        }
        
        
    }
    
    [picker dismissModalViewControllerAnimated: YES];
    
    QRootElement *root = [[QRootElement alloc] init];
    root.title = @"Maintenance Request";
    root.grouped = YES;
    root.controllerName = @"MaintenanceDialog";
    
    QSection *section = [[QSection alloc] init];
    QSection *submitSection = [[QSection alloc] init];

    QMapElement *mapField = [[QMapElement alloc] initWithTitle:@"Location" coordinate:CLLocationCoordinate2DMake(deviceLocation.coordinate.latitude, deviceLocation.coordinate.longitude)];
    QEntryElement *UNIField = [[QEntryElement alloc] initWithTitle:@"UNI" Value:nil];
    QEntryElement *roomFloorField = [[QEntryElement alloc] initWithTitle:@"Room/Floor" Value:nil];
    QMultilineElement *description = [[QMultilineElement alloc] initWithTitle:@"Description" Value:nil];
    QButtonElement *submitPostButton = [[QButtonElement alloc] initWithTitle:@"Submit" Value:@"Post"];
    
    [section addElement:UNIField];
    [section addElement:roomFloorField];
    [section addElement:description];
    [section addElement:mapField];
    
    [submitSection addElement:submitPostButton];
    
    [root addSection:section];
    [root addSection:submitSection];
    
    submitPostButton.controllerAction = @"getUnauthorizedToken";
    
    MaintenanceDialog *formController = [QuickDialogController controllerForRoot:root];
    [self.navigationController pushViewController:formController animated:YES];
}

#pragma mark - CLLocationDelegate

- (void)startUpdatingLocation {
    UIAlertView *noLocationAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" 
                                                              message:@"Location services are turned off. Go to Settings to enable them." 
                                                             delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
    if ([CLLocationManager locationServicesEnabled]) {
        if([CLLocationManager authorizationStatus] != 3) {
            NSLog(@"auth status is %o", [CLLocationManager authorizationStatus]);
            [noLocationAlert show];
        }
    }
    else {[noLocationAlert show];}
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];

}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if (!oldLocation) {
        self.deviceLocation = newLocation;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // TODO: Test on iOS 4
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
    }
}

@end
