unit WXPayRes;

interface

resourcestring
 NONCE_STR='abcdefghijklmnopqrstuvwxyz0123456789';//����ַ��� <32λ
 PAY_API='https://api.mch.weixin.qq.com/pay/micropay';//֧��API��ַ
 PAYORDERQUERY_API='https://api.mch.weixin.qq.com/pay/orderquery';//��ѯ����API
 PAYREVERSE_API='https://api.mch.weixin.qq.com/secapi/pay/reverse';//��������API
 REFUND_API='https://api.mch.weixin.qq.com/secapi/pay/refund';//�˿�API��ַ
 REFUNDQUERY_API='https://api.mch.weixin.qq.com/pay/refundquery';//��ѯ�˿�API
 XML_ATTACH='attach';
 XML_SIGN='sign';
 XML_BODY='body';

implementation

end.
