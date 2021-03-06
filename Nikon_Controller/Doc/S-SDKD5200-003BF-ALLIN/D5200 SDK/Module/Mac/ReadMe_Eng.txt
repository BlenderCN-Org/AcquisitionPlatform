Nikon Type0009 Module SDK Revision.3 summary


Usage
 Control the camera.


Supported camera
 D5200


Environment of operation
 [Windows]
    Windows XP (SP3)
    (*  Professional, Home Edition)
    Windows Vista (SP2) -- 32bit / 64bit(Compatibility mode)
    (*  Ultimate, Enterprise, Business, Home Premium, Home Basic)
    Windows 7 (SP1) -- 32bit / 64bit(Compatibility mode)
    (*  Ultimate, Enterprise, Professional, Home Premium, Home Basic)
    Windows 8 -- 32bit / 64bit(Compatibility mode)


 [Macintosh]
    Mac OS X 10.9.5 (Mavericks)
    Mac OS X 10.10.3 (Yosemite)
    Mac OS X 10.11 (El Capitan)
    *  64bit mode only (32bit mode is not supported)

Contents
 [Windows]
    Documents
      MAID3(E).pdf : Basic interface specification
      MAID3Type0009(E).pdf : Extended interface specification used 
                                                              by Type0009 Module
      Usage of Type0009 Module(E).pdf : Notes for using Type0009 Module
      Type0009 Sample Guide(E).pdf : The usage of a sample program

    Binary Files
      Type0009.md3 : Type0009 Module for Win
      NkdPTP.dll : Driver for PTP mode used by Win

    Header Files
      Maid3.h : Basic header file of MAID interface
      Maid3d1.h : Extended header file for Type0009 Module
      NkTypes.h : Definitions of the types used in this program.
      NkEndian.h : Definitions of the types used in this program.
      Nkstdint.h : Definitions of the types used in this program.

    Sample Program
      Type0009_CtrlSample_Win : Project for Microsoft Visual Studio 2010


 [Macintosh]
    Documents
      MAID3(E).pdf : Basic interface specification
      MAID3Type0009(E).pdf : Extended interface specification used by 
                                                                Type0009 Module
      Usage of Type0009 Module(E).pdf : Notes for using Type0009 Module
      Type0009 Sample Guide(E).pdf : The usage of a sample program
      [Mac OS] Notice about using Module SDK(E).txt : Notes for using SDK
                                                                on Mac OS

    Binary Files
      Type0009 Module.bundle : Type0009 Module for Mac
      libNkPTPDriver2.dylib : PTP driver for Mac
 
    Header Files
      Maid3.h : Basic header file of MAID interface
      Maid3d1.h : Extended header file for Type0009 Module
      NkTypes.h : Definitions of the types used in this program.
      NkEndian.h : Definitions of the types used in this program.
      Nkstdint.h : Definitions of the types used in this program.

    Sample Program
      Type0009_CtrlSample_Mac : Sample program project for Xcode 6.2.


Limitations
 This module cannot control two or more cameras.
