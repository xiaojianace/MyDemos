unit PWXPay;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack,
  IdSSL, IdSSLOpenSSL, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP,IniFiles,StrUtils,IdHashMessageDigest,IdIPWatch,
  libeay32,EncdDecd,HttpApp, InvokeRegistry, Rio, SOAPHTTPClient;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    edtSMSQM: TEdit;
    Label2: TLabel;
    edtDDH: TEdit;
    Label3: TLabel;
    edtJE: TEdit;
    btnPay: TButton;
    Label4: TLabel;
    edtTHDDH: TEdit;
    Label5: TLabel;
    edtZJE: TEdit;
    Label6: TLabel;
    edtTHJE: TEdit;
    btnRefud: TButton;
    Memo1: TMemo;
    Button1: TButton;
    http: TIdHTTP;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnPayClick(Sender: TObject);
    procedure btnRefudClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    //获得随机 <32位字符串
     function GetRandomStr(InNonceStr: string): string;
     //使用URL键值对的格式（即key1=value1&key2=value2…）拼接成字符串
     function GetStringList(InStringList: TStringList): string;
     //转成JSON格式
     function GetStringListToJson(InStringList:TStringList):String;
     function  BSTrack_Post(sUrl:string;sJsonPara:string):string;

  public
    { Public declarations }
    FAPPID,FMCHID,FKEYID:String;
    TParamList:TStringList;
    TTempList:TStringList;
    TBizContent:TStringList;
    IniWXPay:TIniFile;
    function Sign(filename,msg : String):string;
    function LoadPrivateKey(filename:string ): pRSA;
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
  TBizContent := TStringList.Create;
  IniWXPay := TIniFile.Create(ExtractFilePath(Application.ExeName)+'\WXPAY.ini');
  FAPPID := IniWXPay.ReadString('SECRET','APPID','');
//  FMCHID := IniWXPay.ReadString('SECRET','MCHID','');
  FKEYID := IniWXPay.ReadString('SECRET','KEYID','');
  FKEYID := '-----BEGIN RSA PRIVATE KEY-----'
          +'MIICXAIBAAKBgQDnBq+jNGh4YJ8d7aWt0ctBzbh4zWzy3jihw8so4JruyMwXj8FZ'
          +'4895ujhA3lc8X+4QbLXlq9WNXZ1uZ2SZnBm6U+3qs0hFfNU0Pj+C4brGBgLWYIVw'
          +'q+MWsmOSZrgRn1BvzhKuyEhoZyg8oReYQc3u71UMz/L2ftloF9AesaShawIDAQAB'
          +'AoGAa+aKh85FcNun1WGWPQ28QfqkSv+e//vcNWlt7KSimB3+fI6uvp4Q3Aiml12B'
          +'HvirBs7PUfqkngb4LYVqzffDZ4jAHFXxwWNHteTdoHgzcHD4GhRzHQwbDCtNYmgy'
          +'u0m6dDSLeBlbBxZ6yOlrHlNX2WyvEOW+OSrWH0u1cl9P3RkCQQD+T/9AzeyWyo3N'
          +'ArGoeAJneZco6hEBaf+pMO+GMg7qu4qjt5pkk7QtBmYlx8ayEHa8LltOgz9+16rn'
          +'Uk/pnXb1AkEA6I8h2gSYEXbfgqmw8z3stLyfs/I95F1e8V2LL8RZMon0yeBlzUC7'
          +'NNbQP8eeynWLf5kpFLexPK6UQFFDRVy63wJBAOCzakOmL28k1ZnY0YSbVPR8mLUL'
          +'666mK8EgfeLChC+fOWZiqcZIQ6Cs0MB8/fEDXwXyp7Z9fTLj+BufvQAbo6kCQD7a'
          +'2KplTXiC6XwWQxYrKXvb80oece3z8oJH5yOc7QLE2J1rgfhMw4xPdu+WE2vjAzYU'
          +'fk70KvocsUME86qemn8CQDu81wjPIa553K55/8rf1n92L+lLBpOPNkCumLKExZJ1'
          +'X+LrYmU6Vqihl6BwZH0JVsLdOj/3k2m6TBukWDjGT88='
          +'-----END RSA PRIVATE KEY-----';

  IniWxPay.Free;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  TParamList.Free;
  TTempList.Free;
  TBizContent.Free;
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
  JSONResult:String;
  ResultJSON:string;
  ISBResult:ISuperObject;
  TIP:TIPWatch;
  sFileDir: String;
begin
  TParamList.Clear;
  //公共请求参数
  TParamList.Values['app_id']:=FAPPID; //支付宝分配给开发者的应用ID
  TParamList.Values['method']:='alipay.trade.pay'; //接口名称
  TParamList.Values['charset']:='utf-8'; //请求使用的编码格式，如utf-8,gbk,gb2312等
  TParamList.Values['sign_type']:='RSA'; //商户生成签名字符串所使用的签名算法类型，目前支持RSA
  TParamList.Values['timestamp']:=FormatDateTime('yyyy-MM-dd HH:mm:ss',now);//发送请求的时间，格式"yyyy-MM-dd HH:mm:ss"
  TParamList.Values['version']:='1.0';//调用的接口版本，固定为：1.0

  //请求参数
  TParamList.Values['out_trade_no']:=Trim(edtDDH.Text);//商户订单号,64个字符以内、可包含字母、数字、下划线；需保证在商户端不重复
  TParamList.Values['scene'] := 'bar_code';//支付场景 条码支付，取值：bar_code 声波支付，取值：wave_code
  TParamList.Values['auth_code'] := Trim(edtSMSQM.Text);//支付授权码
  TParamList.Values['total_amount']:=Trim(edtJE.Text);//订单总金额，单位为元，精确到小数点后两位，取值范围[0.01,100000000]
  TParamList.Values['subject']:='测试商品';//订单标题

  //得到biz_content
  TBizContent.Clear;
  TBizContent.Values['out_trade_no']:=Trim(edtDDH.Text);//商户订单号,64个字符以内、可包含字母、数字、下划线；需保证在商户端不重复
  TBizContent.Values['scene'] := 'bar_code';//支付场景 条码支付，取值：bar_code 声波支付，取值：wave_code
  TBizContent.Values['auth_code'] := Trim(edtSMSQM.Text);//支付授权码
  TBizContent.Values['total_amount']:=Trim(edtJE.Text);//订单总金额，单位为元，精确到小数点后两位，取值范围[0.01,100000000]
  TBizContent.Values['subject']:='测试商品';//订单标题
  TParamList.Values['biz_content']:=GetStringListToJson(TBizContent); //请求参数的集合，最大长度不限，除公共参数外所有请求参数都必须放在这个参数中传递

  //得到sign签名
  TTempList.Clear;
  TTempList.Values['app_id']:=FAPPID; //支付宝分配给开发者的应用ID
  TTempList.Values['method']:='alipay.trade.pay'; //接口名称
  TTempList.Values['charset']:='utf-8'; //请求使用的编码格式，如utf-8,gbk,gb2312等
  TTempList.Values['sign_type']:='RSA'; //商户生成签名字符串所使用的签名算法类型，目前支持RSA
  TTempList.Values['timestamp']:=FormatDateTime('yyyy-MM-dd HH:mm:ss',now);//发送请求的时间，格式"yyyy-MM-dd HH:mm:ss"
  TTempList.Values['version']:='1.0';//调用的接口版本，固定为：1.0
  TTempList.Values['out_trade_no']:=Trim(edtDDH.Text);//商户订单号,64个字符以内、可包含字母、数字、下划线；需保证在商户端不重复
  TTempList.Values['scene'] := 'bar_code';//支付场景 条码支付，取值：bar_code 声波支付，取值：wave_code
  TTempList.Values['auth_code'] := Trim(edtSMSQM.Text);//支付授权码
  TTempList.Values['total_amount']:=Trim(edtJE.Text);//订单总金额，单位为元，精确到小数点后两位，取值范围[0.01,100000000]
  TTempList.Values['subject']:='测试商品';//订单标题
  TTempList.Values['biz_content'] :=  TParamList.Values['biz_content'];

  TTempList.Sort;//排序
//  TTempList.Values['key']:=FKEYID;//支付私钥

  sFileDir := ExtractFilePath(Application.ExeName)+'\rsa_private_key.pem';

  OpenSSL_add_all_algorithms;
  TParamList.Values['sign']:=Sign(FKEYID, AnsiToUtf8(GetStringList(TTempList)));

//  TParamList.Values['sign']:=UpperCase(MD5.StrToMD5(AnsiToUtf8(GetStringList(TTempList))));//签名
  JSONResult:=GetStringListToJson(TParamList);
  TTempList.Clear;
  TTempList.Text:=AnsiToUtf8(JSONResult);
  ResultJSON:=Utf8ToAnsi(http.Post(PAY_API,TTempList));
  ISBResult:=SO(ResultJSON);
  if ISBResult['code'].AsString='10000' then
    ShowMessage('支付成功！')
  else
    ShowMessage('支付失败！原因：'+ISBResult['sub_code'].AsString+ISBResult['sub_msg'].AsString);
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

procedure TForm1.btnRefudClick(Sender: TObject);
var
  MD5:TMD5;
  JSONResult:String;
  ResultJSON:string;
  ISBResult:ISuperObject;
  TIP:TIPWatch;
begin
   TParamList.Clear;
  //公共请求参数
  TParamList.Values['app_id']:=FAPPID; //支付宝分配给开发者的应用ID
  TParamList.Values['method']:='alipay.trade.pay'; //接口名称
  TParamList.Values['charset']:='utf-8'; //请求使用的编码格式，如utf-8,gbk,gb2312等
  TParamList.Values['sign_type']:='RSA'; //商户生成签名字符串所使用的签名算法类型，目前支持RSA
  TParamList.Values['timestamp']:=FormatDateTime('yyyy-MM-dd HH:mm:ss',now);//发送请求的时间，格式"yyyy-MM-dd HH:mm:ss"
  TParamList.Values['version']:='1.0';//调用的接口版本，固定为：1.0

  //请求参数
  TParamList.Values['out_trade_no']:=Trim(edtTHDDH.Text);//商户订单号,64个字符以内、可包含字母、数字、下划线；需保证在商户端不重复
  TParamList.Values['refund_amount']:=Trim(edtTHJE.Text);//订单总金额，单位为元，精确到小数点后两位，取值范围[0.01,100000000]

  //得到biz_content
  TBizContent.Clear;
  TBizContent.Values['out_trade_no']:=Trim(edtTHDDH.Text);//商户订单号,64个字符以内、可包含字母、数字、下划线；需保证在商户端不重复
  TBizContent.Values['refund_amount']:=Trim(edtTHJE.Text);//订单总金额，单位为元，精确到小数点后两位，取值范围[0.01,100000000]
  TParamList.Values['biz_content']:=GetStringListToJson(TBizContent); //请求参数的集合，最大长度不限，除公共参数外所有请求参数都必须放在这个参数中传递

  //得到sign签名
  TTempList.Clear;
  TTempList.Values['app_id']:=FAPPID; //支付宝分配给开发者的应用ID
  TTempList.Values['method']:='alipay.trade.pay'; //接口名称
  TTempList.Values['charset']:='utf-8'; //请求使用的编码格式，如utf-8,gbk,gb2312等
  TTempList.Values['sign_type']:='RSA'; //商户生成签名字符串所使用的签名算法类型，目前支持RSA
  TTempList.Values['timestamp']:=FormatDateTime('yyyy-MM-dd HH:mm:ss',now);//发送请求的时间，格式"yyyy-MM-dd HH:mm:ss"
  TTempList.Values['version']:='1.0';//调用的接口版本，固定为：1.0
  TTempList.Values['out_trade_no']:=Trim(edtTHDDH.Text);//商户订单号,64个字符以内、可包含字母、数字、下划线；需保证在商户端不重复
  TTempList.Values['refund_amount']:=Trim(edtTHJE.Text);//订单总金额，单位为元，精确到小数点后两位，取值范围[0.01,100000000]

  TTempList.Sort;//排序
  TTempList.Values['key']:=FKEYID;//支付私钥

  TParamList.Values['sign']:=UpperCase(MD5.StrToMD5(AnsiToUtf8(GetStringList(TTempList))));//签名
  JSONResult:=GetStringListToJson(TParamList);
  TTempList.Clear;
  TTempList.Text:=AnsiToUtf8(JSONResult);
  ResultJSON:=Utf8ToAnsi(http.Post(PAY_API,TTempList));
  ISBResult:=SO(ResultJSON);
  if ISBResult['code'].AsString='10000' then
    ShowMessage('退款成功！')
  else
    ShowMessage('退款失败！原因：'+ISBResult['sub_code'].AsString+ISBResult['sub_msg'].AsString);
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

function TForm1.GetStringListToJson(InStringList: TStringList): String;
var
  JSON: string;
  Cnt: Integer;
begin
  JSon := '{';
  for Cnt := 0 to InStringList.Count - 2 do
  begin
    JSon := JSON +  QuotedStr(InStringList.Names[Cnt]) + ':' + QuotedStr(InStringList.ValueFromIndex[Cnt])+',' ;
  end;
  JSon := JSON +  QuotedStr(InStringList.Names[Cnt]) + ':' + QuotedStr(InStringList.ValueFromIndex[Cnt]);
  JSon := JSon + '}';
  Result := JSon;
end;

function TForm1.LoadPrivateKey(filename: string): pRSA;
var
  bp: PBIO;
  A, pkey: pRSA;
begin
  A := nil;
  bp := BIO_new(BIO_s_file());
  BIO_read_filename(bp, PChar(filename));
  pkey := PEM_read_bio_RSAPrivateKey(bp, A, nil, NIL);
  BIO_free(bp);
  Result := pkey;
end;
 
function TForm1.Sign(filename, msg: String): string;
var
  ctx: EVP_MD_CTX;
  buf_in: PChar;
  m_len, outl: cardinal;
  pkey: pRSA;
  m, buf_out: array [0 .. 1024] of Char;
  p: array [0 .. 255] of Char;
  i: Integer;
begin
  buf_out := '';
  if filename = '' then
  begin
    Result := '';
    Exit;
  end;
//  ZeroMemory(@m, SizeOf(m));
//  ZeroMemory(@buf_out, SizeOf(buf_out));
  pkey := LoadPrivateKey(filename);
  buf_in := PChar(msg);
  EVP_MD_CTX_init(@ctx); // 初始化
  EVP_SignInit(@ctx, EVP_sha1()); //将需要使用的摘要算法存入ctxl中
  EVP_SignUpdate(@ctx, buf_in, Length(buf_in));////存入编码值
  EVP_DigestFinal(@ctx, m, m_len);//求取编码的长度为m_len摘要值存入m中
  RSA_sign(EVP_sha1()._type, m, m_len, buf_out, outl, pkey);//64为SHA1的NID

  EVP_MD_CTX_cleanup(@ctx);
  Result := EncodeString(StrPas(buf_out));
end;

procedure TForm1.Button1Click(Sender: TObject);
const APIAddress='http://api.kdniao.cc/Ebusiness/EbusinessOrderHandle.aspx';
var
  MD5:TMD5;
  JSONResult:String;
  ResultJSON:string;
  ISBResult:ISuperObject;
  TIP:TIPWatch;
  sFileDir: String;
  requestData:String;
  sAppKey:String;
  ResponseStream:TStringStream;
begin
  sAppKey := '413c9869-bf6a-47a7-8dce-d363846a8e0c';
  //OrderCode	订单编号 ShipperCode 快递公司编码	LogisticCode 物流单号
  requestData := '{''OrderCode'':'''',''ShipperCode'':''YD'',''LogisticCode'':''1000871734219''}';

  TParamList.Clear;

  //公共请求参数
  TParamList.Values['RequestData']:=StringReplace(HttpEncode(UTF8Encode(requestData)),'''','%27',[rfReplaceAll]);
  TParamList.Values['EBusinessID']:='1309561'; //商户ID
  TParamList.Values['RequestType']:='1002'; //请求指令类型：1002
  //数据内容签名：把(请求内容(未编码)+AppKey)进行MD5加密，然后Base64编码，最后 进行URL(utf-8)编码
  TParamList.Values['DataSign']:= HttpEncode(UTF8Encode(EncodeString(LowerCase(MD5.StrToMD5(requestData+sAppKey)))));
  TParamList.Values['DataType']:='2';//请求、返回数据类型：2-json；
  ResponseStream  := TStringStream.Create('');
  http.Request.ContentType := 'application/x-www-form-urlencoded';
  http.Post(APIAddress,TParamList,ResponseStream);
  ResultJSON := UTF8Decode(ResponseStream.DataString);
  ISBResult:=SO(ResultJSON);
  if ISBResult['Success'].AsString='true' then
  begin
    ShowMessage('查询成功！');
    Memo1.Lines.Clear;
    Memo1.Lines.Add(ResultJSON);
  end
  else
    ShowMessage('查询失败！原因：'+ISBResult['Reason'].AsString);

end;

function TForm1.BSTrack_Post(sUrl, sJsonPara: string): string;
var
  httpr:TIdHTTP;
  jsonToSend:TStringStream;
begin
   httpr := TIdHttp.Create(nil);
   httpr.HandleRedirects := True;//允许头转向
   httpr.ReadTimeout := 5000;//请求超时设置
   httpr.Request.ContentType := 'application/json';//设置内容类型为json
   sJsonPara := '{"RequestData":"%7b%22LogisticCode%22%3a%221000871734219%22%2c%22ShipperCode%22%3a%22YD%22%7d",'
    +'"EBusinessID":"1309561","RequestType":"1002","DataSign":"YmU3ZjAzODgxZjQ3OGUzNTgzMDY0Y2NkNzQyZDE3MDI%3d","DataSign":"2"}';
   jsonToSend := TStringStream.Create(sJsonPara);//创建一个包含JSON数据的变量
   jsonToSend.Position := 0;//将流位置置为0
   try
     result := httpr.Post(sUrl, jsonToSend);//接收POST后的数据返回
   except
     ;
   end;
   jsonToSend.free;
   httpr.free;//释放
end;

end.
