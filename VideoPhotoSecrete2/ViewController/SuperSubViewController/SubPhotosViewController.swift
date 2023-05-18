//
//  SubPhotosViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 11/05/2023.
//

import UIKit
import PhotosUI
import Kingfisher

class SubPhotosViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        var count = 0
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        
        guard let documentUrl = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
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
                    }
                }
            }
        }
        dismiss(animated: true)
    }
    
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
        self.navigationController?.pushViewController(ShowImageViewController.cellTapped(image: image, imageName: imageName, fileName: self.title!), animated: true)
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
        print(albumUrl)
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

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name = self.title!
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
        
        updatePhotosName();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isSelecting = false
        DispatchQueue.main.async {
            self.updatePhotosName()
            self.collectionView.reloadData()
        }
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
    
    @IBAction func addFromGalleryBtnTapped(_ sender: UIButton) {
        var config = PHPickerConfiguration()
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
