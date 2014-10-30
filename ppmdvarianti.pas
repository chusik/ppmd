unit PPMdVariantI;

{$mode objfpc}{$H+}
{$packrecords c}
{$inline on}

interface

uses
  Classes, SysUtils, CTypes, PPMdContext, PPMdSubAllocatorVariantI,
  CarrylessRangeCoder;

const
  MRM_RESTART = 0;
  MRM_CUT_OFF = 1;
  MRM_FREEZE = 2;

  UP_FREQ = 5;
  O_BOUND = 9;

type
  PPPMdModelVariantI = ^TPPMdModelVariantI;
  TPPMdModelVariantI = record
    core: TPPMdCoreModel;

    alloc: PPPMdSubAllocatorVariantI;

    NS2BSIndx: array[Byte] of cuint8; // constants
    QTable: array[0..259] of cuint8;  // constants

    MaxContext: PPPMdContext;
    MaxOrder, MRMethod: cint;
    SEE2Cont: array[0..23, 0..31] of TSEE2Context;
    DummySEE2Cont: TSEE2Context;
    BinSumm: array[0..24, 0..63] of cuint16; // binary SEE-contexts
  end;

function  CreatePPMdModelVariantI(input: PInStream;
    suballocsize: cint; maxorder: cint; restoration: cint): PPPMdModelVariantI; cdecl;
procedure FreePPMdModelVariantI(self: PPPMdModelVariantI); cdecl;

procedure StartPPMdModelVariantI(self: PPPMdModelVariantI; input: PInStream;
    alloc: PPPMdSubAllocatorVariantI; maxorder: cint; restoration: cint); cdecl;
function NextPPMdVariantIByte(self: PPPMdModelVariantI): cint; cdecl;

implementation

function CreatePPMdModelVariantI(input: PInStream; suballocsize: cint;
  maxorder: cint; restoration: cint): PPPMdModelVariantI; cdecl;
var
  self: PPPMdModelVariantI;
  alloc: PPPMdSubAllocatorVariantI;
begin
  self:= GetMem(sizeof(TPPMdModelVariantI));
  if (self = nil) then Exit(nil);
  alloc:= CreateSubAllocatorVariantI(suballocsize);
  if (alloc = nil) then
  begin
    FreeMem(self);
    Exit(nil);
  end;
  StartPPMdModelVariantI(self, input, alloc, maxorder, restoration);
  Result:= self;
end;

procedure FreePPMdModelVariantI(self: PPPMdModelVariantI); cdecl;
begin
  FreeMem(self^.alloc);
  FreeMem(self);
end;

procedure StartPPMdModelVariantI(self: PPPMdModelVariantI; input: PInStream;
  alloc: PPPMdSubAllocatorVariantI; maxorder: cint; restoration: cint); cdecl;
begin

end;

function NextPPMdVariantIByte(self: PPPMdModelVariantI): cint; cdecl;
begin

end;

end.
