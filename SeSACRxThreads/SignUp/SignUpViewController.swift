//
//  SignUpViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SignUpViewController: UIViewController {
  
  private let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요").configured {
    $0.spellCheckingType = .no
    $0.autocorrectionType = .no
    $0.autocapitalizationType = .none
    $0.keyboardType = .emailAddress
  }
  
  private let nextButton = PointButton(title: "다음")
  private let validationInfoLabel = UILabel()
  
  private let viewModel = SignUpViewModel()
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = Color.white
    
    configureLayout()
    bind()
  }

  private func bind() {
    let input = SignUpViewModel.Input(email: .init())
    let output = viewModel.transform(input: input)
    
    output.validation
      .drive(nextButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    output.validation
      .map { $0 ? "사용 가능한 이메일이에요" : "이메일 형식에 맞지 않아요" }
      .drive(validationInfoLabel.rx.text)
      .disposed(by: disposeBag)
    
    output.validation
      .map { $0 ? UIColor.systemGreen : UIColor.systemRed }
      .drive(validationInfoLabel.rx.textColor)
      .disposed(by: disposeBag)
    
    nextButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.navigationController?.pushViewController(PasswordViewController(), animated: true)
      }
      .disposed(by: disposeBag)
    
    emailTextField.rx.text.orEmpty
      .bind(to: input.email)
      .disposed(by: disposeBag)
    
    emailTextField.rx.text.orEmpty
      .map { $0.isEmpty }
      .bind(to: validationInfoLabel.rx.isHidden)
      .disposed(by: disposeBag)
  }
  
  func configureLayout() {
    view.addSubview(emailTextField)
    view.addSubview(nextButton)
    view.addSubview(validationInfoLabel)
    
    emailTextField.snp.makeConstraints { make in
      make.height.equalTo(50)
      make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
      make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
    }
    
    validationInfoLabel.snp.makeConstraints { make in
      make.top.equalTo(emailTextField.snp.bottom).offset(5)
      make.leading.equalTo(emailTextField)
      make.height.equalTo(20)
    }
    
    nextButton.snp.makeConstraints { make in
      make.height.equalTo(50)
      make.top.equalTo(validationInfoLabel.snp.bottom).offset(30)
      make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
    }
  }
}
