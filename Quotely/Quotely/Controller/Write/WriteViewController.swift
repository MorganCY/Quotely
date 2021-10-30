//
//  WriteViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation
import UIKit
import PhotosUI
import Vision

class WriteViewController: BaseImagePickerViewController {

    private var recognizedImage: UIImage? = UIImage() {
        didSet {
            recognizeText(image: recognizedImage)
        }
    }

    // MARK: ViewControls
    var contentTextView = ContentTextView() {

        didSet {
            contentTextView.placeholder(text: Placeholder.comment.rawValue, color: .lightGray)
        }
    }
    private let addHashtagButton = UIButton()
    private let hashtagButton = UIButton()
    private var postImageView = UIImageView()
    private let deleteImageButton = DeleteButton()
    private let optionPanel = UIView()
    private let recognizeTextButton = RowButton(
        image: UIImage.sfsymbol(.fileScanner)!,
        imageColor: .M2!,
        labelColor: .black,
        text: "掃描文字"
    )
    private let uploadImageButton = RowButton(
        image: UIImage.sfsymbol(.photo)!,
        imageColor: .M2!,
        labelColor: .black,
        text: "上傳圖片"
    )

    var hashtagTitle = String() {
        didSet {
            self.hasHashtag = !self.hashtagTitle.isEmpty
            self.hashtagButton.setTitle(" \(hashtagTitle) ", for: .normal)
        }
    }

    var hasHashtag = false {
        didSet {
            DispatchQueue.main.async {
                self.addHashtagButton.isHidden = self.hasHashtag
                self.hashtagButton.isHidden = !self.hasHashtag
            }
        }
    }

    var hasImage = false {
        didSet {
            DispatchQueue.main.async {
                self.deleteImageButton.isHidden = !self.hasImage
            }
        }
    }

    private var isRecognizedTextButtonTapped = false

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
    private var navTitle = "撰寫摘語"
    private var navButtonTitle = "分享"

    var contentHandler: ((String) -> Void) = {_ in}

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        recognizeTextButton.addTarget(self, action: #selector(openImagePicker(_:)), for: .touchUpInside)
        uploadImageButton.addTarget(self, action: #selector(openImagePicker(_:)), for: .touchUpInside)
        addHashtagButton.addTarget(self, action: #selector(addHashtag(_:)), for: .touchUpInside)
        hashtagButton.addTarget(self, action: #selector(deleteHashtag(_:)), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        layoutViews()

        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupNavigation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        recognizedImage = nil
    }

    @objc func onPublish(_ sender: UIBarButtonItem) {

        // Pass edited content to post detail page
        self.contentHandler(self.contentTextView.text)

        // Check if the page is under edit state
        if let postID = postID {

            PostManager.shared.updatePost(
                postID: postID,
                content: contentTextView.text,
                imageUrl: imageUrl ?? nil,
                hashtag: hashtagTitle
            ) { result in

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
                hashtag: hashtagTitle,
                likeNumber: nil,
                likeUser: nil,
                commentNumber: nil)

            PostManager.shared.publishPost(post: &post) { result in

                switch result {

                case .success(let success):

                    print(success)

                    guard let postID = post.postID else { return }

                    var hashtag = Hashtag(
                        title: self.hashtagTitle,
                        newPostID: postID,
                        postList: [])

                    HashtagManager.shared.addHashtag(hashtag: &hashtag) { result in

                        switch result {

                        case .success(let success):

                            print(success)

                            self.dismiss(animated: true, completion: nil)

                        case .failure(let error):

                            print(error)
                        }
                    }

                case .failure(let error):

                    print(error)
                }
            }

        } else {

            Toast.showFailure(text: "請輸入內容")
        }
    }

    @objc func addHashtag(_ sender: UIButton) {

        guard let hashtagVC =
                UIStoryboard.write
                .instantiateViewController(
                    withIdentifier: String(describing: HashtagListViewController.self)
                ) as? HashtagListViewController else {

                    return
                }

        let navVC = UINavigationController(rootViewController: hashtagVC)

        hashtagVC.hashtagHandler = { hashtag in

            self.hashtagTitle = hashtag
        }

        present(navVC, animated: true, completion: nil)
    }

    @objc func deleteHashtag(_ sender: UIButton) {

        hashtagTitle.removeAll()
    }

    override func openImagePicker(_ sender: UIButton) {
        super.openImagePicker(sender)

        switch sender {

        case recognizeTextButton: isRecognizedTextButtonTapped = true
        case uploadImageButton: isRecognizedTextButtonTapped = false
        default: break
        }
    }

    private func recognizeText(image: UIImage?) {

        guard let cgImage = image?.cgImage else {
            return
        }

        Toast.showLoading(text: "掃描中")

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        let request = VNRecognizeTextRequest { [weak self] request, error in

            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {

                      Toast.showFailure(text: "掃描失敗")

                      return
                  }

            let text = observations.compactMap {

                $0.topCandidates(1).first?.string

            }.joined()

            DispatchQueue.main.async {

                self?.contentTextView.text = text

                Toast.shared.hud.dismiss()
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

    override func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {

        picker.dismiss(animated: true) {

            Toast.showLoading(text: "載入中")
        }

        guard let selectedImage = info[.editedImage] as? UIImage else {

            return
        }

//        postImageView.image = selectedImage
//
//        dismiss(animated: true)

        switch isRecognizedTextButtonTapped {

        case true:

            self.recognizedImage = selectedImage

        case false:

            ImageManager.shared.uploadImage(image: selectedImage) { result in

                switch result {

                case .success(let url):

                    self.imageUrl = url

                    Toast.shared.hud.dismiss()

                    DispatchQueue.main.async {

                        self.hasImage = true

                        self.postImageView.loadImage(url, placeHolder: nil)
                    }

                case .failure(let error):

                    Toast.shared.hud.dismiss()

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
        }
    }

    @available(iOS 14, *)
    override func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        switch isRecognizedTextButtonTapped {

        case true:

            picker.dismiss(animated: true)

            guard !results.isEmpty else { return }

            for result in results {

                result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (image, _) in

                    guard let image = image as? UIImage else { return picker.dismiss(animated: true) }

                    DispatchQueue.main.async {

                        self.recognizedImage = image
                    }
                })
            }

        case false:

            picker.dismiss(animated: true) {

                Toast.showLoading(text: "載入中")
            }

            guard !results.isEmpty else { return }

            for result in results {

                result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (image, error) in

                    guard let image = image as? UIImage else {

                        DispatchQueue.main.async {

                            picker.dismiss(animated: true)
                        }

                        return
                    }

                    ImageManager.shared.uploadImage(image: image) { result in

                        switch result {

                        case .success(let url):

                            self.imageUrl = url

                            Toast.shared.hud.dismiss()

                            DispatchQueue.main.async {

                                self.hasImage = true

                                self.postImageView.loadImage(url, placeHolder: nil)
                            }

                        case .failure(let error):

                            Toast.shared.hud.dismiss()

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
}

// MARK: Image
extension WriteViewController {

    @objc func deleteImage(_ sender: UIButton) {

        guard let imageUrl = imageUrl else { return }

        ImageManager.shared.deleteImage(imageUrl: imageUrl, removeUrlHandler: { [weak self] in

            self?.postImageView.image = nil

            self?.imageUrl = nil

            self?.hasImage = false
        })
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

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissSelf(_:))
        )
    }

    @objc func dismissSelf(_ sender: UIBarButtonItem) {

        self.dismiss(animated: true, completion: nil)
    }

    func layoutViews() {

        let views = [
            contentTextView, addHashtagButton, hashtagButton, postImageView, deleteImageButton, optionPanel, recognizeTextButton, uploadImageButton
        ]

        views.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([

            contentTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentTextView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25),

            addHashtagButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 16),
            addHashtagButton.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor),
            addHashtagButton.heightAnchor.constraint(equalToConstant: 32),

            hashtagButton.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 16),
            hashtagButton.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor),
            hashtagButton.heightAnchor.constraint(equalToConstant: 32),

            postImageView.topAnchor.constraint(equalTo: addHashtagButton.bottomAnchor, constant: 24),
            postImageView.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor),
            postImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            postImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),

            deleteImageButton.centerXAnchor.constraint(equalTo: postImageView.trailingAnchor),
            deleteImageButton.centerYAnchor.constraint(equalTo: postImageView.topAnchor),
            deleteImageButton.widthAnchor.constraint(equalTo: postImageView.widthAnchor, multiplier: 0.15),
            deleteImageButton.heightAnchor.constraint(equalTo: deleteImageButton.widthAnchor),

            optionPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            optionPanel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 32),
            optionPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            optionPanel.widthAnchor.constraint(equalTo: view.widthAnchor),

            recognizeTextButton.leadingAnchor.constraint(equalTo: optionPanel.leadingAnchor),
            recognizeTextButton.topAnchor.constraint(equalTo: optionPanel.topAnchor, constant: 8),
            recognizeTextButton.widthAnchor.constraint(equalTo: optionPanel.widthAnchor),
            recognizeTextButton.heightAnchor.constraint(equalTo: optionPanel.heightAnchor, multiplier: 0.3),
            uploadImageButton.leadingAnchor.constraint(equalTo: optionPanel.leadingAnchor),
            uploadImageButton.topAnchor.constraint(equalTo: recognizeTextButton.bottomAnchor),
            uploadImageButton.widthAnchor.constraint(equalTo: optionPanel.widthAnchor),
            uploadImageButton.heightAnchor.constraint(equalTo: optionPanel.heightAnchor, multiplier: 0.3)
        ])
    }

    func setupViews() {

        contentTextView.placeholder(text: Placeholder.comment.rawValue, color: .lightGray)

        recognizeTextButton.cornerRadius = recognizeTextButton.frame.width / 2
        uploadImageButton.cornerRadius = uploadImageButton.frame.width / 2

        addHashtagButton.isHidden = hasHashtag
        hashtagButton.isHidden = !hasHashtag

        addHashtagButton.setTitle(" ＋ 選擇主題 ", for: .normal)
        addHashtagButton.setTitleColor(.gray, for: .normal)
        addHashtagButton.cornerRadius = CornerRadius.standard.rawValue / 3
        addHashtagButton.borderColor = .gray
        addHashtagButton.borderWidth = 1
        addHashtagButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)

        hashtagButton.setTitle(" \(hashtagTitle) X ", for: .normal)
        hashtagButton.setTitleColor(.white, for: .normal)
        hashtagButton.backgroundColor = .gray
        hashtagButton.cornerRadius = CornerRadius.standard.rawValue / 3
        hashtagButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)

        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.layer.cornerRadius = 10

        deleteImageButton.isHidden = !hasImage
        deleteImageButton.addTarget(self, action: #selector(deleteImage(_:)), for: .touchUpInside)
        deleteImageButton.backgroundColor = .clear

        optionPanel.backgroundColor = .white
        optionPanel.cornerRadius = CornerRadius.standard.rawValue
        optionPanel.dropShadow(opacity: 0.5)
    }
}
