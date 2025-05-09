/// 中文文案排版指南 Prompt
///
/// 参考：https://github.com/cfug/flutter.cn/wiki/中文文案排版指南-(Chinese-Typography-Guide)
final chineseTypographyGuidePrompt =
    '''
以下会提供给你正确以及错误的示例：
### 空格
#### 中英文之间应增加空格
[正确]：
- 在 LeanCloud 上，数据存储是围绕 AVObject 进行的。
- 在 LeanCloud 上，数据存储是围绕 AVObject 进行的。
  每个 AVObject 都包含了与 JSON 兼容的 key-value 对应的数据。
  数据是 schema-free 的，你不需要在每个 AVObject 上提前指定存在哪些键，只要直接设定对应的 key-value 即可。

[错误]：
- 在LeanCloud上，数据存储是围绕AVObject进行的。
- 在 LeanCloud上，数据存储是围绕AVObject 进行的。

#### 中文与数字之间应增加空格
[正确]：
- 今天出去买菜花了 5000 元。

[错误]：
- 今天出去买菜花了 5000元。
- 今天出去买菜花了5000元。

#### 数字与单位之间应增加空格
[正确]：
- 我家的光纤入屋宽频有 10 Gbps，SSD 一共有 20 TB。

[错误]：
- 我家的光纤入屋宽频有 10Gbps，SSD 一共有 20TB。

例外：度 (°) 或者百分比 (%) 与数字之间不需要增加空格

[正确]：
- 今天是 233° 的高温。
- 新 MacBook Pro 有 15% 的 CPU 性能提升。

[错误]：
- 今天是 233 ° 的高温。
- 新 MacBook Pro 有 15 % 的 CPU 性能提升。

#### 全角标点与其他字符之间应避免加空格
[正确]：
- 刚刚买了一部 iPhone，好开心！

[错误]：
- 刚刚买了一部 iPhone ，好开心！
- 刚刚买了一部 iPhone， 好开心！

### 标点符号
#### 应避免重复使用标点符号
[正确]：
- 德国队竟然战胜了巴西队！
- 她竟然对你说「喵」？！

[错误]：
- 德国队竟然战胜了巴西队！！
- 德国队竟然战胜了巴西队！！！！！！！！
- 她竟然对你说「喵」？？！！
- 她竟然对你说「喵」？！？！？？！！

### 全角和半角
#### 应使用全角中文标点
[正确]：
- 嗨！你知道嘛？今天前台的小妹跟我说「喵」了哎！
- 核磁共振成像（NMRI）是什么原理都不知道？JFGI！

[错误]：
- 嗨! 你知道嘛? 今天前台的小妹跟我说 "喵" 了哎！
- 嗨!你知道嘛?今天前台的小妹跟我说"喵"了哎！
- 核磁共振成像 (NMRI) 是什么原理都不知道? JFGI!
- 核磁共振成像(NMRI)是什么原理都不知道?JFGI!

#### 数字应使用半角字符
[正确]：
- 这件蛋糕只卖 1000 元。

[错误]：
- 这件蛋糕只卖 １０００ 元。

#### 遇到完整的英文整句、特殊名词，其内容应使用半角标点
[正确]：
- 贾伯斯那句话是怎么说的？「Stay hungry, stay foolish.」
- 推荐你阅读《Hackers & Painters: Big Ideas from the Computer Age》，非常的有趣。

[错误]：
- 贾伯斯那句话是怎么说的？「Stay hungry，stay foolish。」
- 推荐你阅读《Hackers＆Painters：Big Ideas from the Computer Age》，非常的有趣。

### 名词
#### 专有名词应使用正确的大小写。
[正确]：
- 使用 GitHub 登录
- 我们的客户有 GitHub、Foursquare、Microsoft Corporation、Google、Facebook, Inc.。

[错误]：
- 使用 github 登录
- 使用 GITHUB 登录
- 使用 Github 登录
- 使用 gitHub 登录
- 使用 gｲんĤЦ8 登录
- 我们的客户有 github、foursquare、microsoft corporation、google、facebook, inc.。
- 我们的客户有 GITHUB、FOURSQUARE、MICROSOFT CORPORATION、GOOGLE、FACEBOOK, INC.。
- 我们的客户有 Github、FourSquare、MicroSoft Corporation、Google、FaceBook, Inc.。
- 我们的客户有 gitHub、fourSquare、microSoft Corporation、google、faceBook, Inc.。
- 我们的客户有 gｲんĤЦ8、ｷouЯƧquﾑгє、๓เςг๏ร๏Ŧt ς๏гק๏гคtเ๏ภn、900913、ƒ4ᄃëв๏๏к, IПᄃ.。

#### 应避免使用不地道的缩写
[正确]：
- 我们需要一位熟悉 JavaScript、HTML5，至少理解一种框架（如 Backbone.js、AngularJS、React 等）的前端开发者。

[错误]：
- 我们需要一位熟悉 Js、h5，至少理解一种框架（如 backbone、angular、RJS 等）的 FED。

### 普遍适用的规则
#### 链接之间应增加空格
[正确]：
- 请 [提交一个 issue](https://xxx) 并分配给相关同事。
- 访问我们网站的最新动态，请 [点击这里](https://xxx) 进行订阅！

[错误]：
- 请[提交一个issue](https://xxx)并分配给相关同事。
- 访问我们网站的最新动态，请[点击这里](https://xxx)进行订阅！

#### 简体中文应使用直角引号
[正确]：
- 「老师，『有条不紊』的『紊』是什么意思？」

[错误]：
- “老师，‘有条不紊’的‘紊’是什么意思？”

#### 全角 / 半角括号的用法
括号是用来做解释和提示用，译者在描述和翻译一个没有共识翻译的英文时，也常放在后面作为原文提示。
当括号里的内容是纯英文的时候，应使用半角括号，如：
今天我们一起去了星巴克 (StarBucks) 点了一份隐藏菜单里的咖啡。

当括号里的内容是纯中文或者中英混合的时候，应使用全角括号，如：
使用 Flutter 可以方便的发布多平台的应用（Android 和 iOS），它对所有开发者（前端、后端、移动端）们都非常友好。
'''.trim();
