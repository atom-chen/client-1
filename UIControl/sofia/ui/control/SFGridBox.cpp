#include "ui/control/SFGridBox.h"
#include "script_support/CCScriptSupport.h"
SFGridBox* SFGridBox::create( int columns, CCSize gridSize )
{
	SFGridBox *pRet = new SFGridBox();
	if (pRet != NULL && pRet->init(columns, gridSize)){
		pRet->autorelease();
	}
	else{
		delete pRet;
		pRet = NULL;
	}
	return pRet;
}

bool SFGridBox::init( int columns, CCSize gridSize )
{
	bool bRet = false;
	do 
	{
		m_columns = columns;
		m_selIndex = -1;
		m_gridSize = gridSize;
		m_grids = 0;
		m_heightMargin = 10;
		m_widthMargin = 10;
		isLoad = false;

		m_touchCount = 0;
		m_touchTime = 0;

		m_dataSource = NULL;
		m_delegate = NULL;
		isCanTouch = false;
		m_dataSourceHandler = 0;
		m_delegateHandler = 0;
		bRet = SFBaseControl::init();

		setTouchEnabled(true);
		setContentSize(getSize());
	} while (0);

	return bRet;
}

void SFGridBox::onEnter()
{
	CCLayer::onEnter();
	isLoad = true;
	//reloadGridBox();

}

void SFGridBox::onExit()
{
	isLoad = false;
	SFBaseControl::onExit();
}


void SFGridBox::addGrid( int count/*=1*/ )
{
	m_grids = m_grids+count;
	reloadGridBox();
}

bool SFGridBox::removeGrid( int count/*=1*/ )
{
	if((m_grids-count) <= 0){
		return false;
	}
	m_grids = m_grids-count;
	reloadGridBox();
	return true;
}

int SFGridBox::getSelIndex()
{
	return m_selIndex;
}

void SFGridBox::setSelIndex( unsigned int index )
{
	m_selIndex = index;
	//CCLOG("selIndex %d", m_selIndex);
}

void SFGridBox::setAllMargin( int margin )
{
	setHeightMargin(margin);
	setWidthMargin(margin);
}

void SFGridBox::setHeightMargin( int margin )
{
	m_heightMargin = margin;
}

void SFGridBox::setWidthMargin( int margin )
{
	m_widthMargin = margin;
}

cocos2d::CCSize SFGridBox::getGridSize()
{
	return m_gridSize;
}

void SFGridBox::reloadGridBox()
{
	if (!isLoad) return;
	if (!m_dataSource && !m_dataSourceHandler) return;
	//removeAllChildrenWithCleanup(true);
	setContentSize(getSize());
	for(int i=0; i<m_grids; i++){
		CCNode *nd;
		if (m_dataSource)
		{
			nd = m_dataSource->cellFromGrid(this, i, m_gridSize);
		}else{
			CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
			nd = CCNode::create();
			nd->retain();
			int state = engine->executeGridBoxDataSourceEvent(m_dataSourceHandler,this,i,m_gridSize.width,m_gridSize.height,nd);
			if (state == 0)
			{
				nd->release();
				nd = NULL;
			}
		}
		if(NULL == nd){
			removeChildByTag(i, true);
			continue;
		}

		nd->setTag(i);
		int rowMax = m_grids/m_columns;
		int row =rowMax - i / m_columns -1;
		int col = i % m_columns;
		CCSize tempSize = nd->getContentSize();
		float tempX = (m_gridSize.width+m_widthMargin)*(col)+tempSize.width*0.5f;
		float tempY = (m_gridSize.height+m_heightMargin)*(row)+tempSize.height*0.5f;
		nd->setPosition(tempX,tempY);

		if(!nd->getParent() || nd->getParent() != this){
			removeChildByTag(i, true);
			addChild(nd);	
		}
		nd->release();
	}

	
// 	setContentSize(CCSizeMake(m_grids*m_gridSize.width+(m_grids-1)*m_widthMargin,
// 							m_grids*m_gridSize.height+(m_grids-1)*m_heightMargin));
}


void SFGridBox::reloadCellWithIndex( int index )
{
	if (!m_dataSource && !m_dataSourceHandler) return;

	CCNode *nd;
	if (m_dataSource)
	{
		nd = m_dataSource->cellFromGrid(this, index, m_gridSize);
	}else{
		nd = CCNode::create();
		nd->retain();
		CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		int state =  engine->executeGridBoxDataSourceEvent(m_dataSourceHandler,this,index,m_gridSize.width,m_gridSize.height,nd);
		if (state == 0)
		{
			nd->release();
			nd = NULL;
		}
	}
	if(NULL == nd || nd->getParent()) 
		return;
	
	nd->setTag(index);
	int row = index / m_columns;
	int col = index % m_columns;
	CCPoint pos;
	nd->setPosition((m_gridSize.width+m_widthMargin)*(col)+nd->getContentSize().width*0.5f, (m_gridSize.height+m_heightMargin)*((m_grids/m_columns)-row-1)+nd->getContentSize().height*0.5f);
	//nd->setPosition((m_gridSize.width+m_widthMargin)*(col), (m_gridSize.height+m_heightMargin)*((m_grids/m_columns)-row-1));
	//nd->setPosition((m_gridSize.width+m_widthMargin)*(col), (m_gridSize.height+m_heightMargin)*row);
	pos = nd->getPosition();

	removeChildByTag(index, true);
	addChild(nd);
	nd->release();
}


void SFGridBox::setDelegate( SFGridBoxDelegate *delegate )
{
	m_delegate = delegate;
}

void SFGridBox::setDataSource( SFGridBoxDataSource *dataSource )
{
	m_dataSource = dataSource;
}

bool SFGridBox::ccTouchBegan( CCTouch *pTouch, CCEvent *pEvent )
{
	if (m_delegateHandler)
	{
		CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		int state =engine->executeGirdBoxTouchEvent(m_delegateHandler,kDidTouchBegin,this,0,pTouch);
		if (state != 0)
		{
			if (isTouchInside(pTouch)){
				actionBegin();
				return true;
			}
		}
	}else{
		if (isTouchInside(pTouch)){
			actionBegin();
			return true;
		}
	}
	
	return false;
}

void SFGridBox::ccTouchMoved( CCTouch *pTouch, CCEvent *pEvent )
{
	if (m_delegate){
		m_delegate->didMoveItem(this, m_selIndex, pTouch, pEvent);
	}
	if(m_delegateHandler && (isTouchInside(pTouch))){
		CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		engine->executeGirdBoxTouchEvent(m_delegateHandler,kDidMoveItem,this,m_selIndex,pTouch);
	}
}

void SFGridBox::ccTouchEnded( CCTouch *pTouch, CCEvent *pEvent )
{
	actionEnd();
	if (m_delegate){
		m_delegate->didTouchEndItem(this, m_selIndex, pTouch, pEvent);
	}
	if(m_delegateHandler && (isTouchInside(pTouch))){
		CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		engine->executeGirdBoxTouchEvent(m_delegateHandler,kDidTouchEndItem,this,m_selIndex,pTouch);
	}
}

void SFGridBox::ccTouchCancelled( CCTouch *pTouch, CCEvent *pEvent )
{
	actionEnd();
	if (m_delegate){
		m_delegate->didTouchEndItem(this, m_selIndex, pTouch, pEvent);
	}
	if(m_delegateHandler && (isTouchInside(pTouch))){
		CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		engine->executeGirdBoxTouchEvent(m_delegateHandler,kDidTouchEndItem,this,m_selIndex,pTouch);
	}
}

bool SFGridBox::isTouchInside( CCTouch *pTouch )
{
	CCPoint touchLocation = pTouch->getLocationInView(); // Get the touch position
	touchLocation = this->getParent()->convertTouchToNodeSpace(pTouch);// convertToNodeSpace(touchLocation);
	CCRect bBox = this->boundingBox();
	if (bBox.containsPoint(touchLocation))
	{
		touchLocation = this->convertTouchToNodeSpace(pTouch);
		int rowMax = m_grids/m_columns;
		int row = rowMax-touchLocation.y/ (m_gridSize.height+m_heightMargin);
		int col = touchLocation.x /(m_gridSize.width+m_widthMargin);
		if (col >=0 && col <= m_columns && row <= rowMax && row >=0)
		{
			int index = (row)*m_columns+col;
			setSelIndex(index);
			return true;
		}
	}
	return false;
}

void SFGridBox::actionBegin()
{
	if (!m_touchCount){
		schedule(schedule_selector(SFGridBox::actionTiming));
	}
	isTouchUp = false;
	m_touchCount++;
}

void SFGridBox::actionEnd()
{
	isTouchUp = true;
	if (m_touchCount >= 2){
		if (m_delegate){
			m_delegate->didDoubleClickItem(this, m_selIndex);
		}else if(m_delegateHandler){
			CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
			engine->executeGirdBoxTouchEvent(m_delegateHandler,kDidDoubleClickItem,this,m_selIndex,NULL);
		}
		//CCLOG("didDoubleClickItem");
		m_touchCount = 0;
		m_touchTime = 0;
		unschedule(schedule_selector(SFGridBox::actionTiming));
	}

	if(m_touchTime <= 35){
		return;
	}
	
	m_touchCount = 0;
	m_touchTime = 0;
	unschedule(schedule_selector(SFGridBox::actionTiming));
}

void SFGridBox::actionTiming(float dt)
{
	if((m_touchTime++) <= 35){
		return;
	}
	if (isTouchUp){
		if (m_delegate){
			m_delegate->didClickItem(this, m_selIndex);
		}else if(m_delegateHandler){
			CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
			engine->executeGirdBoxTouchEvent(m_delegateHandler,kDidClickItem,this,m_selIndex,NULL);
		}
		//CCLOG("didClickItem");
	}
	else if (m_touchCount==1){
		if (m_delegate){
			m_delegate->didLongPressItem(this, m_selIndex);
		}else if(m_delegateHandler){
			CCScriptEngineProtocol* engine = CCScriptEngineManager::sharedManager()->getScriptEngine();
			engine->executeGirdBoxTouchEvent(m_delegateHandler,kDidLongPressItem,this,m_selIndex,NULL);
		}
		//CCLOG("didLongPressItem");
	}
	m_touchCount = 0;
	m_touchTime = 0;
	unschedule(schedule_selector(SFGridBox::actionTiming));
}

cocos2d::CCSize SFGridBox::getSize()
{
	int row = (m_grids / m_columns);
	if(row == 0)
		row=row+1;

	//int row = (m_grids/m_columns)+1;
// 	int h = m_gridSize.height*(row)+m_heightMargin*(row-1);
// 	int w = m_gridSize.width*(m_columns)+m_widthMargin*((m_columns-1)?(m_columns-1):0);

	int h = (m_gridSize.height+m_heightMargin)*(row)-m_heightMargin;
	int w = (m_gridSize.width+m_widthMargin)*(m_columns)-m_widthMargin;

	return CCSizeMake(w,h);
}

unsigned SFGridBox::getGridCount()
{
	return m_grids;
}



void SFGridBox::registerWithTouchDispatcher()
{
	CCTouchDispatcher* pDispatcher = CCDirector::sharedDirector()->getTouchDispatcher();
	pDispatcher->addTargetedDelegate(this,-128,false);
}