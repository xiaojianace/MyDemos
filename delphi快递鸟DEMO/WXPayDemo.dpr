program WXPayDemo;

uses
  Forms,
  PWXPay in 'PWXPay.pas' {Form1},
  WXPayRes in 'WXPayRes.pas',
  superobject in 'superobject.pas',
  superxmlparser in 'superxmlparser.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
