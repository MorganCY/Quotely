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

    let imageOptionDimmingView = UIView()
    let cameraButton = RowButton(
        image: UIImage.sfsymbol(.cameraNormal),
        imageColor: .M1,
        labelColor: .gray,
        text: "打開相機")
    let galleryButton = RowButton(
        image: UIImage.sfsymbol(.photo),
        imageColor: .M1,
        labelColor: .gray,
        text: "打開相簿")
    var imageOptionViews: [UIView] {
        return [imageOptionDimmingView, cameraButton, galleryButton]
    }

    var isImageOptionShow = false {
        didSet {
            imageOptionViews.forEach {
                $0.isHidden = !isImageOptionShow
            }
            if isImageOptionShow {
                imageOptionViews.forEach {
                    view.bringSubviewToFront($0)
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageOption()
        imagePicker.delegate = self
    }

    @objc func openImagePicker(_ sender: UIButton) {

        openImagePicker()
    }

    func openImagePicker() {

        isImageOptionShow = true
    }

    @objc func openCamera(_ sender: UIButton) {

        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {

            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true) {
                self.isImageOptionShow = false
            }

        } else {

            Toast.showFailure(text: ToastText.noCamera.rawValue)
        }
    }

    @objc func openGallery(_ sender: UIButton) {

        if #available(iOS 14, *) {

            var imageConfiguration = PHPickerConfiguration()
            imageConfiguration.filter = PHPickerFilter.images

            let picker = PHPickerViewController(configuration: imageConfiguration)
            picker.delegate = self

            self.present(picker, animated: true) {
                self.isImageOptionShow = false
            }

        } else {

            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {

                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)

            } else {

                Toast.showFailure(text: ToastText.noCamera.rawValue)
            }
        }
    }

    @objc func collapseImageOption(_ sender: UITapGestureRecognizer) { isImageOptionShow = false }

    func setupImageOption() {

        let dismissOptionGesture = UITapGestureRecognizer(target: self, action: #selector(collapseImageOption(_:)))

        imageOptionViews.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.bringSubviewToFront($0)
            $0.isHidden = !isImageOptionShow
        }

        imageOptionDimmingView.backgroundColor = .black.withAlphaComponent(0.7)
        imageOptionDimmingView.addGestureRecognizer(dismissOptionGesture)

        cameraButton.addTarget(self, action: #selector(openCamera(_:)), for: .touchUpInside)
        galleryButton.addTarget(self, action: #selector(openGallery(_:)), for: .touchUpInside)

        cameraButton.backgroundColor = .white
        cameraButton.cornerRadius = CornerRadius.standard.rawValue

        galleryButton.backgroundColor = .white
        galleryButton.cornerRadius = CornerRadius.standard.rawValue

        NSLayoutConstraint.activate([

            imageOptionDimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            imageOptionDimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageOptionDimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageOptionDimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            cameraButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -8),
            cameraButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            cameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            cameraButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1),

            galleryButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 8),
            galleryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            galleryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            galleryButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1)
        ])
    }

    // ImagePickerController delegate method which should be properly overridden by subclasses
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        fatalError("didFinishPickingMediaWithInfo is not overridden")
    }

    // PHPicker delegate method which should be properly overridden by subclasses
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        fatalError("didFinishPickingMediaWithInfo is not overridden")
    }
}
