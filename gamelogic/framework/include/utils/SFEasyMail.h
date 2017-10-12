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
		const std::string & strUser,		//�û���
		const std::string & strPsw,			//����
		const std::string & strSmtpServer,  //smtp������
		const std::string & strMailFrom		//�ʼ���Դ
		);  
	virtual ~SFEasyMail();
	
	void	SetMailContent(const std::string & strSubject/*�ʼ�����*/, const std::string & strContent/*�ʼ�����*/);
	bool	SendMail();
	void	AddRecipient(const std::string & strMailTo);


	bool	SendEasyMail(const std::string & strUser, const std::string & strPsw,const std::string & strSmtpServer,const std::string & strMailFrom,
		const std::string & strMailTo,const std::string & strSubject/*�ʼ�����*/, const std::string & strContent/*�ʼ�����*/);

protected:
	static size_t read_callback(void *ptr, size_t size, size_t nmemb, void *userp);
	static long tvdiff(struct timeval newer, struct timeval older);  
	//��ȡ��ǰʱ��  
	static struct timeval tvnow(void); 
private:
	std::string m_strUser;						//�����û���  
	std::string m_strPsw;						//��������  
	std::string m_strSmtpServer;				//����SMTP������  
	//int         m_iPort;						//����SMTP�������˿�  
	std::string m_RecipientList;		//�������ʼ�list  
	std::string m_strMailFrom;					//����������  
	std::vector<std::string> m_MailContent;		//���͵����ݶ��У�����ͷ��������  
	int         m_iMailContentPos;				//���ڷ�������ʱ��¼���͵��ڼ���content  
};

#endif