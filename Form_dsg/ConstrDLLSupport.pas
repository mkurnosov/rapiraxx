//===================================================================//
//                                                                   //
//   ����� ������� ���� ������ ����������� ��� ������                //
//   � Dynamic Link Libraries (DLL) � ������������ ������������.     //
//   Copyright (C) M. Kurnosov  2000-2001                            //
//                                                                   //
//===================================================================//

{
    � ����� DLL ������ �������������� ��������� GetDLLExportInfo :

        procedure GetDLLExportInfo(var DLLInfo : TDLLExportInfo);

    �� ���������� ����� ���������������� ������ ������� ���� :

        TDLLExportFun = function (var Param : TDLLProcParam) : Integer;

    ���� ������� ���������� ������, �� ��� ���������� �������� 0 � �
    Param.ReturnValue ���������� ��������� � ������� ������������� ������.
}


unit ConstrDLLSupport;

interface
uses Windows ,Forms;
const

    MAX_PROCEDURES  = 50;      //  ����. ���-�� �������������� ��������
    MAX_FUNCTIONS   = 50;      //  ����. ���-�� �������������� �������
    MAX_PARAMS      = 20;      //  ����. ���-�� ������������ ����������

    // return code
    RETURN_SUCCESS = 1;
    RETURN_FAILURE = 0;

type
    //
    //  �������� �������������� ��������� (�� DLL)
    //
    TExportProcDescription = record
        ProcName    : PChar;               //  ��� ���������
        CountParams : Byte;                //  ���-�� ���������� ����������

        // ���� ���������� :
        //  1 - String,  2 - Longint,  3 - Boolean
        ParamsTypes : array [0..MAX_PARAMS - 1] of Byte;
    end;

    TExportFunDescription = record
        FunName     : PChar;           //  ��� �������
        CountParams : Byte;            //  ���-�� ���������� ����������
        ReturnType  : Byte;            //  ��� ������������� ��������

        // ���� ���������� :
        //  1 - String,  2 - Longint,  3 - Boolean
        ParamsTypes : array [0..MAX_PARAMS - 1] of Byte;
    end;

    //
    //  ���������� � �������� �� DLL
    //
    TDLLExportInfo = record
        Procedures : array [0..MAX_PROCEDURES - 1] of TExportProcDescription;
        CountProcedures  : Integer;  //  ���-�� �������������� ��������

        Functions  : array [0..MAX_FUNCTIONS - 1] of TExportFunDescription;
        CountFunctions : Integer;
    end;

    //
    //  ������ �������������� ������� ������ ���� �������� � ������������
    //  ���������� ���� TDLLProcParam.
    //
    TDLLProcParam = record
        // ������������ ��������
        Params      : array [0..MAX_PARAMS - 1] of PChar;
        CountParams : Integer;
        ReturnValue : PChar;   // �������� ������������ ��������
    end;


    TFormInfo = record
        FormHandle       : THandle;    // HWND
        CanvasHandle     : THandle;    // HDC
    end;

    //
    //  ����������� ��� ����� (������) �������������� ���������
    //  ���� ���������� 0 - �� ������
    //
    TDLLExportFun = function (var Param : TDLLProcParam) : Integer;

    //
    //  ����������� ��� GetDLLExportInfo
    //
    TDLLInfoProc = procedure ( var DLLInfo : TDLLExportInfo;
                               const ConsrtForm : TFormInfo );

implementation
end.
