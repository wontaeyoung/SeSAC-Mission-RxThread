//
//  EditShoppingSheet.swift
//  SeSACRxThreads
//
//  Created by 원태영 on 4/2/24.
//

import UIKit
import KazUtility
import RxSwift
import RxCocoa

final class EditShoppingSheetController: RxBaseViewController {
  
  // MARK: - UI
  private let inputField = SignTextField(placeholderText: "무엇을 구매하실건가요?")
  private let editButton = UIButton().configured {
    $0.configuration = .filled().configured {
      $0.title = "수정하기"
      $0.cornerStyle = .medium
      $0.buttonSize = .medium
    }
  }
  
  // MARK: - Property
  let itemRelay: BehaviorRelay<ShopItem>
  private let editDoneEvent = PublishRelay<Void>()
  
  // MARK: - Initializer
  init(item: ShopItem) {
    self.itemRelay = .init(value: item)
    
    super.init()
  }
  
  // MARK: - Life Cycle
  override func setHierarchy() {
    view.addSubviews(inputField, editButton)
  }
  
  override func setConstraint() {
    inputField.snp.makeConstraints { make in
      make.centerY.equalTo(view)
      make.leading.equalTo(view).inset(20)
      make.height.equalTo(50)
    }
    
    editButton.snp.makeConstraints { make in
      make.top.equalTo(inputField)
      make.leading.equalTo(inputField.snp.trailing).offset(10)
      make.trailing.equalTo(view).inset(20)
      make.height.equalTo(50)
    }
  }
  
  override func bind() {
    itemRelay
      .map { $0.name }
      .bind(to: inputField.rx.text)
      .disposed(by: disposeBag)
    
    editButton.rx.tap
      .withLatestFrom(inputField.rx.text.orEmpty)
      .bind(with: self, onNext: { owner, newName in
        owner.updateItem(text: newName)
        owner.editDoneEvent.accept(())
      })
      .disposed(by: disposeBag)
    
    editDoneEvent
      .bind(with: self) { owner, _ in
        owner.navigationController?.popViewController(animated: true)
      }
      .disposed(by: disposeBag)
  }
  
  // MARK: - Method
  private func updateItem(text: String) {
    var mutableItem = itemRelay.value
    mutableItem.name = text
    itemRelay.accept(mutableItem)
  }
}
