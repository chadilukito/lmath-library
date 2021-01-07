unit MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, DateUtils,
  fftw_, uFFT, uFFTFort,//FFTW
  ap, fft, //ALGLIB v2.6
  uDFT, //DFT for LMath
  utypes, //type definition of LMath
  uMath;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    ResultsMemo: TMemo;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  FFTWPlan:fftw_plan;
  N,I:Integer;
  StartTime, EndTime:TDateTime;
  FFTLibTime,AlgLibTime,LMathTime:int64;
  LMathInput,LMathOutput:TCompVector;
  FFTWInput,FFTWOutput:Array of Double;
  ALGLIBInput,ALGLIBOutput:TComplex1DArray;
begin
  Button1.Enabled:=False;
  Randomize();
  // N:=Random(100000);
  N := 16;
  ResultsMemo.Append('Executing test. Data length: '+IntToStr(N));
  SetLength(LMathInput,N);
  SetLength(LMathOutput,N);
  SetLength(FFTWInput,2*N);
  SetLength(FFTWOutput,2*N);
  SetLength(ALGLIBInput,N);
  SetLength(ALGLIBOutput,N);
  for I := 0 to (N-1) do
  begin
    LMathInput[I].X:=Cos(I*7)+Sin(1.7/(I+1));
    LMathInput[I].Y:=IntPower(-1,I div 4)*1.2;
    FFTWInput[2*I]:=LMathInput[I].X;
    FFTWInput[2*I+1]:=LMathInput[I].Y;
    ALGLIBInput[I].X:=LMathInput[I].X;
    ALGLIBInput[I].Y:=LMathInput[I].Y;
  end;

  // FFTLib
  StartTime := Time;
  FFTWPlan:=fftw_.fftw_plan_dft_1d(N,@FFTWInput[0],@FFTWOutput[0],-1,128);
  fftw_.fftw_execute(FFTWPlan);
  EndTime := Time;
  FFTLibTime := MilliSecondsBetween(EndTime,StartTime);

  //LMath
  StartTime:=Time;
  // uDFT.FFTC1D(LMathInput,0,High(LMathInput));
  // uFFT.FFT(16,LMathInput,LMathOutput);
  uFFTFort.FFT(LMathInput,LMathOutput,0,High(LMathInput));
  EndTime := Time;
  for I := 0 to N-1 do
    LMathOutput[I] := LMathOutput[I+1];
  LMathTime:=MilliSecondsBetween(EndTime,StartTime);

  //AlgLib
  StartTime := Time;
  fft.FFTC1D(ALGLIBInput,N);
  EndTime := Time;
  AlgLibTime := MilliSecondsBetween(EndTime,StartTime);

  ResultsMemo.Append('Time needed for DFT, ms:');
  ResultsMemo.Append('  FFTW: '+IntToStr(FFTLibTime));
  ResultsMemo.Append('AlgLib: '+IntToStr(AlgLibTime));
  ResultsMemo.Append(' LMath: '+IntToStr(LMathTime));

  for I := 0 to (N-1) do
  begin
    LMathOutput[I] := LMathInput[I];
    ALGLIBOutput[I]:= ALGLIBInput[I];
    if ((abs(LMathOutput[I].X)>=1e-12) and ((abs(ALGLIBOutput[I].X/LMathOutput[I].X-1)>1e-6) or (abs(FFTWOutput[2*I]/LMathOutput[I].X-1)>1e-6))) or
       ((abs(LMathOutput[I].X)<1e-12) and ((abs(ALGLIBOutput[I].X)>=1e-12) or (abs(FFTWOutput[2*I])>=1e-12))) or
       ((abs(LMathOutput[I].Y)>=1e-12) and ((abs(ALGLIBOutput[I].Y/LMathOutput[I].Y-1)>1e-6) or (abs(FFTWOutput[2*I+1]/LMathOutput[I].Y-1)>1e-6))) or
       ((abs(LMathOutput[I].Y)<1e-12) and ((abs(ALGLIBOutput[I].Y)>=1e-12) or (abs(FFTWOutput[2*I+1])>=1e-12))) then
    begin
      ResultsMemo.Append('FFT deviation that cannot be ignored happens at I = '+inttostr(I));
      ResultsMemo.Append('  LMath: '+floattostr(LMathOutput[I].X)+' + i'+floattostr(LMathOutput[I].Y));
      ResultsMemo.Append('  FFTW:  '+floattostr(FFTWOutput[2*I])+' + i'+floattostr(FFTWOutput[2*I+1]));
      ResultsMemo.Append('  ALGLIB:'+floattostr(ALGLIBOutput[I].X)+' + i'+floattostr(ALGLIBOutput[I].Y));
    end;
  end;

  uDFT.FFTC1DInv(LMathInput,0,High(LMathInput));  //<------ where is call to FFTW?
  fft.FFTC1DInv(ALGLIBInput,N);
  for I := 0 to (N-1) do
  begin
    LMathOutput[I].X:=LMathInput[I].X;
    LMathOutput[I].Y:=LMathInput[I].Y;
    ALGLIBOutput[I].X:=ALGLIBInput[I].X;
    ALGLIBOutput[I].Y:=ALGLIBInput[I].Y;
    if ((abs(LMathOutput[I].X)>=1e-12) and ((abs(ALGLIBOutput[I].X/LMathOutput[I].X-1)>1e-6) or (abs(FFTWInput[2*I]/LMathOutput[I].X-1)>1e-6))) or
       ((abs(LMathOutput[I].X)<1e-12) and ((abs(ALGLIBOutput[I].X)>=1e-12) or (abs(FFTWInput[2*I])>=1e-12))) or
       ((abs(LMathOutput[I].Y)>=1e-12) and ((abs(ALGLIBOutput[I].Y/LMathOutput[I].Y-1)>1e-6) or (abs(FFTWInput[2*I+1]/LMathOutput[I].Y-1)>1e-6))) or
       ((abs(LMathOutput[I].Y)<1e-12) and ((abs(ALGLIBOutput[I].Y)>=1e-12) or (abs(FFTWInput[2*I+1])>=1e-12))) then
    begin
        ResultsMemo.Append('Inverse FFT deviation that cannot be ignored happens at I = '+inttostr(I));
        ResultsMemo.Append('  LMath: '+floattostr(LMathOutput[I].X)+' + i'+floattostr(LMathOutput[I].Y));
        ResultsMemo.Append('  FFTW:  '+floattostr(FFTWOutput[2*I])+' + i'+floattostr(FFTWOutput[2*I+1]));
        ResultsMemo.Append('  ALGLIB:'+floattostr(ALGLIBOutput[I].X)+' + i'+floattostr(ALGLIBOutput[I].Y));
        ResultsMemo.Append('');
    end;
 {      showmessage('IFFT deviation that cannot be ignored happens at I = '+inttostr(I)+#13#10+
                  'LMath: '+floattostr(LMathOutput[I].X)+' + i'+floattostr(LMathOutput[I].Y)+#13#10+
                  'FFTW:  '+floattostr(FFTWInput[2*I])+' + i'+floattostr(FFTWInput[2*I+1])+#13#10+
                  'ALGLIB:'+floattostr(ALGLIBOutput[I].X)+' + i'+floattostr(ALGLIBOutput[I].Y));
    end;  }
  end;
  ResultsMemo.Append('Test ended');
  ResultsMemo.Append('');
  Button1.Enabled:=True;
  Button1.SetFocus;
end;

end.

