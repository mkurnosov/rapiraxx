//===================================================================//
//                                                                   //
//   Здесь описаны типы данных необходимые для работы                //
//   с Dynamic Link Libraries (DLL) в Конструкторе Исполнителей.     //
//   Copyright (C) M. Kurnosov  2000-2001                            //
//                                                                   //
//===================================================================//

{
    В любой DLL должна присутствовать процедура GetDLLExportInfo :

        procedure GetDLLExportInfo(var DLLInfo : TDLLExportInfo);

    Из библиотеки могут экспортироваться только функции типа :

        TDLLExportFun = function (var Param : TDLLProcParam) : Integer;

    Если функция обнаружила ошибку, то она возвращает значение 0 и в
    Param.ReturnValue содержится сообщение о причине возникновения ошибки.
}


unit ConstrDLLSupport;

interface
uses Windows ,Forms;
const

    MAX_PROCEDURES  = 50;      //  макс. кол-во экспортируемых процедур
    MAX_FUNCTIONS   = 50;      //  макс. кол-во экспортируемых функций
    MAX_PARAMS      = 20;      //  макс. кол-во передаваемых параметров

    // return code
    RETURN_SUCCESS = 1;
    RETURN_FAILURE = 0;

type
    //
    //  Описание экспортируемой процедуры (из DLL)
    //
    TExportProcDescription = record
        ProcName    : PChar;               //  имя процедуры
        CountParams : Byte;                //  кол-во формальных пареметров

        // типы пареметров :
        //  1 - String,  2 - Longint,  3 - Boolean
        ParamsTypes : array [0..MAX_PARAMS - 1] of Byte;
    end;

    TExportFunDescription = record
        FunName     : PChar;           //  имя функции
        CountParams : Byte;            //  кол-во формальных пареметров
        ReturnType  : Byte;            //  тип возвращаемого значения

        // типы пареметров :
        //  1 - String,  2 - Longint,  3 - Boolean
        ParamsTypes : array [0..MAX_PARAMS - 1] of Byte;
    end;

    //
    //  Информация о экспорте из DLL
    //
    TDLLExportInfo = record
        Procedures : array [0..MAX_PROCEDURES - 1] of TExportProcDescription;
        CountProcedures  : Integer;  //  кол-во экспортируемых процедур

        Functions  : array [0..MAX_FUNCTIONS - 1] of TExportFunDescription;
        CountFunctions : Integer;
    end;

    //
    //  Каждая экспортируемая функция должна быть описанна с единственным
    //  параметром типа TDLLProcParam.
    //
    TDLLProcParam = record
        // передаваемые значения
        Params      : array [0..MAX_PARAMS - 1] of PChar;
        CountParams : Integer;
        ReturnValue : PChar;   // значение возвращаемое функцией
    end;


    TFormInfo = record
        FormHandle       : THandle;    // HWND
        CanvasHandle     : THandle;    // HDC
    end;

    //
    //  Процедурный тип ЛЮБОЙ (КАЖДОЙ) экспортируемой процедуры
    //  Если возвращает 0 - то ошибка
    //
    TDLLExportFun = function (var Param : TDLLProcParam) : Integer;

    //
    //  Процедурный тип GetDLLExportInfo
    //
    TDLLInfoProc = procedure ( var DLLInfo : TDLLExportInfo;
                               const ConsrtForm : TFormInfo );

implementation
end.
