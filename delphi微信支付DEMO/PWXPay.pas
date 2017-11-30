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
    //获得随机 <32位字符串
     function GetRandomStr(InNonceStr: string): string;
     //使用URL键值对的格式（即key1=value1&key2=value2…）拼接成字符串
     function GetStringList(InStringList: TStringList): string;
     //转成XML格式
     function GetStringListToXml(InStringList: TStringList): String;
     //查询订单
     function PAYORDERQUERYAPI:String;
  public
    { Public declarations }
    FAPPID,FMCHID,FKEYID:String;
    TParamList:TStringList;
    TTempList:TStringList;
    IniWXPay:TIniFile;
  end;

  TMD5=class(TIdHashMessageDigest5)
  function StrToMD5(S:string):string;overload; //MD5加密

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
  TParamList.Values['appid']:=FAPPID; //微信分配的公众账号ID
  TParamList.Values['mch_id']:=FMCHID; //商户号
  TParamList.Values['nonce_str']:=GetRandomStr(NONCE_STR);//随机字符串<32位
  TParamList.Values['body']:='测试商品'; //商品描述
  TParamList.Values['out_trade_no']:=Trim(edtDDH.Text);//订单号 CXJ_XP1608060014
  TParamList.Values['total_fee']:=Trim(edtJE.Text);//订单总金额，单位为分，只能为整数
  TParamList.Values['spbill_create_ip']:=TIP.GetLocalIP;    //调用微信支付API的机器IP
  TParamList.Values['auth_code']:=Trim(edtSMSQM.Text);//扫码支付授权码

  TTempList.Clear;
  TTempList.Values['appid']:=FAPPID; //微信分配的公众账号ID
  TTempList.Values['mch_id']:=FMCHID; //商户号
  TTempList.Values['nonce_str']:=TParamList.Values['nonce_str'];//随机字符串<32位
  TTempList.Values['body']:='测试商品'; //商品描述
  TTempList.Values['out_trade_no']:=Trim(edtDDH.Text);//订单号
  TTempList.Values['total_fee']:=Trim(edtJE.Text);//订单总金额，单位为分，只能为整数
  TTempList.Values['spbill_create_ip']:=TIP.GetLocalIP;    //调用微信支付API的机器IP
  TTempList.Values['auth_code']:=Trim(edtSMSQM.Text);//扫码支付授权码
  TTempList.Sort;//排序
  TTempList.Values['key']:=FKEYID;//商户支付密钥

  TParamList.Values['sign']:=UpperCase(MD5.StrToMD5(AnsiToUtf8(GetStringList(TTempList))));//签名
  XMLResult:=GetStringListToXml(TParamList);
  TTempList.Clear;
  TTempList.Text:=AnsiToUtf8(XMLResult);
  ResultXML:=Utf8ToAnsi(http.Post(PAY_API,TTempList));
  SO:=XMLParseString(ResultXML,True);
  if SO.S['return_code']='FAIL' then
  begin
//    Application.MessageBox(PAnsiChar('支付失败'+SO.S['return_msg']),'系统提示');
    ShowMessage('支付失败'+SO.S['return_msg']);
  end
  else begin
    if SO.S['result_code']='FAIL' then
//      Application.MessageBox(PAnsiChar(SO.S['err_code_des']),'系统提示')
    begin
      if SO.S['err_code']='SYSTEMERROR' then //系统错误
      begin

      end
      else if SO.S['err_code']='USERPAYING' then //用户支付中，需要输入密码
      begin

      end
      else
        ShowMessage(SO.S['err_code_des']);
    end
    else if SO.S['result_code']='SUCCESS' then
//      Application.MessageBox(PAnsiChar('支付成功,订单号'+SO.S['transaction_id']+'收到'+SO.S['cash_fee']),'系统提示');
     ShowMessage('支付成功,订单号'+SO.S['transaction_id']+'收到'+SO.S['cash_fee']);
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
  TParamList.Values['appid']:=FAPPID; //微信分配的公众账号ID
  TParamList.Values['mch_id']:=FMCHID; //商户号
  TParamList.Values['nonce_str']:=GetRandomStr(NONCE_STR);//随机字符串<32位
  TParamList.Values['out_trade_no']:=Trim(edtTHDDH.Text);//订单号
  TParamList.Values['out_refund_no']:=Trim(edtTHDDH.Text);//退款订单号
  TParamList.Values['total_fee']:=Trim(edtZJE.Text);//订单总金额，单位为分，只能为整数
  TParamList.Values['refund_fee']:=Trim(edtTHJE.Text);//退款金额
  TParamList.Values['op_user_id']:='店员';//操作员帐号, 默认为商户号
  TParamList.Values['spbill_create_ip']:=TIP.GetLocalIP;//'169.254.254.203';    //调用微信支付API的机器IP

  TTempList.Clear;
  TTempList.Values['appid']:=FAPPID; //微信分配的公众账号ID
  TTempList.Values['mch_id']:=FMCHID; //商户号
  TTempList.Values['nonce_str']:=TParamList.Values['nonce_str'];//随机字符串<32位
  TTempList.Values['out_trade_no']:=Trim(edtTHDDH.Text);//订单号
  TTempList.Values['out_refund_no']:=Trim(edtTHDDH.Text);//退款订单号
  TTempList.Values['total_fee']:=Trim(edtZJE.Text);//订单总金额，单位为分，只能为整数
  TTempList.Values['refund_fee']:=Trim(edtTHJE.Text);//退款金额
  TTempList.Values['op_user_id']:='店员';//操作员帐号, 默认为商户号
  TTempList.Values['spbill_create_ip']:=TIP.GetLocalIP;    //调用微信支付API的机器IP
  TTempList.Sort;//排序
  TTempList.Values['key']:=FKEYID;//商户支付密钥
 
  TParamList.Values['sign']:=UpperCase(MD5.StrToMD5(AnsiToUtf8(GetStringList(TTempList))));//签名
  XMLResult:=GetStringListToXml(TParamList);
  TTempList.Clear;
  TTempList.Text:=AnsiToUtf8(XMLResult);
  ResultXML:=Utf8ToAnsi(http.Post(REFUND_API,TTempList));
  SO:=XMLParseString(ResultXML,True);
  if SO.S['return_code']='FAIL' then
  begin
//    Application.MessageBox(PAnsiChar('退款失败'+SO.S['return_msg']),'系统提示');
    ShowMessage('退款失败'+SO.S['return_msg']);
  end
  else begin
    if SO.S['result_code']='FAIL' then
//      Application.MessageBox(PAnsiChar(SO.S['err_code_des']),'系统提示')
      ShowMessage(SO.S['err_code_des'])
    else if SO.S['result_code']='SUCCESS' then
//      Application.MessageBox(PAnsiChar('退款成功'),'系统提示');
      ShowMessage('退款成功');

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
  TParamList.Values['appid']:=FAPPID; //微信分配的公众账号ID
  TParamList.Values['mch_id']:=FMCHID; //商户号
  TParamList.Values['out_trade_no']:=Trim(edtDDH.Text);//订单号 CXJ_XP1608060014
  TParamList.Values['nonce_str']:=GetRandomStr(NONCE_STR);//随机字符串<32位

  TTempList.Clear;
  TTempList.Values['appid']:=FAPPID; //微信分配的公众账号ID
  TTempList.Values['mch_id']:=FMCHID; //商户号
  TTempList.Values['out_trade_no']:=Trim(edtDDH.Text);//订单号 CXJ_XP1608060014
  TTempList.Values['nonce_str']:=TParamList.Values['nonce_str'];//随机字符串<32位
  TTempList.Sort;//排序
  TTempList.Values['key']:=FKEYID;//商户支付密钥

  TParamList.Values['sign']:=UpperCase(MD5.StrToMD5(AnsiToUtf8(GetStringList(TTempList))));//签名
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
