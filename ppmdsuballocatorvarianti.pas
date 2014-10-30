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
var
  offs: cuint32;
  oldptr: Pointer;
  oldindex, newindex: cint;
begin
  oldptr:= _OffsetToPointer(self, oldoffs);
  oldindex:= self^.Units2Index[oldnum - 1];
  newindex:= self^.Units2Index[oldnum];
  if (oldindex = newindex) then Exit(oldoffs);

  offs:= AllocUnitsVariantI(self, oldnum + 1);
  if (offs <> 0) then
  begin
    // !!!memcpy(_OffsetToPointer(self, offs), oldptr, oldnum * UNIT_SIZE);
    InsertBlockAfter(@self^.BList[oldindex], oldptr, oldnum, self);
  end;
  Result:= offs;
end;

function ShrinkUnitsVariantI(self: PPPMdSubAllocatorVariantI; oldoffs: cuint32; oldnum: cint; newnum: cint): cuint32;
begin

end;

procedure FreeUnitsVariantI(self: PPPMdSubAllocatorVariantI; offs: cuint32; num: cint);
var
  index: cint;
begin
  index:= self^.Units2Index[num - 1];
  InsertBlockAfter(@self^.BList[index], _OffsetToPointer(self, offs), self^.Index2Units[index], self);
end;

function GetUsedMemoryVariantI(self: PPPMdSubAllocatorVariantI): cuint32;
var
  i: cint;
  size: cuint32;
begin
  size:= self^.SubAllocatorSize - (self^.HighUnit - self^.LowUnit) - (self^.UnitsStart - self^.pText);

  for i:= 0 to N_INDEXES - 1 do size -= UNIT_SIZE * self^.Index2Units[i] * self^.BList[i].Stamp;

  Result:= size;
end;

procedure SpecialFreeUnitVariantI(self: PPPMdSubAllocatorVariantI; offs: cuint32);
var
  ptr: Pointer;
begin
  ptr:= _OffsetToPointer(self, offs);
  if (pcuint8(ptr) = self^.UnitsStart) then
  begin
    pcuint32(ptr)^:= $ffffffff;
    self^.UnitsStart += UNIT_SIZE;
  end
  else InsertBlockAfter(@self^.BList[0], ptr, 1, self);
end;

function MoveUnitsUpVariantI(self: PPPMdSubAllocatorVariantI; oldoffs: cuint32;
  num: cint): cuint32;
begin

end;

procedure ExpandTextAreaVariantI(self: PPPMdSubAllocatorVariantI);
begin

end;

procedure GlueFreeBlocks(self: PPPMdSubAllocatorVariantI);
var
  i, k, sz: cint;
  s0: TPPMdMemoryBlockVariantI;
  p, p0, p1: PPPMdMemoryBlockVariantI;
begin
  if (self^.LowUnit <> self^.HighUnit) then self^.LowUnit^:= 0;

  p0:= @s0;
  s0.next:= 0;
  for i:= 0 to N_INDEXES - 1 do
  begin
    while (AreBlocksAvailable(@self^.BList[i])) do
    begin
      p:= PPPMdMemoryBlockVariantI(RemoveBlockAfter(@self^.BList[i], self));
      if (p^.NU <> 0) then continue;
      p1:= p + p^.NU;
      while (p1^.Stamp = $ffffffff) do
      begin
  	p^.NU += p1^.NU;
  	p1^.NU:= 0;
        p1:= p + p^.NU;
      end;
      LinkBlockAfter(p0, p, self);
      p0:= p;
    end;
  end;

  while (AreBlocksAvailable(@s0)) do
  begin
    p:= RemoveBlockAfter(@s0, self);
    sz:= p^.NU;
    if (sz <> 0) then continue;

    while (sz > 128) do
    begin
      InsertBlockAfter(@self^.BList[N_INDEXES - 1], p, 128, self);
      sz -= 128;
      p += 128;
    end;

    i:= self^.Units2Index[sz - 1];
    if (self^.Index2Units[i] <> sz) then
    begin
      Dec(i);
      k:= sz - self^.Index2Units[i];
      InsertBlockAfter(@self^.BList[k - 1], p + (sz - k), k, self);
    end;
    InsertBlockAfter(@self^.BList[i], p, self^.Index2Units[i], self);
  end;
  self^.GlueCount:= 1 shl 13;
end;

function NextBlock(self: PPPMdMemoryBlockVariantI; alloc: PPPMdSubAllocatorVariantI): PPPMdMemoryBlockVariantI;
begin
  Result:= OffsetToPointer(@alloc^.core, self^.next);
end;

procedure SetNextBlock(self: PPPMdMemoryBlockVariantI; newnext: PPPMdMemoryBlockVariantI; alloc: PPPMdSubAllocatorVariantI);
begin
  self^.next:= PointerToOffset(@alloc^.core, newnext);
end;

function AreBlocksAvailable(self: PPPMdMemoryBlockVariantI): cbool;
begin
  Result:= self^.next <> 0;
end;

procedure LinkBlockAfter(self: PPPMdMemoryBlockVariantI; p: PPPMdMemoryBlockVariantI; alloc: PPPMdSubAllocatorVariantI);
begin
  SetNextBlock(p, NextBlock(self, alloc), alloc);
  SetNextBlock(self, p, alloc);
end;

procedure UnlinkBlockAfter(self: PPPMdMemoryBlockVariantI; alloc: PPPMdSubAllocatorVariantI);
begin
  SetNextBlock(self, NextBlock(NextBlock(self, alloc), alloc), alloc);
end;

function RemoveBlockAfter(self: PPPMdMemoryBlockVariantI; alloc: PPPMdSubAllocatorVariantI): Pointer;
var
  p: PPPMdMemoryBlockVariantI;
begin
  p:= NextBlock(self, alloc);
  UnlinkBlockAfter(self, alloc);
  Dec(self^.Stamp);
  Result:= p;
end;

procedure InsertBlockAfter(self: PPPMdMemoryBlockVariantI; pv: Pointer; NU: cint; alloc: PPPMdSubAllocatorVariantI);
var
  p: PPPMdMemoryBlockVariantI;
begin
  p:= PPPMdMemoryBlockVariantI(pv);
  LinkBlockAfter(self, p, alloc);
  p^.Stamp:= $ffffffff;
  p^.NU:= NU;
  Inc(self^.Stamp);
end;

function I2B(self: PPPMdSubAllocatorVariantI; index: cint): cuint;
begin
  Result:= UNIT_SIZE * self^.Index2Units[index];
end;

procedure SplitBlock(self: PPPMdSubAllocatorVariantI; pv: Pointer; oldindex: cint; newindex: cint);
var
  p: pcuint8;
  i, k, diff: cint;
begin
  p:= pcuint8(pv) + I2B(self, newindex);

  diff:= self^.Index2Units[oldindex] - self^.Index2Units[newindex];
  i:= self^.Units2Index[diff - 1];
  if (self^.Index2Units[i] <> diff) then
  begin
    Dec(i);
    k:= self^.Index2Units[i];
    InsertBlockAfter(@self^.BList[i], p, k, self);
    p += k * UNIT_SIZE;
    diff -= k;
  end;
  InsertBlockAfter(@self^.BList[self^.Units2Index[diff - 1]], p, diff, self);
end;

end.

