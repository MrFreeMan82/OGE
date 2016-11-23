unit uGlobal;

interface
uses SysUtils, Classes, StdCtrls, uData;

type TTheme = integer;

type TModule = integer;


const
    AlgebraAnswArr: array[0..9, 0..9] of double = (
                                              (20.756, 2, 0, 0, 0, 0, 0, 0, 0, 0),
                                              (0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                                              (0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                                              (0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                                              (0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                                              (0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                                              (0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                                              (0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                                              (0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                                              (0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
                                            );

function CheckAnswer(mdl: TModule; taskVariant, task: integer; x: double): boolean;
function strToFloatEx(const s: string): double;



implementation

function strToFloatEx(const s: string): double;
var sett: TFormatSettings;
begin
      sett.DecimalSeparator := '.';
      result := strToFloatDef(s, 0, sett);
end;

function CheckAnswer(mdl: TModule; taskVariant, task: integer; x: double): boolean;
const e: double = 0.01;
begin
    result := false;                                                                //task - 1 потому что индекс массива начинаесться с 0
end;

end.
