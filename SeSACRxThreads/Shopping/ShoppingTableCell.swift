//
//  ShoppingTableCell.swift
//  SeSACRxThreads
//
//  Created by 원태영 on 4/2/24.
//

import UIKit
import KazUtility
import SnapKit
import RxSwift
import RxCocoa

final class ShoppingTableCell: RxBaseTableCell {
  
  // MARK: - UI
  private let checkboxButton = UIButton(configuration: .plain())
  private let itemNameLabel = UILabel()
  private let bookmarkButton = UIButton(configuration: .plain())
  
  // MARK: - Property
  private var checkboxTapEvnet: (() -> Void)?
  private var bookmarkTapEvent: (() -> Void)?
  
  // MARK: - Life Cycle
  override func setHierarchy() {
    contentView.addSubviews(checkboxButton, itemNameLabel, bookmarkButton)
  }
  
  override func setConstraint() {
    checkboxButton.snp.makeConstraints { make in
      make.leading.equalTo(contentView).inset(20)
      make.centerY.equalTo(contentView)
      make.size.equalTo(30)
    }
    
    itemNameLabel.snp.makeConstraints { make in
      make.leading.equalTo(checkboxButton.snp.trailing).offset(10)
      make.centerY.equalTo(contentView)
      make.trailing.equalTo(bookmarkButton.snp.leading).offset(-10)
    }
    
    bookmarkButton.snp.makeConstraints { make in
      make.trailing.equalTo(contentView).inset(20)
      make.centerY.equalTo(contentView)
      make.size.equalTo(30)
    }
  }
  
  override func bind() {
    checkboxButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.checkboxTapEvnet?()
      }
      .disposed(by: disposeBag)
    
    bookmarkButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.bookmarkTapEvent?()
      }
      .disposed(by: disposeBag)
  }
  
  // MARK: - Method
  func updateUI(with item: ShopItem) {
    configureCheckboxButton(isDone: item.isDone)
    configureNameLabel(name: item.name)
    configureBookmarkButton(bookmark: item.bookmark)
  }
  
  func checkboxButtonTapEvent(closure: @escaping () -> Void) {
    checkboxTapEvnet = closure
  }
  
  func bookmarkButtonTapEvent(closure: @escaping () -> Void) {
    bookmarkTapEvent = closure
  }
  
  private func configureCheckboxButton(isDone: Bool) {
    checkboxButton.configuration?.configure {
      $0.image = UIImage(systemName: isDone ? "checkmark.square.fill" : "checkmark.square")
    }
  }
  
  private func configureNameLabel(name: String) {
    itemNameLabel.text = name
  }
  
  private func configureBookmarkButton(bookmark: Bool) {
    bookmarkButton.configuration?.configure {
      $0.image = UIImage(systemName: bookmark ? "star.fill" : "star")
    }
  }
}
