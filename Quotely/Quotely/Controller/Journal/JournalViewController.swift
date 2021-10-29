//
//  JournalViewController.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/26.
//

import Foundation
import UIKit
import SwiftUI

class JournalViewController: UIViewController {

    let defaults = UserDefaults.standard

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dailyQuoteLabel: UILabel!

    var selectedEmoji: SFSymbol?

    let backgroundView = UIView()
    let editPanel = UIView()
    let panelTitle = UILabel()
    let buttonImages = [
        UIImage.sfsymbol(.smile),
        UIImage.sfsymbol(.book),
        UIImage.sfsymbol(.umbrella),
        UIImage.sfsymbol(.moon),
        UIImage.sfsymbol(.fire),
        UIImage.sfsymbol(.music)
    ]
    var emojiSelection = SelectionView()
    var journalTextView = ContentTextView()
    let submitButton = UIButton()
    let collapseButton = ImageButton(image: UIImage.sfsymbol(.collapse)!, color: .white)
    var buttonStack = UIStackView()
    let paletteButton = ImageButton(image: UIImage.sfsymbol(.color)!, color: .lightGray)
    let likeButton = ImageButton(image: UIImage.sfsymbol(.heartNormal)!, color: .lightGray)

    var editPanelCollapse = NSLayoutConstraint()
    var editPanelExpand = NSLayoutConstraint()
    var backgroundViewCollapse = NSLayoutConstraint()
    var backgroundViewExpand = NSLayoutConstraint()
    var backgroundViewCornerRadius = CGFloat()
    var journalTextViewCollapse = NSLayoutConstraint()
    var journalTextViewExpand = NSLayoutConstraint()

    var isEditPanelExpand = false {
        didSet {
            expandAnimation()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.BG

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

        navigationController?.navigationBar.shadowImage = UIImage()

        setupBackgroundView()

        setupEditPanel()

        setupButtons()

        setupCollapseButton()

        setupTitle()

        submitButton.addTarget(self, action: #selector(submitJournal(_:)), for: .touchUpInside)

        fetchQuoteOncePerDay()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        backgroundView.cornerRadius = isEditPanelExpand
        ?
        0 : backgroundView.frame.width / 2
        collapseButton.cornerRadius = collapseButton.frame.width / 2

        editPanel.dropShadow(opacity: 0.4)
        paletteButton.dropShadow(opacity: 0.2, width: 3, height: 3, radius: 3)
        likeButton.dropShadow(opacity: 0.2, width: 3, height: 3, radius: 3)
    }

    @objc func submitJournal(_ sender: UIButton) {

        var journal = Journal(
            uid: "test123456",
            createdTime: Date().millisecondsSince1970,
            emoji: "\(selectedEmoji ?? .smile)",
            content: journalTextView.text)

        JournalManager.shared.addJournal(
            journal: &journal
        ) { result in

            switch result {

            case .success(let success):
                print(success)
                self.isEditPanelExpand = false
                self.journalTextView.text.removeAll()

            case .failure(let error):
                print(error)
            }
        }
    }

    func fetchQuoteOncePerDay() {

        let lastJournalCall = defaults.string(forKey: "LastJournalCall")

        let currentDate = Date().getCurrentTime(format: .dd)

        if lastJournalCall != nil {

            if currentDate != lastJournalCall {

                fetchQuote()
                defaults.set(currentDate, forKey: "LastJournalCall")

            } else {

                self.dailyQuoteLabel.text = defaults.string(forKey: "LastJournalQuote")
            }

        } else {

            fetchQuote()
            defaults.set(currentDate, forKey: "LastJournalCall")
        }
    }

    func fetchQuote() {

        CardManager.shared.fetchRandomCards(
            limitNumber: 1) { result in

                switch result {

                case .success(let cards):

                    let lastJournalQuote = "\(cards.first?.content ?? "")\n\n\(cards.first?.author ?? "")"

                    self.defaults.set(lastJournalQuote, forKey: "LastJournalQuote")

                    self.dailyQuoteLabel.text = lastJournalQuote

                case .failure(let error):
                    print(error)
                }
            }
    }

    @objc func collapseEditPanel(_ sender: UIButton) {

        isEditPanelExpand = false
    }

    func expandAnimation() {

        UIView.animate(
            withDuration: 1 / 2,
            delay: 0,
            options: .curveEaseIn
        ) {
            self.editPanelCollapse.isActive = !self.isEditPanelExpand
            self.editPanelExpand.isActive = self.isEditPanelExpand

            self.backgroundViewCollapse.isActive = !self.isEditPanelExpand
            self.backgroundViewExpand.isActive = self.isEditPanelExpand

            self.backgroundView.cornerRadius = self.isEditPanelExpand
            ?
            0 : self.backgroundView.frame.width / 2

            self.journalTextViewCollapse.isActive = !self.isEditPanelExpand
            self.journalTextViewExpand.isActive = self.isEditPanelExpand

            self.submitButton.isHidden = !self.isEditPanelExpand

            self.collapseButton.isHidden = !self.isEditPanelExpand

            self.paletteButton.isHidden = self.isEditPanelExpand

            self.likeButton.isHidden = self.isEditPanelExpand

            self.view.layoutIfNeeded()
        }
    }
}

extension JournalViewController: SelectionViewDataSource {

    // swiftlint:disable identifier_name
    func numberOfButtonsAt(_ view: SelectionView) -> Int {
        buttonImages.count
    }

    func buttonStyle(_view: SelectionView) -> ButtonStyle { .image }

    func buttonColor(_ view: SelectionView) -> UIColor { .lightGray }

    func indicatorColor(_ view: SelectionView) -> UIColor { .M1 ?? .black }

    func buttonImage(_ view: SelectionView, index: Int) -> UIImage {

        view.buttons[0].tintColor = .black
        return buttonImages[index] ?? UIImage()
    }
}

extension JournalViewController: SelectionViewDelegate {

    func didSelectButtonAt(_ view: SelectionView, at index: Int) {

        view.buttons.forEach {
            $0.tintColor = .lightGray
        }
        view.buttons[index].tintColor = .black

        if isEditPanelExpand == false {
            isEditPanelExpand = true
        }

        switch index {

        case 0: selectedEmoji = .smile
        case 1: selectedEmoji = .book
        case 2: selectedEmoji = .umbrella
        case 3: selectedEmoji = .moon
        case 4: selectedEmoji = .fire
        case 5: selectedEmoji = .music
        default: selectedEmoji = .smile
        }
    }

    func shouldSelectButtonAt(_ view: SelectionView, at index: Int) -> Bool { true }
}

extension JournalViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        isEditPanelExpand = journalTextView.isFirstResponder
        ? true : false
    }
}

// MARK: SetupViews
extension JournalViewController {

    func setupTitle() {

        dateLabel.text = "\(Date().getCurrentTime(format: .dd))"
        monthLabel.text = "\(Date().getCurrentTime(format: .MM))月"
    }

    func setupEditPanel() {

        let panelObjects = [editPanel, panelTitle, emojiSelection, journalTextView, submitButton]

        panelObjects.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        editPanel.backgroundColor = .white
        editPanel.cornerRadius = CornerRadius.standard.rawValue
        emojiSelection.dataSource = self
        emojiSelection.delegate = self
        journalTextView.delegate = self
        self.submitButton.isHidden = !self.isEditPanelExpand

        editPanelCollapse = editPanel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25)
        editPanelExpand = editPanel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.45)
        editPanelCollapse.isActive = !isEditPanelExpand
        editPanelExpand.isActive = isEditPanelExpand
        journalTextView.cornerRadius = CornerRadius.standard.rawValue * 0.75

        panelTitle.text = "今日隨筆"
        panelTitle.font = UIFont(name: "Pingfang TC", size: 18)

        journalTextView.placeholder(text: Placeholder.comment.rawValue, color: .lightGray)

        submitButton.setTitle("存檔", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.backgroundColor = .M2
        submitButton.cornerRadius = CornerRadius.standard.rawValue * 0.75
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        journalTextViewCollapse = journalTextView.bottomAnchor.constraint(
            equalTo: editPanel.bottomAnchor,
            constant: -24
        )
        journalTextViewExpand = journalTextView.bottomAnchor.constraint(
            equalTo: self.submitButton.topAnchor,
            constant: -16
        )
        journalTextViewCollapse.isActive = !isEditPanelExpand

        NSLayoutConstraint.activate([
            editPanel.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 32),
            editPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editPanel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),

            panelTitle.leadingAnchor.constraint(equalTo: editPanel.leadingAnchor, constant: 16),
            panelTitle.topAnchor.constraint(equalTo: editPanel.topAnchor, constant: 16),

            emojiSelection.leadingAnchor.constraint(equalTo: panelTitle.leadingAnchor),
            emojiSelection.topAnchor.constraint(equalTo: panelTitle.bottomAnchor, constant: 24),
            emojiSelection.widthAnchor.constraint(equalTo: editPanel.widthAnchor, multiplier: 0.9),
            emojiSelection.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.042),

            journalTextView.topAnchor.constraint(equalTo: emojiSelection.bottomAnchor, constant: 32),
            journalTextView.leadingAnchor.constraint(equalTo: panelTitle.leadingAnchor),
            journalTextView.trailingAnchor.constraint(equalTo: editPanel.trailingAnchor, constant: -16),

            submitButton.leadingAnchor.constraint(equalTo: panelTitle.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: journalTextView.trailingAnchor),
            submitButton.heightAnchor.constraint(equalTo: editPanel.heightAnchor, multiplier: 0.12),
            submitButton.bottomAnchor.constraint(equalTo: editPanel.bottomAnchor, constant: -24)
        ])
    }

    func setupCollapseButton() {

        view.addSubview(collapseButton)
        collapseButton.translatesAutoresizingMaskIntoConstraints = false
        collapseButton.isHidden = !isEditPanelExpand
        collapseButton.backgroundColor = .clear
        collapseButton.addTarget(self, action: #selector(collapseEditPanel(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([
            collapseButton.centerXAnchor.constraint(equalTo: editPanel.centerXAnchor),
            collapseButton.topAnchor.constraint(equalTo: editPanel.bottomAnchor, constant: 32),
            collapseButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.1),
            collapseButton.heightAnchor.constraint(equalTo: collapseButton.widthAnchor)])
    }

    func setupButtons() {

        let buttons = [paletteButton, likeButton]
        view.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.spacing = 64

        buttons.forEach {
            buttonStack.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .white
            $0.isHidden = isEditPanelExpand
            $0.cornerRadius = CornerRadius.standard.rawValue
        }

        NSLayoutConstraint.activate([
            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStack.topAnchor.constraint(equalTo: editPanel.bottomAnchor, constant: 48),

            paletteButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),
            paletteButton.heightAnchor.constraint(equalTo: paletteButton.widthAnchor),

            likeButton.widthAnchor.constraint(equalTo: paletteButton.widthAnchor),
            likeButton.heightAnchor.constraint(equalTo: paletteButton.widthAnchor)
        ])
    }

    func setupBackgroundView() {

        view.addSubview(backgroundView)
        view.sendSubviewToBack(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        backgroundViewCollapse = backgroundView.centerYAnchor.constraint(equalTo: view.topAnchor, constant: -50)
        backgroundViewExpand = backgroundView.topAnchor.constraint(equalTo: self.view.topAnchor)

        backgroundViewCollapse.isActive = !isEditPanelExpand

        NSLayoutConstraint.activate([
            backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundView.heightAnchor.constraint(equalTo: backgroundView.widthAnchor),
            backgroundView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2)
        ])

        backgroundView.backgroundColor = .M1
    }
}
