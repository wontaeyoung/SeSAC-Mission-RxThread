//
//  PasswordViewModel.swift
//  SeSACRxThreads
//
//  Created by 원태영 on 4/3/24.
//

import RxSwift
import RxCocoa

final class PasswordViewModel: ViewModel {
  
  // MARK: - I / O
  struct Input {
    let password: PublishRelay<String>
    let confirmPassword: PublishRelay<String>
  }
  
  struct Output {
    let lengthValidation: Driver<Bool>
    let equalValidation: Driver<Bool>
    let validation: Driver<Bool>
  }
  
  // MARK: - Property
  let disposeBag = DisposeBag()
  
  // MARK: - Method
  func transform(input: Input) -> Output {
    
    let lengthValidation = input.password
      .map { 8...16 ~= $0.count }
    
    let equalPasswordValidation = Observable.combineLatest(input.password, input.confirmPassword)
      .map { $0 == $1 }
    
    let validation = Observable.combineLatest(lengthValidation, equalPasswordValidation)
      .map { $0 && $1 }
      .asDriver(onErrorJustReturn: false)
    
    return Output(
      lengthValidation: lengthValidation.asDriver(onErrorJustReturn: false),
      equalValidation: equalPasswordValidation.asDriver(onErrorJustReturn: false), 
      validation: validation
    )
  }
}
