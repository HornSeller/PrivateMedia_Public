//
//  PhotosViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 10/05/2023.
//

import UIKit
import Kingfisher

class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var toolBarImgView: UIImageView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var renameBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    enum Mode {
        case view
        case select
    }
    var defaultValue = ["listPhotosAlbum": []]
    let userDefault = UserDefaults.standard
    
    let fileManager = FileManager.default
    
    var selectBarButton: UIBarButtonItem!
    
    var mMode: Mode = .view {
        didSet {
            switch mMode {
            case .view:
                selectBarButton.title = "Select"
                collectionView.allowsMultipleSelection = false
                addBtn.isHidden = false
                toolBarImgView.isHidden = true
                deleteBtn.isHidden = true
                shareBtn.isHidden = true
                renameBtn.isHidden = true
            case .select:
                selectBarButton.title = "Cancel"
                collectionView.allowsMultipleSelection = true
                addBtn.isHidden = true
                toolBarImgView.isHidden = false
                deleteBtn.isHidden = false
                shareBtn.isHidden = false
                renameBtn.isHidden = false
            }
        }
    }
    
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
                let lastImage = albumUrl.appendingPathComponent(fileList[fileList.count - 1])
                cell.imageView.image = UIImage(contentsOfFile: lastImage.path)
            }
        } catch {
            print(error.localizedDescription)
        }
        
//        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
//        cell.addGestureRecognizer(longPressRecognizer)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nameArray = userDefault.stringArray(forKey: "listPhotosAlbum")
        let name = nameArray![indexPath.row]
        
        switch mMode {
        case .view:
            self.navigationController?.pushViewController(SubPhotosViewController.makeSelf(name: name), animated: true)
        case .select:
            break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //userDefault.removeObject(forKey: "listPhotosAlbum")
        
        selectBarButton = {
            let barButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectBtnTapped(_:)))
            barButtonItem.tintColor = .white
            return barButtonItem
        }()
        
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
        navigationItem.rightBarButtonItem = selectBarButton
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
    
    @objc func selectBtnTapped(_ sender: UIBarButtonItem) {
        mMode = mMode == .view ? .select : .view
        collectionView.reloadData()
    }
    
//    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
//        if gestureRecognizer.state == .began {
//            guard let cell = gestureRecognizer.view as? PhotosCollectionViewCell else {
//                return
//            }
//            let touchPoint = gestureRecognizer.location(in: collectionView)
//
//            // Tìm indexPath của ô (cell) tại điểm chạm
//            if let indexPath = collectionView.indexPathForItem(at: touchPoint) {
//                if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionViewCell {
//                    cell.isSelected = true
//                    cell.backgroundColor = .red
//                }
//            }
//            collectionView.allowsMultipleSelection = true
//        }
//    }
    
    func toggleSelectionForCell(at indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotosCollectionViewCell {
            cell.isSelected = !cell.isSelected
        }
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func deleteBtnTapped(_ sender: UIButton) {
        var dataCollectionView = userDefault.stringArray(forKey: "listPhotosAlbum")
        guard let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        var indexArr: [Int] = []
        let photosURL = documentURL.appendingPathComponent("Photos")
        
        if let selectedCell = collectionView.indexPathsForSelectedItems {
            for indexPath in selectedCell.reversed() {
                indexArr.append(indexPath.row)
                print(indexPath.row)
            }
                    
            indexArr.sort(by: >)
            
            if indexArr.count == 0 {
                let alert = UIAlertController(title: "Please choose at least 1 Album to delete", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
            }
            
            let alert = UIAlertController(title: "Do you really want to delete \(indexArr.count) Album(s)?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .cancel, handler: { (_) in
                for index in indexArr {
                    let albumUrl = photosURL.appendingPathComponent(dataCollectionView![index])
                    do {
                        try self.fileManager.removeItem(at: albumUrl)
                        dataCollectionView?.remove(at: index)
                    } catch {
                        print("Error deleting video: \(error)")
                    }
                }
                
                self.userDefault.setValue(dataCollectionView, forKey: "listPhotosAlbum")
                self.collectionView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .destructive))
            
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func shareBtnTapped(_ sender: UIButton) {
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let photosUrl = documentsUrl!.appendingPathComponent("Photos")
        let albumsName: [String] = userDefault.stringArray(forKey: "listPhotosAlbum")!
        var selectedAlbums: [String] = []
        var filesToShare: [Any] = []
        if let selectedCell = collectionView.indexPathsForSelectedItems {
            for indexPath in selectedCell {
                selectedAlbums.append(albumsName[indexPath.row])
            }
            for selectedAlbum in selectedAlbums {
                do {
                    let selectedAlbumUrl = photosUrl.appendingPathComponent(selectedAlbum)
                    let imagesName = try fileManager.contentsOfDirectory(atPath: selectedAlbumUrl.path)
                    for imageName in imagesName {
                        filesToShare.append(selectedAlbumUrl.appendingPathComponent(imageName))
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
            let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func renameBtnTapped(_ sender: UIButton) {
        var dataCollectionView = userDefault.stringArray(forKey: "listPhotosAlbum")
        let selectedCells = collectionView.indexPathsForSelectedItems
        if selectedCells?.count == 0 {
            let alert = UIAlertController(title: "Please choose 1 Album to rename", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        else if selectedCells!.count > 1 {
            let alert = UIAlertController(title: "Please choose only 1 Album to rename", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        else {
            let selectedCell = selectedCells![0]
            let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            let photosUrl = documentsUrl!.appendingPathComponent("Photos")
            let oldFolderUrl = photosUrl.appendingPathComponent(dataCollectionView![selectedCell.row])
            let alert = UIAlertController(title: "Enter the new name", message: nil, preferredStyle: .alert)
            alert.addTextField()
            alert.addAction(UIAlertAction(title: "Rename", style: .cancel, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
                if textField?.text == "" {
                    let alert = UIAlertController(title: "Error", message: "Please enter album name", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                    self.present(alert, animated: true)
                    return
                }
                let newFolderUrl = photosUrl.appendingPathComponent(textField!.text!)
                do {
                    try self.fileManager.moveItem(at: oldFolderUrl, to: newFolderUrl)
                } catch {
                    print(error.localizedDescription)
                }
                dataCollectionView![selectedCell.row] = (textField?.text)!
                self.userDefault.set(dataCollectionView, forKey: "listPhotosAlbum")
                self.collectionView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
            present(alert, animated: true)
        }
    }
    
    @IBAction func createAlbumBtnTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Create album", message: nil, preferredStyle: .alert)
        alert.addTextField(){ (textfield) in
            textfield.placeholder = "Enter album name here"
        }
        alert.addAction(UIAlertAction(title: "Create", style: .cancel, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            guard let fileNames = self.userDefault.stringArray(forKey: "listPhotosAlbum") else {
                return
            }
            
            if textField?.text == "" {
                let alert = UIAlertController(title: "Error", message: "Please enter album name", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
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
