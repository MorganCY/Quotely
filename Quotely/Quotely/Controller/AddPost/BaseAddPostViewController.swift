//
//  BaseWriteViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/9.
//

import Foundation
import UIKit
import PhotosUI
import Vision

class BaseAddPostViewController: BaseImagePickerViewController {

    // MARK: Post Content
    var postID: String? {
        didSet {
            setupNavigation()
        }
    }
    var card: Card?
    var editContentHandler: ((_ content: String, _ time: Int64, _ postImage: UIImage?) -> Void)?
    var cardPostHandler: ((_ postID: String) -> Void)?

    // MARK: Post Image
    var hasPostImage = false
    var imageUrl: String?
    var uploadedImage: UIImage? = UIImage.asset(.bg4)
    private var isRecognizedTextButtonTapped = false
    private var recognizedImage: UIImage? = UIImage() {
        didSet {
            recognizeText(image: recognizedImage) { text in
                self.contentTextView.text = text
            }
        }
    }

    // MARK: Interface
    private var navigationTitle = ["title": "撰寫", "buttonTitle": "發布"]
    var contentTextView = ContentTextView()
    private let textNumberLabel = UILabel()
    private let optionPanel = UIView()
    private let recognizeTextButton = RowButton(
        image: UIImage.sfsymbol(.fileScanner),
        imageColor: .M2, labelColor: .black, text: "掃描文字")
    private var uploadImageButton = RowButton(
        image: UIImage.sfsymbol(.photo),
        imageColor: .M2, labelColor: .black, text: "上傳圖片")

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViews()
        setupViews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        recognizeTextButton.cornerRadius = recognizeTextButton.frame.width / 2
        uploadImageButton.cornerRadius = uploadImageButton.frame.width / 2
        optionPanel.dropShadow(opacity: 0.5)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        recognizedImage = nil
    }

    private func createPost(post: inout Post) {

        PostManager.shared.createPost(post: &post) { result in

            switch result {

            case .success(let postID):
                self.updateUser(postID: postID, action: .positive)

            case .failure(let error):
                print(error)
                Toast.showFailure(text: ToastText.failToAdd.rawValue)
            }
        }
    }

    private func updatePost(postID: String, imageUrl: String?) {

        PostManager.shared.updatePost(
            postID: postID,
            editTime: Date().millisecondsSince1970,
            content: self.contentTextView.text,
            imageUrl: imageUrl
        ) { result in

            switch result {

            case .success(let success):

                print(success)

                self.dismiss(animated: true) {
                    Toast.showSuccess(text: ToastText.successUpdated.rawValue)

                    self.editContentHandler?(
                        self.contentTextView.text,
                        Date().millisecondsSince1970,
                        self.uploadedImage)
                }

            case .failure(let error):
                print(error)
                Toast.showFailure(text: ToastText.failToUpdate.rawValue)
            }
        }
    }

    func updateUser(postID: String, action: FirebaseAction) {

        UserManager.shared.updateUserPost(
            postID: postID, postAction: action
        ) { result in

            switch result {

            case .success(let successStatus):
                print(successStatus)

                if self.cardPostHandler == nil {

                    Toast.shared.hud.dismiss()
                    self.goToDesignatedTab(.explore)
                }

                self.cardPostHandler?(postID)

            case .failure(let error):
                print(error)
                Toast.showFailure(text: ToastText.failToUpload.rawValue)
            }
        }
    }

    private func onPublish() {

        guard !contentTextView.text.isEmpty else {

            Toast.showFailure(text: ToastText.remindInput.rawValue)
            return
        }

        Toast.showLoading(text: ToastText.uploading.rawValue)

        if let postID = self.postID {

            if hasPostImage {

                ImageManager.shared.createImage(image: uploadedImage ?? UIImage()) { result in

                    switch result {

                    case .success(let url):
                        self.updatePost(postID: postID, imageUrl: url)
                        Toast.shared.hud.dismiss()

                    case .failure(let error):
                        print(error)
                        Toast.showFailure(text: ToastText.failToUpload.rawValue)
                    }
                }
            } else {

                self.updatePost(postID: postID, imageUrl: imageUrl)
            }

        } else {

            publishNewPost()
        }
    }

    private func publishNewPost() {

        if hasPostImage {

            ImageManager.shared.createImage(image: uploadedImage ?? UIImage()) { result in

                switch result {

                case .success(let url):
                    Toast.shared.hud.dismiss()

                    var post = Post(
                        content: self.contentTextView.text,
                        imageUrl: url,
                        cardID: self.card?.cardID,
                        cardContent: self.card?.content,
                        cardAuthor: self.card?.author)

                    self.createPost(post: &post)

                case .failure(let error):
                    print(error)
                    Toast.showFailure(text: ToastText.failToUpload.rawValue)
                }
            }
        } else {

            var post = Post(
                content: self.contentTextView.text,
                imageUrl: nil,
                cardID: self.card?.cardID,
                cardContent: self.card?.content,
                cardAuthor: self.card?.author)

            self.createPost(post: &post)
        }
    }

    override func openImagePicker(_ sender: UIButton) {

        super.openImagePicker(sender)

        switch sender {

        case recognizeTextButton: isRecognizedTextButtonTapped = true

        case uploadImageButton: isRecognizedTextButtonTapped = false

        default: break
        }
    }

    override func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {

        picker.dismiss(animated: true)
        Toast.showLoading(text: ToastText.uploading.rawValue)

        guard let selectedImage = info[.editedImage] as? UIImage else {

            Toast.showFailure(text: ToastText.remindImage.rawValue)
            return
        }

        if isRecognizedTextButtonTapped {

            self.recognizedImage = selectedImage

        } else {

            self.uploadedImage = selectedImage
            self.hasPostImage = true
        }

        Toast.shared.hud.dismiss()
    }

    @available(iOS 14, *)
    override func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)

        Toast.showLoading(text: ToastText.uploading.rawValue)

        guard !results.isEmpty else {

            Toast.showFailure(text: ToastText.remindImage.rawValue)
            return
        }

        for result in results {

            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { image, error in

                if let error = error {

                    print(error)
                    Toast.showFailure(text: ToastText.failToUpload.rawValue)
                }

                guard let selectedImage = image as? UIImage else {

                    picker.dismiss(animated: true)
                    return
                }

                if self.isRecognizedTextButtonTapped {

                    self.recognizedImage = selectedImage

                } else {

                    self.uploadedImage = selectedImage
                    self.hasPostImage = true
                }

                Toast.shared.hud.dismiss()
            })
        }
    }
}

extension BaseAddPostViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        let currentText = textView.text ?? ""

        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

        textNumberLabel.text = "\(updatedText.count) / 140"

        return updatedText.count <= 140
    }
}

extension BaseAddPostViewController {

    @objc func tapPublishButton(_ sender: UIBarButtonItem) {
        onPublish()
    }

    @objc func dismissSelf(_ sender: UIBarButtonItem) {
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        sceneDelegate?.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }

    func setupNavigation() {

        if postID != nil {

            navigationTitle = ["title": "編輯", "buttonTitle": "更新"]
        }

        navigationItem.title = navigationTitle["title"]

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self, action: #selector(dismissSelf(_:)))

        navigationItem.setupRightBarButton(
            image: nil, text: navigationTitle["buttonTitle"], target: self,
            action: #selector(tapPublishButton(_:)), color: .M1)
    }

    func layoutViews() {

        let views = [contentTextView, textNumberLabel, optionPanel, recognizeTextButton, uploadImageButton]

        views.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([

            contentTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentTextView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25),

            textNumberLabel.trailingAnchor.constraint(equalTo: contentTextView.trailingAnchor, constant: -16),
            textNumberLabel.bottomAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: -8),
            textNumberLabel.widthAnchor.constraint(equalTo: contentTextView.widthAnchor, multiplier: 0.3),

            optionPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            optionPanel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25),
            optionPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            optionPanel.widthAnchor.constraint(equalTo: view.widthAnchor),

            recognizeTextButton.leadingAnchor.constraint(equalTo: optionPanel.leadingAnchor),
            recognizeTextButton.topAnchor.constraint(equalTo: optionPanel.topAnchor, constant: 16),
            recognizeTextButton.widthAnchor.constraint(equalTo: optionPanel.widthAnchor),
            recognizeTextButton.heightAnchor.constraint(equalTo: optionPanel.heightAnchor, multiplier: 0.3),

            uploadImageButton.leadingAnchor.constraint(equalTo: optionPanel.leadingAnchor),
            uploadImageButton.topAnchor.constraint(equalTo: recognizeTextButton.bottomAnchor, constant: 6),
            uploadImageButton.widthAnchor.constraint(equalTo: optionPanel.widthAnchor),
            uploadImageButton.heightAnchor.constraint(equalTo: optionPanel.heightAnchor, multiplier: 0.3)
        ])
    }

    func setupViews() {

        contentTextView.placeholder(text: Placeholder.comment.rawValue, color: .lightGray)
        contentTextView.delegate = self
        contentTextView.contentInset = .init(top: 0, left: 10, bottom: 0, right: 0)

        recognizeTextButton.addTarget(self, action: #selector(openImagePicker(_:)), for: .touchUpInside)
        uploadImageButton.addTarget(self, action: #selector(openImagePicker(_:)), for: .touchUpInside)

        textNumberLabel.text = "\(contentTextView.text.count) / 140"
        textNumberLabel.textColor = .black
        textNumberLabel.font = UIFont.setRegular(size: 14)
        textNumberLabel.textAlignment = .right

        optionPanel.backgroundColor = .white
        optionPanel.cornerRadius = CornerRadius.standard.rawValue
    }
}
