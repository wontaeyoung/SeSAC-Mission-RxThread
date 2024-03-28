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
  let notNumberInvalidText = Observable.just("숫자만 입력 가능해요")
  let overMinLengthInvalidText = Observable.just("10자 이상 입력해주세요")
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
    
    let validation = phoneTextField.rx.text.orEmpty
      .compactMap { Int($0) }
      .map { String($0).count >= 10 }

    validation
      .withLatestFrom(overMinLengthInvalidText)
      .bind(to: descriptionLabel.rx.text)
      .disposed(by: disposeBag)
    
    validation
      .map { $0 ? UIColor.systemCyan : UIColor.lightGray }
      .bind(to: nextButton.rx.backgroundColor)
      .disposed(by: disposeBag)
    
    validation
      .bind(to: nextButton.rx.isEnabled, descriptionLabel.rx.isHidden)
      .disposed(by: disposeBag)
  }
}
