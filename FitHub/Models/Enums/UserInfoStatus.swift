//
//  UserInfoStatus.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/01.
//

import Foundation

enum UserInfoStatus {
    case notValidDateOfBirth
    case notValidSexNumber
    case underage
    case notValidPhoneNumber
    case notValidPassword
    case passwordLengthError
    case notMatchPassword
    case passwordSuccess
    case nickNameSuccess
    case matchPassword
    case ok
    case passwordOK
    case nickNameOK
    case duplicateNickName
    
    var message: String {
        switch self {
        case .notValidDateOfBirth: return "생년월일 및 성별을 정확히 입력해주세요."
        case .notValidSexNumber: return "생년월일 및 성별을 정확히 입력해주세요."
        case .underage: return "만 14세 미만은 서비스 이용이 불가합니다."
        case .notValidPhoneNumber: return "휴대폰 번호가 올바르지 않습니다."
        case .notValidPassword: return "특수문자,숫자,영문 조합으로 입력하세요."
        case .passwordLengthError: return "비밀번호는 8~16자 이내로 입력하세요."
        case .notMatchPassword: return "비밀번호가 일치하지 않습니다."
        case .passwordSuccess: return "사용할 수 있는 비밀번호입니다."
        case .matchPassword: return "비밀번호가 일치합니다."
        case .ok: return ""
        case .passwordOK: return "영어,숫자,특수문자를 조합하여 8~16자로 입력해주세요"
        case .nickNameOK: return "한글 혹은 영문을 포함하여 1~10자로 입력해주세요."
        case .duplicateNickName: return "이미 존재하는 닉네임 입니다."
        case .nickNameSuccess: return "사용 가능한 닉네임 입니다."
        }
    }
}
