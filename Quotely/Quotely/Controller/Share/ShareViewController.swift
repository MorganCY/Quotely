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

    enum TemplateType {

        case fullImage
        case halfImage
        case smallImage
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

    var fullImageTemplateView = ShareTemplateView(type: .fullImage, content: "", author: "")
    var halfImageTemplateView = ShareTemplateView(type: .halfImage, content: "", author: "")
    var smallImageTemplateView = ShareTemplateView(type: .smallImage, content: "", author: "")

    var templateViews: [ShareTemplateView] {

        return [fullImageTemplateView, halfImageTemplateView, smallImageTemplateView]
    }

    var templateImage: UIImage? {
        didSet {
            templateViews.forEach { $0.dataSource = self }
        }
    }

    let uploadImageButton = ImageButton(image: UIImage.sfsymbol(.photo)!, color: .white, bgColor: .black)

    let templateSelectionView = SelectionView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 242 / 255, green: 255 / 255, blue: 243 / 255, alpha: 1)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(dismissSelf(_:))
        )

        layoutTemplateView()

        layoutSelectionView()

        configureUploadImageButton(templateType: .fullImage)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        templateViews.forEach { $0.dropShadow(opacity: 0.5) }

        uploadImageButton.cornerRadius = uploadImageButton.frame.width / 2
    }

    @objc func dismissSelf(_ sender: UIBarButtonItem) {

        self.dismiss(animated: true, completion: nil)
    }

    func layoutTemplateView() {

        fullImageTemplateView.isHidden = false
        halfImageTemplateView.isHidden = true
        smallImageTemplateView.isHidden = true

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

        view.addSubview(templateSelectionView)
        templateSelectionView.translatesAutoresizingMaskIntoConstraints = false
        templateSelectionView.dataSource = self
        templateSelectionView.delegate = self

        NSLayoutConstraint.activate([

            templateSelectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            templateSelectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            templateSelectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
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

    override func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {

        picker.dismiss(animated: true)

        guard let selectedImage = info[.editedImage] as? UIImage else {

            Toast.showFailure(text: "圖片載入問題")
            fatalError("Cannot load image")
        }

        DispatchQueue.main.async {

            self.templateImage = selectedImage
        }
    }

    @available(iOS 14, *)
    override func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)

        guard !results.isEmpty else {

            Toast.showFailure(text: "圖片載入問題")
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

        templateViews.forEach { $0.isHidden = true }
        templateViews[index].isHidden = false

        switch index {

        case 0: configureUploadImageButton(templateType: .fullImage)
        case 1: configureUploadImageButton(templateType: .halfImage)
        case 2: configureUploadImageButton(templateType: .smallImage)
        default: break
        }
    }
}
