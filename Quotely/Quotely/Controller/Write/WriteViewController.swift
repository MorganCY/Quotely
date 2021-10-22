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

class WriteViewController: UIViewController {

    // MARK: ViewControls
    private var contentTextView: UITextView = {
        let textView = UITextView()
        textView.placeholder = "有什麼感觸...?"
        textView.placeholderColor = UIColor.lightGray
        return textView
    }()
    private let hashtagLabel = UILabel()
    private let buttonStackView = UIStackView()
    private let postImageView = UIImageView()

    var imagePicker = UIImagePickerController()
    var imageConfiguration = PHPickerConfiguration()

    @IBOutlet weak var optionPanel: UIView!

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self

        navigationItem.title = "撰寫摘語"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "分享", style: .plain,
            target: self, action: #selector(onPublish(_:))
        )
    }

    override func viewDidLayoutSubviews() {

        layoutViews()

        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {

        tabBarController?.tabBar.isHidden = false
    }

    // MARK: Action
    @IBAction func uploadImage(_ sender: Any) {

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

        guard let image = postImageView.image else {

            publishPost(imageUrl: nil)

            return
        }

        ImageManager.shared.uploadImage(image: image) { result in

            switch result {

            case .success(let url):

                self.publishPost(imageUrl: url)

            case .failure(let error):

                print(error)
            }
        }
    }

    func publishPost(imageUrl: String?) {

        guard let content = self.contentTextView.text else {

            self.present(
                UIAlertController(
                    title: "請輸入內容", message: nil, preferredStyle: .alert
                ), animated: true
            )

            return
        }

        var post = Post(
            uid: "test123456",
            createdTime: Date().millisecondsSince1970,
            editTime: nil,
            content: content,
            imageUrl: imageUrl,
            hashtag: nil,
            likeNumber: nil,
            likeUser: [""],
            commentNumber: nil)

        PostManager.shared.publishPost(post: &post) { _ in

            self.dismiss(animated: true, completion: nil)
        }
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

        imageConfiguration.filter = PHPickerFilter.images

        let picker = PHPickerViewController(configuration: imageConfiguration)

        picker.delegate = self

        self.present(picker, animated: true, completion: nil)
    }

    // MARK: SetupViews
    func layoutViews() {

        self.view.addSubview(contentTextView)
        self.view.addSubview(hashtagLabel)
        self.view.addSubview(postImageView)

        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        hashtagLabel.translatesAutoresizingMaskIntoConstraints = false
        postImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            contentTextView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            contentTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant:  -16),
            contentTextView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.25),

            hashtagLabel.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 16),
            hashtagLabel.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor),
            hashtagLabel.heightAnchor.constraint(equalToConstant: 32),

            postImageView.topAnchor.constraint(equalTo: hashtagLabel.bottomAnchor, constant: 32),
            postImageView.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor),
            postImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5),
            postImageView.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5)
        ])
    }

    func setupViews() {

        hashtagLabel.text = "新增標籤"
        hashtagLabel.textColor = .black
        contentTextView.font = UIFont.systemFont(ofSize: 18)
        contentTextView.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        contentTextView.cornerRadius = CornerRadius.standard.rawValue
        hashtagLabel.font = UIFont.systemFont(ofSize: 18)

        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.layer.cornerRadius = 10

        optionPanel.shadowColor = UIColor.gray.cgColor
        optionPanel.shadowOpacity = 0.3
        optionPanel.shadowOffset = CGSize(width: 6, height: 8)
        optionPanel.cornerRadius = CornerRadius.standard.rawValue
        optionPanel.borderColor = UIColor.gray.withAlphaComponent(0.3)
        optionPanel.borderWidth = 1
    }
}

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
}

extension WriteViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)

        guard !results.isEmpty else { return }

        for result in results {

            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (image, error) in

                if let image = image as? UIImage {

                    DispatchQueue.main.async {

                        self.postImageView.image = image
                    }

                } else {

                    print(String(describing: error))
                }
            })
        }
    }
}
