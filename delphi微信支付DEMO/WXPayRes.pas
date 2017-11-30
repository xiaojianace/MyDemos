unit WXPayRes;

interface

resourcestring
 NONCE_STR='abcdefghijklmnopqrstuvwxyz0123456789';//随机字符串 <32位
 PAY_API='https://api.mch.weixin.qq.com/pay/micropay';//支付API地址
 PAYORDERQUERY_API='https://api.mch.weixin.qq.com/pay/orderquery';//查询订单API
 PAYREVERSE_API='https://api.mch.weixin.qq.com/secapi/pay/reverse';//撤销订单API
 REFUND_API='https://api.mch.weixin.qq.com/secapi/pay/refund';//退款API地址
 REFUNDQUERY_API='https://api.mch.weixin.qq.com/pay/refundquery';//查询退款API
 XML_ATTACH='attach';
 XML_SIGN='sign';
 XML_BODY='body';

implementation

end.
