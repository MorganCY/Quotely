//
//  BaseProfileViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/20.
//

import Foundation
import UIKit
import PhotosUI

class MyViewController: BaseProfileViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        visitedUid = UserManager.shared.visitorUserInfo?.uid

        navigationItem.setupRightBarButton(
            image: UIImage.sfsymbol(.settings),
            text: nil,
            target: self,
            action: #selector(tapSettingsButton(_:)),
            color: .M1)
    }

    func createImage(image: UIImage, imagePicker: UIImagePickerController) {

        ImageManager.shared.createImage(image: image) { result in

            switch result {

            case .success(let url):
                Toast.shared.hud.dismiss()
                self.updateUserInfo(imageUrl: url, userName: nil)

            case .failure(let error):
                print(error)
                Toast.showFailure(text: ToastText.failToUpload.rawValue)
                imagePicker.dismiss(animated: true)
            }
        }
    }

    func updateUserInfo(imageUrl: String?, userName: String?) {

        UserManager.shared.updateUserInfo(
            profileImageUrl: imageUrl,
            userName: userName
        ) { result in

            switch result {

            case .success(let success):
                print(success)

                if imageUrl != nil {
                    self.fetchVisitedUserInfo(uid: UserManager.shared.visitorUserInfo?.uid ?? "")
                    Toast.shared.hud.dismiss()
                }

            case .failure(let error):
                print(error)
                Toast.showFailure(text: ToastText.failToUpdate.rawValue)
            }
        }
    }

    @available(iOS 14, *)
    func createImage(image: UIImage, phpicker: PHPickerViewController) {

        ImageManager.shared.createImage(image: image) { result in

            switch result {

            case .success(let url):
                Toast.shared.hud.dismiss()
                self.updateUserInfo(imageUrl: url, userName: nil)

            case .failure(let error):
                print(error)
                Toast.showFailure(text: ToastText.failToUpload.rawValue)
                phpicker.dismiss(animated: true, completion: nil)
            }
        }
    }

    @objc func tapSettingsButton(_ sender: UIBarButtonItem) {

        guard let settingsVC =
                UIStoryboard.profile.instantiateViewController(
                    withIdentifier: SettingsViewController.identifier
                ) as? SettingsViewController
        else { return }

        let navigationVC = BaseNavigationController(rootViewController: settingsVC)

        navigationVC.modalPresentationStyle = .fullScreen

        present(navigationVC, animated: true)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: ProfileTableViewHeaderView.identifier
        ) as? ProfileTableViewHeaderView else {

            fatalError("Cannot create header view")
        }

        guard let userInfo = UserManager.shared.visitorUserInfo else {

            return UITableViewHeaderFooterView()
        }

        header.layoutMyHeader(userInfo: userInfo)

        let goToFollowListGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(tapFollowNumberLabel(_:)))

        header.followStackView.addGestureRecognizer(goToFollowListGesture)
        header.followStackView.isUserInteractionEnabled = true
        header.editImageHandler = {

            self.openImagePicker()
        }

        header.editNameHandler = { userName in

            self.updateUserInfo(imageUrl: nil, userName: userName)
        }

        return header
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProfileTableViewCell.identifier,
            for: indexPath
        ) as? ProfileTableViewCell else {

            fatalError("Cannot create cell")
        }

        guard let post = visitedUserPostList?[indexPath.row] else {

            return UITableViewCell()
        }

        cell.layoutCell(post: post)
        cell.hideSelectionStyle()

        return cell
    }

    override func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {

        picker.dismiss(animated: true)

        Toast.showLoading(text: ToastText.uploading.rawValue)

        guard let selectedImage = info[.editedImage] as? UIImage else {

            return
        }

        ImageManager.shared.deleteImage(
            imageUrl: self.visitedUserInfo?.profileImageUrl ?? "") { result in

                switch result {

                case .success(let success):
                    print(success)
                    self.createImage(image: selectedImage, imagePicker: picker)

                case .failure(let error):
                    print(error)
                }
            }
    }

    @available(iOS 14, *)
    override func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)

        Toast.showLoading(text: ToastText.uploading.rawValue)

        guard !results.isEmpty else { return }

        for result in results {

            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (image, error) in

                guard let selectedImage = image as? UIImage else {

                    DispatchQueue.main.async {

                        picker.dismiss(animated: true)
                    }

                    return
                }

                ImageManager.shared.deleteImage(
                    imageUrl: self.visitedUserInfo?.profileImageUrl ?? "") { result in

                        switch result {

                        case .success(let success):
                            print(success)
                            self.createImage(image: selectedImage, phpicker: picker)

                        case .failure(let error):
                            print(error)
                        }
                    }
            })
        }
    }
}
