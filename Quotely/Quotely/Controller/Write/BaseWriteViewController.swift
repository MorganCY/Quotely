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

// swiftlint:disable type_body_length
class BaseWriteViewController: BaseImagePickerViewController {

    // if it's in edit state, postID will be passed in
    var postID: String? {
        didSet {
            guard postID != nil else { return }
            navTitle = "編輯"
            navButtonTitle = "更新"
            setupNavigation()
        }
    }
    private var navTitle = "撰寫"
    private var navButtonTitle = "分享"

    var card: Card?
    var onPublishPostID: String?
    var editContentHandler: ((String, Int64, UIImage?) -> Void) = {_, _, _ in}
    var cardPostHandler: ()?

    var hasPostImage = false
    var imageUrl: String?
    var uploadedImage: UIImage? = UIImage.asset(.bg4)
    private var isRecognizedTextButtonTapped = false
    private var recognizedImage: UIImage? = UIImage() {
        didSet {
            recognizeText(image: recognizedImage)
        }
    }

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
                self.onPublishPostID = postID
                self.updateUser(postID: postID, action: .positive)

            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    Toast.showFailure(text: "新增想法失敗")
                }
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
                    DispatchQueue.main.async {
                        Toast.showSuccess(text: "更新成功")
                    }

                    self.editContentHandler(
                        self.contentTextView.text,
                        Date().millisecondsSince1970,
                        self.uploadedImage)
                }

            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    Toast.showFailure(text: "更新失敗")
                }
            }
        }
    }

    private func updateUser(postID: String, action: FirebaseAction) {

        UserManager.shared.updateUserPost(
            postID: postID, postAction: action
        ) { result in

            switch result {

            case .success(let successStatus):
                print(successStatus)

                guard let cardPostHandler = self.cardPostHandler else {

                    DispatchQueue.main.async {
                        Toast.shared.hud.dismiss()
                    }

                    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                    let tabBar = sceneDelegate?.window?.rootViewController as? UITabBarController

                    sceneDelegate?.window?.rootViewController?.dismiss(animated: true, completion: {
                        tabBar?.selectedIndex = 2
                    })

                    return
                }

                cardPostHandler

            case .failure(let error):
                print(error)

                DispatchQueue.main.async {
                    Toast.showFailure(text: "上傳失敗")
                }
            }
        }
    }

    private func onPublish() {

        guard !contentTextView.text.isEmpty else {

            DispatchQueue.main.async {
                Toast.showFailure(text: "請輸入內容")
            }
            return
        }

        DispatchQueue.main.async {
            Toast.showLoading(text: "上傳中")
        }

        if let postID = self.postID {

            switch hasPostImage {

            case true:

                ImageManager.shared.createImage(image: uploadedImage ?? UIImage()) { result in

                    switch result {

                    case .success(let url):
                        self.updatePost(postID: postID, imageUrl: url)
                        DispatchQueue.main.async {
                            Toast.shared.hud.dismiss()
                        }

                    case .failure(let error):
                        print(error)
                        DispatchQueue.main.async {
                            Toast.showFailure(text: "上傳圖片失敗")
                        }
                    }
                }

            case false:

                self.updatePost(postID: postID, imageUrl: imageUrl)
            }

        } else {

            publishNewPost()
        }
    }

    private func publishNewPost() {

        // check if there's image

        switch hasPostImage {

        case true:

            // upload the image

            ImageManager.shared.createImage(image: uploadedImage ?? UIImage()) { result in

                switch result {

                case .success(let url):

                    DispatchQueue.main.async { Toast.shared.hud.dismiss() }

                    var post = Post(
                        uid: UserManager.shared.visitorUserInfo?.uid ?? "",
                        createdTime: Date().millisecondsSince1970, editTime: nil,
                        content: self.contentTextView.text, imageUrl: url,
                        likeNumber: 0, commentNumber: 0, likeUser: nil,
                        cardID: self.card?.cardID,
                        cardContent: self.card?.content,
                        cardAuthor: self.card?.author)

                    // create post data with image url

                    self.createPost(post: &post)

                case .failure(let error):

                    print(error)

                    DispatchQueue.main.async { Toast.showFailure(text: "上傳圖片失敗") }
                }
            }

        case false:

            // create a post without image url

            var post = Post(
                uid: UserManager.shared.visitorUserInfo?.uid ?? "",
                createdTime: Date().millisecondsSince1970, editTime: nil,
                content: self.contentTextView.text, imageUrl: nil,
                likeNumber: 0, commentNumber: 0, likeUser: nil,
                cardID: self.card?.cardID,
                cardContent: self.card?.content,
                cardAuthor: self.card?.author)

            self.createPost(post: &post)
        }
    }

    private func recognizeText(image: UIImage?) {

        guard let cgImage = image?.cgImage else {
            return
        }

        DispatchQueue.main.async {
            Toast.showLoading(text: "掃描中")
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        let request = VNRecognizeTextRequest { [weak self] request, error in

            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {

                      DispatchQueue.main.async {
                          Toast.showFailure(text: "掃描失敗")
                      }
                      return
                  }

            let text = observations.compactMap {

                $0.topCandidates(1).first?.string

            }.joined()

            DispatchQueue.main.async {

                self?.contentTextView.text = text
                DispatchQueue.main.async {
                    Toast.shared.hud.dismiss()
                }
            }
        }

        request.recognitionLanguages = ["zh-Hant", "en"]

        do {

            try VNRecognizeTextRequest.supportedRecognitionLanguages(for: .accurate, revision: 2)

        } catch {

            print(error)
        }

        do {

            try handler.perform([request])

        } catch {

            print(error)
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

        DispatchQueue.main.async {
            Toast.showLoading(text: "上傳中")
        }

        switch isRecognizedTextButtonTapped {

        case true:

            picker.dismiss(animated: true)

            guard let selectedImage = info[.editedImage] as? UIImage else {

                DispatchQueue.main.async {
                    Toast.showFailure(text: "沒有選取圖片")
                }
                return
            }

            self.recognizedImage = selectedImage

            DispatchQueue.main.async {
                Toast.shared.hud.dismiss()
            }

        case false:

            guard let selectedImage = info[.editedImage] as? UIImage else {

                DispatchQueue.main.async {
                    Toast.showFailure(text: "沒有選取圖片")
                }
                return
            }

            self.uploadedImage = selectedImage

            self.hasPostImage = true

            DispatchQueue.main.async {
                Toast.shared.hud.dismiss()
            }

            picker.dismiss(animated: true)
        }
    }

    @available(iOS 14, *)
    override func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)

        DispatchQueue.main.async {
            Toast.showLoading(text: "上傳中")
        }

        guard !results.isEmpty else {

            DispatchQueue.main.async {
                Toast.showFailure(text: "沒有選取照片")
            }
            return
        }

        switch isRecognizedTextButtonTapped {

        case true:

            for result in results {

                result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (image, error) in

                    if let error = error {

                        print(error)
                        DispatchQueue.main.async {
                            Toast.showFailure(text: "上傳照片失敗")
                        }
                    }

                    guard let image = image as? UIImage else {

                        picker.dismiss(animated: true)
                        return
                    }

                    self.recognizedImage = image

                    DispatchQueue.main.async {
                        Toast.shared.hud.dismiss()
                    }
                })
            }

        case false:

            for result in results {

                result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (image, error) in

                    if let error = error {

                        print(error)
                        DispatchQueue.main.async {
                            Toast.showFailure(text: "上傳照片失敗")
                        }
                    }

                    guard let selectedImage = image as? UIImage else {

                        picker.dismiss(animated: true)

                        DispatchQueue.main.async {
                            Toast.shared.hud.dismiss()
                        }
                        return
                    }

                    self.uploadedImage = selectedImage

                    self.hasPostImage = true

                    DispatchQueue.main.async {
                        Toast.shared.hud.dismiss()
                    }
                })
            }
        }
    }
}

extension BaseWriteViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        let currentText = textView.text ?? ""

        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

        textNumberLabel.text = "\(updatedText.count) / 140"

        return updatedText.count <= 140
    }
}

extension BaseWriteViewController {

    @objc func tapPublishButton(_ sender: UIBarButtonItem) {
        onPublish()
    }

    @objc func dismissSelf(_ sender: UIBarButtonItem) {
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        sceneDelegate?.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }

    func setupNavigation() {

        navigationItem.title = navTitle

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self, action: #selector(dismissSelf(_:)))

        navigationItem.setupRightBarButton(
            image: nil, text: "發布", target: self,
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
        optionPanel.dropShadow(opacity: 0.5)
    }
}
