//
//  SubDocumentsViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 16/05/2023.
//

import UIKit
import QuickLook
import MobileCoreServices
import UniformTypeIdentifiers

class SubDocumentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate, QLPreviewControllerDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! SubDocumentsTableViewCell
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let documentsFileUrl = documentsUrl!.appendingPathComponent("Documents")
        let folderUrl = documentsFileUrl.appendingPathComponent(self.title!)
        do {
            let fileList = try fileManager.contentsOfDirectory(atPath: folderUrl.path)
            let fileName = fileList[indexPath.row]
            let components = fileName.components(separatedBy: ".")
            if components.count > 1 {
                let fileExtension = components[1]
                print(fileExtension)
                switch fileExtension {
                case "doc":
                    cell.imgView.image = UIImage(named: "doc")
                    break
                case "docx":
                    cell.imgView.image = UIImage(named: "doc")
                    break
                case "xls":
                    cell.imgView.image = UIImage(named: "xls")
                    break
                case "ppt":
                    cell.imgView.image = UIImage(named: "ppt")
                    break
                case "pdf":
                    cell.imgView.image = UIImage(named: "pdf")
                    break
                default:
                    cell.imgView.image = UIImage(named: "Document")
                    break
                }
                
            }
            cell.titleLb.text = fileName
            cell.backgroundColor = UIColor.clear
            print(fileName)
        } catch {
            print(error.localizedDescription)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let documentInteractionController = UIDocumentInteractionController()
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let documentsFileUrl = documentsUrl!.appendingPathComponent("Documents")
        let folderUrl = documentsFileUrl.appendingPathComponent(self.title!)
        let tempFolder = documentsUrl!.appendingPathComponent("temp")
        
        do {
            try fileManager.createDirectory(atPath: tempFolder.path, withIntermediateDirectories: true)
            let fileList = try fileManager.contentsOfDirectory(atPath: folderUrl.path)
            let fileName = fileList[indexPath.row]
            fileUrlForQL = folderUrl.appendingPathComponent(fileName)
            tempFile = tempFolder.appendingPathComponent(fileName)
            print(fileUrlForQL as Any)
            try fileManager.copyItem(at: fileUrlForQL!, to: tempFile!)
            
            let previewController = QLPreviewController()
            previewController.dataSource = self
            present(previewController, animated: true)
//            documentInteractionController.url = fileUrl
//            documentInteractionController.delegate = self
//            documentInteractionController.presentPreview(animated: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        tempFile! as any QLPreviewItem
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        
        guard let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let documentsFileUrl = documentsUrl.appendingPathComponent("Documents")
        let folderUrl = documentsFileUrl.appendingPathComponent(title!)
        
        for url in urls {
            do {
                print(url)
                let fileName = url.lastPathComponent
                let components = fileName.components(separatedBy: ".")
                if components.count > 1 {
                    let nameWithoutExtension = components[0]
                    let fileExtension = components[1]
                    let name = "\(nameWithoutExtension)_\(formatter.string(from: Date())).\(fileExtension)"
                    print(name)
                    let fileUrl = folderUrl.appendingPathComponent(name)
                    try fileManager.moveItem(at: url, to: fileUrl)
                    cellCount += 1
                    tableView.reloadData()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let fileManager = FileManager.default
    var cellCount = 0
    var fileUrlForQL: URL?
    var tempFile: URL?
    
    let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.microsoft.word.doc", "org.openxmlformats.wordprocessingml.document", "com.microsoft.excel.xls", "org.openxmlformats.spreadsheetml.sheet", "com.microsoft.powerpoint.​ppt", "org.openxmlformats.presentationml.presentation",
        "com.adobe.pdf"], in: .import)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SubDocumentsTableViewCell", bundle: .main), forCellReuseIdentifier: "myCell")
        tableView.rowHeight = 80
        
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(leftBarButtonTapped))
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cellCount = 0
        guard let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let documentsFileUrl = documentsUrl.appendingPathComponent("Documents")
        let tempFolder = documentsUrl.appendingPathComponent("temp")
        
        do {
            let fileList = try fileManager.contentsOfDirectory(atPath: "\(documentsFileUrl.path)/\(self.title!)")
            cellCount = fileList.count
            
            let contents = try fileManager.contentsOfDirectory(atPath: tempFolder.path)
            print(contents)
            //try fileManager.removeItem(at: tempFile ?? tempFolder)
            try fileManager.removeItem(at: tempFolder)
        } catch {
            print(error.localizedDescription)
        }
        self.tableView.reloadData()
    }
    
    @objc func leftBarButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addBtnTapped(_ sender: UIButton) {
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true, completion: nil)
    }

    static func makeSelf(name: String) -> SubDocumentsViewController {
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController: SubDocumentsViewController = storyboard.instantiateViewController(withIdentifier: "SubDocumentsViewController") as! SubDocumentsViewController
        rootViewController.title = name
        
        
        return rootViewController
    }
}
