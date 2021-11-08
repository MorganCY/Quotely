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
    private let textNumberLabel = UILabel()
    private let cardTopicTitleLabel = UILabel()
    private var cardTopicView = CardTopicView(content: "", author: "")
    private var postImageView = UIImageView()
    private let deleteImageButton = DeleteButton()
    private let optionPanel = UIView()
    private let recognizeTextButton = RowButton(
        image: UIImage.sfsymbol(.fileScanner)!,
        imageColor: .M2!,
        labelColor: .black,
        text: "掃描文字"
    )
    private var uploadImageButton = RowButton(
        image: UIImage.sfsymbol(.photo)!,
        imageColor: .M2!,
        labelColor: .black,
        text: "上傳圖片"
    )

    var hasImage = false

    private var isRecognizedTextButtonTapped = false

    var card: Card? {
        didSet {
            guard let card = card else { return }
            cardTopicView = CardTopicView(content: card.content, author: card.author)
            isCard = true
            hasImage = true
            uploadImageButton = RowButton(
                image: UIImage.sfsymbol(.photo)!,
                imageColor: .M2!,
                labelColor: .black,
                text: "上傳卡片圖片"
            )
        }
    }
    var postID: String? {
        didSet {
            guard postID != nil else { return }
            navTitle = "編輯"
            navButtonTitle = "更新"
            setupNavigation()
            isCard = false
        }
    }
    var isCard = false {
        didSet {
            cardTopicTitleLabel.isHidden = !isCard
            cardTopicView.isHidden = !isCard
            postImageView.isHidden = isCard
        }
    }
    var imageUrl: String?
    var uploadedImage = UIImage.asset(.bg4)! {
        didSet {
            if isCard == true {
                cardTopicView.dataSource = self
            } else {
                DispatchQueue.main.async { self.postImageView.image = self.uploadedImage }
            }
        }
    }

    private var navTitle = "撰寫"
    private var navButtonTitle = "分享"

    var contentHandler: ((String, Int64) -> Void) = {_, _ in}

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cardTopicView.dataSource = self

        deleteImageButton.isHidden = true

        recognizeTextButton.addTarget(self, action: #selector(openImagePicker(_:)), for: .touchUpInside)
        uploadImageButton.addTarget(self, action: #selector(openImagePicker(_:)), for: .touchUpInside)
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

        // Check if the page is under edit state
        if let postID = postID {

            PostManager.shared.updatePost(
                postID: postID,
                editTime: Date().millisecondsSince1970,
                content: contentTextView.text,
                imageUrl: imageUrl ?? nil
            ) { result in

                    switch result {

                    case .success(let success):

                        print(success)

                        self.dismiss(animated: true) {

                            Toast.showSuccess(text: "更新成功")

                            // Pass edited content to post detail page

                            self.contentHandler(
                                self.contentTextView.text,
                                Date().millisecondsSince1970
                            )
                        }

                    case .failure(let error):

                        Toast.showFailure(text: "更新失敗")

                        print(error)
                    }
            }

        } else {

            self.publishPost()
        }
    }

    func publishPost() {

        Toast.showLoading(text: "上傳中")

        guard let uid = SignInManager.shared.uid else {

            Toast.showFailure(text: "上傳失敗")

            return
        }

        let cardID = isCard ? card?.cardID : nil

        if !contentTextView.text.isEmpty || hasImage == true {

            // check if there's image

            switch hasImage {

            case true:

                // upload the image

                ImageManager.shared.uploadImage(image: uploadedImage) { result in

                    switch result {

                    case .success(let url):

                        var post = Post(
                            uid: uid,
                            createdTime: Date().millisecondsSince1970,
                            editTime: nil,
                            content: self.contentTextView.text   ,
                            imageUrl: url,
                            likeNumber: 0,
                            likeUser: nil,
                            commentNumber: nil,
                            cardID: cardID
                        )

                        // create post data with image url

                        PostManager.shared.publishPost(post: &post) { result in

                            switch result {

                            case .success(let postID):

                                // if it's a card post, update card data

                                guard let cardID = cardID else {

                                    // if not card post, update user post list

                                    UserManager.shared.updateUserPost(
                                        uid: uid,
                                        postID: postID,
                                        postAction: .publish
                                    ) { result in

                                        switch result {

                                        case .success(let success):

                                            print(success)

                                            Toast.shared.hud.dismiss()

                                            self.dismiss(animated: true, completion: nil)

                                        case .failure(let error):

                                            print(error)

                                            Toast.showFailure(text: "上傳失敗")
                                        }
                                    }

                                    return
                                }

                                CardManager.shared.updateCardPostList(
                                    cardID: cardID,
                                    postID: postID
                                ) { result in

                                    switch result {

                                    case .success(let success):
                                        print(success)

                                        UserManager.shared.updateUserPost(
                                            uid: uid,
                                            postID: postID,
                                            postAction: .publish
                                        ) { result in

                                            switch result {

                                            case .success(let success):

                                                print(success)

                                                Toast.shared.hud.dismiss()

                                                self.dismiss(animated: true, completion: nil)

                                            case .failure(let error):

                                                print(error)

                                                Toast.showFailure(text: "上傳失敗")
                                            }
                                        }

                                    case .failure(let error):
                                        print(error)

                                        Toast.showFailure(text: "上傳失敗")
                                    }
                                }

                            case .failure(let error):

                                print(error)

                                Toast.showFailure(text: "上傳失敗")
                            }
                        }

                    case .failure(let error):

                        print(error)

                        Toast.showFailure(text: "上傳失敗")
                    }
                }

            case false:

                // create a post without image url

                var post = Post(
                    uid: uid,
                    createdTime: Date().millisecondsSince1970,
                    editTime: nil,
                    content: self.contentTextView.text   ,
                    imageUrl: nil,
                    likeNumber: 0,
                    likeUser: nil,
                    commentNumber: nil,
                    cardID: cardID
                )

                PostManager.shared.publishPost(post: &post) { result in

                    switch result {

                    case .success(let postID):

                        // if it's a card post, update card data

                        guard let cardID = cardID else {

                            self.dismiss(animated: true, completion: nil)

                            return
                        }

                        CardManager.shared.updateCardPostList(
                            cardID: cardID,
                            postID: postID) { result in

                                switch result {

                                case .success(let success):

                                    print(success)

                                    Toast.shared.hud.dismiss()

                                    self.dismiss(animated: true, completion: nil)

                                case .failure(let error):

                                    print(error)

                                    Toast.showFailure(text: "上傳失敗")
                                }
                            }

                    case .failure(let error):

                        print(error)

                        Toast.showFailure(text: "上傳失敗")
                    }
                }
            }
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

    @objc func deleteImage(_ sender: UIButton) {
        deleteImageButton.isHidden = true
        postImageView.image = nil
    }

    override func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {

        switch isRecognizedTextButtonTapped {

        case true:

            picker.dismiss(animated: true)

            guard let selectedImage = info[.editedImage] as? UIImage else {

                return
            }

            self.recognizedImage = selectedImage

        case false:

            guard let selectedImage = info[.editedImage] as? UIImage else {

                return
            }

            self.hasImage = true

            self.uploadedImage = selectedImage

            picker.dismiss(animated: true)
        }
    }

    @available(iOS 14, *)
    override func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)

        guard !results.isEmpty else { return }

        switch isRecognizedTextButtonTapped {

        case true:

            for result in results {

                result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (image, _) in

                    guard let image = image as? UIImage else { return picker.dismiss(animated: true) }

                    DispatchQueue.main.async {

                        self.recognizedImage = image
                    }
                })
            }

        case false:

            for result in results {

                result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (image, error) in

                    if let error = error {

                        print(error)

                    } else {

                        guard let selectedImage = image as? UIImage else {

                            picker.dismiss(animated: true)

                            return
                        }

                        self.hasImage = true

                        self.uploadedImage = selectedImage

                    }
                })
            }
        }
    }
}

extension WriteViewController: CardTopicViewDataSource {

    func getCardImage(_ view: CardTopicView) -> UIImage { uploadedImage }
}

extension WriteViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""

        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

        textNumberLabel.text = "\(updatedText.count) / 140"

        return updatedText.count <= 140
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
            contentTextView, textNumberLabel, cardTopicTitleLabel, cardTopicView, postImageView, deleteImageButton, optionPanel, recognizeTextButton, uploadImageButton
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

            textNumberLabel.trailingAnchor.constraint(equalTo: contentTextView.trailingAnchor, constant: -16),
            textNumberLabel.bottomAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: -8),

            cardTopicTitleLabel.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 24),
            cardTopicTitleLabel.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor),
            cardTopicTitleLabel.heightAnchor.constraint(equalToConstant: 20),

            postImageView.topAnchor.constraint(equalTo: contentTextView.bottomAnchor, constant: 24),
            postImageView.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor),
            postImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),
            postImageView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4),

            cardTopicView.topAnchor.constraint(equalTo: cardTopicTitleLabel.bottomAnchor, constant: 8),
            cardTopicView.leadingAnchor.constraint(equalTo: contentTextView.leadingAnchor),
            cardTopicView.trailingAnchor.constraint(equalTo: contentTextView.trailingAnchor),
            cardTopicView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2),

            deleteImageButton.centerXAnchor.constraint(equalTo: postImageView.trailingAnchor),
            deleteImageButton.centerYAnchor.constraint(equalTo: postImageView.topAnchor),
            deleteImageButton.widthAnchor.constraint(equalTo: postImageView.widthAnchor, multiplier: 0.15),
            deleteImageButton.heightAnchor.constraint(equalTo: deleteImageButton.widthAnchor),

            optionPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            optionPanel.topAnchor.constraint(equalTo: cardTopicView.bottomAnchor, constant: 56),
            optionPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            optionPanel.widthAnchor.constraint(equalTo: view.widthAnchor),

            recognizeTextButton.leadingAnchor.constraint(equalTo: optionPanel.leadingAnchor),
            recognizeTextButton.topAnchor.constraint(equalTo: optionPanel.topAnchor, constant: 8),
            recognizeTextButton.widthAnchor.constraint(equalTo: optionPanel.widthAnchor),
            recognizeTextButton.heightAnchor.constraint(equalTo: optionPanel.heightAnchor, multiplier: 0.25),
            uploadImageButton.leadingAnchor.constraint(equalTo: optionPanel.leadingAnchor),
            uploadImageButton.topAnchor.constraint(equalTo: recognizeTextButton.bottomAnchor),
            uploadImageButton.widthAnchor.constraint(equalTo: optionPanel.widthAnchor),
            uploadImageButton.heightAnchor.constraint(equalTo: optionPanel.heightAnchor, multiplier: 0.25)
        ])
    }

    func setupViews() {

        contentTextView.placeholder(text: Placeholder.comment.rawValue, color: .lightGray)
        contentTextView.delegate = self

        recognizeTextButton.cornerRadius = recognizeTextButton.frame.width / 2
        uploadImageButton.cornerRadius = uploadImageButton.frame.width / 2

        cardTopicTitleLabel.text = "引用卡片"
        cardTopicTitleLabel.numberOfLines = 1
        cardTopicTitleLabel.textColor = .M1
        cardTopicTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)

        textNumberLabel.text = "\(contentTextView.text.count) / 140"
        textNumberLabel.textColor = .black
        textNumberLabel.font = UIFont.systemFont(ofSize: 14)

        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.layer.cornerRadius = 10

        deleteImageButton.addTarget(self, action: #selector(deleteImage(_:)), for: .touchUpInside)
        deleteImageButton.backgroundColor = .clear

        optionPanel.backgroundColor = .white
        optionPanel.cornerRadius = CornerRadius.standard.rawValue
        optionPanel.dropShadow(opacity: 0.5)
    }
}
