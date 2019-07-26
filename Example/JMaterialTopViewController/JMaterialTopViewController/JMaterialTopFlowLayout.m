//
//  JMaterialTopFlowLayout.m
//  
//
//  Created by jun on 2019/6/15.
//  Copyright © 2019 jun. All rights reserved.
//

#import "JMaterialTopFlowLayout.h"

@implementation JMaterialTopFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing = 0;
    if (self.collectionView.bounds.size.height) {
        
        self.itemSize = self.collectionView.bounds.size;
    }
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}

@end
