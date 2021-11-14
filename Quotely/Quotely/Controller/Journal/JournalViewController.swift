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

    private let dateLabel = UILabel()
    private let dailyQuoteLabel = UILabel()

    var selectedEmoji: SFSymbol?

    let backgroundView = UIView()
    let editPanel = UIView()
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
    let collapseButton = ImageButton(image: UIImage.sfsymbol(.collapse), color: .M1)
    let journalListButton = RowButton(
        image: UIImage.sfsymbol(.calendar),
        imageColor: .M2,
        labelColor: .gray,
        text: "查看所有隻字"
    )

    var editPanelCollapse = NSLayoutConstraint()
    var editPanelExpand = NSLayoutConstraint()
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

        fetchQuoteOncePerDay()
        configureGradientLayer()
        setupTitle()
        setupEditPanel()
        setupButtons()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        backgroundView.cornerRadius = isEditPanelExpand
        ?
        0 : backgroundView.frame.width / 2
        collapseButton.cornerRadius = collapseButton.frame.width / 2
    }

    @objc func submitJournal(_ sender: UIButton) {

        var journal = Journal(
            uid: UserManager.shared.visitorUserInfo?.uid ?? "",
            createdTime: Date().millisecondsSince1970,
            emoji: "\(selectedEmoji?.rawValue ?? "face.smiling")",
            content: journalTextView.text)

        JournalManager.shared.addJournal(
            journal: &journal
        ) { result in

            switch result {

            case .success(let success):
                print(success)
                self.isEditPanelExpand = false
                self.journalTextView.text.removeAll()
                Toast.showSuccess(text: "成功新增隻字")

            case .failure(let error):
                print(error)
                Toast.showFailure(text: "新增隻字失敗")
            }
        }
    }

    @objc func goToFavoriteCardList(_ sender: UIButton) {

        guard let favCardVC =
                UIStoryboard.card
                .instantiateViewController(
                    withIdentifier: String(describing: FavoriteCardViewController.self)
                ) as? FavoriteCardViewController else {

                    return
                }

        show(favCardVC, sender: nil)
    }

    @objc func goToJournalList(_ sender: UIButton) {

        guard let journalListVC =
                UIStoryboard.journal
                .instantiateViewController(
                    withIdentifier: String(describing: JournalListViewController.self)
                ) as? JournalListViewController else {

                    return
                }

        show(journalListVC, sender: nil)
    }

    func fetchQuoteOncePerDay() {

        let lastJournalCall = defaults.string(forKey: "LastJournalCall")

        let currentDate = Date().getCurrentTime(format: .dd)

        if lastJournalCall != nil {

            if currentDate != lastJournalCall {

                fetchQuote()
                defaults.set(currentDate, forKey: "LastJournalCall")

            } else {

                self.dailyQuoteLabel.text = defaults.string(forKey: "LastJournalQuote")?
                    .replacingOccurrences(of: "\\n", with: "\n")
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

                    let lastJournalQuote = "\(cards.first?.content.replacingOccurrences(of: "\\n", with: "\n") ?? "")\n\n\(cards.first?.author ?? "")"

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

            self.backgroundView.cornerRadius = self.isEditPanelExpand
            ?
            0 : self.backgroundView.frame.width / 2

            self.journalTextViewCollapse.isActive = !self.isEditPanelExpand
            self.journalTextViewExpand.isActive = self.isEditPanelExpand

            self.submitButton.isHidden = !self.isEditPanelExpand

            self.collapseButton.isHidden = !self.isEditPanelExpand

            self.journalListButton.isHidden = self.isEditPanelExpand

            self.view.layoutIfNeeded()
        }
    }
}

extension JournalViewController: SelectionViewDataSource {

    func numberOfButtonsAt(_ view: SelectionView) -> Int { buttonImages.count }

    func buttonStyle(_ view: SelectionView) -> ButtonStyle { .image }

    func buttonColor(_ view: SelectionView) -> UIColor { .lightGray }

    func indicatorColor(_ view: SelectionView) -> UIColor { .M1 }

    func indicatorWidth(_ view: SelectionView) -> CGFloat { 0.8 }

    func buttonImage(_ view: SelectionView, index: Int) -> UIImage {

        view.buttons[0].tintColor = .black
        
        return buttonImages[index]
    }
}

extension JournalViewController: SelectionViewDelegate {

    func didSelectButtonAt(_ view: SelectionView, at index: Int) {

        view.buttons.forEach { $0.tintColor = .lightGray }
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
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        let currentText = textView.text ?? ""

        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

        return updatedText.count <= 140
    }
}

// MARK: SetupViews
extension JournalViewController {

    func configureGradientLayer() {

        let gradient = CAGradientLayer()

        view.backgroundColor = .clear
        gradient.colors = [UIColor.M1.cgColor, UIColor.M4.cgColor]
        gradient.locations = [0, 1]
        gradient.frame = view.bounds
        view.layer.addSublayer(gradient)
    }

    func setupTitle() {

        let labels = [dateLabel, dailyQuoteLabel]
        labels.forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = .white
            $0.textAlignment = .center
        }

        dateLabel.text = "\(Date().getCurrentTime(format: .MM)).\(Date().getCurrentTime(format: .dd))"
        dateLabel.font = UIFont(name: "Avenir Next Heavy", size: 90.0)
        dailyQuoteLabel.font = UIFont(name: "Pingfang TC", size: 16.0)
        dailyQuoteLabel.numberOfLines = 0

        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dailyQuoteLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            dailyQuoteLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dailyQuoteLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dailyQuoteLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    func setupEditPanel() {

        let panelObjects = [editPanel, emojiSelection, journalTextView, submitButton]

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
        editPanelExpand = editPanel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        editPanelCollapse.isActive = !isEditPanelExpand
        editPanelExpand.isActive = isEditPanelExpand
        journalTextView.cornerRadius = CornerRadius.standard.rawValue * 0.75
        journalTextView.contentInset = .init(top: 0, left: 10, bottom: 0, right: 0)

        journalTextView.placeholder(text: "  寫點什麼，只有自己看得到...", color: .lightGray)

        submitButton.setTitle("存檔", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.backgroundColor = .M2
        submitButton.cornerRadius = CornerRadius.standard.rawValue * 0.75
        submitButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)

        submitButton.addTarget(self, action: #selector(submitJournal(_:)), for: .touchUpInside)
        journalTextViewCollapse = journalTextView.bottomAnchor.constraint(
            equalTo: editPanel.bottomAnchor,
            constant: -20
        )
        journalTextViewExpand = journalTextView.bottomAnchor.constraint(
            equalTo: self.submitButton.topAnchor,
            constant: -16
        )
        journalTextViewCollapse.isActive = !isEditPanelExpand

        NSLayoutConstraint.activate([
            editPanel.topAnchor.constraint(equalTo: dailyQuoteLabel.bottomAnchor, constant: 40),
            editPanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editPanel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),

            emojiSelection.widthAnchor.constraint(equalTo: editPanel.widthAnchor, multiplier: 0.9),
            emojiSelection.topAnchor.constraint(equalTo: editPanel.topAnchor, constant: 24),
            emojiSelection.centerXAnchor.constraint(equalTo: editPanel.centerXAnchor),
            emojiSelection.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.042),

            journalTextView.topAnchor.constraint(equalTo: emojiSelection.bottomAnchor, constant: 32),
            journalTextView.widthAnchor.constraint(equalTo: editPanel.widthAnchor, multiplier: 0.9),
            journalTextView.centerXAnchor.constraint(equalTo: editPanel.centerXAnchor),

            submitButton.leadingAnchor.constraint(equalTo: editPanel.leadingAnchor, constant: 24),
            submitButton.trailingAnchor.constraint(equalTo: journalTextView.trailingAnchor),
            submitButton.heightAnchor.constraint(equalTo: editPanel.heightAnchor, multiplier: 0.12),
            submitButton.bottomAnchor.constraint(equalTo: editPanel.bottomAnchor, constant: -24)
        ])
    }

    func setupButtons() {

        view.addSubview(journalListButton)
        view.addSubview(collapseButton)
        journalListButton.translatesAutoresizingMaskIntoConstraints = false
        collapseButton.translatesAutoresizingMaskIntoConstraints = false

        collapseButton.isHidden = !isEditPanelExpand
        collapseButton.backgroundColor = .clear
        collapseButton.addTarget(self, action: #selector(collapseEditPanel(_:)), for: .touchUpInside)

        journalListButton.cornerRadius = CornerRadius.standard.rawValue
        journalListButton.backgroundColor = .white
        journalListButton.addTarget(self, action: #selector(goToJournalList(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([
            collapseButton.centerXAnchor.constraint(equalTo: editPanel.centerXAnchor),
            collapseButton.topAnchor.constraint(equalTo: editPanel.bottomAnchor, constant: 16),
            collapseButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15),
            collapseButton.heightAnchor.constraint(equalTo: collapseButton.widthAnchor),
            journalListButton.leadingAnchor.constraint(equalTo: editPanel.leadingAnchor),
            journalListButton.topAnchor.constraint(equalTo: editPanel.bottomAnchor, constant: 24),
            journalListButton.trailingAnchor.constraint(equalTo: editPanel.trailingAnchor),
            journalListButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1)
        ])
    }
}
