//
//  HomeViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 10/05/2023.
//

import UIKit
import NVActivityIndicatorView

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let titleCell = ["Photos", "Videos", "Audios", "Documents"]
    let imageCell = ["elipse-5", "elipse-6", "elipse-7", "elipse-8"]
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
        cell.alpha = 0.9
        return cell
    }
    

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "myCell")
                
                
        let margin: CGFloat = 13
        var marginTop: CGFloat = 13
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = margin
        layout.minimumInteritemSpacing = margin
        var sizeCell = (view.frame.size.width - 3 * margin) / 2 - 2
        if UIDevice.current.userInterfaceIdiom == .pad {
            sizeCell = (view.frame.size.width - 5 * margin) / 4 - 2
            marginTop = 150
            layout.sectionInset = UIEdgeInsets.init(top: marginTop, left: margin, bottom: margin, right: margin)
        }
                            
        layout.itemSize = CGSize(width: sizeCell, height: sizeCell)
        layout.sectionInset = UIEdgeInsets.init(top: marginTop, left: margin, bottom: margin, right: margin)
        collectionView.collectionViewLayout = layout
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.performSegue(withIdentifier: "photosSegue", sender: self)
            break
        case 1:
            self.performSegue(withIdentifier: "videosSegue", sender: self)
            break
        case 2:
            self.performSegue(withIdentifier: "audiosSegue", sender: self)
            break
        case 3:
            self.performSegue(withIdentifier: "documentsSegue", sender: self)
            break
        default:
            break
        }
    }

}
