unit PWXPay;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack,
  IdSSL, IdSSLOpenSSL, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP,IniFiles,StrUtils,IdHashMessageDigest,IdIPWatch,
  ExtCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    edtSMSQM: TEdit;
    Label2: TLabel;
    edtDDH: TEdit;
    Label3: TLabel;
    edtJE: TEdit;
    btnPay: TButton;
    http: TIdHTTP;
    ssl: TIdSSLIOHandlerSocketOpenSSL;
    Label4: TLabel;
    edtTHDDH: TEdit;
    Label5: TLabel;
    edtZJE: TEdit;
    Label6: TLabel;
    edtTHJE: TEdit;
    btnRefud: TButton;
    Button1: TButton;
    Timer1: TTimer;
    Label7: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnPayClick(Sender: TObject);
    procedure btnRefudClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    //������ <32λ�ַ���
     function GetRandomStr(InNonceStr: string): string;
     //ʹ��URL��ֵ�Եĸ�ʽ����key1=value1&key2=value2����ƴ�ӳ��ַ���
     function GetStringList(InStringList: TStringList): string;
     //ת��XML��ʽ
     function GetStringListToXml(InStringList: TStringList): String;
     //��ѯ����
     function PAYORDERQUERYAPI:String;
  public
    { Public declarations }
    FAPPID,FMCHID,FKEYID:String;
    TParamList:TStringList;
    TTempList:TStringList;
    IniWXPay:TIniFile;
  end;

  TMD5=class(TIdHashMessageDigest5)
  function StrToMD5(S:string):string;overload; //MD5����

  end;
  TIPWatch=class(TIdIPWatch)
    function GetLocalIP:String;overload;
  end;

var
  Form1: TForm1;

implementation

uses WXPayRes,superobject,superxmlparser;



{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  TParamList := TStringList.Create;
  TTempList := TStringList.Create;
  IniWXPay := TIniFile.Create(ExtractFilePath(Application.ExeName)+'\WXPAY.ini');
  FAPPID := IniWXPay.ReadString('SECRET','APPID','');
  FMCHID := IniWXPay.ReadString('SECRET','MCHID','');
  FKEYID := IniWXPay.ReadString('SECRET','KEYID','');
  IniWxPay.Free;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  TParamList.Free;
  TTempList.Free;
end;

function TForm1.GetRandomStr(InNonceStr: string): string;
var
  StartCnt, EndCnt, GetCnt: Integer;
begin
  Randomize;
  StartCnt := Random(length(InNonceStr));
  EndCnt := Random(length(InNonceStr));
  if (Abs(StartCnt - EndCnt) > 32) or
    (Abs(StartCnt - EndCnt) = 0) then
    GetCnt := 32
  else
    GetCnt := Abs(StartCnt - EndCnt);

  if (Abs(StartCnt - EndCnt) = 0)
   and ((32 + StartCnt) > Length(InNonceStr)) then
   StartCnt := 32 + StartCnt - Length(InNonceStr);

  if StartCnt - EndCnt > 0 then
    StartCnt := EndCnt;

  Result := MidStr(InNonceStr, StartCnt, GetCnt) ;
end;


procedure TForm1.btnPayClick(Sender: TObject);
var
  MD5:TMD5;
  XMLResult:String;
  ResultXML:string;
  SO:ISuperObject;
  TIP:TIPWatch;
begin
  TParamList.Clear;
  TParamList.Values['appid']:=FAPPID; //΢�ŷ���Ĺ����˺�ID
  TParamList.Values['mch_id']:=FMCHID; //�̻���
  TParamList.Values['nonce_str']:=GetRandomStr(NONCE_STR);//����ַ���<32λ
  TParamList.Values['body']:='������Ʒ'; //��Ʒ����
  TParamList.Values['out_trade_no']:=Trim(edtDDH.Text);//������ CXJ_XP1608060014
  TParamList.Values['total_fee']:=Trim(edtJE.Text);//�����ܽ���λΪ�֣�ֻ��Ϊ����
  TParamList.Values['spbill_create_ip']:=TIP.GetLocalIP;    //����΢��֧��API�Ļ���IP
  TParamList.Values['auth_code']:=Trim(edtSMSQM.Text);//ɨ��֧����Ȩ��

  TTempList.Clear;
  TTempList.Values['appid']:=FAPPID; //΢�ŷ���Ĺ����˺�ID
  TTempList.Values['mch_id']:=FMCHID; //�̻���
  TTempList.Values['nonce_str']:=TParamList.Values['nonce_str'];//����ַ���<32λ
  TTempList.Values['body']:='������Ʒ'; //��Ʒ����
  TTempList.Values['out_trade_no']:=Trim(edtDDH.Text);//������
  TTempList.Values['total_fee']:=Trim(edtJE.Text);//�����ܽ���λΪ�֣�ֻ��Ϊ����
  TTempList.Values['spbill_create_ip']:=TIP.GetLocalIP;    //����΢��֧��API�Ļ���IP
  TTempList.Values['auth_code']:=Trim(edtSMSQM.Text);//ɨ��֧����Ȩ��
  TTempList.Sort;//����
  TTempList.Values['key']:=FKEYID;//�̻�֧����Կ

  TParamList.Values['sign']:=UpperCase(MD5.StrToMD5(AnsiToUtf8(GetStringList(TTempList))));//ǩ��
  XMLResult:=GetStringListToXml(TParamList);
  TTempList.Clear;
  TTempList.Text:=AnsiToUtf8(XMLResult);
  ResultXML:=Utf8ToAnsi(http.Post(PAY_API,TTempList));
  SO:=XMLParseString(ResultXML,True);
  if SO.S['return_code']='FAIL' then
  begin
//    Application.MessageBox(PAnsiChar('֧��ʧ��'+SO.S['return_msg']),'ϵͳ��ʾ');
    ShowMessage('֧��ʧ��'+SO.S['return_msg']);
  end
  else begin
    if SO.S['result_code']='FAIL' then
//      Application.MessageBox(PAnsiChar(SO.S['err_code_des']),'ϵͳ��ʾ')
    begin
      if SO.S['err_code']='SYSTEMERROR' then //ϵͳ����
      begin

      end
      else if SO.S['err_code']='USERPAYING' then //�û�֧���У���Ҫ��������
      begin

      end
      else
        ShowMessage(SO.S['err_code_des']);
    end
    else if SO.S['result_code']='SUCCESS' then
//      Application.MessageBox(PAnsiChar('֧���ɹ�,������'+SO.S['transaction_id']+'�յ�'+SO.S['cash_fee']),'ϵͳ��ʾ');
     ShowMessage('֧���ɹ�,������'+SO.S['transaction_id']+'�յ�'+SO.S['cash_fee']);
  end;
end;

function TForm1.GetStringList(InStringList: TStringList): string;
var
  Cnt: Integer;
  ResultStr: String;
begin
  ResultStr := '';
  for Cnt := 0 to InStringList.Count - 1 do
  begin
    if Cnt <> (InStringList.Count - 1) then
    begin
      ResultStr := ResultStr + InStringList.Names[Cnt] + '=' + InStringList.ValueFromIndex[Cnt] + '&'
    end
    else
      ResultStr := ResultStr +  InStringList.Names[Cnt] + '=' + InStringList.ValueFromIndex[Cnt];
  end;
  Result := ResultStr;
end;

{ TMD5 }

function TMD5.StrToMD5(S: string): string;
var
  MD5Encode:TMD5;
begin
  MD5Encode := TMD5.Create;
  Result := MD5Encode.HashStringAsHex(S);
  MD5Encode.Free;
end;

function TForm1.GetStringListToXml(InStringList: TStringList): String;
var
  Xml: string;
  Cnt: Integer;
begin
//  Xml := '<xml> ';
//  for Cnt := 0 to InStringList.Count - 1 do
//  begin
//    if (UpperCase(InStringList.Names[Cnt]) = XML_ATTACH) or
//      (UpperCase(InStringList.Names[Cnt]) = XML_SIGN) or
//      (UpperCase(InStringList.Names[Cnt]) = XML_BODY) then
//      Xml := Xml + '<' + InStringList.Names[Cnt] + '><![CDATA[' + InStringList.ValueFromIndex[Cnt] + ']]></' + InStringList.Names[Cnt] + '>'
//    else
//      Xml := Xml + '<' + InStringList.Names[Cnt] + '>' + InStringList.ValueFromIndex[Cnt] + '</' + InStringList.Names[Cnt] + '>';
//  end;
//  Xml := Xml + '</xml>';
//  Result := Xml;
   Xml := '<xml> ';
  for Cnt := 0 to InStringList.Count - 1 do
  begin
    Xml := Xml + '<' + InStringList.Names[Cnt] + '>' + InStringList.ValueFromIndex[Cnt] + '</' + InStringList.Names[Cnt] + '>';
  end;
  Xml := Xml + '</xml>';
  Result := Xml;
end;



procedure TForm1.btnRefudClick(Sender: TObject);
var
  MD5:TMD5;
  XMLResult:String;
  ResultXML:string;
  SO:ISuperObject;
  TIP:TIPWatch;
begin
  TParamList.Clear;
  TParamList.Values['appid']:=FAPPID; //΢�ŷ���Ĺ����˺�ID
  TParamList.Values['mch_id']:=FMCHID; //�̻���
  TParamList.Values['nonce_str']:=GetRandomStr(NONCE_STR);//����ַ���<32λ
  TParamList.Values['out_trade_no']:=Trim(edtTHDDH.Text);//������
  TParamList.Values['out_refund_no']:=Trim(edtTHDDH.Text);//�˿����
  TParamList.Values['total_fee']:=Trim(edtZJE.Text);//�����ܽ���λΪ�֣�ֻ��Ϊ����
  TParamList.Values['refund_fee']:=Trim(edtTHJE.Text);//�˿���
  TParamList.Values['op_user_id']:='��Ա';//����Ա�ʺ�, Ĭ��Ϊ�̻���
  TParamList.Values['spbill_create_ip']:=TIP.GetLocalIP;//'169.254.254.203';    //����΢��֧��API�Ļ���IP

  TTempList.Clear;
  TTempList.Values['appid']:=FAPPID; //΢�ŷ���Ĺ����˺�ID
  TTempList.Values['mch_id']:=FMCHID; //�̻���
  TTempList.Values['nonce_str']:=TParamList.Values['nonce_str'];//����ַ���<32λ
  TTempList.Values['out_trade_no']:=Trim(edtTHDDH.Text);//������
  TTempList.Values['out_refund_no']:=Trim(edtTHDDH.Text);//�˿����
  TTempList.Values['total_fee']:=Trim(edtZJE.Text);//�����ܽ���λΪ�֣�ֻ��Ϊ����
  TTempList.Values['refund_fee']:=Trim(edtTHJE.Text);//�˿���
  TTempList.Values['op_user_id']:='��Ա';//����Ա�ʺ�, Ĭ��Ϊ�̻���
  TTempList.Values['spbill_create_ip']:=TIP.GetLocalIP;    //����΢��֧��API�Ļ���IP
  TTempList.Sort;//����
  TTempList.Values['key']:=FKEYID;//�̻�֧����Կ
 
  TParamList.Values['sign']:=UpperCase(MD5.StrToMD5(AnsiToUtf8(GetStringList(TTempList))));//ǩ��
  XMLResult:=GetStringListToXml(TParamList);
  TTempList.Clear;
  TTempList.Text:=AnsiToUtf8(XMLResult);
  ResultXML:=Utf8ToAnsi(http.Post(REFUND_API,TTempList));
  SO:=XMLParseString(ResultXML,True);
  if SO.S['return_code']='FAIL' then
  begin
//    Application.MessageBox(PAnsiChar('�˿�ʧ��'+SO.S['return_msg']),'ϵͳ��ʾ');
    ShowMessage('�˿�ʧ��'+SO.S['return_msg']);
  end
  else begin
    if SO.S['result_code']='FAIL' then
//      Application.MessageBox(PAnsiChar(SO.S['err_code_des']),'ϵͳ��ʾ')
      ShowMessage(SO.S['err_code_des'])
    else if SO.S['result_code']='SUCCESS' then
//      Application.MessageBox(PAnsiChar('�˿�ɹ�'),'ϵͳ��ʾ');
      ShowMessage('�˿�ɹ�');

  end;
end;

{ TIPWatch }

function TIPWatch.GetLocalIP: String;
var
  TIP:TIPWatch;
begin
  TIP := TIPWatch.Create(nil);
  Result := TIP.LocalIP;
  TIP.Free;
end;

function TForm1.PAYORDERQUERYAPI: String;
var
  MD5:TMD5;
  XMLResult:String;
  ResultXML:string;
  SO:ISuperObject;
  TIP:TIPWatch;
begin
  TParamList.Clear;
  TParamList.Values['appid']:=FAPPID; //΢�ŷ���Ĺ����˺�ID
  TParamList.Values['mch_id']:=FMCHID; //�̻���
  TParamList.Values['out_trade_no']:=Trim(edtDDH.Text);//������ CXJ_XP1608060014
  TParamList.Values['nonce_str']:=GetRandomStr(NONCE_STR);//����ַ���<32λ

  TTempList.Clear;
  TTempList.Values['appid']:=FAPPID; //΢�ŷ���Ĺ����˺�ID
  TTempList.Values['mch_id']:=FMCHID; //�̻���
  TTempList.Values['out_trade_no']:=Trim(edtDDH.Text);//������ CXJ_XP1608060014
  TTempList.Values['nonce_str']:=TParamList.Values['nonce_str'];//����ַ���<32λ
  TTempList.Sort;//����
  TTempList.Values['key']:=FKEYID;//�̻�֧����Կ

  TParamList.Values['sign']:=UpperCase(MD5.StrToMD5(AnsiToUtf8(GetStringList(TTempList))));//ǩ��
  XMLResult:=GetStringListToXml(TParamList);
  TTempList.Clear;
  TTempList.Text:=AnsiToUtf8(XMLResult);
  ResultXML:=Utf8ToAnsi(http.Post(PAYORDERQUERY_API,TTempList));
  SO:=XMLParseString(ResultXML,True);
  if SO.S['return_code']='FAIL' then
  begin
    Result:=SO.S['return_msg'];
  end
  else begin
    if SO.S['result_code']='FAIL' then
       Result := SO.S['err_code_des']
    else if SO.S['result_code']='SUCCESS' then
      Result := SO.S['trade_state'];
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  ShowMessage(PAYORDERQUERYAPI);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  showmessage('1');
  Timer1.Enabled := False;
end;

end.
