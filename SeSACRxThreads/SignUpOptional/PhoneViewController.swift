//
//  PhoneViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class PhoneViewController: UIViewController {
  
  let phoneTextField = SignTextField(placeholderText: "연락처를 입력해주세요")
  let nextButton = PointButton(title: "다음")
  let descriptionLabel = UILabel()
  
  let initialNumber = Observable.just("010")
  let invalidDescriptionText = Observable.just("10자 이상의 숫자만 입력 가능해요")
  let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = Color.white
    
    configureLayout()
    bind()
  }
  
  private func showNextView() {
    navigationController?.pushViewController(PhoneViewController(), animated: true)
  }
  
  func configureLayout() {
    view.addSubview(phoneTextField)
    view.addSubview(descriptionLabel)
    view.addSubview(nextButton)
    
    phoneTextField.snp.makeConstraints { make in
      make.height.equalTo(50)
      make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
      make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
    }
    
    descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(phoneTextField.snp.bottom).offset(10)
      make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
      make.height.equalTo(20)
    }
    
    nextButton.snp.makeConstraints { make in
      make.height.equalTo(50)
      make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
      make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
    }
  }
  
  private func bind() {
    initialNumber
      .bind(to: phoneTextField.rx.text)
      .disposed(by: disposeBag)
    
    invalidDescriptionText
      .bind(to: descriptionLabel.rx.text)
      .disposed(by: disposeBag)
    
    let onlyNumberValidation = phoneTextField.rx.text.orEmpty
      .map { Int($0) != nil }
    
    let lengthValidation = phoneTextField.rx.text.orEmpty
      .map { $0.count >= 10 }

    let combineValidation = Observable.combineLatest(onlyNumberValidation, lengthValidation) { $0 && $1 }
    
    combineValidation
      .map { $0 ? UIColor.systemCyan : UIColor.lightGray }
      .bind(to: nextButton.rx.backgroundColor)
      .disposed(by: disposeBag)
    
    combineValidation
      .bind(to: nextButton.rx.isEnabled, descriptionLabel.rx.isHidden)
      .disposed(by: disposeBag)
  }
}
