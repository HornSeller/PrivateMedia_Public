//
//  SubPhotosViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 11/05/2023.
//

import UIKit
import PhotosUI
import Kingfisher
import Photos

class SubPhotosViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        var count = 0
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        
        guard let documentUrl = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        var imageUrls: [Any] = []
        let photosURL = documentUrl.appendingPathComponent("Photos")
        let photosDirectory = photosURL.appendingPathComponent(self.name)
        for result in results {
            
            // Kiểm tra xem đối tượng có phải là ảnh không
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                // Tải ảnh
                result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { (url, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    } else if let url = url {
                        imageUrls.append(url)
                        print(url)
                        let imageName = url.lastPathComponent
                        let components = imageName.components(separatedBy: ".")
                        if components.count > 1 {
                            let nameWithoutExtension = components[0]
                            let fileExtension = components.last
                            let name = "\(formatter.string(from: Date()))\(count)_\(nameWithoutExtension).\(fileExtension ?? "jpeg")"
                            let imageUrl = photosDirectory.appendingPathComponent(name)
                            do {
                                try self.fileManager.moveItem(at: url, to: imageUrl)
                                self.updatePhotosName()
                                DispatchQueue.main.async {
                                    self.collectionView.reloadData()
                                }
                                
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                        count += 1
                        if (count == results.count) {
                            let identifiers = results.compactMap(\.assetIdentifier)
                            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.deleteAssets(fetchResult)
                            }) { success, error in
                                if success {
                                    // Photo was successfully removed
                                } else {
                                    // Error occurred while removing the photo
                                }
                            }
                        }
                    }
                }
            }
        }
        dismiss(animated: true)
    }
    
    func removePhotoFromLibrary(with assetIdentifier: String) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "localIdentifier = %@", assetIdentifier)
        
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        
        if let asset = fetchResult.firstObject {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets([asset] as NSArray)
            }) { success, error in
                if success {
                    // Photo was successfully removed
                } else {
                    // Error occurred while removing the photo
                }
            }
        } else {
            // Photo asset not found
        }
    }
    
    enum Mode {
        case view
        case select
    }
    var mMode: Mode = .view {
        didSet {
            switch mMode {
            case .view:
                selectBarButton.title = "Select"
                collectionView.allowsMultipleSelection = false
                toolBarImgView.isHidden = true
                deleteBtn.isHidden = true
                shareBtn.isHidden = true
                addFromGalleryBtn.isHidden = false
                takePhotoBtn.isHidden = false
            case .select:
                selectBarButton.title = "Cancel"
                collectionView.allowsMultipleSelection = true
                toolBarImgView.isHidden = false
                deleteBtn.isHidden = false
                shareBtn.isHidden = false
                addFromGalleryBtn.isHidden = true
                takePhotoBtn.isHidden = true
            }
        }
    }
    var selectBarButton: UIBarButtonItem!
    var fileManager = FileManager.default
    var name = ""
    var photosName: [String] = []
    //var cellCount = 0
    var imageNames: [String] = []
    var albumUrl: URL?
    
    let imagePickerController = UIImagePickerController()
    
    let insetsSession = UIEdgeInsets(top: 20, left: 15, bottom: 50, right: 15)
    let itemPerRow: CGFloat = 3
    var isSelecting: Bool = false
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photosName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! SubPhotosCollectionViewCell
        
        let imageName = photosName[indexPath.row]
        cell.imageView.kf.setImage(with: albumUrl?.appendingPathComponent(imageName), placeholder: UIImage(named: "loading"), options: nil, progressBlock: nil, completionHandler: nil)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        cell.addGestureRecognizer(longPressRecognizer)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageName = photosName[indexPath.row]
        let imageURL = albumUrl!.appendingPathComponent(imageName)
        guard let image = UIImage(contentsOfFile: imageURL.path) else {
            return
        }
        switch mMode {
        case .view:
            self.navigationController?.pushViewController(ShowImageViewController.cellTapped(image: image, imageName: imageName, fileName: self.title!), animated: true)
        case .select:
            break
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Lấy ảnh được chọn
            guard let image = info[.originalImage] as? UIImage else {
                picker.dismiss(animated: true, completion: nil)
                return
            }
            
            saveImage(image: image)
            
            picker.dismiss(animated: true, completion: nil)
            collectionView.reloadData()
        }
    
    func updatePhotosName() {
        let documentsDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let photosURL = documentsDirectory.appendingPathComponent("Photos")
        let photosDirectory = photosURL.appendingPathComponent(name)
        albumUrl = photosDirectory
        print(albumUrl!.path)
        do {
            self.photosName = try fileManager.contentsOfDirectory(atPath: photosDirectory.path)
            self.photosName.sort { (lhs: String, rhs: String) -> Bool in
                return lhs < rhs
            }
            // Lưu danh sách các tệp ảnh vào một mảng
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var takePhotoBtn: UIButton!
    @IBOutlet weak var addFromGalleryBtn: UIButton!
    @IBOutlet weak var toolBarImgView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name = self.title!
        
        selectBarButton = {
            let barButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectBtnTapped(_:)))
            barButtonItem.tintColor = .white
            return barButtonItem
        }()
        navigationItem.rightBarButtonItem = selectBarButton
        
        collectionView.register(UINib(nibName: "SubPhotosCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "myCell")
        
        let margin: CGFloat = 10
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = margin
        layout.minimumInteritemSpacing = margin
        var sizeCell = (view.frame.size.width - 4 * margin) / 3 - 2
        if UIDevice.current.userInterfaceIdiom == .pad {
            sizeCell = (view.frame.size.width - 5 * margin) / 4 - 2
        }

        layout.itemSize = CGSize(width: sizeCell, height: sizeCell)
        layout.sectionInset = UIEdgeInsets.init(top: margin, left: margin, bottom: margin, right: margin)
        collectionView.collectionViewLayout = layout
        
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(leftBarButtonTapped))
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        updatePhotosName()
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                // User has granted access to the photo library
            } else {
                // User has denied or restricted access to the photo library
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isSelecting = false
        DispatchQueue.main.async {
            self.updatePhotosName()
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ImageCache.default.clearMemoryCache()
    }
    
    @objc func selectBtnTapped(_ sender: UIBarButtonItem) {
        mMode = mMode == .view ? .select : .view
        collectionView.reloadData()
    }
    
    @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            guard let cell = recognizer.view as? SubPhotosCollectionViewCell else {
                return
            }
            let actionSheet = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                // TODO: Handle delete action
                if let indexPath = self.collectionView.indexPath(for: cell) {
                    let photoURL = self.albumUrl?.appendingPathComponent(self.photosName[indexPath.row])
                    do {
                        try self.fileManager.removeItem(at: photoURL!)
                        self.updatePhotosName()
                        self.collectionView.reloadData()
                    } catch {
                        print("Error deleting video: \(error)")
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            actionSheet.addAction(deleteAction)
            actionSheet.addAction(cancelAction)
            present(actionSheet, animated: true, completion: nil)
            // TODO: Handle long press action
        }
    }
    
    @IBAction func deleteBtnTapped(_ sender: UIButton) {
        var indexArr: [Int] = []
        if let selectedCell = collectionView.indexPathsForSelectedItems {
            for indexPath in selectedCell.reversed() {
                indexArr.append(indexPath.row)
            }
            
            indexArr.sort(by: >)
            
            if indexArr.count == 0 {
                let alert = UIAlertController(title: "Please choose at least 1 Photo to delete", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
            }
            
            let alert = UIAlertController(title: "Do you really want to delete \(indexArr.count) Photo(s)?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
                for index in indexArr {
                    do {
                        try self.fileManager.removeItem(at: (self.albumUrl?.appendingPathComponent(self.photosName[index]))!)
                        self.updatePhotosName()
                        self.collectionView.reloadData()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            self.collectionView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel))
            
            self.present(alert, animated: true)
            
        }
    }
    
    @IBAction func shareBtnTapped(_ sender: UIButton) {
        var filesToShare: [Any] = []
        if let selectedCell = collectionView.indexPathsForSelectedItems {
            for indexPath in selectedCell.reversed() {
                filesToShare.append((self.albumUrl?.appendingPathComponent(self.photosName[indexPath.row]))!)
            }
            
            let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func addFromGalleryBtnTapped(_ sender: UIButton) {
        let photoLibrary = PHPhotoLibrary.shared()
        var config = PHPickerConfiguration(photoLibrary: photoLibrary)
        config.selectionLimit = 0
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func takePicBtnTapped(_ sender: UIButton) {
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    func saveImage(image: UIImage) {
            // Lưu ảnh vào thư mục Documents của ứng dụng
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let imageNameDate = "\(formatter.string(from: Date()))_image.jpg"
            
            fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let photosDirectory = documentsURL.appendingPathComponent("Photos")
            let fileURL = photosDirectory.appendingPathComponent(name)
            let photoURL = fileURL.appendingPathComponent(imageNameDate)
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                try? imageData.write(to: photoURL)
            }
        }
    
    @objc func leftBarButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    static func makeSelf(name: String) -> SubPhotosViewController {
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController: SubPhotosViewController = storyboard.instantiateViewController(withIdentifier: "SubPhotosViewController") as! SubPhotosViewController
        rootViewController.title = name
        
        return rootViewController
    }
}
