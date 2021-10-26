//
//  WriteViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation
import UIKit
import PhotosUI
import UITextView_Placeholder
import JGProgressHUD
import SwiftUI

class WriteViewController: UIViewController {

    // MARK: ViewControls
    var contentTextView = ContentTextView() {

        didSet {
            contentTextView.placeholder(text: Placeholder.comment.rawValue, color: .lightGray)
        }
    }
    let hashtagLabel = UILabel()
    var postImageView = UIImageView()
    private let deleteImageButton = DeleteButton()

    var hasImage = false {
        didSet {
            DispatchQueue.main.async {
                self.deleteImageButton.isHidden = !self.hasImage
            }
        }
    }
    var navTitle = "撰寫摘語"
    var navButtonTitle = "分享"
    var imagePicker = UIImagePickerController()

    var imageUrl: String? {
        didSet {
            self.postImageView.loadImage(imageUrl ?? "", placeHolder: nil)
        }
    }
    var postID: String? {
        didSet {
            guard postID != nil else { return }
            navTitle = "編輯摘語"
            navButtonTitle = "更新"
        }
    }

    var contentHandler: ((String) -> Void) = {_ in}

    @IBOutlet weak var optionPanel: UIView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        layoutViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupViews()

        setupNavigation()
    }

    // MARK: Actions
    @IBAction func uploadImage(_ sender: UIButton) {

        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in

            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in

            self.openGallary()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    @objc func onPublish(_ sender: UIBarButtonItem) {

        // Pass edited content to post detail page
        self.contentHandler(self.contentTextView.text)

        // Check if the page is under edit state
        if let postID = postID {

            PostManager.shared.updatePost(
                postID: postID,
                content: contentTextView.text,
                imageUrl: imageUrl ?? nil) { result in

                    switch result {

                    case .success(let success):

                        print(success)

                        self.dismiss(animated: true) {

                            Toast.showSuccess(text: "更新成功")
                        }

                    case .failure(let error):

                        Toast.showFailure(text: "更新失敗")

                        print(error)
                    }
            }

        } else {

            guard let imageUrl = imageUrl else {

                publishPost(imageUrl: nil)

                return
            }

            self.publishPost(imageUrl: imageUrl)
        }
    }

    func publishPost(imageUrl: String?) {

        if !contentTextView.text.isEmpty || hasImage == true {

            var post = Post(
                uid: "test123456",
                createdTime: Date().millisecondsSince1970,
                editTime: nil,
                content: contentTextView.text   ,
                imageUrl: imageUrl,
                hashtag: nil,
                likeNumber: nil,
                likeUser: nil,
                commentNumber: nil)

            PostManager.shared.publishPost(post: &post) { _ in

                self.dismiss(animated: true, completion: nil)
            }

        } else {

            Toast.showFailure(text: "請輸入內容")
        }
    }
}

// MARK: Image
extension WriteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {

        guard let selectedImage = info[.editedImage] as? UIImage else {

            return
        }

        postImageView.image = selectedImage

        dismiss(animated: true)
    }

    // MARK: ImagePickerActions
    func openCamera() {

        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {

            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)

        } else {

            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
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

                let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    @objc func deleteImage(_ sender: UIButton) {

        guard let imageUrl = imageUrl else { return }

        ImageManager.shared.deleteImage(imageUrl: imageUrl, removeUrlHandler: { [weak self] in

            self?.postImageView.image = nil

            self?.imageUrl = nil
        })

        hasImage = false
    }
}

@available(iOS 14, *)
extension WriteViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true) {
            Toast.showLoading(text: "載入圖片中")
        }

        guard !results.isEmpty else { return }

        for result in results {

            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (image, error) in

                guard let image = image as? UIImage else { return picker.dismiss(animated: true) }

                self.hasImage = true

                ImageManager.shared.uploadImage(image: image) { result in

                    switch result {

                    case .success(let url):

                        self.imageUrl = url

                        Toast.shared.hud.dismiss()

                        DispatchQueue.main.async {

                            self.postImageView.loadImage(url, placeHolder: nil)
                        }

                    case .failure(let error):

                        print(error)

                        self.present(
                            UIAlertController(
                                title: "上傳失敗",
                                message: nil,
                                preferredStyle: .alert
                            ), animated: true, completion: nil
                        )

                        picker.dismiss(animated: true)
                    }
                }
            })
        }
    }
}

// MARK: SetupViews
extension WriteViewController {

    func setupNavigation() {

        navigationItem.title = navTitle

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: navButtonTitle, style: .plain,
            target: self, action: #selector(onPublish(_:))
        )
    }

    func layoutViews() {

        self.view.addSubview(contentTextView)
        self.view.addSubview(hashtagLabel)
        self.view.addSubview(postImageView)
        self.view.addSubview(deleteImageButton)

        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        hashtagLabel.translatesAutoresizingMaskIntoConstraints = false
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        deleteImageButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            contentTextView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            contentTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            contentTextView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.25),

            hashtagLabel.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 16),
            hashtagLabel.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor),
            hashtagLabel.heightAnchor.constraint(equalToConstant: 32),

            postImageView.topAnchor.constraint(equalTo: hashtagLabel.bottomAnchor, constant: 32),
            postImageView.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor),
            postImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5),
            postImageView.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5),

            deleteImageButton.centerXAnchor.constraint(equalTo: postImageView.trailingAnchor),
            deleteImageButton.centerYAnchor.constraint(equalTo: postImageView.topAnchor),
            deleteImageButton.widthAnchor.constraint(equalTo: postImageView.widthAnchor, multiplier: 0.15),
            deleteImageButton.heightAnchor.constraint(equalTo: deleteImageButton.widthAnchor)
        ])
    }

    func setupViews() {

        hashtagLabel.text = "新增標籤"
        hashtagLabel.textColor = .black
        hashtagLabel.font = UIFont.systemFont(ofSize: 18)

        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.layer.cornerRadius = 10

        deleteImageButton.isHidden = !hasImage
        deleteImageButton.cornerRadius = deleteImageButton.frame.width / 2
        deleteImageButton.addTarget(self, action: #selector(deleteImage(_:)), for: .touchUpInside)

        optionPanel.shadowColor = UIColor.gray.cgColor
        optionPanel.shadowOpacity = 0.3
        optionPanel.shadowOffset = CGSize(width: 6, height: 8)
        optionPanel.cornerRadius = CornerRadius.standard.rawValue
        optionPanel.borderColor = UIColor.gray.withAlphaComponent(0.3)
        optionPanel.borderWidth = 1
        optionPanel.layer.shouldRasterize = true
    }
}
