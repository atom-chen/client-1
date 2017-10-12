/********************************************************************
	created:	2014/04/14
	created:	14:4:2014   11:01
	filename: 	E:\Sophia\client\trunk\gamelogic\SFGameAnalyzer.h
	file path:	E:\Sophia\client\trunk\gamelogic
	file base:	SFGameAnalyzer
	file ext:	h
	author:		Liu Rui
	
	purpose:	游戏统计接口
*********************************************************************/

#ifndef SFGameAnalyzer_h__
#define SFGameAnalyzer_h__

#include <string>

class SFGameAnalyzer
{
public:
	SFGameAnalyzer(){}
	~SFGameAnalyzer(){}

	static void logGameEvent(int eventId, std::string eventData);
};

#endif // SFGameAnalyzer_h__