unit PPMdSubAllocator;

{$mode delphi}
{$packrecords c}

interface

uses
  CTypes;

type
  PPPMdSubAllocator = ^TPPMdSubAllocator;
  TPPMdSubAllocator = record
    Init: procedure(self: PPPMdSubAllocator);
    AllocContext: function(self: PPPMdSubAllocator): cuint32;
    AllocUnits: function(self: PPPMdSubAllocator; num: cint): cuint32;  // 1 unit == 12 bytes, NU <= 128
    ExpandUnits: function(self: PPPMdSubAllocator; oldoffs: cuint32; oldnum: cint): cuint32;
    ShrinkUnits: function(self: PPPMdSubAllocator; oldoffs: cuint32; oldnum: cint; newnum: cint): cuint32;
    FreeUnits: procedure(self: PPPMdSubAllocator; offs: cuint32; num: cint);
  end;

procedure InitSubAllocator(self: PPPMdSubAllocator); inline;
function AllocContext(self: PPPMdSubAllocator): cuint32; inline;
function AllocUnits(self: PPPMdSubAllocator; num: cint): cuint32; inline;
function ExpandUnits(self: PPPMdSubAllocator; oldoffs: cuint32; oldnum: cint): cuint32; inline;
function ShrinkUnits(self: PPPMdSubAllocator; oldoffs: cuint32; oldnum: cint; newnum: cint): cuint32; inline;
procedure FreeUnits(self: PPPMdSubAllocator; offs: cuint32; num: cint); inline;

function OffsetToPointer(self: PPPMdSubAllocator; offset: cuint32): Pointer;
function PointerToOffset(self: PPPMdSubAllocator; pointer: Pointer): cuint32;

implementation

procedure InitSubAllocator(self: PPPMdSubAllocator);
begin
  self^.Init(self);
end;

function AllocContext(self: PPPMdSubAllocator): cuint32;
begin
  Result:= self^.AllocContext(self);
end;

function AllocUnits(self: PPPMdSubAllocator; num: cint): cuint32;
begin
  Result:= self^.AllocUnits(self, num);
end;

function ExpandUnits(self: PPPMdSubAllocator; oldoffs: cuint32; oldnum: cint): cuint32;
begin
  Result:= self^.ExpandUnits(self, oldoffs, oldnum);
end;

function ShrinkUnits(self: PPPMdSubAllocator; oldoffs: cuint32; oldnum: cint; newnum: cint): cuint32;
begin
  Result:= self^.ShrinkUnits(self, oldoffs, oldnum, newnum);
end;

procedure FreeUnits(self: PPPMdSubAllocator; offs: cuint32; num: cint);
begin
  self^.FreeUnits(self, offs, num);
end;

// TODO: Keep pointers as pointers on 32 bit, and offsets on 64 bit.

function OffsetToPointer(self: PPPMdSubAllocator; offset: cuint32): Pointer;
begin
  if (offset = 0) then Exit(nil);
  Result:= pcuint8(self) + offset;
end;

function PointerToOffset(self: PPPMdSubAllocator; pointer: Pointer): cuint32;
begin
  if (pointer = nil) then Exit(0);
  Result:= ptruint(pointer) - ptruint(self);
end;

end.

