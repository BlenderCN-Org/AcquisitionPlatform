Nikon Type0009 Module SDK Revision.3 概要


■用途
 カメラのコントロールを行う。


■サポートするカメラ
 D5200


■動作環境・制限事項
 [Windows]
    Windows XP (SP3)
    (※Professional, Home Edition)
    Windows Vista (SP2) --- 32bit版 / 64bit版(32bit互換モード)
    (※Ultimate, Enterprise, Business, Home Premium, Home Basic)
    Windows 7 (SP1) --- 32bit版 / 64bit版(32bit互換モード)
    (※Ultimate, Enterprise, Professional, Home Premium, Home Basic)
    Windows 8 -- 32bit / 64bit(32bit互換モード)

 [Macintosh]
    Mac OS X 10.9.5 (Mavericks)
    Mac OS X 10.10.3 (Yosemite)
    Mac OS X 10.11 (El Capitan)
    ※64bitモードのみ（32bitモードは非サポート）


■内容物
 [Windows]
    Documents
      MAID3(J).pdf : 基本インターフェース仕様
      MAID3Type0009(J).pdf : Type0009 Moduleで使用される拡張インターフェース仕様
      Usage of Type0009 Module(J).pdf : Type0009 Module を使用する上での注意事項
      Type0009 Sample Guide(J).pdf : サンプルプログラムの使用方法

    Binary Files
      Type0009.md3 : Windows用 Type0009 Module本体
      NkdPTP.dll : Windows用　PTPドライバ
 
    Header Files
      Maid3.h : MAIDインターフェース基本ヘッダ
      Maid3d1.h : Type0009用MAIDインターフェース拡張ヘッダ
      NkTypes.h : 本プログラムで使用する型の定義
      NkEndian.h : 本プログラムで使用する型の定義
      Nkstdint.h : 本プログラムで使用する型の定義

    Sample Program
      Type0009_CtrlSample_Win : Microsoft Visual Studio 2010 用プロジェクト


 [Macintosh]
    Documents
      MAID3(J).pdf : 基本インターフェース仕様
      MAID3Type0009(J).pdf : Type0009 Moduleで使用される拡張インターフェース仕様
      Usage of Type0009 Module(J).pdf : Type0009 Module を使用する上での注意事項
      Type0009 Sample Guide(J).pdf : サンプルプログラムの使用方法
      [Mac OS] Notice about using Module SDK(J).txt : Mac OSで使用する上での注意事項

    Binary Files
        Type0009 Module.bundle : Macintosh用 Type0009 Module本体 
        libNkPTPDriver2.dylib : Macintosh用 PTP ドライバ
 
    Header Files
      Maid3.h : MAIDインターフェース基本ヘッダ
      Maid3d1.h : Type0009用MAIDインターフェース拡張ヘッダ
      NkTypes.h : 本プログラムで使用する型の定義
      NkEndian.h : 本プログラムで使用する型の定義
      Nkstdint.h : 本プログラムで使用する型の定義

    Sample Program
      Type0009_CtrlSample_Mac : Xcode 6.2用のサンプルプログラムプロジェクト


■制限事項
 本Module SDKを利用してコントロールできるカメラは1台のみです。
 複数台のコントロールには対応していません。
