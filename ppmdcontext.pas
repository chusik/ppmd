unit PPMdContext;

{$mode objfpc}{$H+}
{$packrecords c}
{$inline on}

interface

uses
  Classes, SysUtils, CTypes, Math, CarrylessRangeCoder, PPMdSubAllocator;

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

  procedure SWAP(var t1, t2: TPPMdState); inline;

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

// Tabulated escapes for exponential symbol distribution
const ExpEscape: array[0..15] of cuint8 = ( 25,14,9,7,5,5,4,4,4,3,3,3,2,2,2,2 );

function GET_MEAN(SUMM, SHIFT, ROUND: cuint16): cuint16; inline;
begin
  Result:= ((SUMM + (1 shl (SHIFT - ROUND))) shr (SHIFT));
end;

procedure PPMdDecodeBinSymbol(self: PPPMdContext; model: PPPMdCoreModel;
  bs: pcuint16; freqlimit: cint; altnextbit: cbool);
var
  bit: cint;
  rs: PPPMdState;
begin
  rs:= PPMdContextOneState(self);

  if (altnextbit) then bit:= NextWeightedBitFromRangeCoder2(@model^.coder, bs^, TOT_BITS)
  else bit:= NextWeightedBitFromRangeCoder(@model^.coder, bs^, 1 shl TOT_BITS);

  if (bit = 0) then
  begin
    model^.PrevSuccess:= 1;
    Inc(model^.RunLength);
    model^.FoundState:= rs;

    if (rs^.Freq < freqlimit) then Inc(rs^.Freq);
    bs^ += INTERVAL - GET_MEAN(bs^, PERIOD_BITS, 2);
  end
  else
  begin
    model^.PrevSuccess:= 0;
    model^.FoundState:= nil;
    model^.LastMaskIndex:= 0;
    model^.CharMask[rs^.Symbol]:= model^.EscCount;

    bs^ -= GET_MEAN(bs^, PERIOD_BITS, 2);
    model^.InitEsc:= ExpEscape[bs^ shr 10];
  end;
end;

function PPMdDecodeSymbol1(self: PPPMdContext; model: PPPMdCoreModel;
  greaterorequal: cbool): cint;
var
  states: PPPMdState;
  adder, count, firstcount,
  highcount, i, lastsym: cint;
begin
  model^.scale:= self^.SummFreq;

  states:= PPMdContextStates(self, model);
  firstcount:= states[0].Freq;
  count:= RangeCoderCurrentCount(@model^.coder, model^.scale);
  adder:= IfThen(greaterorequal, 1, 0);

  if (count < firstcount) then
  begin
    RemoveRangeCoderSubRange(@model^.coder, 0, firstcount);
    if (2 * firstcount + adder > cint(model^.scale)) then
    begin
  	    model^.PrevSuccess:= 1;
  	    Inc(model^.RunLength);
    end
    else model^.PrevSuccess:= 0;

    model^.FoundState:= @states[0];
    states[0].Freq:= firstcount + 4;
    self^.SummFreq += 4;

    if (firstcount + 4 > MAX_FREQ) then model^.RescalePPMdContext(self, model);

    Exit(-1);
  end;

  highcount:= firstcount;
  model^.PrevSuccess:= 0;

  for i:= 1 to self^.LastStateIndex do
  begin
    highcount += states[i].Freq;
    if (highcount > count) then
    begin
      RemoveRangeCoderSubRange(@model^.coder, highcount - states[i].Freq, highcount);
      UpdatePPMdContext1(self, model, @states[i]);
      Exit(-1);
    end;
  end;

  lastsym:= model^.FoundState^.Symbol;

  // if ( Suffix ) PrefetchData(Suffix);
  RemoveRangeCoderSubRange(@model^.coder, highcount, model^.scale);
  model^.LastMaskIndex:= self^.LastStateIndex;
  model^.FoundState:= nil;

  for i:= 0 to self^.LastStateIndex do model^.CharMask[states[i].Symbol]:= model^.EscCount;

  Result:= lastsym;
end;

procedure UpdatePPMdContext1(self: PPPMdContext; model: PPPMdCoreModel;
  state: PPPMdState);
begin
  state^.Freq += 4;
  self^.SummFreq += 4;

  if (state[0].Freq > state[-1].Freq) then
  begin
    SWAP(state[0], state[-1]);
    model^.FoundState:= @state[-1];
    if (state[-1].Freq > MAX_FREQ) then model^.RescalePPMdContext(self, model);
  end
  else
  begin
    model^.FoundState:= state;
  end;
end;

procedure PPMdDecodeSymbol2(self: PPPMdContext; model: PPPMdCoreModel;
  see: PSEE2Context);
var
  highcount: cint;
  total: cint = 0;
  state: PPPMdState;
  i, n, count: cint;
  ps: array[Byte] of PPPMdState;
begin
  n:= self^.LastStateIndex - model^.LastMaskIndex;

  state:= PPMdContextStates(self, model);
  for i:= 0 to n - 1 do
  begin
    while (model^.CharMask[state^.Symbol] = model^.EscCount) do Inc(state);

    total += state^.Freq;
    ps[i]:= state;
    Inc(state);
  end;

  model^.scale += total;
  count:= RangeCoderCurrentCount(@model^.coder, model^.scale);

  if (count < total) then
  begin
    i:= 0;
    highcount:= ps[0]^.Freq;
    while (highcount <= count) do
    begin
      Inc(i);
      highcount += ps[i]^.Freq;
    end;

    RemoveRangeCoderSubRange(@model^.coder, highcount - ps[i]^.Freq, highcount);
    UpdateSEE2(see);
    UpdatePPMdContext2(self, model, ps[i]);
  end
  else
  begin
    RemoveRangeCoderSubRange(@model^.coder, total, model^.scale);
    model^.LastMaskIndex:= self^.LastStateIndex;
    see^.Summ += model^.scale;

    for i:=0 to n - 1 do model^.CharMask[ps[i]^.Symbol]:= model^.EscCount;
  end;
end;

procedure UpdatePPMdContext2(self: PPPMdContext; model: PPPMdCoreModel;
  state: PPPMdState);
begin
  model^.FoundState:= state;
  state^.Freq += 4;
  self^.SummFreq += 4;
  if (state^.Freq > MAX_FREQ) then model^.RescalePPMdContext(self, model);
  Inc(model^.EscCount);
  model^.RunLength:= model^.InitRL;
end;

procedure RescalePPMdContext(self: PPPMdContext; model: PPPMdCoreModel);
var
  n0, n1: cint;
  tmp: TPPMdState;
  states: PPPMdState;
  numzeros: cint = 1;
  i, j, n, escfreq, adder: cint;
begin
  states:= PPMdContextStates(self, model);
  n:= self^.LastStateIndex + 1;

  // Bump frequency of found state
  model^.FoundState^.Freq += 4;

  // Divide all frequencies and sort list
  escfreq:= self^.SummFreq + 4;
  adder:= IfThen(model^.OrderFall = 0, 0, 1);
  self^.SummFreq:= 0;

  for i:= 0 to n - 1 do
  begin
  	escfreq -= states[i].Freq;
  	states[i].Freq:= (states[i].Freq + adder) shr 1;
  	self^.SummFreq += states[i].Freq;

  	// Keep states sorted by decreasing frequency
  	if (i > 0) and (states[i].Freq > states[i - 1].Freq) then
  	begin
  		// If not sorted, move current state upwards until list is sorted
  		tmp:= states[i];

  		j:= i - 1;
  		while (j > 0) and (tmp.Freq > states[j-1].Freq) do Dec(j);

  		Move((@states[j])^, (@states[j + 1])^, sizeof(TPPMdState) * (i - j));
  		states[j]:= tmp;
  	end;
  end;

  // TODO: add better sorting stage here.

  // Drop states whose frequency has fallen to 0
  if (states[n - 1].Freq = 0) then
  begin
  	while (numzeros < n) and (states[n - 1 - numzeros].Freq = 0) do Inc(numzeros);

  	escfreq += numzeros;

  	self^.LastStateIndex -= numzeros;
  	if (self^.LastStateIndex = 0) then
  	begin
  		tmp:= states[0];
  		repeat
  		  tmp.Freq:= (tmp.Freq + 1) shr 1;
  		  escfreq:= escfreq shr 1;
  		until not (escfreq > 1);

  		FreeUnits(model^.alloc, self^.States, (n + 1) shr 1);
  		model^.FoundState:= PPMdContextOneState(self);
  		model^.FoundState^:= tmp;

  		Exit;
  	end;

  	n0:= (n + 1) shr 1;
        n1:= (self^.LastStateIndex + 2) shr 1;
  	if (n0 <> n1) then self^.States:= ShrinkUnits(model^.alloc, self^.States, n0, n1);
  end;

  self^.SummFreq += (escfreq + 1) shr 1;

  // The found state is the first one to breach the limit, thus it is the largest and also first
  model^.FoundState:= PPMdContextStates(self, model);
end;

procedure ClearPPMdModelMask(self: PPPMdCoreModel);
begin
  self^.EscCount:= 1;
  FillChar(self^.CharMask, sizeof(self^.CharMask), 0);
end;

procedure SWAP(var t1, t2: TPPMdState);
var
  tmp: TPPMdState;
begin
  tmp:= t1;
  t1:= t2;
  t2:= tmp;
end;

end.

