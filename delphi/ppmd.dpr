program ppmd;

{$APPTYPE CONSOLE}

uses
  SysUtils, Classes, AbPPMd;

var
  Source, Target: TFileStream;
begin
  Source:= TFileStream.Create('test.ppmd', fmOpenREad);
  Target:= TFileStream.Create('test.c', fmCreate);
  DecompressPPMd(Source, Target);
  Target.Free;
  Source.Free;
end.
