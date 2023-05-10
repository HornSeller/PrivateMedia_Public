//
//  HomeViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 10/05/2023.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let titleCell = ["Photos", "Videos", "Audios", "Documents"]
    let imageCell = ["elipse-2", "elipse", "elipse-3", "elipse-4"]
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        titleCell.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! HomeCollectionViewCell
        cell.label.text = titleCell[indexPath.row]
        cell.imageView.image = UIImage(named: imageCell[indexPath.row])
        cell.layer.cornerRadius = 20 // Bo tròn viền cell
        cell.layer.borderWidth = 0.5 // Độ rộng của viền cell
//        cell.layer.borderColor = UIColor.lightGray.cgColor // Màu của viền cell
//        cell.layer.shadowColor = UIColor.darkGray.cgColor // Màu của đổ bóng cell
//        cell.layer.shadowOffset = CGSize(width: 2, height: 2) // Kích thước của đổ bóng cell
//        cell.layer.shadowOpacity = 0.3 // Độ đậm của đổ bóng cell
//        cell.layer.shadowRadius = 2.5 // Độ cong của đổ bóng cell
        cell.backgroundColor = .black
        return cell
    }
    

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "myCell")
                
                
                let margin: CGFloat = 13
                            let layout = UICollectionViewFlowLayout()
                            layout.scrollDirection = .vertical
                            layout.minimumLineSpacing = margin
                            layout.minimumInteritemSpacing = margin
                            var sizeCell = (view.frame.size.width - 3 * margin) / 2 - 2
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                sizeCell = (view.frame.size.width - 3 * margin) / 2 - 2
                            }
                            
                            layout.itemSize = CGSize(width: sizeCell, height: sizeCell)
                            layout.sectionInset = UIEdgeInsets.init(top: margin, left: margin, bottom: margin, right: margin)
                collectionView.collectionViewLayout = layout
    }
    


}
