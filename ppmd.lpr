program ppmd;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, CarrylessRangeCoder, PPMdContext, PPMdSubAllocator
  { you can add units after this };

begin
end.

