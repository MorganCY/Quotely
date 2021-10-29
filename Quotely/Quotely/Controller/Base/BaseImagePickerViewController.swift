//
//  ImagePickerViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/29.
//

import Foundation
import UIKit
import PhotosUI

class BaseImagePickerViewController: UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    PHPickerViewControllerDelegate {

    var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
    }

    @objc func openImagePicker(_ sender: UIButton) {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "打開相機", style: .default, handler: { _ in

            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: "打開相簿", style: .default, handler: { _ in

            self.openGallary()
        }))

        alert.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    func openCamera() {

        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {

            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)

        } else {

            let alert  = UIAlertController(title: "沒有相機可使用", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func openGallary() {

        if #available(iOS 14, *) {

            var imageConfiguration = PHPickerConfiguration()
            imageConfiguration.filter = PHPickerFilter.images

            let picker = PHPickerViewController(configuration: imageConfiguration)
            picker.delegate = self

            self.present(picker, animated: true, completion: nil)

        } else {

            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {

                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)

            } else {

                let alert  = UIAlertController(
                    title: "沒有相機可使用",
                    message: nil,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    // ImagePickerController delegate method which should be properly overridden by subclasses
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {}

    // PHPicker delegate method which should be properly overridden by subclasses
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {}
}
