unit PPMdContext;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, CTypes, CarrylessRangeCoder, PPMdSubAllocator;

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

implementation

function MakeSEE2(initval: cint; count: cint): TSEE2Context;
begin

end;

function GetSEE2MeanMasked(self: PSEE2Context): cuint;
begin

end;

function GetSEE2Mean(self: PSEE2Context): cuint;
begin

end;

procedure UpdateSEE2(self: PSEE2Context);
begin

end;

function PPMdStateSuccessor(self: PPPMdState; model: PPPMdCoreModel
  ): PPPMdContext;
begin

end;

procedure SetPPMdStateSuccessorPointer(self: PPPMdState;
  newsuccessor: PPPMdContext; model: PPPMdCoreModel);
begin

end;

function PPMdContextStates(self: PPPMdContext; model: PPPMdCoreModel
  ): PPPMdState;
begin

end;

procedure SetPPMdContextStatesPointer(self: PPPMdContext;
  newstates: PPPMdState; model: PPPMdCoreModel);
begin

end;

function PPMdContextSuffix(self: PPPMdContext; model: PPPMdCoreModel
  ): PPPMdContext;
begin

end;

procedure SetPPMdContextSuffixPointer(self: PPPMdContext;
  newsuffix: PPPMdContext; model: PPPMdCoreModel);
begin

end;

function PPMdContextOneState(self: PPPMdContext): PPPMdState;
begin

end;

function NewPPMdContext(model: PPPMdCoreModel): PPPMdContext;
begin

end;

function NewPPMdContextAsChildOf(model: PPPMdCoreModel;
  suffixcontext: PPPMdContext; suffixstate: PPPMdState; firststate: PPPMdState
  ): PPPMdContext;
begin

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

