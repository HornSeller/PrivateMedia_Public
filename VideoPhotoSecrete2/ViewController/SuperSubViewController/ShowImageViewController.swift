//
//  ShowImageViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 15/05/2023.
//

import UIKit

class ShowImageViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    let fileManager = FileManager.default
    var imageV = UIImage()
    var imageN = ""
    var fileN = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = imageV
        imageView.contentMode = .scaleAspectFit
        scrollView.delegate = self
    }
    
    @IBAction func deleteBarBtnTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Are you really want to delete this Photo?", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let okAction = UIAlertAction(title: "OK", style: .destructive, handler: { (_) in
            
            guard let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            
            let photosURL = documentURL.appendingPathComponent("Photos/\(self.fileN)")
            let imageURL = photosURL.appendingPathComponent(self.imageN)
            print(imageURL.path)
            do {
                try self.fileManager.removeItem(atPath: imageURL.path)
                let alert2 = UIAlertController(title: "Delete successfully", message: nil, preferredStyle: .alert)
                alert2.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert2, animated: true)
            } catch let error {
                print(error.localizedDescription)
            }
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    static func cellTapped(image: UIImage, imageName: String, fileName: String) -> ShowImageViewController {
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController: ShowImageViewController = storyboard.instantiateViewController(withIdentifier: "ShowImageViewController") as! ShowImageViewController
        rootViewController.imageV = image
        rootViewController.imageN = imageName
        rootViewController.fileN = fileName
        
        return rootViewController
    }
}
