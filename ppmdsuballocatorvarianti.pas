unit PPMdSubAllocatorVariantI;

{$mode objfpc}{$H+}
{$packrecords c}
{$inline on}

interface

uses
  Classes, SysUtils, CTypes, PPMdSubAllocator;

type
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

function CreateSubAllocatorVariantI(size: cint): PPPMdSubAllocatorVariantI;
begin

end;

procedure FreeSubAllocatorVariantI(self: PPPMdSubAllocatorVariantI);
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

end.

