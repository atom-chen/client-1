#include "utils/SFEasyMail.h"
#include "curl/curl.h"
#define MULTI_PERFORM_HANG_TIMEOUT 60 * 1000  
SFEasyMail::SFEasyMail(const std::string & strUser,const std::string & strPsw,
					   const std::string & strSmtpServer,const std::string & strMailFrom)
{
	m_strUser = strUser;
	m_strPsw = strPsw;
	m_strSmtpServer = strSmtpServer;
	m_strMailFrom = strMailFrom;
	m_iMailContentPos = 0;
}

SFEasyMail::~SFEasyMail()
{

}

void SFEasyMail::SetMailContent( const std::string & strSubject/*邮件主题*/, const std::string & strContent/*邮件内容*/)
{
	m_iMailContentPos = 0;
	m_MailContent.clear();
	m_MailContent.push_back("MIME-Versioin: 1.0\n");
	m_MailContent.push_back("Subject:");
	m_MailContent.push_back(strSubject);
	m_MailContent.push_back("\n");
	m_MailContent.push_back("Content-Transfer-Encoding: 8bit\n");
	m_MailContent.push_back("Content-Type: text/html; \n Charset=\"UTF-8\"\n\n");
	m_MailContent.push_back(strContent);
}

size_t SFEasyMail::read_callback(void *ptr, size_t size, size_t nmemb, void *userp)
{
	SFEasyMail * pSm = (SFEasyMail *)userp;  

	if(size*nmemb < 1)  
		return 0;  
	if(pSm->m_iMailContentPos < pSm->m_MailContent.size())  
	{  
		size_t len;  
		len = pSm->m_MailContent[pSm->m_iMailContentPos].length();  

		memcpy(ptr, pSm->m_MailContent[pSm->m_iMailContentPos].c_str(), pSm->m_MailContent[pSm->m_iMailContentPos].length());  
		pSm->m_iMailContentPos++; /* advance pointer */  
		return len;  
	}  
	return 0;                         /* no more data left to deliver */
}

bool SFEasyMail::SendMail()
{
	bool bRet = true;
	int still_running = 1; 
	CURL* curl_;
	CURLM *mcurl; 
	struct timeval mp_start;
	mcurl = curl_multi_init();  

	struct curl_slist *slist=NULL;
	curl_ = curl_easy_init();
	curl_easy_setopt(curl_, CURLOPT_URL, m_strSmtpServer.c_str() );
	curl_easy_setopt(curl_, CURLOPT_USERNAME, m_strUser.c_str());
	curl_easy_setopt(curl_, CURLOPT_PASSWORD, m_strPsw.c_str());
	curl_easy_setopt(curl_, CURLOPT_READFUNCTION, &SFEasyMail::read_callback);
	curl_easy_setopt(curl_, CURLOPT_MAIL_FROM, m_strMailFrom.c_str());
	slist = curl_slist_append(slist, m_RecipientList.c_str());  //接收者
	curl_easy_setopt(curl_, CURLOPT_MAIL_RCPT, slist);
	curl_easy_setopt(curl_, CURLOPT_USE_SSL, (long)CURLUSESSL_ALL);
	curl_easy_setopt(curl_, CURLOPT_SSL_VERIFYPEER, 0L);
	curl_easy_setopt(curl_, CURLOPT_SSL_VERIFYHOST, 0L);
	curl_easy_setopt(curl_, CURLOPT_READDATA, this);
	curl_easy_setopt(curl_, CURLOPT_VERBOSE, 1L);
	curl_easy_setopt(curl_, CURLOPT_SSLVERSION, 0L);
	curl_easy_setopt(curl_, CURLOPT_SSL_SESSIONID_CACHE, 0L);

	curl_multi_add_handle(mcurl, curl_); 

	mp_start = tvnow();  
	curl_multi_perform(mcurl, &still_running);

	while (still_running) {  
		struct timeval timeout;  
		int rc; /* select() return code */  
  
		fd_set fdread;  
		fd_set fdwrite;  
		fd_set fdexcep;  
		int maxfd = -1;  
  
		long curl_timeo = -1;  
  
		FD_ZERO(&fdread);  
		FD_ZERO(&fdwrite);  
		FD_ZERO(&fdexcep);  
  
		/* set a suitable timeout to play around with */  
		timeout.tv_sec = 1;  
		timeout.tv_usec = 0;  
  
		CURLMcode e = curl_multi_timeout(mcurl, &curl_timeo);  
		if (e != CURLE_OK)
		{
			printf("curl_multi_timeout error : %d\n",e);  
		}
		if (curl_timeo >= 0) {  
			timeout.tv_sec = curl_timeo / 1000;  
			if (timeout.tv_sec > 1)  
				timeout.tv_sec = 1;  
			else  
				timeout.tv_usec = (curl_timeo % 1000) * 1000;  
		}  
  
		/* get file descriptors from the transfers */  
		e = curl_multi_fdset(mcurl, &fdread, &fdwrite, &fdexcep, &maxfd);  
		if (e != CURLE_OK)
		{
			printf("curl_multi_fdset error : %d\n",e);  
		}
  
		/* In a real-world program you OF COURSE check the return code of the 
		   function calls.  On success, the value of maxfd is guaranteed to be 
		   greater or equal than -1.  We call select(maxfd + 1, ...), specially in 
		   case of (maxfd == -1), we call select(0, ...), which is basically equal 
		   to sleep. */  
  
		rc = select(maxfd + 1, &fdread, &fdwrite, &fdexcep, &timeout);  
  
		if (tvdiff(tvnow(), mp_start) > MULTI_PERFORM_HANG_TIMEOUT) {  
			fprintf(stderr, "ABORTING TEST, since it seems "  
					"that it would have run forever.\n");  
			bRet = false;  
			break;  
		}  
  
		do
		{
			e = curl_multi_perform(mcurl, &still_running);
			// about this
			// http://curl.haxx.se/libcurl/c/curl_multi_perform.html
		} while (e == CURLM_CALL_MULTI_PERFORM);
		if (e != CURLE_OK)
		{
			printf("curl_multi_perform error : %d\n",e);  
		}
// 		switch (rc) {  
// 			case -1:  
// 				/* select error */  
// 				printf("select error\n");  
// 				bRet = false;  
// 				break;  
// 			case 0: /* timeout */  
// 				printf("time out, retry again!\n");  
// 				curl_multi_perform(mcurl, &still_running);  
// 				break;  
// 			default: /* action */  
// 				curl_multi_perform(mcurl, &still_running);  
// 				break;  
// 		}  
	}

	curl_multi_remove_handle(mcurl, curl_);  
	curl_slist_free_all(slist);  
	curl_multi_cleanup(mcurl);  
	curl_easy_cleanup(curl_);  

// 	curl_easy_perform(curl_);
// 	curl_easy_cleanup(curl_);
	return bRet;
}

void SFEasyMail::AddRecipient( const std::string & strMailTo )
{
	m_RecipientList = strMailTo;
}

bool SFEasyMail::SendEasyMail( const std::string & strUser, const std::string & strPsw,const std::string & strSmtpServer,const std::string & strMailFrom, const std::string & strMailTo,const std::string & strSubject/*邮件主题*/, const std::string & strContent/*邮件内容*/ )
{
	m_strUser = strUser;
	m_strPsw = strPsw;
	m_strSmtpServer = strSmtpServer;
	m_strMailFrom = strMailFrom;
	m_RecipientList.clear();
	//m_RecipientList.push_back(strMailTo);
	AddRecipient(strMailTo);
	this->SetMailContent(strSubject, strContent);
	this->SendMail();
	return true;
}

long SFEasyMail::tvdiff( struct timeval newer, struct timeval older )
{
	return (newer.tv_sec-older.tv_sec)*1000+  
		(newer.tv_usec-older.tv_usec)/1000;  
}

struct timeval SFEasyMail::tvnow( void )
{
/* 
  ** time() returns the value of time in seconds since the Epoch. 
  */   
	struct timeval now;  
	now.tv_sec = (long)time(NULL);  
	now.tv_usec = 0;  
	return now;  
}


