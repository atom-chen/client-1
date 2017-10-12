#ifndef _SF_EASY_MAIL_H_
#define _SF_EASY_MAIL_H_
#include <string>
#include <list>
#include <vector>
class SFEasyMail
{
public:
	//SFEasyMail();
	SFEasyMail(  //create sendmail object with paremeter;  
		const std::string & strUser,		//用户名
		const std::string & strPsw,			//密码
		const std::string & strSmtpServer,  //smtp服务器
		const std::string & strMailFrom		//邮件来源
		);  
	virtual ~SFEasyMail();
	
	void	SetMailContent(const std::string & strSubject/*邮件主题*/, const std::string & strContent/*邮件内容*/);
	bool	SendMail();
	void	AddRecipient(const std::string & strMailTo);


	bool	SendEasyMail(const std::string & strUser, const std::string & strPsw,const std::string & strSmtpServer,const std::string & strMailFrom,
		const std::string & strMailTo,const std::string & strSubject/*邮件主题*/, const std::string & strContent/*邮件内容*/);

protected:
	static size_t read_callback(void *ptr, size_t size, size_t nmemb, void *userp);
	static long tvdiff(struct timeval newer, struct timeval older);  
	//获取当前时间  
	static struct timeval tvnow(void); 
private:
	std::string m_strUser;						//邮箱用户名  
	std::string m_strPsw;						//邮箱密码  
	std::string m_strSmtpServer;				//邮箱SMTP服务器  
	//int         m_iPort;						//邮箱SMTP服务器端口  
	std::string m_RecipientList;		//接收者邮件list  
	std::string m_strMailFrom;					//发送者邮箱  
	std::vector<std::string> m_MailContent;		//发送的内容队列，包括头和内容项  
	int         m_iMailContentPos;				//用于发送数据时记录发送到第几个content  
};

#endif