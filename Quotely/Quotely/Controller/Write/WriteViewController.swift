//
//  WriteViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/18.
//

import Foundation
import UIKit

class WriteViewController: UIViewController {

    private let contentTextView = UITextView()

    private let hashtagLabel = UILabel()

    private let socialShareButton = VerticalButton(title: "社群分享", image: UIImage.sfsymbol(.shareNormal), padding: 4.0)

    private let cameraScanButton = UIButton()

    private let photoUploadButton = UIButton()

    private let buttonStackView = UIStackView()

    private let postImageView = UIImageView()

    var imagePicker = UIImagePickerController()

    let postManager = PostManager()

    let imageManager = ImageManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "撰寫摘語"

        contentTextView.delegate = self

        layoutButtons()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "分享", style: .plain, target: self, action: #selector(publish(_:)))

        activateButtons()

        imagePicker.delegate = self
    }

    override func viewDidLayoutSubviews() {

        layoutViews()

        layoutButtonIcons()
    }

    @objc func uploadImage(_ sender: UIButton) {

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

    @objc func publish(_ sender: UIBarButtonItem) {

        guard let image = postImageView.image else { return }

        imageManager.uploadImage(image: image) { result in

            switch result {

            case .success(let url):

                guard let content = self.contentTextView.text else {

                    self.present(UIAlertController(title: "請輸入內容", message: nil, preferredStyle: .alert), animated: true)

                    return
                }

                let post = Post(
                    uid: "test123456",
                    createdTime: Date().millisecondsSince1970,
                    editTime: nil,
                    content: content,
                    imageUrl: url,
                    hashtag: nil,
                    likeNumber: nil,
                    likeUser: nil,
                    commentNumber: nil)

                self.postManager.publishPost(post: post) { _ in

                    self.dismiss(animated: true, completion: nil)
                }

            case .failure(let error):

                print(error)
            }
        }
    }

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

        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }

    func activateButtons() {

        photoUploadButton.addTarget(self, action: #selector(uploadImage(_:)), for: .touchUpInside)
    }

    private func layoutViews() {

        self.view.addSubview(contentTextView)
        self.view.addSubview(hashtagLabel)
        self.view.addSubview(postImageView)

        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        hashtagLabel.translatesAutoresizingMaskIntoConstraints = false
        postImageView.translatesAutoresizingMaskIntoConstraints = false

        hashtagLabel.text = "新增標籤"
        contentTextView.text = "有什麼感觸...?"
        contentTextView.textColor = .gray
        hashtagLabel.textColor = .black
        contentTextView.font = UIFont.systemFont(ofSize: 18)
        hashtagLabel.font = UIFont.systemFont(ofSize: 18)

        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.layer.cornerRadius = 10

        NSLayoutConstraint.activate([

            contentTextView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            contentTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
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

    func layoutButtons() {

        let buttons = [socialShareButton, cameraScanButton, photoUploadButton]

        self.view.addSubview(buttonStackView)
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 30
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false

        buttons.forEach {

            buttonStackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.imageView?.contentMode = .scaleAspectFit
        }

//        socialShareButton.setTitle("社群分享", for: .normal)
//        socialShareButton.setTitleColor(.gray, for: .normal)
//        socialShareButton.titleLabel?.text = "社群分享"

        NSLayoutConstraint.activate([

            buttonStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            socialShareButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.08),
            socialShareButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2),
            cameraScanButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.08),
            cameraScanButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2),
            photoUploadButton.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.08),
            photoUploadButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2)
        ])
    }

    func layoutButtonIcons() {

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: socialShareButton.frame.width, weight: .regular, scale: .large)

//        socialShareButton.setImage(UIImage.sfsymbol(.shareNormal)?.withConfiguration(symbolConfig), for: .normal)

        cameraScanButton.setImage(UIImage.sfsymbol(.cameraNormal)?.withConfiguration(symbolConfig), for: .normal)
        cameraScanButton.setTitle("掃描文字", for: .normal)
        cameraScanButton.setTitleColor(.gray, for: .normal)

        photoUploadButton.setImage(UIImage.sfsymbol(.photo)?.withConfiguration(symbolConfig), for: .normal)
        photoUploadButton.setTitle("上傳照片", for: .normal)
        photoUploadButton.setTitleColor(.gray, for: .normal)
    }
}

extension WriteViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {

        contentTextView.text = ""

        contentTextView.textColor = UIColor.black

        if !contentTextView.text!.isEmpty && contentTextView.text! == "有什麼感觸...?" {

            contentTextView.text = ""

            contentTextView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {

        if contentTextView.text.isEmpty {

            contentTextView.text = "有什麼感觸...?"

            contentTextView.textColor = UIColor.lightGray

        }
    }
}

extension WriteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let selectedImage = info[.editedImage] as? UIImage else {

            return
        }

        postImageView.image = selectedImage

        dismiss(animated: true)
    }
}
