program ppmd;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, CarrylessRangeCoder, PPMdContext, PPMdSubAllocator,
PPMdSubAllocatorVariantI, PPMdVariantI, AbPPMd
  { you can add units after this };

var
  Source, Target: TFileStream;
begin
  Source:= TFileStream.Create('test.ppmd', fmOpenREad);
  Target:= TFileStream.Create('test.c', fmCreate);
  DecompressPPMd(Source, Target);
  Target.Free;
  Source.Free;
end.

