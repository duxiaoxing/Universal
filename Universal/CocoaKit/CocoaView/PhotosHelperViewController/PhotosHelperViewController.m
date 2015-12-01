//
//  PhotosHelperViewController.m
//  Demo
//
//  Created by 杜晓星 on 15/12/1.
//  Copyright © 2015年 杜晓星. All rights reserved.
//

#import "PhotosHelperViewController.h"

#import "PhotosHelperCollectionViewCell.h"
#import "CameraCollectionViewCell.h"
#import "SelectedPhotoCollectionViewCellLayout.h"
#import "SelectedPhotoCollectionViewCell.h"


#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotosHelperViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *selectedContentView;
@property (weak, nonatomic) IBOutlet UIButton *finishSeletedButton;

@property(nonatomic,strong) NSMutableArray  *sourceArray;

@property(nonatomic,strong) NSMutableArray  *selectedArray;

@property (weak, nonatomic) IBOutlet UICollectionView *sourceCollectionView;

@property (weak, nonatomic) IBOutlet UICollectionView *selectedCollectionView;

@property(nonatomic,strong)UIImagePickerController *cameraPickerController;

@property(nonatomic,assign)NSInteger photosTotalCount;


@end

@implementation PhotosHelperViewController

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
 
    [super viewDidLoad];
    if (_selectMax == 0) {
        _selectMax = 3 ;
    }
    self.cameraPickerController = [self buildCameraPickerController];
    [_sourceCollectionView registerNib:[UINib nibWithNibName:@"CameraCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CameraCollectionViewCell"];
    [_sourceCollectionView registerNib:[UINib nibWithNibName:@"PhotosHelperCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"PhotosHelperCollectionViewCell"];
    [_selectedCollectionView registerNib:[UINib nibWithNibName:@"SelectedPhotoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"SelectedPhotoCollectionViewCell"];
    
    _sourceCollectionView.collectionViewLayout = [self photoCollectionFlowLayout];
    _selectedCollectionView.collectionViewLayout = [[SelectedPhotoCollectionViewCellLayout alloc]init];

    _sourceArray = [NSMutableArray array];
    _selectedArray = [NSMutableArray array];
    
    [self readALAssetsLibrary];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == _sourceCollectionView) {
        return _sourceArray.count + 1;
    }
    else if(collectionView == _selectedCollectionView)
    {
        return _selectedArray.count;
    }
    else
    {
        return 0 ;
    }
    
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *temCell = nil ;
    
    if (collectionView == _sourceCollectionView) {
        if (indexPath.row == 0) {
            CameraCollectionViewCell *cell = (CameraCollectionViewCell*)[self __collectionView:_sourceCollectionView cellWithIndex:indexPath];
            temCell = cell;
        }
        else
        {   PhotosHelperCollectionViewCell *cell = (PhotosHelperCollectionViewCell*)[self __collectionView:_sourceCollectionView cellWithIndex:indexPath];
            temCell = cell;
            [cell cellWithSource:_sourceArray[indexPath.row - 1]];
        }
    }
    else if (collectionView == _selectedCollectionView)
    {
        SelectedPhotoCollectionViewCell *cell = (SelectedPhotoCollectionViewCell*)[self __collectionView:_selectedCollectionView cellWithIndex:indexPath];
        temCell = cell;
        cell.model = _selectedArray[indexPath.row];
    }
    else
    {
        return temCell;
    }
    
    return temCell ;
}

- (UICollectionViewFlowLayout*)photoCollectionFlowLayout
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    
    CGFloat screenWidth =   CGRectGetWidth([UIScreen mainScreen].bounds) ;
    
    CGFloat itemWidth = (screenWidth - 4*5)/3;
    layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    
    return layout;
}

- (void)readALAssetsLibrary
{
     ALAssetsLibrary *assetsLibrary=[[ALAssetsLibrary alloc]init];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            UIImage *image=[UIImage imageWithCGImage:result.thumbnail];
            if (image) {
                
                @autoreleasepool {
                    PhotosHelperCollectionViewCellModel *model = [[PhotosHelperCollectionViewCellModel alloc]init];
                    model.image = image;
                    model.selected = NO;
                    [_sourceArray addObject:model];
                }
                  if (index == 0) {
                    [self reloadCollectionView];
                }
            }
          }];

    } failureBlock:^(NSError *error) {

    }];
}
- (UIImagePickerController*)buildCameraPickerController
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    UIImagePickerController *imgPickerController = [[UIImagePickerController alloc] init];
    imgPickerController.delegate = self;
    imgPickerController.allowsEditing = YES;
    imgPickerController.sourceType = sourceType;
    
    return imgPickerController;

}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (collectionView == _sourceCollectionView) {

        UICollectionViewCell *cell = [self __collectionView:collectionView cellWithIndex:indexPath];
        if ([cell isKindOfClass:[CameraCollectionViewCell class]]) {
            
            if ([self beyondLimted]) {
                
                NSLog(@"当前已经选择%ld张,最大可以选择%ld张",_selectedArray.count,_selectMax);
                
                return ;
            }
            else
            {
                [self presentViewController:self.cameraPickerController animated:YES completion:nil];
            }
        }
        else
        {
            PhotosHelperCollectionViewCellModel *model = _sourceArray[indexPath.row - 1];
            if ([_selectedArray containsObject:model]) {
                model.selected = !model.selected ;
                if (model.selected == NO) {
                    [_selectedArray removeObject:model];
                }
            }
            else
            {
                if ([self beyondLimted]) {
                    
                    NSLog(@"当前已经选择%ld张,最大可以选择%ld张",_selectedArray.count,_selectMax);
                    
                    return ;
                }
                else
                {   model.selected = !model.selected ;
                    [_selectedArray addObject:model];
                }
            }
            [self reloadCollectionView];
            
            _finishSeletedButton.titleLabel.text = [NSString stringWithFormat:@"完成(%ld/%ld)",_selectedArray.count,_selectMax];
        }
    }
    else
    {
        
    }
}

- (void)reloadCollectionView
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_sourceCollectionView reloadData];
    });
    
    [_selectedCollectionView reloadData];
}

- (BOOL)beyondLimted
{
    if (_selectedArray.count >= _selectMax) {
        
        return YES;
    }
    else
    {
        return NO ;
    }
}

- (UICollectionViewCell*)__collectionView:(UICollectionView*)collectionView cellWithIndex:(NSIndexPath*)indexPath
{
    if (collectionView == _sourceCollectionView) {
        if (indexPath.row == 0) {
             return [collectionView dequeueReusableCellWithReuseIdentifier:@"CameraCollectionViewCell" forIndexPath:indexPath];
        }
        else
        {
            return  [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotosHelperCollectionViewCell" forIndexPath:indexPath];
        }
    }
    else if (collectionView == _selectedCollectionView)
    {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectedPhotoCollectionViewCell" forIndexPath:indexPath];
    }
    else
    {
        return nil;
    }
 
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    PhotosHelperCollectionViewCellModel *model = [[PhotosHelperCollectionViewCellModel alloc]init];
    model.image = image;
 
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    });
    
    model.selected = YES;
    [_selectedArray addObject:model];
    [_sourceArray insertObject:model atIndex:0];
    [self reloadCollectionView];
    
    _finishSeletedButton.titleLabel.text = [NSString stringWithFormat:@"完成(%ld/%ld)",_selectedArray.count,_selectMax];
    
    
    [self dismissCameraPickerViewControllerWithDelay:0];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissCameraPickerViewControllerWithDelay:0];
}

- (void)dismissCameraPickerViewControllerWithDelay:(NSTimeInterval)timer
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timer * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.cameraPickerController dismissViewControllerAnimated:YES completion:nil];
     });

}

- (IBAction)finishButtonClick:(id)sender {
    if ([_delegate respondsToSelector:@selector(didSelectedImageArray:)]) {
        [_delegate didSelectedImageArray:_selectedArray];
    }
}

@end