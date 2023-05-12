//
//  PhotosViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 10/05/2023.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    var defaultValue = ["listPhotosAlbum": []]
    let userDefault = UserDefaults.standard
    
    let fileManager = FileManager.default
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dataCollectionView = userDefault.stringArray(forKey: "listPhotosAlbum")
        return dataCollectionView!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! PhotosCollectionViewCell
        let dataCollectionView = userDefault.stringArray(forKey: "listPhotosAlbum")
        cell.titleLb.text = dataCollectionView![indexPath.row]
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let photosUrl = documentsUrl!.appendingPathComponent("Photos")
        let albumUrl = photosUrl.appendingPathComponent(dataCollectionView![indexPath.row])
        do {
            var fileList = try fileManager.contentsOfDirectory(atPath: albumUrl.path)
            cell.countLb.text = String(fileList.count)
            if fileList.count == 0 {
                cell.imageView.image = UIImage(named: "1")
            }
            else {
                fileList.sort { (lhs: String, rhs: String) -> Bool in
                    return lhs < rhs
                }
                let firstImage = albumUrl.appendingPathComponent(fileList[0])
                cell.imageView.image = UIImage(contentsOfFile: firstImage.path)
            }
        } catch {
            print(error.localizedDescription)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nameArray = userDefault.stringArray(forKey: "listPhotosAlbum")
        let name = nameArray![indexPath.row]
        self.navigationController?.pushViewController(SubPhotosViewController.makeSelf(name: name), animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //userDefault.removeObject(forKey: "listPhotosAlbum")
        // tạo folder Photos tại lần đầu tiên sử dụng app
        guard let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let photosURL = documentURL.appendingPathComponent("Photos")
        
        if !self.fileManager.fileExists(atPath: photosURL.path) {
            do {
                try self.fileManager.createDirectory(atPath: photosURL.path, withIntermediateDirectories: true, attributes: nil)
                let documentPath = photosURL.path
                print("Path to pictures directory: \(documentPath)")
            } catch {
                print("Error creating directory: \(error)")
            }
        }
        //
        
        userDefault.register(defaults: defaultValue)
        self.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
                ]
        
        collectionView.register(UINib(nibName: "PhotosCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "myCell")
        
        let margin: CGFloat = 10
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = margin
        layout.minimumInteritemSpacing = 1
        var sizeCell = (view.frame.size.width - 4 * margin) / 3 - 2
        if UIDevice.current.userInterfaceIdiom == .pad {
            sizeCell = (view.frame.size.width - 5 * margin) / 4 - 2
        }
                    
        layout.itemSize = CGSize(width: sizeCell, height: sizeCell + 56)
        layout.sectionInset = UIEdgeInsets.init(top: margin, left: margin, bottom: margin, right: margin)
        collectionView.collectionViewLayout = layout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func createAlbumBtnTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Create album", message: "", preferredStyle: .alert)
        alert.addTextField(){ (textfield) in
            textfield.placeholder = "Enter album name here"
        }
        alert.addAction(UIAlertAction(title: "Create", style: .cancel, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            guard let fileNames = self.userDefault.stringArray(forKey: "listPhotosAlbum") else {
                return
            }
            
            for fileName in fileNames {
                if textField?.text == fileName {
                   let alert = UIAlertController(title: "Error", message: "Album has existed", preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                   self.present(alert, animated: true)
                   return
                   }
            }
            
            var dataUserdefault = self.userDefault.stringArray(forKey: "listPhotosAlbum")
            dataUserdefault?.append((textField?.text)!)
            self.userDefault.set(dataUserdefault, forKey: "listPhotosAlbum")
            
            guard let fileNames = self.userDefault.stringArray(forKey: "listPhotosAlbum") else {
                return
            }
            
            guard let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            
            let photosURL = documentURL.appendingPathComponent("Photos")
            for fileName in fileNames {
                let fileURL = photosURL.appendingPathComponent(fileName).path
                if !self.fileManager.fileExists(atPath: fileURL) {
                    do {
                        try self.fileManager.createDirectory(atPath: fileURL, withIntermediateDirectories: true, attributes: nil)
                        let documentPath = documentURL.path
                        print("Path to pictures directory: \(documentPath)")
                    } catch {
                        print("Error creating directory: \(error)")
                    }
                }
            }
            
            self.collectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        
        self.present(alert, animated: true)
    }
    
}
