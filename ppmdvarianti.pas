unit PPMdVariantI;

{$mode objfpc}{$H+}
{$packrecords c}
{$inline on}

interface

uses
  Classes, SysUtils, CTypes, PPMdContext, PPMdSubAllocatorVariantI,
  CarrylessRangeCoder, PPMdSubAllocator, Math;

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
function CreateSuccessors(self: PPPMdModelVariantI; skip: cbool; state: PPPMdState; context: PPPMdContext): PPPMdContext; forward;
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
  for i:= 2 to 11 - 1 do self^.NS2BSIndx[i]:= 2 * 2;
  for i:= 11 to 256 - 1 do self^.NS2BSIndx[i]:= 2 * 3;

  for i:= 0 to UP_FREQ - 1 do self^.QTable[i]:= i;
  m:= UP_FREQ;
  k:= 1;
  step:= 1;
  for i:= UP_FREQ to 260 - 1 do
  begin
    self^.QTable[i]:= m;
    Dec(k);
    if (k = 0) then
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
const
  InitBinEsc: array[0..7] of cuint16 = ($3cdd,$1f3f,$59bf,$48f3,$64a1,$5abc,$6632,$6051);
var
  i, k, m: cint;
  maxstates: PPPMdState;
begin
  InitSubAllocator(self^.core.alloc);

  FillChar(self^.core.CharMask, sizeof(self^.core.CharMask), 0);

  self^.core.PrevSuccess:= 0;
  self^.core.OrderFall:= self^.MaxOrder;
  self^.core.InitRL:= -IfThen((self^.MaxOrder < 12), self^.MaxOrder, 12) - 1;
  self^.core.RunLength:= self^.core.InitRL;

  self^.MaxContext:= NewPPMdContext(@self^.core);
  self^.MaxContext^.LastStateIndex:= 255;
  self^.MaxContext^.SummFreq:= 257;
  self^.MaxContext^.States:= AllocUnits(self^.core.alloc, 256 div 2);

  maxstates:= PPMdContextStates(self^.MaxContext, @self^.core);
  for i:= 0 to 256 - 1 do
  begin
    maxstates[i].Symbol:= i;
    maxstates[i].Freq:= 1;
    maxstates[i].Successor:= 0;
  end;

  i:= 0;
  for m:= 0 to 25 - 1 do
  begin
    while (self^.QTable[i] = m) do Inc(i);
    for k:= 0 to 8 - 1 do self^.BinSumm[m, k]:= BIN_SCALE - InitBinEsc[k] div (i + 1);
    k:= 8;
    while (k < 64) do
    begin
     Move((@self^.BinSumm[m, 0])^, (@self^.BinSumm[m, k])^, 8 * sizeof(cuint16));
     k += 8;
   end;
  end;

  i:= 0;
  for m:= 0 to 24 - 1 do
  begin
    while (self^.QTable[i + 3] = m + 3) do Inc(i);
    for k:= 0 to 32 - 1 do self^.SEE2Cont[m, k]:= MakeSEE2(2 * i + 5, 7);
  end;
end;

function NextPPMdVariantIByte(self: PPPMdModelVariantI): cint; cdecl;
var
  byte: cuint8;
  mincontext: PPPMdContext;
begin
  mincontext:= self^.MaxContext;

  if (mincontext^.LastStateIndex <> 0) then DecodeSymbol1VariantI(mincontext, self)
  else DecodeBinSymbolVariantI(mincontext, self);

  while (self^.core.FoundState <> nil) do
  begin
    repeat
      Inc(self^.core.OrderFall);
      mincontext:= PPMdContextSuffix(mincontext, @self^.core);
      if (mincontext = nil) then Exit(-1);
    until not (mincontext^.LastStateIndex = self^.core.LastMaskIndex);

    DecodeSymbol2VariantI(mincontext, self);
  end;

  byte:= self^.core.FoundState^.Symbol;

  if (self^.core.OrderFall = 0) and (pcuint8(PPMdStateSuccessor(self^.core.FoundState, @self^.core)) >= self^.alloc^.UnitsStart) then
  begin
    self^.MaxContext:= PPMdStateSuccessor(self^.core.FoundState, @self^.core);
    //PrefetchData(MaxContext)
  end
  else
  begin
    UpdateModel(self, mincontext);
    //PrefetchData(MaxContext)
    if (self^.core.EscCount = 0) then ClearPPMdModelMask(@self^.core);
  end;

  Result:= byte;
end;

procedure UpdateModel(self: PPPMdModelVariantI; mincontext: PPPMdContext);
label
  RESTART_MODEL;
var
  flag: cuint8;
  fs: TPPMdState;
  states1: cuint32;
  states: PPPMdState;
  minnum, s0, currnum: cint;
  cf, sf, freq: cuint;
  currstates, new: PPPMdState;
  state: PPPMdState = nil;
  context, currcontext,
  Successor, newsuccessor: PPPMdContext;
begin
	fs:= self^.core.FoundState^;
	currcontext:= self^.MaxContext;

	if (fs.Freq < MAX_FREQ div 4) and (mincontext^.Suffix <> 0) then
	begin
		context:= PPMdContextSuffix(mincontext, @self^.core);
		if (context^.LastStateIndex <> 0) then
		begin
			state:= PPMdContextStates(context, @self^.core);

			if (state^.Symbol <> fs.Symbol) then
			begin
				repeat Inc(state);
				until not (state^.Symbol <> fs.Symbol);

				if (state[0].Freq >= state[-1].Freq) then
				begin
					SWAP(state[0], state[-1]);
					Dec(state);
				end;
			end;

			if (state^.Freq < MAX_FREQ - 9) then
			begin
				state^.Freq += 2;
				context^.SummFreq += 2;
			end;
		end
		else
		begin
			state:= PPMdContextOneState(context);
			if (state^.Freq < 32) then Inc(state^.Freq);
		end;
	end;

	if (self^.core.OrderFall = 0) and (fs.Successor <> 0) then
	begin
		newsuccessor:= CreateSuccessors(self, true, state, mincontext);
		SetPPMdStateSuccessorPointer(self^.core.FoundState, newsuccessor, @self^.core);
		if (newsuccessor = nil) then goto RESTART_MODEL;
		self^.MaxContext:= newsuccessor;
		Exit;
	end;

	self^.alloc^.pText^:= fs.Symbol; Inc(self^.alloc^.pText);
	Successor:= PPPMdContext(self^.alloc^.pText);

	if (self^.alloc^.pText >= self^.alloc^.UnitsStart) then goto RESTART_MODEL;

	if (fs.Successor <> 0) then
	begin
		if pcuint8(PPMdStateSuccessor(@fs, @self^.core)) < self^.alloc^.UnitsStart then
		begin
			SetPPMdStateSuccessorPointer(@fs, CreateSuccessors(self, false, state, mincontext), @self^.core);
		end;
	end
	else
	begin
		SetPPMdStateSuccessorPointer(@fs, ReduceOrder(self, state, mincontext), @self^.core);
	end;

	if (fs.Successor = 0) then goto RESTART_MODEL;

        Dec(self^.core.OrderFall);
        if (self^.core.OrderFall = 0) then
	begin
		Successor:= PPMdStateSuccessor(@fs, @self^.core);
		if (self^.MaxContext <> mincontext) then Dec(self^.alloc^.pText);
	end
	else if (self^.MRMethod > MRM_FREEZE) then
	begin
		Successor:= PPMdStateSuccessor(@fs, @self^.core);
		self^.alloc^.pText:= self^.alloc^.HeapStart;
		self^.core.OrderFall:= 0;
	end;

	minnum:= mincontext^.LastStateIndex + 1;
	s0:= mincontext^.SummFreq - minnum - (fs.Freq - 1);
	flag:= IfThen(fs.Symbol >= $40, 8, 0);

        while (currcontext <> mincontext) do
	begin
		currnum:= currcontext^.LastStateIndex + 1;
		if (currnum <> 1) then
		begin
			if ((currnum and 1) = 0) then
			begin
				states1:= ExpandUnits(self^.core.alloc, currcontext^.States, currnum shr 1);
				if (states1 = 0) then goto RESTART_MODEL;
				currcontext^.States:= states1;
			end;
			if (3 * currnum - 1 < minnum) then Inc(currcontext^.SummFreq);
		end
		else
		begin
			states:= OffsetToPointer(self^.core.alloc,AllocUnits(self^.core.alloc, 1));
			if (states = nil) then goto RESTART_MODEL;
			states[0]:= PPMdContextOneState(currcontext)^;
			SetPPMdContextStatesPointer(currcontext, states, @self^.core);

			if (states[0].Freq < MAX_FREQ div 4 - 1) then states[0].Freq *= 2
			else states[0].Freq:= MAX_FREQ - 4;

			currcontext^.SummFreq:= states[0].Freq + self^.core.InitEsc + IfThen(minnum > 3, 1, 0);
		end;

		cf:= 2 * fs.Freq * (currcontext^.SummFreq + 6);
		sf:= s0 + currcontext^.SummFreq;


		if (cf < 6 * sf) then
		begin
			if (cf >= 4 * sf) then freq:= 3
			else if (cf > sf) then freq:= 2
			else freq:= 1;
			currcontext^.SummFreq += 4;
		end
		else
		begin
			if (cf > 15 * sf) then freq:= 7
			else if (cf > 12 * sf) then freq:= 6
			else if (cf > 9 * sf) then freq:= 5
			else freq:= 4;
			currcontext^.SummFreq += freq;
		end;

		Inc(currcontext^.LastStateIndex);
		currstates:= PPMdContextStates(currcontext, @self^.core);
		new:= @currstates[currcontext^.LastStateIndex];
		SetPPMdStateSuccessorPointer(new, Successor, @self^.core);
		new^.Symbol:= fs.Symbol;
		new^.Freq:= freq;
		currcontext^.Flags:= currcontext^.Flags or flag;
        currcontext:= PPMdContextSuffix(currcontext, @self^.core)
        end;

	self^.MaxContext:= PPMdStateSuccessor(@fs, @self^.core);

	Exit;

	RESTART_MODEL:
	RestoreModel(self, currcontext, mincontext, PPMdStateSuccessor(@fs, @self^.core));
end;

function CreateSuccessors(self: PPPMdModelVariantI; skip: cbool; state: PPPMdState; context: PPPMdContext): PPPMdContext;
label
  skip_label;
var
  i, cf, s0: cint;
  n: cint = 0;
  upbranch, newcontext: PPPMdContext;
  statelist: array[0..MAX_O - 1] of PPPMdState;
  onestate: PPPMdState;
  ct: TPPMdContext;
  newsym, sym: cuint8;
begin
  upbranch:= PPMdStateSuccessor(self^.core.FoundState, @self^.core);
  sym:= self^.core.FoundState^.Symbol;

  if (not skip) then
  begin
    statelist[n]:= self^.core.FoundState;
    Inc(n);
    if (context^.Suffix = 0) then goto skip_label;
  end;

  if Assigned(state) then
  begin
    context:= PPMdContextSuffix(context, @self^.core);
    if (PPMdStateSuccessor(state, @self^.core) <> upbranch) then
    begin
      context:= PPMdStateSuccessor(state, @self^.core);
      goto skip_label;
    end;
    statelist[n]:= state; Inc(n);
    if  (context^.Suffix = 0) then goto skip_label;
  end;

  repeat
    context:= PPMdContextSuffix(context, @self^.core);
    if (context^.LastStateIndex <> 0) then
    begin
      state:= PPMdContextStates(context, @self^.core);
      while (state^.Symbol <> sym) do Inc(state);

      if (state^.Freq < MAX_FREQ - 9) then
      begin
	      Inc(state^.Freq);
	      Inc(context^.SummFreq);
      end;
    end
    else
    begin
      state:= PPMdContextOneState(context);
    //	state^.Freq += cuint8((not PPMdContextSuffix(context, @self^.core)^.LastStateIndex) and (state^.Freq < 24));
    end;

    if (PPMdStateSuccessor(state, @self^.core) <> upbranch) then
    begin
      context:= PPMdStateSuccessor(state, @self^.core);
      break;
    end;
    statelist[n]:= state; Inc(n);
  until not (context^.Suffix <> 0);

  skip_label:

  if (n = 0) then Exit(context);

  newsym:= pcuint8(upbranch)^;

  ct.LastStateIndex:= 0;
  ct.Flags:= 0;
  if (sym >= $40) then ct.Flags:= ct.Flags or $10;
  if (newsym >= $40) then ct.Flags:= ct.Flags or $08;

  onestate:= PPMdContextOneState(@ct);
  onestate^.Symbol:= newsym;
  SetPPMdStateSuccessorPointer(onestate, PPPMdContext(pcuint8(upbranch) + 1), @self^.core);

  if (context^.LastStateIndex <> 0) then
  begin
    state:= PPMdContextStates(context, @self^.core);
    while (state^.Symbol <> newsym) do Inc(state);

    cf:= state^.Freq - 1;
    s0:= context^.SummFreq - context^.LastStateIndex - cf;

    if (2 * cf <= s0) then
    begin
	    if (5 * cf > s0) then onestate^.Freq:= 2
	    else onestate^.Freq:= 1;
    end
    else onestate^.Freq:= 1 + ((cf + 2 * s0 - 3) div s0);
  end
  else onestate^.Freq:= PPMdContextOneState(context)^.Freq;

  for i:= n - 1 downto 0 do
  begin
    newcontext:= PPPMdContext(OffsetToPointer(self^.core.alloc,AllocContext(self^.core.alloc)));
    if (newcontext = nil) then Exit(nil);

    Move(ct, newcontext^, 8);
    SetPPMdContextSuffixPointer(newcontext, context, @self^.core);
    SetPPMdStateSuccessorPointer(statelist[i], newcontext, @self^.core);

    context:= newcontext;
  end;

  Result:= context;
end;

function ReduceOrder(self: PPPMdModelVariantI; state: PPPMdState; startcontext: PPPMdContext): PPPMdContext;
label
  skip;
var
  i: cint;
  n: cint = 0;
  sym: cuint8;
  tmp: PPPMdState;
  context, upbranch, successor: PPPMdContext;
  statelist: array[0..MAX_O - 1] of PPPMdState;
begin
  context:= startcontext;
  upbranch:= PPPMdContext(self^.alloc^.pText);
  sym:= self^.core.FoundState^.Symbol;

  statelist[n]:= self^.core.FoundState; Inc(n);
  Inc(self^.core.OrderFall);

  if Assigned(state) then
  begin
  	context:= PPMdContextSuffix(context, @self^.core);
  	if (state^.Successor <> 0) then goto skip;
  	statelist[n]:= state; Inc(n);
  	Inc(self^.core.OrderFall);
  end;

  while True do
  begin
    if (context^.Suffix = 0) then
    begin
      if (self^.MRMethod > MRM_FREEZE) then
      begin
  	      for i:= 0 to n - 1 do SetPPMdStateSuccessorPointer(statelist[i], context, @self^.core);
  	      self^.alloc^.pText:= @self^.alloc^.HeapStart[0] + 1;
  	      self^.core.OrderFall:= 1;
      end
      else
      begin
  	for i:= 0 to n - 1 do SetPPMdStateSuccessorPointer(statelist[i], upbranch, @self^.core);
      end;
      Exit(context);
    end;

    context:= PPMdContextSuffix(context, @self^.core);

    if (context^.LastStateIndex <> 0) then
    begin
      state:= PPMdContextStates(context, @self^.core);
      while (state^.Symbol <> sym) do Inc(state);

      if (state^.Freq < MAX_FREQ - 9) then
      begin
  	state^.Freq += 2;
  	context^.SummFreq += 2;
      end
    end
    else
    begin
      state:= PPMdContextOneState(context);
      if (state^.Freq < 32) then Inc(state^.Freq);
    end;

    if (state^.Successor <> 0) then break;

    statelist[n]:= state; Inc(n);
    Inc(self^.core.OrderFall);
  end;
  skip:

  if (self^.MRMethod > MRM_FREEZE) then
  begin
    successor:= PPMdStateSuccessor(state, @self^.core);
    for i:= 0 to n - 1 do SetPPMdStateSuccessorPointer(statelist[i], successor, @self^.core);

    self^.alloc^.pText:= @self^.alloc^.HeapStart[0] + 1;
    self^.core.OrderFall:= 1;

    Exit(successor);
  end
  else
  begin
    for i:= 0 to n - 1 do SetPPMdStateSuccessorPointer(statelist[i], upbranch, @self^.core);
  end;

  if (PPMdStateSuccessor(state, @self^.core) <= upbranch) then
  begin
    tmp:= self^.core.FoundState;
    self^.core.FoundState:= state;
    SetPPMdStateSuccessorPointer(state, CreateSuccessors(self, false, nil, context), @self^.core);
    self^.core.FoundState:= tmp;
  end;

  if (self^.core.OrderFall = 1) and (startcontext = self^.MaxContext) then
  begin
    self^.core.FoundState^.Successor:= state^.Successor;
    Dec(self^.alloc^.pText);
  end;

  Result:= PPMdStateSuccessor(state, @self^.core);
end;

procedure RestoreModel(self: PPPMdModelVariantI; currcontext, mincontext, FSuccessor: PPPMdContext);
var
  state: TPPMdState;
  context: PPPMdContext;
begin
  self^.alloc^.pText:= @self^.alloc^.HeapStart[0];

  context:= self^.MaxContext;
  while (context <> currcontext) do
  begin
    if (context^.LastStateIndex = 1) then
    begin
      state:= PPMdContextStates(context, @self^.core)^;
      SpecialFreeUnitVariantI(self^.alloc, context^.States);

      state.Freq:= (state.Freq + 11) shr 3;
      PPMdContextOneState(context)^:= state;

      context^.LastStateIndex:= 0;
      context^.Flags:= context^.Flags and $10;
      if (state.Symbol >= $40) then context^.Flags += $08;
    end
    else
    begin
      ShrinkContext(context, context^.LastStateIndex - 1, false, self);
    end;

    context:= PPMdContextSuffix(context, @self^.core);
  end;

  while (context <> mincontext) do
  begin
    if (context^.LastStateIndex = 0) then
    begin
      PPMdContextOneState(context)^.Freq:= (PPMdContextOneState(context)^.Freq + 1) shr 1;
    end
    else
    begin
      context^.SummFreq += 4;
      if (context^.SummFreq > 128 + 4 * context^.LastStateIndex) then
        ShrinkContext(context, context^.LastStateIndex, true, self);
    end;

    context:= PPMdContextSuffix(context, @self^.core);
  end;

  if (self^.MRMethod > MRM_FREEZE) then
  begin
    self^.MaxContext:= FSuccessor;
    if ((self^.alloc^.BList[1].Stamp and 1) = 0) then Inc(self^.alloc^.GlueCount);
  end
  else if (self^.MRMethod = MRM_FREEZE) then
  begin
    while (self^.MaxContext^.Suffix <> 0) do self^.MaxContext:= PPMdContextSuffix(self^.MaxContext, @self^.core);

    RemoveBinConts(self^.MaxContext, 0, self);
    self^.MRMethod:= self^.MRMethod + 1;
    self^.alloc^.GlueCount:= 0;
    self^.core.OrderFall:= self^.MaxOrder;
  end
  else if (self^.MRMethod = MRM_RESTART) or (GetUsedMemoryVariantI(self^.alloc) < (self^.alloc^.SubAllocatorSize shr 1)) then
  begin
    RestartModel(self);
    self^.core.EscCount:= 0;
  end
  else
  begin
    while (self^.MaxContext^.Suffix <> 0) do self^.MaxContext:= PPMdContextSuffix(self^.MaxContext, @self^.core);
    repeat
      CutOffContext(self^.MaxContext, 0, self);
      ExpandTextAreaVariantI(self^.alloc);
    until not (GetUsedMemoryVariantI(self^.alloc) > 3 * (self^.alloc^.SubAllocatorSize shr 2));

    self^.alloc^.GlueCount:= 0;
    self^.core.OrderFall:= self^.MaxOrder;
  end
end;

procedure ShrinkContext(self: PPPMdContext; newlastindex: cint; scale: cbool; model: PPPMdModelVariantI);
var
  i, escfreq: cint;
  states: PPPMdState;
begin
  self^.States:= ShrinkUnits(model^.core.alloc, self^.States, (self^.LastStateIndex + 2) shr 1, (newlastindex + 2) shr 1);
  self^.LastStateIndex:= newlastindex;

  if (scale) then self^.Flags:= self^.Flags and $14
  else self^.Flags:= self^.Flags and $10;

  states:= PPMdContextStates(self, @model^.core);
  escfreq:= self^.SummFreq;
  self^.SummFreq:= 0;

  for i:= 0 to self^.LastStateIndex do
  begin
    escfreq -= states[i].Freq;
    if (scale) then states[i].Freq:= (states[i].Freq + 1) shr 1;
    self^.SummFreq += states[i].Freq;
    if (states[i].Symbol >= $40) then self^.Flags:= self^.Flags or $08;
  end;

  if (scale) then escfreq:= (escfreq + 1) shr 1;

  self^.SummFreq += escfreq;
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

