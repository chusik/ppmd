unit PPMdContext;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, CTypes, CarrylessRangeCoder, PPMdSubAllocator;

const
  MAX_O = 255;
  INT_BITS = 7;
  PERIOD_BITS = 7;
  TOT_BITS =  (INT_BITS + PERIOD_BITS);
  MAX_FREQ =  124;
  INTERVAL = (1 shl INT_BITS);
  BIN_SCALE = (1 shl TOT_BITS);

type
  // SEE-contexts for PPM-contexts with masked symbols
  PSEE2Context = ^TSEE2Context;
  TSEE2Context = packed record
    Summ: cuint16;
    Shift, Count: cuint8;
  end;

  PPPMdState = ^TPPMdState;
  TPPMdState = packed record
    Symbol, Freq: cuint8;
    Successor: cuint32;
   end;

  PPPMdContext = ^TPPMdContext;
  TPPMdContext = packed record
    LastStateIndex, Flags: cuint8;
    SummFreq: cuint16;
    States: cuint32;
    Suffix: cuint32;
  end;

  PPPMdCoreModel = ^TPPMdCoreModel;
  TPPMdCoreModel = record
    alloc: PPPMdSubAllocator;

    coder: TCarrylessRangeCoder;
    scale: cuint32;

    FoundState: PPPMdState; // found next state transition
    OrderFall, InitEsc, RunLength, InitRL: cint;
    CharMask: array[Byte] of cuint8;
    LastMaskIndex, EscCount, PrevSuccess: cuint8;

    RescalePPMdContext: procedure(self: PPPMdContext; model: PPPMdCoreModel);
  end;

  function MakeSEE2(initval: cint; count: cint): TSEE2Context;
  function GetSEE2MeanMasked(self: PSEE2Context): cuint;
  function GetSEE2Mean(self: PSEE2Context): cuint;
  procedure UpdateSEE2(self: PSEE2Context);

  function PPMdStateSuccessor(self: PPPMdState; model: PPPMdCoreModel): PPPMdContext;
  procedure SetPPMdStateSuccessorPointer(self: PPPMdState; newsuccessor: PPPMdContext; model: PPPMdCoreModel);
  function PPMdContextStates(self: PPPMdContext; model: PPPMdCoreModel): PPPMdState;
  procedure SetPPMdContextStatesPointer(self: PPPMdContext; newstates: PPPMdState; model: PPPMdCoreModel);
  function PPMdContextSuffix(self: PPPMdContext; model: PPPMdCoreModel): PPPMdContext;
  procedure SetPPMdContextSuffixPointer(self: PPPMdContext; newsuffix: PPPMdContext; model: PPPMdCoreModel);
  function PPMdContextOneState(self: PPPMdContext): PPPMdState;

  function NewPPMdContext(model: PPPMdCoreModel): PPPMdContext;
  function NewPPMdContextAsChildOf(model: PPPMdCoreModel; suffixcontext: PPPMdContext; suffixstate: PPPMdState; firststate: PPPMdState): PPPMdContext;

  procedure PPMdDecodeBinSymbol(self: PPPMdContext; model: PPPMdCoreModel; bs: pcuint16; freqlimit: cint; altnextbit: cbool);
  function PPMdDecodeSymbol1(self: PPPMdContext; model: PPPMdCoreModel; greaterorequal: cbool): cint;
  procedure UpdatePPMdContext1(self: PPPMdContext; model: PPPMdCoreModel; state: PPPMdState);
  procedure PPMdDecodeSymbol2(self: PPPMdContext; model: PPPMdCoreModel; see: PSEE2Context);
  procedure UpdatePPMdContext2(self: PPPMdContext; model: PPPMdCoreModel; state: PPPMdState);
  procedure RescalePPMdContext(self: PPPMdContext; model: PPPMdCoreModel);

  procedure ClearPPMdModelMask(self: PPPMdCoreModel);

  // #define SWAP(t1,t2) { PPMdState tmp=(t1); (t1)=(t2); (t2)=tmp; }

implementation

function MakeSEE2(initval: cint; count: cint): TSEE2Context;
var
  self: TSEE2Context;
begin
  self.Shift:= PERIOD_BITS - 4;
  self.Summ:= initval shl self.Shift;
  self.Count:= count;
  Result:= self;
end;

function GetSEE2MeanMasked(self: PSEE2Context): cuint;
var
  retval: cuint;
begin
  retval:= self^.Summ shr self^.Shift;
  self^.Summ -= retval;
  retval:= retval and $03ff;
  if (retval = 0) then Exit(1);
  Result:= retval;
end;

function GetSEE2Mean(self: PSEE2Context): cuint;
var
  retval: cuint;
begin
  retval:= self^.Summ shr self^.Shift;
  self^.Summ -= retval;
  if (retval = 0) then Exit(1);
  Result:= retval;
end;

procedure UpdateSEE2(self: PSEE2Context);
begin
  if (self^.Shift >= PERIOD_BITS) then Exit;

  Dec(self^.Count);
  if (self^.Count = 0) then
  begin
    self^.Summ *= 2;
    self^.Count:= 3 shl self^.Shift;
    Inc(self^.Shift);
  end;
end;

function PPMdStateSuccessor(self: PPPMdState; model: PPPMdCoreModel): PPPMdContext;
begin
  Result:= OffsetToPointer(model^.alloc, self^.Successor);
end;

procedure SetPPMdStateSuccessorPointer(self: PPPMdState;
  newsuccessor: PPPMdContext; model: PPPMdCoreModel);
begin
  self^.Successor:= PointerToOffset(model^.alloc, newsuccessor);
end;

function PPMdContextStates(self: PPPMdContext; model: PPPMdCoreModel): PPPMdState;
begin
  Result:= OffsetToPointer(model^.alloc, self^.States);
end;

procedure SetPPMdContextStatesPointer(self: PPPMdContext;
  newstates: PPPMdState; model: PPPMdCoreModel);
begin
  self^.States:= PointerToOffset(model^.alloc, newstates);
end;

function PPMdContextSuffix(self: PPPMdContext; model: PPPMdCoreModel): PPPMdContext;
begin
  Result:= OffsetToPointer(model^.alloc, self^.Suffix);
end;

procedure SetPPMdContextSuffixPointer(self: PPPMdContext;
  newsuffix: PPPMdContext; model: PPPMdCoreModel);
begin
  self^.Suffix:= PointerToOffset(model^.alloc, newsuffix);
end;

function PPMdContextOneState(self: PPPMdContext): PPPMdState;
begin
  Result:= PPPMdState(@self^.SummFreq);
end;

function NewPPMdContext(model: PPPMdCoreModel): PPPMdContext;
var
  context: PPPMdContext;
begin
  context:= OffsetToPointer(model^.alloc, AllocContext(model^.alloc));
  if Assigned(context) then
  begin
    context^.LastStateIndex:= 0;
    context^.Flags:= 0;
    context^.Suffix:= 0;
  end;
  Result:= context;
end;

function NewPPMdContextAsChildOf(model: PPPMdCoreModel;
  suffixcontext: PPPMdContext; suffixstate: PPPMdState; firststate: PPPMdState
  ): PPPMdContext;
var
  context: PPPMdContext;
begin
  context:= OffsetToPointer(model^.alloc, AllocContext(model^.alloc));
  if Assigned(context) then
  begin
    context^.LastStateIndex:= 0;
    context^.Flags:= 0;
    SetPPMdContextSuffixPointer(context, suffixcontext, model);
    SetPPMdStateSuccessorPointer(suffixstate, context, model);
    if Assigned(firststate) then (PPMdContextOneState(context))^:= firststate^;
  end;
  Result:= context;
end;

procedure PPMdDecodeBinSymbol(self: PPPMdContext; model: PPPMdCoreModel;
  bs: pcuint16; freqlimit: cint; altnextbit: cbool);
begin

end;

function PPMdDecodeSymbol1(self: PPPMdContext; model: PPPMdCoreModel;
  greaterorequal: cbool): cint;
begin

end;

procedure UpdatePPMdContext1(self: PPPMdContext; model: PPPMdCoreModel;
  state: PPPMdState);
begin

end;

procedure PPMdDecodeSymbol2(self: PPPMdContext; model: PPPMdCoreModel;
  see: PSEE2Context);
begin

end;

procedure UpdatePPMdContext2(self: PPPMdContext; model: PPPMdCoreModel;
  state: PPPMdState);
begin

end;

procedure RescalePPMdContext(self: PPPMdContext; model: PPPMdCoreModel);
begin

end;

procedure ClearPPMdModelMask(self: PPPMdCoreModel);
begin

end;

end.

