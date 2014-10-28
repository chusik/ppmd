unit CarrylessRangeCoder;

{$mode delphi}
{$packrecords c}

interface

uses
  Classes, SysUtils, CTypes;

type

  PInStream = ^TInStream;
  TInStream = record
    nextByte: function(self: PInStream): cuint8; cdecl;
  end;

  PCarrylessRangeCoder = ^TCarrylessRangeCoder;
  TCarrylessRangeCoder = record
    input: PInStream;
    low, code, range, bottom: cuint32;
    uselow: cbool;
  end;

  procedure InitializeRangeCoder(self: PCarrylessRangeCoder; input: PInStream; uselow: cbool; bottom: cint);

  function RangeCoderCurrentCount(self: PCarrylessRangeCoder; scale: cuint32): cuint32;
  procedure RemoveRangeCoderSubRange(self: PCarrylessRangeCoder; lowcount: cuint32; highcount: cuint32);

  function NextSymbolFromRangeCoder(self: PCarrylessRangeCoder; freqtable: pcuint32; numfreq: cint): cint;
  function NextBitFromRangeCoder(self: PCarrylessRangeCoder): cint;
  function NextWeightedBitFromRangeCoder(self: PCarrylessRangeCoder; weight: cint; size: cint): cint;

  function NextWeightedBitFromRangeCoder2(self: PCarrylessRangeCoder; weight: cint; shift: cint): cint;

  procedure NormalizeRangeCoder(self: PCarrylessRangeCoder);

  function InStreamNextByte(self: PInStream): cuint8; inline;

implementation

procedure InitializeRangeCoder(self: PCarrylessRangeCoder; input: PInStream;
  uselow: cbool; bottom: cint);
begin
  self^.input:= input;
  self^.low:= 0;
  self^.code:= 0;
  self^.range:= $ffffffff;
  self^.uselow:= uselow;
  self^.bottom:= bottom;
  self^.code:=
    InStreamNextByte(input) shl 24 or
    InStreamNextByte(input) shl 16 or
    InStreamNextByte(input) shl 8  or
    InStreamNextByte(input);
end;

function RangeCoderCurrentCount(self: PCarrylessRangeCoder; scale: cuint32): cuint32;
begin
  self^.range:= self^.range div scale;
  Result:= (self^.code - self^.low) div self^.range;
end;

procedure RemoveRangeCoderSubRange(self: PCarrylessRangeCoder;
  lowcount: cuint32; highcount: cuint32);
begin
  if (self^.uselow) then
    self^.low += self^.range * lowcount
  else
    self^.code -= self^.range * lowcount;

  self^.range *= highcount - lowcount;

  NormalizeRangeCoder(self);
end;

function NextSymbolFromRangeCoder(self: PCarrylessRangeCoder;
  freqtable: pcuint32; numfreq: cint): cint;
var
  totalfreq: cuint32 = 0;
  cumulativefreq: cuint32 = 0;
  n: cint = 0;
  tmp: cuint32;
  i: cint;
begin
  for i:= 0 to numfreq - 1 do totalfreq += freqtable[i];

  tmp:= RangeCoderCurrentCount(self, totalfreq);

  while(n < numfreq - 1) and (cumulativefreq + freqtable[n] <= tmp) do
  begin
    cumulativefreq += freqtable[n];
    Inc(n);
  end;

  RemoveRangeCoderSubRange(self, cumulativefreq, cumulativefreq + freqtable[n]);

  Result:= n;
end;

function NextBitFromRangeCoder(self: PCarrylessRangeCoder): cint;
var
  bit: cint;
begin
  bit:= RangeCoderCurrentCount(self, 2);

  if (bit = 0) then RemoveRangeCoderSubRange(self, 0, 1)
  else RemoveRangeCoderSubRange(self, 1, 2);

  Result:= bit;
end;

function NextWeightedBitFromRangeCoder(self: PCarrylessRangeCoder;
  weight: cint; size: cint): cint;
var
  val, bit: cint;
begin
  val:= RangeCoderCurrentCount(self, size);

  if (val < weight) then // <= ?
  begin
    bit:= 0;
    RemoveRangeCoderSubRange(self, 0, weight);
  end
  else
  begin
    bit:= 1;
    RemoveRangeCoderSubRange(self, weight, size);
  end;

  Result:= bit;
end;

function NextWeightedBitFromRangeCoder2(self: PCarrylessRangeCoder;
  weight: cint; shift: cint): cint;
var
  bit: cint;
  threshold: cuint32;
begin
  threshold:= (self^.range shr shift) * weight;

  if (self^.code < threshold) then // <= ?
  begin
    bit:= 0;
    self^.range:= threshold;
  end
  else
  begin
    bit:= 1;
    self^.range -= threshold;
    self^.code -= threshold;
  end;

  NormalizeRangeCoder(self);

  Result:= bit;
end;

procedure NormalizeRangeCoder(self: PCarrylessRangeCoder);
begin
  while True do
  begin
    if ( (self^.low xor (self^.low + self^.range)) >= $1000000 ) then
    begin
      if (self^.range >= self^.bottom) then Break
      else self^.range:= -cint32(self^.low and (self^.bottom - 1));
    end;

    self^.code:= (self^.code shl 8) or InStreamNextByte(self^.input);
    self^.range:= self^.range shl 8;
    self^.low:= self^.low shl 8;
  end;
end;

function InStreamNextByte(self: PInStream): cuint8;
begin
  Result := self^.nextByte(self);
end;

end.

