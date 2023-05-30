//
//  SubVideosViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 12/05/2023.
//

import UIKit
import AVKit
import Kingfisher
import AVFoundation
import MobileCoreServices
import PhotosUI

class SubVideosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate, UINavigationControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        var count = 0
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        
        for result in results {
            result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [self] url, error in
                if let error = error {
                    // Xử lý lỗi
                    print("Error loading video URL: \(error.localizedDescription)")
                } else if let url = url {
                    // Thực hiện các hoạt động với URL của từng video
                    let imageName = url.lastPathComponent
                    let components = imageName.components(separatedBy: ".")
                    if components.count > 1 {
                        let nameWithoutExtension = components[0]
                        let fileExtension = components.last
                        let name = "\(formatter.string(from: Date()))\(count)_\(nameWithoutExtension).\(fileExtension ?? ".mp4")"
                        let videoURL = albumUrl!.appendingPathComponent(name)
                        //let videoURLforImageFolder = imageForCellURL?.appendingPathComponent(name)
                        do {
                            try self.fileManager.moveItem(at: url, to: videoURL)
//                            let image = generateThumbnail(path: videoURL)
//                            if let imageData = image!.jpegData(compressionQuality: 1.0) {
//                                try? imageData.write(to: videoURLforImageFolder!)
//                            }
                            generateThumbnail(path: videoURL)
                            self.updateVideosName()
                            //self.updateListImage()
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
        
        dismiss(animated: true)
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
                takeVideoBtn.isHidden = false
            case .select:
                selectBarButton.title = "Cancel"
                collectionView.allowsMultipleSelection = true
                toolBarImgView.isHidden = false
                deleteBtn.isHidden = false
                shareBtn.isHidden = false
                addFromGalleryBtn.isHidden = true
                takeVideoBtn.isHidden = true
            }
        }
    }
    
    var selectBarButton: UIBarButtonItem!
    var imageForCellURL: URL?
    var fileManager = FileManager.default
    var name = ""
    var videosName: [String] = []
    var listImage: [String] = []
    var videos: [URL] = []
    let videoPicker = UIImagePickerController()
    var albumUrl: URL?
    
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var takeVideoBtn: UIButton!
    @IBOutlet weak var addFromGalleryBtn: UIButton!
    @IBOutlet weak var toolBarImgView: UIImageView!
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        videosName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! SubVideosCollectionViewCell
        
        ImageCache.default.retrieveImage(forKey: albumUrl?.appendingPathComponent(videosName[indexPath.row]).path ?? "", options: nil) { result in
            switch result {
                case .success(let value):
                cell.imageView.image = value.image
                break
                case .failure(let error):
                    print(error)
                break
            }
        }
        
        let videoDuration = getVideoDuration(url: (albumUrl?.appendingPathComponent(videosName[indexPath.row]))!)
        cell.label.text = videoDuration
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        cell.addGestureRecognizer(longPressRecognizer)
        // ----------------------------------------------------------
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch mMode {
        case .view:
            let player = AVPlayer(url: (albumUrl?.appendingPathComponent(videosName[indexPath.row]))!)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            present(playerViewController, animated: true) {
                player.play()
            }
        case .select:
            break
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedVideo = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            saveVideo(pickedVideo: pickedVideo)
        }
        dismiss(animated: true, completion: nil)
        updateVideosName()
        collectionView.reloadData()
    }
    
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
        // tạo folder ImageForCell tại lần đầu tiên sử dụng app
//        guard let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            return
//        }
//
//        imageForCellURL = documentURL.appendingPathComponent("ImageForCell")
//
//        if !self.fileManager.fileExists(atPath: imageForCellURL!.path) {
//            do {
//                try self.fileManager.createDirectory(atPath: imageForCellURL!.path, withIntermediateDirectories: true, attributes: nil)
//                let documentPath = imageForCellURL!.path
//                print("Path to pictures directory: \(documentPath)")
//            } catch {
//                print("Error creating directory: \(error)")
//            }
//        }
        //
        
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(leftBarButtonTapped))
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        collectionView.register(UINib(nibName: "SubVideosCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "myCell")
        
        let margin: CGFloat = 10
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = margin
        layout.minimumInteritemSpacing = 1
        var sizeCell = (view.frame.size.width - 4 * margin) / 3 - 2
        if UIDevice.current.userInterfaceIdiom == .pad {
            sizeCell = (view.frame.size.width - 5 * margin) / 4 - 2
        }
                    
        layout.itemSize = CGSize(width: sizeCell, height: sizeCell)
        layout.sectionInset = UIEdgeInsets.init(top: margin, left: margin, bottom: margin, right: margin)
        collectionView.collectionViewLayout = layout
        updateVideosName()
        //updateListImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateVideosName()
        //updateListImage()
    }
    
    @IBAction func addFromGalleryBtnTapped(_ sender: UIButton) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .videos
        configuration.selectionLimit = 0 // Chọn 0 để cho phép chọn nhiều video
                
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func takeVideoBtnTapped(_ sender: UIButton) {
        videoPicker.sourceType = .camera
        videoPicker.mediaTypes = [kUTTypeMovie as String]
        videoPicker.delegate = self
        present(videoPicker, animated: true)
    }
    
    @IBAction func deleteBtnTapped(_ sender: UIButton) {
        var indexArr: [Int] = []
        if let selectedCell = collectionView.indexPathsForSelectedItems {
            for indexPath in selectedCell.reversed() {
                indexArr.append(indexPath.row)
            }
            
            indexArr.sort(by: >)
            
            if indexArr.count == 0 {
                let alert = UIAlertController(title: "Please choose at least 1 Video to delete", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                self.present(alert, animated: true)
            }
            
            let alert = UIAlertController(title: "Do you really want to delete \(indexArr.count) Video(s)?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .cancel, handler: { (_) in
                for index in indexArr {
                    do {
                        try self.fileManager.removeItem(at: (self.albumUrl?.appendingPathComponent(self.videosName[index]))!)
                        self.updateVideosName()
                        self.collectionView.reloadData()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            self.collectionView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .destructive))
            
            self.present(alert, animated: true)
            
        }
    }
    
    @IBAction func shareBtnTapped(_ sender: UIButton) {
    }
    
    @objc func selectBtnTapped(_ sender: UIBarButtonItem) {
        mMode = mMode == .view ? .select : .view
        collectionView.reloadData()
    }
    
    @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        videos.removeAll()
        if recognizer.state == .began {
            guard let cell = recognizer.view as? SubVideosCollectionViewCell else {
                return
            }
            let actionSheet = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                // TODO: Handle delete action
                if let indexPath = self.collectionView.indexPath(for: cell) {
                    let videoURL = self.albumUrl?.appendingPathComponent(self.videosName[indexPath.row])
                    do {
                        try self.fileManager.removeItem(at: videoURL!)
                        self.updateVideosName()
                        self.collectionView.reloadData()
                    } catch {
                        print(error.localizedDescription)
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
    
    @objc func leftBarButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func updateVideosName() {
        let documentsDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let photosURL = documentsDirectory.appendingPathComponent("Videos")
        let photosDirectory = photosURL.appendingPathComponent(name)
        albumUrl = photosDirectory
        do {
            self.videosName = try fileManager.contentsOfDirectory(atPath: photosDirectory.path)
            self.videosName.sort { (lhs: String, rhs: String) -> Bool in
                return lhs < rhs
            }
            // Lưu danh sách các tệp ảnh vào một mảng
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func updateListImage() {
        do {
            self.listImage = try fileManager.contentsOfDirectory(atPath: imageForCellURL!.path)
            self.listImage.sort { (lhs: String, rhs: String) -> Bool in
                return lhs < rhs
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func makeSelf(name: String) -> SubVideosViewController {
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController: SubVideosViewController = storyboard.instantiateViewController(withIdentifier: "SubVideosViewController") as! SubVideosViewController
        rootViewController.title = name
        
        return rootViewController
    }
    
    func saveVideo(pickedVideo: URL) {
        do {
            let pickedVideo1 = try Data(contentsOf: pickedVideo, options: .mappedIfSafe)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMddHHmmss"
            let videoNameDate = "\(formatter.string(from: Date()))_video.mp4"
            
            guard let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            
            let videosFileURL = documentURL.appendingPathComponent("Videos")
            let fileURL = videosFileURL.appendingPathComponent(name)
            let videoURL = fileURL.appendingPathComponent(videoNameDate)
            videos.append(videoURL)
            fileManager.createFile(atPath: videoURL.path, contents: pickedVideo1)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func generateThumbnail(path: URL) -> UIImage? {
        if ImageCache.default.isCached(forKey: path.path) {
            return nil
        }
        let asset = AVAsset(url: path)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            ImageCache.default.store(thumbnail, forKey: path.path)
            
            return thumbnail
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func getVideoDuration(url: URL) -> String? {
        let asset = AVAsset(url: url)
        let duration = asset.duration
        let durationSeconds = CMTimeGetSeconds(duration)
        
        let minutes = Int(durationSeconds / 60)
        let seconds = Int(durationSeconds) % 60
        
        let formattedDuration = String(format: "%02d:%02d", minutes, seconds)
        return formattedDuration
    }
}
