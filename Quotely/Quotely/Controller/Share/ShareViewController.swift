//
//  ShareViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/1.
//

import Foundation
import UIKit
import PhotosUI

class ShareViewController: BaseImagePickerViewController {

    /*
     * Templates
     */
    enum TemplateType {

        case fullImage
        case halfImage
        case smallImage
    }

    var currentTemplateType: TemplateType = .fullImage {
        didSet {
            fullImageTemplateView.isHidden = !(currentTemplateType == .fullImage)
            halfImageTemplateView.isHidden = !(currentTemplateType == .halfImage)
            smallImageTemplateView.isHidden = !(currentTemplateType == .smallImage)

            sharingImage = {
                switch currentTemplateType {

                case .fullImage: return fullImageTemplateView.convertToImage()
                case .halfImage: return halfImageTemplateView.convertToImage()
                case .smallImage: return smallImageTemplateView.convertToImage()
                }
            }()
        }
    }

    var fullImageTemplateView = ShareTemplateView(type: .fullImage, content: "", author: "")
    var halfImageTemplateView = ShareTemplateView(type: .halfImage, content: "", author: "")
    var smallImageTemplateView = ShareTemplateView(type: .smallImage, content: "", author: "")
    var templateViews: [ShareTemplateView] {

        return [fullImageTemplateView, halfImageTemplateView, smallImageTemplateView]
    }
    let templateSelectionView = SelectionView()
    let selectionViewBackground = UIView()

    /*
     * Template content
     */
    var sharingImage = UIImage()

    var templateImage: UIImage? {
        didSet {
            templateViews.forEach { $0.dataSource = self }
        }
    }

    var templateContent: [String] = [] {
        didSet {
            fullImageTemplateView = ShareTemplateView(
                type: .fullImage,
                content: templateContent[0],
                author: templateContent[1]
            )
            halfImageTemplateView = ShareTemplateView(
                type: .halfImage,
                content: templateContent[0],
                author: templateContent[1]
            )
            smallImageTemplateView = ShareTemplateView(
                type: .smallImage,
                content: templateContent[0],
                author: templateContent[1]
            )
        }
    }

    let uploadImageButton = ImageButton(image: UIImage.sfsymbol(.photo)!, color: .white, bgColor: .black)

    /*
     * Share to social media
     */
    let dimmingView = UIView()
    let shareOptionPanel = UIView()
    let instagramButton = RowButton(image: UIImage.asset(.instagram)!, imageColor: .M2!, text: "Instagram 限時動態")
    let savePhotoButton = RowButton(image: UIImage.sfsymbol(.download)!, imageColor: .M2!, text: "下載至裝置")
    var optionPanelViews: [UIView] {

        return [dimmingView, shareOptionPanel, instagramButton, savePhotoButton]
    }
    var isSharing = false {
        didSet {
            self.optionPanelViews.forEach { $0.isHidden = !self.isSharing }
            if isSharing { optionPanelViews.forEach { view.bringSubviewToFront($0) } }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 242 / 255, green: 255 / 255, blue: 243 / 255, alpha: 1)
        setupNavigaiton()
        layoutTemplateView()
        layoutSelectionView()
        configureUploadImageButton(templateType: .fullImage)
        configureShareOption()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        templateViews.forEach { $0.dropShadow(opacity: 0.5) }
        uploadImageButton.cornerRadius = uploadImageButton.frame.width / 2
    }

    @objc func dismissSelf(_ sender: UIBarButtonItem) {

        dismiss(animated: true, completion: nil)
    }

    @objc func expandOptionPanel(_ sender: UIBarButtonItem) {

        isSharing = true
    }

    @objc func collapseOptionPanel(_ sender: UITapGestureRecognizer) { isSharing = false }

    @objc func shareToInstagramStory(_ sender: UIButton) {

        if let storiesUrl = URL(string: "instagram-stories://share") {

            if UIApplication.shared.canOpenURL(storiesUrl) {

                guard let imageData = sharingImage.pngData() else { return }

                let pasteboardItems: [String: Any] = [
                    "com.instagram.sharedSticker.stickerImage": imageData,
                    "com.instagram.sharedSticker.backgroundTopColor": UIColor.M1?.toHexString() ?? "#757E66",
                    "com.instagram.sharedSticker.backgroundBottomColor": UIColor.M2?.toHexString() ?? "#D3D6C9"
                ]

                let pasteboardOptions = [
                    UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)
                ]

                UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)

                UIApplication.shared.open(storiesUrl, options: [:], completionHandler: nil)

            } else {

                Toast.showFailure(text: "裝置未安裝Instagram")
                print("User doesn't have instagram on their device.")
            }
        }
    }

    @objc func saveImageToDevice(_ sender: UIButton) {

        UIImageWriteToSavedPhotosAlbum(sharingImage, nil, nil, nil)
        isSharing = false
        Toast.showSuccess(text: "已下載")
    }

    override func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {

        picker.dismiss(animated: true) {

            Toast.showLoading(text: "載入中")
        }

        guard let selectedImage = info[.editedImage] as? UIImage else {

            Toast.showFailure(text: "圖片載入異常")
            fatalError("Cannot load image")
        }

        DispatchQueue.main.async {

            Toast.shared.hud.dismiss()
            self.templateImage = selectedImage
        }
    }

    @available(iOS 14, *)
    override func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true) {

            Toast.showLoading(text: "載入中")
        }

        guard !results.isEmpty else {

            Toast.showFailure(text: "圖片載入異常")
            return
        }

        for result in results {

            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (image, _) in

                guard let selectedImage = image as? UIImage else {

                    DispatchQueue.main.async {

                        picker.dismiss(animated: true)
                    }

                    return
                }

                DispatchQueue.main.async {

                    Toast.shared.hud.dismiss()
                    self.templateImage = selectedImage
                }
            })
        }
    }
}

extension ShareViewController: ShareTemplateViewDataSource {

    func imageOfTemplateContent(_ view: ShareTemplateView) -> UIImage {

        return templateImage ?? UIImage.asset(.plant)!
    }
}

extension ShareViewController: SelectionViewDataSource, SelectionViewDelegate {
    func buttonStyle(_ view: SelectionView) -> ButtonStyle { .text }

    func numberOfButtonsAt(_ view: SelectionView) -> Int { templateViews.count }

    func buttonTitle(_ view: SelectionView, index: Int) -> String {

        let titles = ["滿版圖片", "半張圖片", "小張圖片"]

        view.buttons[0].setTitleColor(.black, for: .normal)

        return titles[index]
    }

    func buttonColor(_ view: SelectionView) -> UIColor { .lightGray }

    func indicatorColor(_ view: SelectionView) -> UIColor { .clear }

    func indicatorWidth(_ view: SelectionView) -> CGFloat { 0 }

    func shouldSelectButtonAt(_ view: SelectionView, at index: Int) -> Bool { true }

    func didSelectButtonAt(_ view: SelectionView, at index: Int) {

        view.buttons.forEach { $0.setTitleColor(.lightGray, for: .normal) }
        view.buttons[index].setTitleColor(.black, for: .normal)

        switch index {

        case 0:

            configureUploadImageButton(templateType: .fullImage)
            currentTemplateType = .fullImage

        case 1:

            configureUploadImageButton(templateType: .halfImage)
            currentTemplateType = .halfImage

        case 2:

            configureUploadImageButton(templateType: .smallImage)
            currentTemplateType = .smallImage

        default: break
        }
    }
}

/*
 * Layout views
 */
extension ShareViewController {

    func setupNavigaiton() {

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissSelf(_:))
        )

        navigationItem.setupRightBarButton(
            image: nil,
            text: "分享",
            target: self,
            action: #selector(expandOptionPanel(_:)),
            color: .black
        )
    }

    func layoutTemplateView() {

        fullImageTemplateView.isHidden = !(currentTemplateType == .fullImage)
        halfImageTemplateView.isHidden = !(currentTemplateType == .halfImage)
        smallImageTemplateView.isHidden = !(currentTemplateType == .smallImage)

        templateViews.forEach {

            view.addSubview($0)
            $0.dataSource = self
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.cornerRadius = CornerRadius.standard.rawValue
            $0.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85).isActive = true
        }

        NSLayoutConstraint.activate([
            fullImageTemplateView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            fullImageTemplateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            halfImageTemplateView.topAnchor.constraint(equalTo: fullImageTemplateView.topAnchor),
            halfImageTemplateView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            smallImageTemplateView.topAnchor.constraint(equalTo: fullImageTemplateView.topAnchor),
            smallImageTemplateView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
    }

    func layoutSelectionView() {

        view.addSubview(selectionViewBackground)
        view.addSubview(templateSelectionView)
        templateSelectionView.translatesAutoresizingMaskIntoConstraints = false
        selectionViewBackground.translatesAutoresizingMaskIntoConstraints = false
        templateSelectionView.dataSource = self
        templateSelectionView.delegate = self
        selectionViewBackground.backgroundColor = .white

        NSLayoutConstraint.activate([

            templateSelectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            templateSelectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            templateSelectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            selectionViewBackground.topAnchor.constraint(equalTo: templateSelectionView.topAnchor, constant: -24),
            selectionViewBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            selectionViewBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            selectionViewBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func configureUploadImageButton(templateType: TemplateType) {

        uploadImageButton.addTarget(self, action: #selector(openImagePicker(_:)), for: .touchUpInside)

        view.addSubview(uploadImageButton)
        uploadImageButton.translatesAutoresizingMaskIntoConstraints = false
        uploadImageButton.borderColor = .white
        uploadImageButton.borderWidth = 1

        switch templateType {

        case .fullImage:

            NSLayoutConstraint.activate([

                uploadImageButton.topAnchor.constraint(equalTo: fullImageTemplateView.topAnchor, constant: 16),
                uploadImageButton.trailingAnchor.constraint(equalTo: fullImageTemplateView.trailingAnchor, constant: -16),
                uploadImageButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1),
                uploadImageButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1)
            ])

        case .halfImage:

            NSLayoutConstraint.activate([

                uploadImageButton.topAnchor.constraint(equalTo: halfImageTemplateView.topAnchor, constant: 16),
                uploadImageButton.trailingAnchor.constraint(equalTo: halfImageTemplateView.trailingAnchor, constant: -16),
                uploadImageButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1),
                uploadImageButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1)
            ])

        case .smallImage:

            NSLayoutConstraint.activate([

                uploadImageButton.topAnchor.constraint(equalTo: smallImageTemplateView.topAnchor, constant: 16),
                uploadImageButton.trailingAnchor.constraint(equalTo: smallImageTemplateView.trailingAnchor, constant: -16),
                uploadImageButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1),
                uploadImageButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1)
            ])
        }
    }

    func configureShareOption() {

        let dismissOptionGesture = UITapGestureRecognizer(target: self, action: #selector(collapseOptionPanel(_:)))

        optionPanelViews.forEach {

            view.addSubview($0)
            view.bringSubviewToFront($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isHidden = !isSharing
        }

        shareOptionPanel.backgroundColor = .white

        dimmingView.backgroundColor = .black.withAlphaComponent(0.5)
        dimmingView.addGestureRecognizer(dismissOptionGesture)

        shareOptionPanel.setSpecificCorner(
            radius: CornerRadius.standard.rawValue,
            corners: [.topLeft, .topRight]
        )

        instagramButton.addTarget(self, action: #selector(shareToInstagramStory(_:)), for: .touchUpInside)
        savePhotoButton.addTarget(self, action: #selector(saveImageToDevice(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([

            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            shareOptionPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            shareOptionPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            shareOptionPanel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            shareOptionPanel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25),

            instagramButton.leadingAnchor.constraint(equalTo: shareOptionPanel.leadingAnchor),
            instagramButton.trailingAnchor.constraint(equalTo: shareOptionPanel.trailingAnchor),
            instagramButton.topAnchor.constraint(equalTo: shareOptionPanel.topAnchor),
            instagramButton.heightAnchor.constraint(equalTo: shareOptionPanel.heightAnchor, multiplier: 0.4),

            savePhotoButton.leadingAnchor.constraint(equalTo: instagramButton.leadingAnchor),
            savePhotoButton.trailingAnchor.constraint(equalTo: instagramButton.trailingAnchor),
            savePhotoButton.topAnchor.constraint(equalTo: instagramButton.bottomAnchor),
            savePhotoButton.heightAnchor.constraint(equalTo: shareOptionPanel.heightAnchor, multiplier: 0.4)
        ])
    }
}
