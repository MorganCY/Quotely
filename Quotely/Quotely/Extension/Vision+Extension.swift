//
//  BaseImagePickerViewController+Extension.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/11/28.
//

import Foundation
import UIKit
import Vision

extension BaseImagePickerViewController {

    func recognizeText(image: UIImage?,
                       textHandler: @escaping (_ text: String) -> Void) {

        guard let cgImage = image?.cgImage else {
            return
        }

        Toast.showLoading(text: ToastText.scanning.rawValue)

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        let request = VNRecognizeTextRequest { request, error in

            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {

                      Toast.showFailure(text: ToastText.failToScan.rawValue)
                      return
                  }

            let text = observations.compactMap {

                $0.topCandidates(1).first?.string

            }.joined()

            DispatchQueue.main.async {
                textHandler(text)
            }
            Toast.shared.hud.dismiss()
        }

        request.recognitionLanguages = ["zh-Hant", "en"]

        do {
            try handler.perform([request])
        } catch {
            print(error)
            Toast.showFailure(text: ToastText.failToScan.rawValue)
        }
    }
}
