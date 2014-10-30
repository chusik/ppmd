unit PPMdSubAllocatorVariantI;

{$mode objfpc}{$H+}
{$packrecords c}
{$inline on}

interface

uses
  Classes, SysUtils, CTypes, PPMdSubAllocator;

const
  N1 = 4;
  N2 = 4;
  N3 = 4;
  N4 = ((128 + 3 - 1 * N1 - 2 * N2 - 3 * N3) div 4);
  UNIT_SIZE = 12;
  N_INDEXES = (N1 + N2 + N3 + N4);

type
  PPPMdMemoryBlockVariantI = ^TPPMdMemoryBlockVariantI;
  TPPMdMemoryBlockVariantI = packed record
    Stamp: cuint32;
    next: cuint32;
    NU: cuint32;
  end;

  PPPMdSubAllocatorVariantI = ^TPPMdSubAllocatorVariantI;
  TPPMdSubAllocatorVariantI = record
    core: TPPMdSubAllocator;

    GlueCount, SubAllocatorSize: cuint32;
    Index2Units: array[0..37] of cuint8;  // constants
    Units2Index: array[0..127] of cuint8; // constants
    pText, UnitsStart, LowUnit, HighUnit: pcuint8;
    BList: array[0..37] of TPPMdMemoryBlockVariantI;
    HeapStart: array[0..0] of cuint8;
  end;

  function CreateSubAllocatorVariantI(size: cint): PPPMdSubAllocatorVariantI;
  procedure FreeSubAllocatorVariantI(self: PPPMdSubAllocatorVariantI);

  function GetUsedMemoryVariantI(self: PPPMdSubAllocatorVariantI): cuint32;
  procedure SpecialFreeUnitVariantI(self: PPPMdSubAllocatorVariantI; offs: cuint32);
  function MoveUnitsUpVariantI(self: PPPMdSubAllocatorVariantI; oldoffs: cuint32; num: cint): cuint32;
  procedure ExpandTextAreaVariantI(self: PPPMdSubAllocatorVariantI);

implementation

function NextBlock(self: PPPMdMemoryBlockVariantI; alloc: PPPMdSubAllocatorVariantI): PPPMdMemoryBlockVariantI; forward;
procedure SetNextBlock(self: PPPMdMemoryBlockVariantI; newnext: PPPMdMemoryBlockVariantI; alloc: PPPMdSubAllocatorVariantI); forward;
function AreBlocksAvailable(self: PPPMdMemoryBlockVariantI): cbool; forward;
procedure LinkBlockAfter(self: PPPMdMemoryBlockVariantI; p: PPPMdMemoryBlockVariantI; alloc: PPPMdSubAllocatorVariantI); forward;
procedure UnlinkBlockAfter(self: PPPMdMemoryBlockVariantI; alloc: PPPMdSubAllocatorVariantI); forward;
function RemoveBlockAfter(self: PPPMdMemoryBlockVariantI; alloc: PPPMdSubAllocatorVariantI): Pointer; forward;
procedure InsertBlockAfter(self: PPPMdMemoryBlockVariantI; pv: Pointer; NU: cint; alloc: PPPMdSubAllocatorVariantI); forward;

function I2B(self: PPPMdSubAllocatorVariantI; index: cint): cuint; forward;
procedure SplitBlock(self: PPPMdSubAllocatorVariantI; pv: Pointer; oldindex: cint; newindex: cint); forward;
//function GetUsedMemory(self: PPPMdSubAllocatorVariantI): cuint32; forward;

procedure InitVariantI(self: PPPMdSubAllocatorVariantI); forward;
function AllocContextVariantI(self: PPPMdSubAllocatorVariantI): cuint32; forward;
function AllocUnitsVariantI(self: PPPMdSubAllocatorVariantI; num: cint): cuint32; forward;
function _AllocUnits(self: PPPMdSubAllocatorVariantI; index: cint): cuint32; forward;
function ExpandUnitsVariantI(self: PPPMdSubAllocatorVariantI; oldoffs: cuint32; oldnum: cint): cuint32; forward;
function ShrinkUnitsVariantI(self: PPPMdSubAllocatorVariantI; oldoffs: cuint32; oldnum: cint; newnum: cint): cuint32; forward;
procedure FreeUnitsVariantI(self: PPPMdSubAllocatorVariantI; offs: cuint32; num: cint); forward;

procedure GlueFreeBlocks(self: PPPMdSubAllocatorVariantI); forward;

function _OffsetToPointer(self: PPPMdSubAllocatorVariantI; offset: cuint32): Pointer; inline;
begin
  Result:= pcuint8(self) + offset;
end;

function _PointerToOffset(self: PPPMdSubAllocatorVariantI; pointer: Pointer): cuint32; inline;
begin
  Result:= ptruint(pointer) - ptruint(self);
end;

function CreateSubAllocatorVariantI(size: cint): PPPMdSubAllocatorVariantI;
var
  self: PPPMdSubAllocatorVariantI;
begin
  self:= GetMem(sizeof(TPPMdSubAllocatorVariantI) + size);
  if (self = nil) then Exit(nil);

  Pointer(self^.core.Init):= @InitVariantI;
  Pointer(self^.core.AllocContext):= @AllocContextVariantI;
  Pointer(self^.core.AllocUnits):= @AllocUnitsVariantI;
  Pointer(self^.core.ExpandUnits):= @ExpandUnitsVariantI;
  Pointer(self^.core.ShrinkUnits):= @ShrinkUnitsVariantI;
  Pointer(self^.core.FreeUnits):= @FreeUnitsVariantI;

  self^.SubAllocatorSize:= size;

  Result:= self;
end;

procedure FreeSubAllocatorVariantI(self: PPPMdSubAllocatorVariantI);
begin
  FreeMem(self);
end;

procedure InitVariantI(self: PPPMdSubAllocatorVariantI);
var
  i, k: cint;
  diff: cuint;
begin
  FillChar(self^.BList, sizeof(self^.BList), 0);

  self^.pText:= self^.HeapStart;
  self^.HighUnit:= @self^.HeapStart[0] + self^.SubAllocatorSize;
  diff:= UNIT_SIZE * (self^.SubAllocatorSize div 8 div UNIT_SIZE * 7);
  self^.LowUnit:= self^.HighUnit - diff;
  self^.UnitsStart:= self^.LowUnit;
  self^.GlueCount:= 0;

  for i:= 0 to N1 - 1 do self^.Index2Units[i]:= 1 + i;
  for i:= 0 to N2 - 1 do self^.Index2Units[N1 + i]:= 2 + N1 + i * 2;
  for i:= 0 to N3 - 1 do self^.Index2Units[N1 + N2 + i]:= 3 + N1 + 2 * N2 + i * 3;
  for i:= 0 to N4 - 1 do self^.Index2Units[N1 + N2 + N3 + i]:= 4 + N1 + 2 * N2 + 3 * N3 + i * 4;

  i:= 0;
  for k:= 0 to 127 do
  begin
    if (self^.Index2Units[i] < k + 1) then Inc(i);
    self^.Units2Index[k]:= i;
  end;
end;

function AllocContextVariantI(self: PPPMdSubAllocatorVariantI): cuint32;
begin
  if (self^.HighUnit <> self^.LowUnit) then
  begin
    self^.HighUnit -= UNIT_SIZE;
    Result:=  _PointerToOffset(self, self^.HighUnit);
  end
  else if (AreBlocksAvailable(@self^.BList[0])) then Result:= _PointerToOffset(self, RemoveBlockAfter(@self^.BList[0], self))
  else Result:= _AllocUnits(self, 0);
end;

function AllocUnitsVariantI(self: PPPMdSubAllocatorVariantI; num: cint): cuint32;
var
  index: cint;
  units: Pointer;
begin
  index:= self^.Units2Index[num - 1];

  if (AreBlocksAvailable(@self^.BList[index])) then Exit(_PointerToOffset(self, RemoveBlockAfter(@self^.BList[index], self)));

  units:= self^.LowUnit;
  self^.LowUnit += I2B(self, index);
  if (self^.LowUnit <= self^.HighUnit) then Exit(_PointerToOffset(self, units));

  self^.LowUnit -= I2B(self, index);

  Result:= _AllocUnits(self, index);
end;

function _AllocUnits(self: PPPMdSubAllocatorVariantI; index: cint): cuint32;
var
  i: cint;
  units: Pointer;
begin
  if (self^.GlueCount = 0) then
  begin
    GlueFreeBlocks(self);
    if (AreBlocksAvailable(@self^.BList[index])) then Exit(_PointerToOffset(self, RemoveBlockAfter(@self^.BList[index], self)));
  end;

  for i:= index + 1 to N_INDEXES - 1 do
  begin
    if (AreBlocksAvailable(@self^.BList[i])) then
    begin
      units:= RemoveBlockAfter(@self^.BList[i], self);
      SplitBlock(self, units, i, index);
      Exit(_PointerToOffset(self, units));
    end;
  end;

  Dec(self^.GlueCount);

  i:= I2B(self, index);
  if (self^.UnitsStart - self^.pText > i) then
  begin
    self^.UnitsStart -= i;
    Exit(_PointerToOffset(self, self^.UnitsStart));
  end;

  Result:= 0;
end;

function ExpandUnitsVariantI(self: PPPMdSubAllocatorVariantI; oldoffs: cuint32; oldnum: cint): cuint32;
begin

end;

function ShrinkUnitsVariantI(self: PPPMdSubAllocatorVariantI; oldoffs: cuint32; oldnum: cint; newnum: cint): cuint32;
begin

end;

procedure FreeUnitsVariantI(self: PPPMdSubAllocatorVariantI; offs: cuint32; num: cint);
begin

end;

function GetUsedMemoryVariantI(self: PPPMdSubAllocatorVariantI): cuint32;
begin

end;

procedure SpecialFreeUnitVariantI(self: PPPMdSubAllocatorVariantI; offs: cuint32
  );
begin

end;

function MoveUnitsUpVariantI(self: PPPMdSubAllocatorVariantI; oldoffs: cuint32;
  num: cint): cuint32;
begin

end;

procedure ExpandTextAreaVariantI(self: PPPMdSubAllocatorVariantI);
begin

end;

procedure GlueFreeBlocks(self: PPPMdSubAllocatorVariantI);
begin

end;

function NextBlock(self: PPPMdMemoryBlockVariantI; alloc: PPPMdSubAllocatorVariantI): PPPMdMemoryBlockVariantI;
begin

end;

procedure SetNextBlock(self: PPPMdMemoryBlockVariantI; newnext: PPPMdMemoryBlockVariantI; alloc: PPPMdSubAllocatorVariantI);
begin

end;

function AreBlocksAvailable(self: PPPMdMemoryBlockVariantI): cbool;
begin

end;

procedure LinkBlockAfter(self: PPPMdMemoryBlockVariantI; p: PPPMdMemoryBlockVariantI; alloc: PPPMdSubAllocatorVariantI);
begin

end;

procedure UnlinkBlockAfter(self: PPPMdMemoryBlockVariantI; alloc: PPPMdSubAllocatorVariantI);
begin

end;

function RemoveBlockAfter(self: PPPMdMemoryBlockVariantI; alloc: PPPMdSubAllocatorVariantI): Pointer;
begin

end;

procedure InsertBlockAfter(self: PPPMdMemoryBlockVariantI; pv: Pointer; NU: cint; alloc: PPPMdSubAllocatorVariantI);
begin

end;

function I2B(self: PPPMdSubAllocatorVariantI; index: cint): cuint;
begin

end;

procedure SplitBlock(self: PPPMdSubAllocatorVariantI; pv: Pointer; oldindex: cint; newindex: cint);
begin

end;

end.

