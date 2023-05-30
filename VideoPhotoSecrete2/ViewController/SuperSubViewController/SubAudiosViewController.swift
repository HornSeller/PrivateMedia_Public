//
//  SubAudiosViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 16/05/2023.
//

import UIKit
import AVFoundation
import AVKit

class SubAudiosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        audiosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! SubAudiosTableViewCell
        
        cell.titleLb.text = nameArray[indexPath.row]
        cell.durationLb.text = getAudioDuration(url: (albumUrl?.appendingPathComponent(audiosName[indexPath.row]))!)
        cell.backgroundColor = UIColor.clear
        
        cell.menuBtn.showsMenuAsPrimaryAction = true
        cell.menuBtn.menu = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "Delete", handler: { (_) in
                do {
                    try self.fileManager.removeItem(at: (self.albumUrl?.appendingPathComponent(self.audiosName[indexPath.row]))!)
                    self.updateAudiosName()
                    self.nameArray.removeAll()
                    for audioName in self.audiosName {
                        self.nameArray.append(self.splitName(name: audioName)!)
                    }
                    tableView.reloadData()
                } catch {
                    print(error.localizedDescription)
                }
            }),
           
            UIAction(title: "Share", handler: { (_) in
                print("c")
            })
            
        ])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileName = audiosName[indexPath.row]
        let fileURL = albumUrl!.appendingPathComponent(fileName)
        
        let player = AVPlayer(url: fileURL)
        let vc = AVPlayerViewController()
        vc.player = player
        
        present(vc, animated: true) {
            vc.player?.play()
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        
        guard let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let audiosFileUrl = documentsUrl.appendingPathComponent("Audios")
        let folderUrl = audiosFileUrl.appendingPathComponent(title!)
        
        for url in urls {
            do {
                print(url)
                let fileName = url.lastPathComponent
                let name = "\(formatter.string(from: Date()))'\(fileName)"
                let fileUrl = folderUrl.appendingPathComponent(name)
                try fileManager.moveItem(at: url, to: fileUrl)
                updateAudiosName()
                nameArray.removeAll()
                for audioName in audiosName {
                    nameArray.append(splitName(name: audioName)!)
                }
                tableView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    var name = ""
    var audiosName: [String] = []
    var nameArray: [String] = []
    var albumUrl: URL?
    let fileManager = FileManager.default
    let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .import)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name = self.title!
        tableView.register(UINib(nibName: "SubAudiosTableViewCell", bundle: nil), forCellReuseIdentifier: "myCell")
        tableView.rowHeight = 93
        
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(leftBarButtonTapped))
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.leftBarButtonItem?.tintColor = .white
        updateAudiosName()
        for audioName in audiosName {
            nameArray.append(splitName(name: audioName)!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        updateAudiosName()
        nameArray.removeAll()
        for audioName in audiosName {
            nameArray.append(splitName(name: audioName)!)
        }
        tableView.reloadData()
    }
    
    @objc func leftBarButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addBtnTapped(_ sender: UIButton) {
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true, completion: nil)
    }
    
    func updateAudiosName() {
        let documentsDirectory = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let audiosURL = documentsDirectory.appendingPathComponent("Audios")
        let audiosDirectory = audiosURL.appendingPathComponent(name)
        albumUrl = audiosDirectory
        print(albumUrl)
        do {
            self.audiosName = try fileManager.contentsOfDirectory(atPath: audiosDirectory.path)
            self.audiosName.sort { (lhs: String, rhs: String) -> Bool in
                return lhs < rhs
            }
            // Lưu danh sách các tệp ảnh vào một mảng
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func splitName(name: String) -> String? {
        let components = name.components(separatedBy: "'")
            if components.count > 1 {
                return components[1]
            }
            return nil
    }
    
    func getAudioDuration(url: URL) -> String? {
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            let duration = Int(audioPlayer.duration)
            let minutes = duration / 60
            let seconds = duration % 60
            let durationString = String(format: "%02d:%02d", minutes, seconds)
            return durationString
        } catch {
            print("Error loading audio file: \(error)")
            return nil
        }
    }
    
    static func makeSelf(name: String) -> SubAudiosViewController {
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController: SubAudiosViewController = storyboard.instantiateViewController(withIdentifier: "SubAudiosViewController") as! SubAudiosViewController
        rootViewController.title = name
        
        return rootViewController
    }

}
