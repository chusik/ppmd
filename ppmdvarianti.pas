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

procedure RestartModel(self: PPPMdModelVariantI); forward;

procedure UpdateModel(self: PPPMdModelVariantI; mincontext: PPPMdContext); forward;
function CreateSuccessors(self: PPPMdModelVariantI; skip: cbool; p1: PPPMdState; mincontext: PPPMdContext): PPPMdContext; forward;
function ReduceOrder(self: PPPMdModelVariantI; state: PPPMdState; startcontext: PPPMdContext): PPPMdContext; forward;
procedure RestoreModel(self: PPPMdModelVariantI; currcontext, mincontext, FSuccessor: PPPMdContext); forward;

procedure ShrinkContext(self: PPPMdContext; newlastindex: cint; scale: cbool; model: PPPMdModelVariantI); forward;
function CutOffContext(self: PPPMdContext; order: cint; model: PPPMdModelVariantI): PPPMdContext; forward;
function RemoveBinConts(self: PPPMdContext; order: cint; model: PPPMdModelVariantI): PPPMdContext; forward;

procedure DecodeBinSymbolVariantI(self: PPPMdContext; model: PPPMdModelVariantI); forward;
procedure DecodeSymbol1VariantI(self: PPPMdContext; model: PPPMdModelVariantI); forward;
procedure DecodeSymbol2VariantI(self: PPPMdContext; model: PPPMdModelVariantI); forward;

procedure RescalePPMdContextVariantI(self: PPPMdContext; model: PPPMdModelVariantI); forward;

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
var
  pc: PPPMdContext;
  i, m, k, step: cint;
begin
  InitializeRangeCoder(@self^.core.coder, input, true, $8000);

  if (maxorder < 2) then // TODO: solid mode
  begin
    FillChar(self^.core.CharMask, sizeof(self^.core.CharMask), 0);
    self^.core.OrderFall:= self^.MaxOrder;
    pc:= self^.MaxContext;
    while (pc^.Suffix <> 0) do
    begin
      Dec(self^.core.OrderFall);
      pc:= PPMdContextSuffix(pc, @self^.core)
    end;
    Exit;
  end;

  self^.alloc:= alloc;
  self^.core.alloc:= @alloc^.core;

  Pointer(self^.core.RescalePPMdContext):= @RescalePPMdContextVariantI;

  self^.MaxOrder:= maxorder;
  self^.MRMethod:= restoration;
  self^.core.EscCount:= 1;

  self^.NS2BSIndx[0]:= 2 * 0;
  self^.NS2BSIndx[1]:= 2 * 1;
  for i:=2 to 11 - 1 do self^.NS2BSIndx[i]:= 2 * 2;
  for i:= 11 to 256 - 1 do self^.NS2BSIndx[i]:= 2 * 3;

  for i:= 0 to UP_FREQ - 1 do self^.QTable[i]:= i;
  m:= UP_FREQ;
  k:= 1;
  step:= 1;
  for i:= UP_FREQ to 260 - 1 do
  begin
    self^.QTable[i]:= m;
    Dec(k);
    if (k <> 0) then
    begin
      Inc(m); Inc(step); k:= step;
    end;
  end;

  self^.DummySEE2Cont.Summ:= $af8f;
  //self^.DummySEE2Cont.Shift:= $ac;
  self^.DummySEE2Cont.Count:= $84;
  self^.DummySEE2Cont.Shift:= PERIOD_BITS;

  RestartModel(self);
end;

procedure RestartModel(self: PPPMdModelVariantI);
begin

end;

function NextPPMdVariantIByte(self: PPPMdModelVariantI): cint; cdecl;
begin

end;

procedure UpdateModel(self: PPPMdModelVariantI; mincontext: PPPMdContext);
begin

end;

function CreateSuccessors(self: PPPMdModelVariantI; skip: cbool; p1: PPPMdState; mincontext: PPPMdContext): PPPMdContext;
begin

end;

function ReduceOrder(self: PPPMdModelVariantI; state: PPPMdState; startcontext: PPPMdContext): PPPMdContext;
begin

end;

procedure RestoreModel(self: PPPMdModelVariantI; currcontext, mincontext, FSuccessor: PPPMdContext);
begin

end;

procedure ShrinkContext(self: PPPMdContext; newlastindex: cint; scale: cbool; model: PPPMdModelVariantI);
begin

end;

function CutOffContext(self: PPPMdContext; order: cint; model: PPPMdModelVariantI): PPPMdContext;
begin

end;

function RemoveBinConts(self: PPPMdContext; order: cint; model: PPPMdModelVariantI): PPPMdContext;
begin

end;

procedure DecodeBinSymbolVariantI(self: PPPMdContext; model: PPPMdModelVariantI);
var
  bs: pcuint16;
  index: cuint8;
  rs: PPPMdState;
begin
  rs:= PPMdContextOneState(self);

  index:= model^.NS2BSIndx[PPMdContextSuffix(self, @model^.core)^.LastStateIndex] + model^.core.PrevSuccess + self^.Flags;
  bs:= @model^.BinSumm[model^.QTable[rs^.Freq - 1], index + ((model^.core.RunLength shr 26) and $20)];

  PPMdDecodeBinSymbol(self, @model^.core, bs, 196, false);
end;

procedure DecodeSymbol1VariantI(self: PPPMdContext; model: PPPMdModelVariantI);
begin
  PPMdDecodeSymbol1(self, @model^.core, true);
end;

procedure DecodeSymbol2VariantI(self: PPPMdContext; model: PPPMdModelVariantI);
begin

end;

procedure RescalePPMdContextVariantI(self: PPPMdContext; model: PPPMdModelVariantI);
begin

end;

end.

