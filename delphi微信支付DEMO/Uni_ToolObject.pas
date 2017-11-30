unit Uni_ToolObject;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdStreamVCLWin32,IdHashMessageDigest,IdHash,IdGlobal;
const
  MD4_INIT_VALUES: T4x4LongWordRecord = (
    $67452301, $EFCDAB89, $98BADCFE, $10325476);
  MD5_SINE : array [1..64] of LongWord = (
   { Round 1. }
   $d76aa478, $e8c7b756, $242070db, $c1bdceee, $f57c0faf, $4787c62a,
   $a8304613, $fd469501, $698098d8, $8b44f7af, $ffff5bb1, $895cd7be,
   $6b901122, $fd987193, $a679438e, $49b40821,
   { Round 2. }
   $f61e2562, $c040b340, $265e5a51, $e9b6c7aa, $d62f105d, $02441453,
   $d8a1e681, $e7d3fbc8, $21e1cde6, $c33707d6, $f4d50d87, $455a14ed,
   $a9e3e905, $fcefa3f8, $676f02d9, $8d2a4c8a,
   { Round 3. }
   $fffa3942, $8771f681, $6d9d6122, $fde5380c, $a4beea44, $4bdecfa9,
   $f6bb4b60, $bebfbc70, $289b7ec6, $eaa127fa, $d4ef3085, $04881d05,
   $d9d4d039, $e6db99e5, $1fa27cf8, $c4ac5665,
   { Round 4. }
   $f4292244, $432aff97, $ab9423a7, $fc93a039, $655b59c3, $8f0ccc92,
   $ffeff47d, $85845dd1, $6fa87e4f, $fe2ce6e0, $a3014314, $4e0811a1,
   $f7537e82, $bd3af235, $2ad7d2bb, $eb86d391
  );

type
  // MD5加密对象
  TMD5 = class(TIdHash)
    FState: T4x4LongWordRecord;
    FCBuffer: T512BitRecord;
    //带入AnsiString，返回AnsiString;
    procedure MDCoder;
    function StrToMD5(S: String): String;
    function StreamToMD5(AStream: Tstream):string;
    function AsHex(const AValue: T4x4LongWordRecord): string;
    function HashValue(const ASrc: string): T4x4LongWordRecord; overload;
    function HashValue(AStream: TStream): T4x4LongWordRecord; overload; virtual;
  end;
var
  MD5: TMD5;
implementation

{ TMD5 }
{$Q-} // Arithmetic operations performed modulo $100000000
procedure TMD5.MDCoder;
var
  A, B, C, D : LongWord;
  i: Integer;
  x : T16x4LongWordRecord; // 64-byte buffer
  function ROL(AVal: LongWord; AShift: Byte): LongWord;
  begin
     Result := (AVal shl AShift) or (AVal shr (32 - AShift));
  end;
begin
  A := FState[0];
  B := FState[1];
  C := FState[2];
  D := FState[3];

  for i := 0 to 15 do
    x[i] := FCBuffer[i*4+0] +
            (FCBuffer[i*4+1] shl 8) +
            (FCBuffer[i*4+2] shl 16) +
            (FCBuffer[i*4+3] shl 24);

  { Round 1 }
  { Note:
      (x and y) or ( (not x) and z)
    is equivalent to
      (((z xor y) and x) xor z)
    -HHellstr鰉 }
  A := ROL(A + (((D xor C) and B) xor D) + x[ 0] + MD5_SINE[ 1],  7) + B;
  D := ROL(D + (((C xor B) and A) xor C) + x[ 1] + MD5_SINE[ 2], 12) + A;
  C := ROL(C + (((B xor A) and D) xor B) + x[ 2] + MD5_SINE[ 3], 17) + D;
  B := ROL(B + (((A xor D) and C) xor A) + x[ 3] + MD5_SINE[ 4], 22) + C;
  A := ROL(A + (((D xor C) and B) xor D) + x[ 4] + MD5_SINE[ 5],  7) + B;
  D := ROL(D + (((C xor B) and A) xor C) + x[ 5] + MD5_SINE[ 6], 12) + A;
  C := ROL(C + (((B xor A) and D) xor B) + x[ 6] + MD5_SINE[ 7], 17) + D;
  B := ROL(B + (((A xor D) and C) xor A) + x[ 7] + MD5_SINE[ 8], 22) + C;
  A := ROL(A + (((D xor C) and B) xor D) + x[ 8] + MD5_SINE[ 9],  7) + B;
  D := ROL(D + (((C xor B) and A) xor C) + x[ 9] + MD5_SINE[10], 12) + A;
  C := ROL(C + (((B xor A) and D) xor B) + x[10] + MD5_SINE[11], 17) + D;
  B := ROL(B + (((A xor D) and C) xor A) + x[11] + MD5_SINE[12], 22) + C;
  A := ROL(A + (((D xor C) and B) xor D) + x[12] + MD5_SINE[13],  7) + B;
  D := ROL(D + (((C xor B) and A) xor C) + x[13] + MD5_SINE[14], 12) + A;
  C := ROL(C + (((B xor A) and D) xor B) + x[14] + MD5_SINE[15], 17) + D;
  B := ROL(B + (((A xor D) and C) xor A) + x[15] + MD5_SINE[16], 22) + C;

  { Round 2 }
  { Note:
      (x and z) or (y and (not z) )
    is equivalent to
      (((y xor x) and z) xor y)
    -HHellstr鰉 }
  A := ROL(A + (C xor (D and (B xor C))) + x[ 1] + MD5_SINE[17],  5) + B;
  D := ROL(D + (B xor (C and (A xor B))) + x[ 6] + MD5_SINE[18],  9) + A;
  C := ROL(C + (A xor (B and (D xor A))) + x[11] + MD5_SINE[19], 14) + D;
  B := ROL(B + (D xor (A and (C xor D))) + x[ 0] + MD5_SINE[20], 20) + C;
  A := ROL(A + (C xor (D and (B xor C))) + x[ 5] + MD5_SINE[21],  5) + B;
  D := ROL(D + (B xor (C and (A xor B))) + x[10] + MD5_SINE[22],  9) + A;
  C := ROL(C + (A xor (B and (D xor A))) + x[15] + MD5_SINE[23], 14) + D;
  B := ROL(B + (D xor (A and (C xor D))) + x[ 4] + MD5_SINE[24], 20) + C;
  A := ROL(A + (C xor (D and (B xor C))) + x[ 9] + MD5_SINE[25],  5) + B;
  D := ROL(D + (B xor (C and (A xor B))) + x[14] + MD5_SINE[26],  9) + A;
  C := ROL(C + (A xor (B and (D xor A))) + x[ 3] + MD5_SINE[27], 14) + D;
  B := ROL(B + (D xor (A and (C xor D))) + x[ 8] + MD5_SINE[28], 20) + C;
  A := ROL(A + (C xor (D and (B xor C))) + x[13] + MD5_SINE[29],  5) + B;
  D := ROL(D + (B xor (C and (A xor B))) + x[ 2] + MD5_SINE[30],  9) + A;
  C := ROL(C + (A xor (B and (D xor A))) + x[ 7] + MD5_SINE[31], 14) + D;
  B := ROL(B + (D xor (A and (C xor D))) + x[12] + MD5_SINE[32], 20) + C;

  { Round 3. }
  A := ROL(A + (B xor C xor D) + x[ 5] + MD5_SINE[33],  4) + B;
  D := ROL(D + (A xor B xor C) + x[ 8] + MD5_SINE[34], 11) + A;
  C := ROL(C + (D xor A xor B) + x[11] + MD5_SINE[35], 16) + D;
  B := ROL(B + (C xor D xor A) + x[14] + MD5_SINE[36], 23) + C;
  A := ROL(A + (B xor C xor D) + x[ 1] + MD5_SINE[37],  4) + B;
  D := ROL(D + (A xor B xor C) + x[ 4] + MD5_SINE[38], 11) + A;
  C := ROL(C + (D xor A xor B) + x[ 7] + MD5_SINE[39], 16) + D;
  B := ROL(B + (C xor D xor A) + x[10] + MD5_SINE[40], 23) + C;
  A := ROL(A + (B xor C xor D) + x[13] + MD5_SINE[41],  4) + B;
  D := ROL(D + (A xor B xor C) + x[ 0] + MD5_SINE[42], 11) + A;
  C := ROL(C + (D xor A xor B) + x[ 3] + MD5_SINE[43], 16) + D;
  B := ROL(B + (C xor D xor A) + x[ 6] + MD5_SINE[44], 23) + C;
  A := ROL(A + (B xor C xor D) + x[ 9] + MD5_SINE[45],  4) + B;
  D := ROL(D + (A xor B xor C) + x[12] + MD5_SINE[46], 11) + A;
  C := ROL(C + (D xor A xor B) + x[15] + MD5_SINE[47], 16) + D;
  B := ROL(B + (C xor D xor A) + x[ 2] + MD5_SINE[48], 23) + C;

  { Round 4. }
  A := ROL(A + ((B or not D) xor C) + x[ 0] + MD5_SINE[49],  6) + B;
  D := ROL(D + ((A or not C) xor B) + x[ 7] + MD5_SINE[50], 10) + A;
  C := ROL(C + ((D or not B) xor A) + x[14] + MD5_SINE[51], 15) + D;
  B := ROL(B + ((C or not A) xor D) + x[ 5] + MD5_SINE[52], 21) + C;
  A := ROL(A + ((B or not D) xor C) + x[12] + MD5_SINE[53],  6) + B;
  D := ROL(D + ((A or not C) xor B) + x[ 3] + MD5_SINE[54], 10) + A;
  C := ROL(C + ((D or not B) xor A) + x[10] + MD5_SINE[55], 15) + D;
  B := ROL(B + ((C or not A) xor D) + x[ 1] + MD5_SINE[56], 21) + C;
  A := ROL(A + ((B or not D) xor C) + x[ 8] + MD5_SINE[57],  6) + B;
  D := ROL(D + ((A or not C) xor B) + x[15] + MD5_SINE[58], 10) + A;
  C := ROL(C + ((D or not B) xor A) + x[ 6] + MD5_SINE[59], 15) + D;
  B := ROL(B + ((C or not A) xor D) + x[13] + MD5_SINE[60], 21) + C;
  A := ROL(A + ((B or not D) xor C) + x[ 4] + MD5_SINE[61],  6) + B;
  D := ROL(D + ((A or not C) xor B) + x[11] + MD5_SINE[62], 10) + A;
  C := ROL(C + ((D or not B) xor A) + x[ 2] + MD5_SINE[63], 15) + D;
  B := ROL(B + ((C or not A) xor D) + x[ 9] + MD5_SINE[64], 21) + C;

  Inc(FState[0], A);
  Inc(FState[1], B);
  Inc(FState[2], C);
  Inc(FState[3], D);
end;
{$Q+}
function TMD5.HashValue(const ASrc: string): T4x4LongWordRecord;
var
  LStream: TStream;  // not TIdStringStream -  Unicode on DotNet!
begin
  LStream := TMemoryStream.Create; try
    with TIdStreamVCLWin32.Create(LStream) do try
      Write(ASrc);
      VCLStream.Position := 0;
      Result := HashValue(VCLStream);
    finally Free; end;
  finally FreeAndNil(LStream); end;
end;

function TMD5.StrToMD5(S: String): String;
begin
  Result := AsHex(hashvalue(AnsiToUtf8(s)));
end;
function TMD5.AsHex(const AValue: T4x4LongWordRecord): string;
Begin
  result := ToHex(AValue);
end;
function TMD5.HashValue(AStream: TStream): T4x4LongWordRecord;
var
  LStartPos: Integer;
  LBitSize,
  LSize: Int64;
  I: Integer;

begin
  LStartPos := AStream.Position;
  LSize := AStream.Size - LStartPos;

  // A straight assignment would be by ref on dotNET.
  for I := 0 to 3 do
    FState[I] := MD4_INIT_VALUES[I];

  while LSize - AStream.Position >= 64 do
  begin
    AStream.Read(FCBuffer, 64);
    MDCoder;
  end;

  // Read the last set of bytes.
  LStartPos := AStream.Read(FCBuffer, 64);
  // Append one bit with value 1
  FCBuffer[LStartPos] := $80;
  LStartPos := LStartPos + 1;

  // Must have sufficient space to insert the 64-bit size value
  if LStartPos > 56 then
  begin
    for I := LStartPos to 63 do
      FCBuffer[I] := 0;
    MDCoder;
    LStartPos := 0;
  end;
  // Pad with zeroes. Leave room for the 64 bit size value.
  for I := LStartPos to 55 do
    FCBuffer[I] := 0;

  // Append the Number of bits processed.
  LBitSize := LSize * 8;
  for I := 56 to 63 do
  begin
    FCBuffer[I] := LBitSize and $FF;
    LBitSize := LBitSize shr 8;
  end;
  MDCoder;

  Result := FState;
end;

function TMD5.StreamToMD5(AStream: Tstream): string;
begin
   Result := AsHex(hashvalue(Astream));
end;

initialization
  MD5 := TMD5.Create;
finalization
  FreeAndNil(MD5);
end.
