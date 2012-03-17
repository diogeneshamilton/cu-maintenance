#import "MainViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface MainViewController ()

@end

@implementation MainViewController

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
    
//    BackgroundBrowserViewController *backgroundVC = [[BackgroundBrowserViewController alloc] initWithImage:imageToSave];
    //    ImageBrowserViewController *imageBrowserVC = [[ImageBrowserViewController alloc] initWithImage:imageToSave];
    
    
//    [self.navigationController pushViewController:backgroundVC animated:YES];   
}

@end
