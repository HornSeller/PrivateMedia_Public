//
//  VideosViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 10/05/2023.
//

import UIKit
import AVFoundation

class VideosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var defaultValue = ["listVideosAlbum": []]
    
    let userDefault = UserDefaults.standard
    
    let fileManager = FileManager.default
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataTable = userDefault.stringArray(forKey: "listVideosAlbum")
        return dataTable!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! VideosTableViewCell
        cell.backgroundColor = UIColor.clear
        let dataTable = userDefault.stringArray(forKey: "listVideosAlbum")
        cell.titleLb.text = dataTable![indexPath.row]
        
        let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let videosURL = documentURL!.appendingPathComponent("Videos")
        let albumURL = videosURL.appendingPathComponent(dataTable![indexPath.row])
        do {
            var filesList = try fileManager.contentsOfDirectory(atPath: albumURL.path)
            if filesList.count == 0 {
                cell.imgView.image = UIImage(named: "2")
                cell.videoCountLb.text = "0 video"
            }
            else if filesList.count == 1 {
                let videoURL = albumURL.appendingPathComponent(filesList[0])
                cell.imgView.image = generateThumbnail(path: videoURL)
                cell.videoCountLb.text = "1 video"
            }
            else {
                filesList.sort { (lhs: String, rhs: String) -> Bool in
                    return lhs < rhs
                }
                let lastVideoURL = albumURL.appendingPathComponent(filesList[filesList.count - 1])
                cell.imgView.image = generateThumbnail(path: lastVideoURL)
                cell.videoCountLb.text = String(filesList.count) + " videos"
            }
        } catch {
            print(error.localizedDescription)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nameArray = userDefault.stringArray(forKey: "listVideosAlbum")
        let name = nameArray![indexPath.row]
        self.navigationController?.pushViewController(SubVideosViewController.makeSelf(name: name), animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        userDefault.register(defaults: defaultValue)
        //userDefault.removeObject(forKey: "listVideosAlbum")
        self.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
                ]
        
        tableView.register(UINib(nibName: "VideosTableViewCell", bundle: nil), forCellReuseIdentifier: "myCell")
        
        tableView.rowHeight = 93
        
        // kiểm tra xem đã tồn tại folder "Videos" chưa
        guard let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let videosURL = documentURL.appendingPathComponent("Videos")
        
        if !self.fileManager.fileExists(atPath: videosURL.path) {
            do {
                try self.fileManager.createDirectory(atPath: videosURL.path, withIntermediateDirectories: true, attributes: nil)
                let documentPath = videosURL.path
                print("Path to pictures directory: \(documentPath)")
            } catch {
                print("Error creating directory: \(error)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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
            
            guard let fileNames = self.userDefault.stringArray(forKey: "listVideosAlbum") else {
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
            
            var dataUserdefault = self.userDefault.stringArray(forKey: "listVideosAlbum")
            dataUserdefault?.append((textField?.text)!)
            self.userDefault.set(dataUserdefault, forKey: "listVideosAlbum")
            
            guard let fileNames = self.userDefault.stringArray(forKey: "listVideosAlbum") else {
                return
            }
            
            guard let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            
            let videosURL = documentURL.appendingPathComponent("Videos")
            
            for fileName in fileNames {
                let fileURL = videosURL.appendingPathComponent(fileName).path
                if !self.fileManager.fileExists(atPath: fileURL) {
                    do {
                        try self.fileManager.createDirectory(atPath: fileURL, withIntermediateDirectories: true, attributes: nil)
                        let documentPath = videosURL.path
                        print("Path to pictures directory: \(documentPath)")
                    } catch {
                        print("Error creating directory: \(error)")
                    }
                }
            }
            
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        
        self.present(alert, animated: true)
    }
    
    func generateThumbnail(path: URL) -> UIImage? {
        let asset = AVAsset(url: path)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
