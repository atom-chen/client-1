/********************************************************************
文件名:SFTableCell.h
创建者:James Ou
创建时间:2013-2-6 10:24
功能描述:
*********************************************************************/

#ifndef __SFTABLECELL_H__
#define __SFTABLECELL_H__

#include "cocos2d.h"
#include "cocos-ext.h"
USING_NS_CC;
USING_NS_CC_EXT;


class SFTableViewCell :public CCTableViewCell{

public:
	void setIdentify(const char* strIdentify){
		m_identify = strIdentify;
	}
	std::string getIdentify(){return m_identify;}
	static SFTableViewCell* create()
	{
		SFTableViewCell* cell = new SFTableViewCell();
		if (cell && cell->init())
		{
			cell->autorelease();
			return cell;
		}
		CC_SAFE_DELETE(cell);
		return NULL;
	}

private:

	std::string m_identify;
protected: int m_index;
public: virtual int getIndex(void) const { return m_index; }
public: virtual void setIndex(int var){ m_index = var; }

};

#endif	//__SFTABLECELL_H__
