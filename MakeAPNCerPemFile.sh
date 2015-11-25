#!/bin/bash
# date: 2015-11-18
# author: 小虎

anykey()
{
	   SAVEDSTTY=`stty -g`
	   stty -echo
	   stty raw
	   dd if=/dev/tty bs=1 count=1 2> /dev/null
	   stty -raw
	   stty echo
	   stty $SAVEDSTTY
}


echo "----开始制作证书----"
echo "--------------------"
echo "1.去http://developer.apple.com制作推送证书"
echo "2.下载证书，双击导入keychain"
echo "3.在keychain中，导出推送证书公钥到桌面，名字为'apns-cert.p12'(建议设置密码)"
echo "4.在keychain中，导出推送导出证书私钥到桌面，名字为'apns-key.p12'(建议设置密码)"
echo "如果以上步骤都ok了，按任意键将开始制作证书........"

CHAR=`anykey`

cd  ~/Desktop/

while ! [[ -s ~/Desktop/apns-cert.p12 ]]; do
	echo "!!!没有找到公钥文件，请去keychain导出推送证书公钥到桌面，名字为'apns-cert.p12'，点任意键继续"

	CHAR=`anykey`
done;

while ! [[ -s ~/Desktop/apns-key.p12 ]]; do
	echo "!!!没有找到私钥文件，请去keychain导出推送证书私钥到桌面，名字为'apns-key.p12'，点任意键继续"

	CHAR=`anykey`
done;


echo "----转换公钥格式----"

openssl pkcs12 -clcerts -nokeys -in apns-cert.p12 -out apns-cert.pem 

echo "----转换私钥格式----"

privateKeyName='apns-key.pem'

openssl pkcs12 -nocerts -in apns-key.p12 -out $privateKeyName 
apnskeypath="~/Desktop/apns-key.pem"

echo "关闭推送证书的密码？（Y/n,Default:NO)"
CHAR=`anykey`

if [ $CHAR == "Y" ]; then
	privateKeyName='apns-key-nopass.pem'
	openssl rsa -in apns-key.pem -out $privateKeyName
fi

echo "----合并密钥----"

cat apns-cert.pem $privateKeyName > apns-push-cert.pem

echo "----完成----"
