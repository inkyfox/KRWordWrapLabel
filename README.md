# KRWordWrapLabel
Although UILabel supports "Word Wrap" for the line breaking mode, it doesn't work on Korean letters. It works just like "Charactor Wrap". This KRWordWrapLabel provides "Word Wrap" based on white spaces not depending on languages. Almost all the the requirements for this library is from Korean, so I'll describe the details in Korean below.

UILabel은 Word Wrap 모드를 지원하지만 한글의 경우 글자 단위로 줄바꿈이 됩니다. 이 KRWordWrapLabel은 UILabel의 Subclass로서 한글의 단어 단위의 줄바꿈이 가능합니다.

### Usage
* 기존의 UILabel과 같이 사용가능합니다. IBDesignable을 적용하여 Interface Builder에서도 preview가 가능합니다.
* Line Break Mode가 "Word Wrap"일때만 동작하며 다른 모드에선 UILabel의 기본 동작으로 보여집니다.
* numberOfLines에 의해 마지막 행이 잘릴 때의 표시 문자열인 ellipsis와 줄 간격인 lineSpace를 IBInspectable로 추가하였습니다.
* 뷰의 폭이 공백없는 제일 긴 문자열의 폭보다 짧은 경우 전체가 UILabel의 기본 동작으로 단어단위로 줄바꿈됩니다.

### ScreenShot
![sreenshot](https://github.com/inkyfox/KRWordWrapLabel/blob/master/screenshot/KRWordWrapLabel.gif)


### LICENSE
[LICENSE UNDER MIT](https://github.com/fenjuly/ArrowDownloadButton/raw/master/LICENSE)
