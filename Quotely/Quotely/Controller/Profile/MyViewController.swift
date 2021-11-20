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

        navigationItem.setupRightBarButton(
            image: UIImage.sfsymbol(.settings),
            text: nil,
            target: self,
            action: #selector(tapSettingsButton(_:)),
            color: .M1
        )
    }

    @objc func tapSettingsButton(_ sender: UIBarButtonItem) {

        guard let settingsVC =
                UIStoryboard.profile
                .instantiateViewController(
                    withIdentifier: String(describing: SettingsViewController.self)
                ) as? SettingsViewController else {

                    return
                }

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

        guard let userInfo = visitedUserInfo else {

            return UITableViewHeaderFooterView()
        }

        header.layoutMyHeader(userInfo: userInfo)

        let goToFollowListGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(goToFollowList(_:))
        )

        header.followStackView.addGestureRecognizer(goToFollowListGesture)
        header.followStackView.isUserInteractionEnabled = true

        header.editImageHandler = {

            self.openImagePicker()
        }

        header.editNameHandler = { userName in

            UserManager.shared.updateUserInfo(
                uid: userInfo.uid,
                profileImageUrl: nil,
                userName: userName
            ) { result in

                switch result {

                case .success(let success):
                    print(success)

                case .failure(let error):
                    print(error)
                }
            }
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

        let post = visitedUserPostList[indexPath.row]

        cell.layoutCell(post: post)
        cell.hideSelectionStyle()

        return cell
    }

    override func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {

        picker.dismiss(animated: true)

        Toast.showLoading(text: "上傳中")

        guard let selectedImage = info[.editedImage] as? UIImage else {

            return
        }

        // remove original image from firebase storage

        ImageManager.shared.deleteImage(
            imageUrl: self.visitedUserInfo?.profileImageUrl ?? "") { result in

                switch result {

                case .failure(let error): print(error)

                case .success(let success):

                    print(success)

                    // upload new image to firebase storage

                    ImageManager.shared.uploadImage(image: selectedImage) { result in

                        switch result {

                        case .success(let url):

                            Toast.shared.hud.dismiss()

                            // update user profile image in firestore

                            UserManager.shared.updateUserInfo(
                                uid: self.visitedUserInfo?.uid ?? "",
                                profileImageUrl: url,
                                userName: nil
                            ) { result in

                                    switch result {

                                    case .success(let success):

                                        print(success)

                                        self.fetchVisitedUserInfo(uid: self.visitedUserInfo?.uid ?? "")

                                        Toast.shared.hud.dismiss()

                                    case .failure(let error):

                                        print(error)

                                        Toast.showFailure(text: "上傳失敗")
                                    }
                                }

                        case .failure(let error):

                            print(error)

                            Toast.showFailure(text: "上傳失敗")

                            picker.dismiss(animated: true)
                        }
                    }
                }
            }
    }

    @available(iOS 14, *)
    override func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)

        Toast.showLoading(text: "上傳中")

        guard !results.isEmpty else { return }

        for result in results {

            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (image, error) in

                guard let selectedImage = image as? UIImage else {

                    DispatchQueue.main.async {

                        picker.dismiss(animated: true)
                    }

                    return
                }

                // remove original image from firebase storage

                ImageManager.shared.deleteImage(
                    imageUrl: self.visitedUserInfo?.profileImageUrl ?? "") { result in

                        switch result {

                        case .failure(let error): print(error)

                        case .success(let success):

                            print(success)

                            // upload new image to firebase storage

                            ImageManager.shared.uploadImage(image: selectedImage) { result in

                                switch result {

                                case .success(let url):

                                    Toast.shared.hud.dismiss()

                                    // update profile image in firestore

                                    UserManager.shared.updateUserInfo(
                                        uid: self.visitedUserInfo?.uid ?? "",
                                        profileImageUrl: url,
                                        userName: nil
                                    ) { result in

                                            switch result {

                                            case .success(let success):

                                                print(success)

                                                self.fetchVisitedUserInfo(uid: self.visitedUserInfo?.uid ?? "")

                                                Toast.shared.hud.dismiss()

                                            case .failure(let error):

                                                print(error)

                                                Toast.showFailure(text: "上傳失敗")
                                            }
                                        }

                                case .failure(let error):

                                    print(error)

                                    Toast.showFailure(text: "上傳失敗")

                                    picker.dismiss(animated: true)
                                }
                            }
                        }
                    }
            })
        }
    }
}
