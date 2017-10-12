/****************************************************************************
 Copyright (c) 2012 cocos2d-x.org
 Copyright (c) 2010 Sangwoo Im

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

#include "ui/control/SFTableView.h"
#include "menu_nodes/CCMenu.h"
#include "support/CCPointExtension.h"

#include "layers_scenes_transitions_nodes/CCLayer.h"

//#include "utils/SFTouchDispatcher.h"
#include "script_support/CCScriptSupport.h"

enum 
{
	kTableCellSizeForIndex,
	kCellSizeForTable,
    kTableCellAtIndex,
	kNumberOfCellsInTableView,
	kTableViewTouchBegan,
	kTableViewTouchMoved,
	kTableViewTouchEnded,
	kTableViewTouchCanceled,
	kTableViewDidAnimateScrollEnd
};


SFTableView* SFTableView::create(SFTableViewDataSource* dataSource, CCSize size)
{
	return SFTableView::create(dataSource, size, NULL);
}

SFTableView* SFTableView::create(SFTableViewDataSource* dataSource, CCSize size, CCNode *container)
{
	SFTableView *table = new SFTableView();
	table->initWithViewSize(size, container);
	table->autorelease();
	table->setDataSource(dataSource);
	table->_updateCellPositions();
	table->_updateContentSize();

	return table;
}

bool SFTableView::initWithViewSize(CCSize size, CCNode* container/* = NULL*/)
{
	if (CCScrollView::initWithViewSize(size,container))
	{
		m_pCellsUsed      = new CCArrayForObjectSorting();
		m_pCellsFreed     = new CCArrayForObjectSorting();
		m_pIndices        = new std::set<unsigned int>();
		m_eVordering      = kSFTableViewFillTopDown;
		this->setDirection(kCCScrollViewDirectionVertical);

		CCScrollView::setDelegate(this);
		setTouchEnabled(true);
		return true;
	}
	return false;
}

SFTableView::SFTableView()
: m_pTouchedCell(NULL)
, m_pIndices(NULL)
, m_pCellsUsed(NULL)
, m_pCellsFreed(NULL)
, m_pDataSource(NULL)
, m_pTableViewDelegate(NULL)
, m_eOldDirection(kCCScrollViewDirectionNone)
,m_pTableViewHandler(0)
,m_pDataSourceHandler(-1)
{
	setSelectedCellIndex(-1);
}

SFTableView::~SFTableView()
{
	CC_SAFE_DELETE(m_pIndices);
	CC_SAFE_RELEASE(m_pCellsUsed);
	CC_SAFE_RELEASE(m_pCellsFreed);
}

void SFTableView::setVerticalFillOrder(SFTableViewVerticalFillOrder fillOrder)
{
	if (m_eVordering != fillOrder) {
		m_eVordering = fillOrder;
		if (m_pCellsUsed->count() > 0) {
			this->reloadData();
		}
	}
}

SFTableViewVerticalFillOrder SFTableView::getVerticalFillOrder()
{
	return m_eVordering;
}

void SFTableView::reloadData()
{
	CCPoint offset = getContentOffset();
	CCSize viewSize = getViewSize();

	m_eOldDirection = kCCScrollViewDirectionNone;
	m_pCellsFreed->removeAllObjects();
	CCObject* pObj = NULL;
	CCARRAY_FOREACH(m_pCellsUsed, pObj)
	{
		SFTableViewCell* cell = (SFTableViewCell*)pObj;

		if(m_pTableViewDelegate != NULL) {
			m_pTableViewDelegate->tableCellWillRecycle(this, cell);
		}
		cell->setIndex(cell->getIdx());
		cell->reset();

		m_pCellsFreed->addObject(cell);
		if (cell->getParent()){
			cell->removeFromParentAndCleanup(true);
		}
	}

	m_pIndices->clear();
	m_pCellsUsed->removeAllObjects();
//     m_pCellsUsed->release();
//     m_pCellsUsed = new CCArrayForObjectSorting();

	this->_updateCellPositions();
	this->_updateContentSize();

	
	CCSize contentSize = getContentSize();
	float detal = viewSize.height - contentSize.height;

	if (detal >= 0 || offset.y>0)
	{

	}else if (offset.y <= detal)
	{
		offset.y = detal;
		setContentOffset(offset);
	}else{
		setContentOffset(offset);
	}

}

void SFTableView::scroll2Cell( unsigned int idx , bool animated/* = true*/)
{
	CCSize viewSize = getViewSize();
	CCSize contentSize = getContentSize();
	CCSize cellSize = CCSizeZero;
	if (m_pDataSource)
	{
		cellSize = getDataSource()->cellSizeForTable(this);
	}else{
		SFTableData* data = SFTableData::create();
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		int state = pEngine->executeTableViewDataSourceEvent(m_pDataSourceHandler,kCellSizeForTable,this,1,data);
		cellSize = data->m_size;
		data->release();
	}
	CCPoint offset = ccp(0, viewSize.height-(contentSize.height-cellSize.height*idx));
	if (viewSize.height-contentSize.height < 0)
	{
		if (offset.y > 0)
			offset.y = 0;
	}

	setContentOffset(offset, animated);
}


SFTableViewCell *SFTableView::cellAtIndex(unsigned int idx)
{
	SFTableViewCell *found = NULL;

	if (m_pIndices->find(idx) != m_pIndices->end())
	{
		found = (SFTableViewCell *)m_pCellsUsed->objectWithObjectID(idx);
	}

	return found;
}

void SFTableView::updateCellAtIndex(unsigned int idx)
{
	if (idx == CC_INVALID_INDEX)
	{
		return;
	}
	unsigned int uCountOfItems = 0;
	if (m_pDataSource)
	{
		uCountOfItems = m_pDataSource->numberOfCellsInTableView(this);
	}else{
		SFTableData* data = SFTableData::create();
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		int state = pEngine->executeTableViewDataSourceEvent(m_pDataSourceHandler,kNumberOfCellsInTableView,this,1,data);
		if (state != 0)
		{
			uCountOfItems = data->m_index;
		}
		data->release();
	}
	if (0 == uCountOfItems || idx > uCountOfItems-1)
	{
		return;
	}

	SFTableViewCell* cell = this->cellAtIndex(idx);
	if (cell)
	{
		this->_moveCellOutOfSight(cell);
	}

	if (m_pDataSource)
	{
		cell = m_pDataSource->tableCellAtIndex(this, idx);
	}else{
		SFTableData* data = SFTableData::create();
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		int stata =  pEngine->executeTableViewDataSourceEvent(m_pDataSourceHandler,kTableCellAtIndex,this,idx,data);
		if (stata != 0)
		{
			cell = data->m_cell;
		}
		data->release();
	}
	
	if (cell) { //Juchao@20140724: 防止cell为空导致程序crash
		this->_setIndexForCell(idx, cell);
		this->_addCellIfNecessary(cell);
	}
}

void SFTableView::insertCellAtIndex(unsigned  int idx)
{
	if (idx == CC_INVALID_INDEX)
	{
		return;
	}
	unsigned int uCountOfItems = 0;
	if (m_pDataSource)
	{
		uCountOfItems = m_pDataSource->numberOfCellsInTableView(this);
	}else{
		SFTableData* data = SFTableData::create();
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		int state = pEngine->executeTableViewDataSourceEvent(m_pDataSourceHandler,kNumberOfCellsInTableView,this,1,data);
		if (state != 0)
		{
			uCountOfItems = data->m_index;
		}
		data->release();
	}
	if (0 == uCountOfItems || idx > uCountOfItems-1)
	{
		return;
	}

	SFTableViewCell* cell = NULL;
	int newIdx = 0;

	cell = (SFTableViewCell*)m_pCellsUsed->objectWithObjectID(idx);
	if (cell)
	{
		newIdx = m_pCellsUsed->indexOfSortedObject(cell);
		for (unsigned int i=newIdx; i<m_pCellsUsed->count(); i++)
		{
			cell = (SFTableViewCell*)m_pCellsUsed->objectAtIndex(i);
			this->_setIndexForCell(cell->getIdx()+1, cell);
		}
	}

 //   [m_pIndices shiftIndexesStartingAtIndex:idx by:1];

	//insert a new cell
	if (m_pDataSource)
	{
		cell = m_pDataSource->tableCellAtIndex(this, idx);
	}else{
		SFTableData* data = SFTableData::create();
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		int stata =  pEngine->executeTableViewDataSourceEvent(m_pDataSourceHandler,kTableCellAtIndex,this,idx,data);
		if (stata != 0)
		{
			cell = data->m_cell;
			
		}
		data->release();
	}
	this->_setIndexForCell(idx, cell);
	this->_addCellIfNecessary(cell);

	this->_updateCellPositions();
	this->_updateContentSize();
}

void SFTableView::removeCellAtIndex(unsigned int idx)
{
	if (idx == CC_INVALID_INDEX)
	{
		return;
	}
	unsigned int uCountOfItems = 0;
	if (m_pDataSource)
	{
		uCountOfItems = m_pDataSource->numberOfCellsInTableView(this);
	}else{
		SFTableData* data = SFTableData::create();
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		int state = pEngine->executeTableViewDataSourceEvent(m_pDataSourceHandler,kNumberOfCellsInTableView,this,1,data);
		if (state != 0)
		{
			uCountOfItems = data->m_index;
		}
		data->release();
	}
	 
	if (0 == uCountOfItems || idx > uCountOfItems-1)
	{
		return;
	}

	unsigned int newIdx = 0;

	SFTableViewCell* cell = this->cellAtIndex(idx);
	if (!cell)
	{
		return;
	}

	newIdx = m_pCellsUsed->indexOfSortedObject(cell);

	//remove first
	this->_moveCellOutOfSight(cell);

	m_pIndices->erase(idx);
	this->_updateCellPositions();
//    [m_pIndices shiftIndexesStartingAtIndex:idx+1 by:-1];
	for (unsigned int i=m_pCellsUsed->count()-1; i > newIdx; i--)
	{
		cell = (SFTableViewCell*)m_pCellsUsed->objectAtIndex(i);
		this->_setIndexForCell(cell->getIdx()-1, cell);
	}
}

SFTableViewCell *SFTableView::dequeueCell()
{
	SFTableViewCell *cell;

	if (m_pCellsFreed->count() == 0) {
		cell = NULL;
	} else {
		cell = (SFTableViewCell*)m_pCellsFreed->objectAtIndex(0);
		cell->retain();
		m_pCellsFreed->removeObjectAtIndex(0);
		cell->autorelease();
	}
	return cell;
}

SFTableViewCell * SFTableView::dequeueCell( int index )
{
	SFTableViewCell *cell = NULL;
	CCObject *obj = NULL;
	CCARRAY_FOREACH(m_pCellsFreed, obj){
		SFTableViewCell *c = (SFTableViewCell*)obj;
		if(c->getIndex() == index){
			c->retain();
			m_pCellsFreed->removeObject(c);
			c->autorelease();
			cell = c;
			break;
		}
	}
	return cell;

}


void SFTableView::_addCellIfNecessary(SFTableViewCell * cell)
{
	if (cell->getParent() != this->getContainer())
	{
		this->getContainer()->addChild(cell);
	}
	m_pCellsUsed->insertSortedObject(cell);
	m_pIndices->insert(cell->getIdx());
	// [m_pIndices addIndex:cell.idx];
}

void SFTableView::_updateContentSize()
{
	CCSize size = CCSizeZero;
	unsigned int cellsCount = 0;
	if (m_pDataSource)
	{
		cellsCount = m_pDataSource->numberOfCellsInTableView(this);
	}else{
		SFTableData* data = SFTableData::create();
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		int state = pEngine->executeTableViewDataSourceEvent(m_pDataSourceHandler,kNumberOfCellsInTableView,this,1,data);
		if (state != 0)
		{
			cellsCount = data->m_index;
		}
		data->release();
	}
	if (cellsCount > 0)
	{
		float maxPosition = m_vCellsPositions[cellsCount];

		switch (this->getDirection())
		{
			case kCCScrollViewDirectionHorizontal:
				size = CCSizeMake(maxPosition, m_tViewSize.height);
				break;
			default:
				size = CCSizeMake(m_tViewSize.width, maxPosition);
				break;
		}
	}

	this->setContentSize(size);

	if (m_eOldDirection != m_eDirection)
	{
		if (m_eDirection == kCCScrollViewDirectionHorizontal)
		{
			this->setContentOffset(ccp(0,0));
		}
		else
		{
			this->setContentOffset(ccp(0,this->minContainerOffset().y));
		}
		m_eOldDirection = m_eDirection;
	}

}

CCPoint SFTableView::_offsetFromIndex(unsigned int index)
{
	CCPoint offset = this->__offsetFromIndex(index);

	CCSize cellSize = CCSizeZero;
	if (m_pDataSource)
	{
		cellSize = getDataSource()->cellSizeForTable(this);
	}else{
		SFTableData* data = SFTableData::create();
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		int state = pEngine->executeTableViewDataSourceEvent(m_pDataSourceHandler,kCellSizeForTable,this,1,data);
		cellSize = data->m_size;
		data->release();
	}
	if (m_eVordering == kCCTableViewFillTopDown)
	{
		offset.y = this->getContainer()->getContentSize().height - offset.y - cellSize.height;
	}
	return offset;
}

CCPoint SFTableView::__offsetFromIndex(unsigned int index)
{
	CCPoint offset;
	CCSize  cellSize;

	switch (this->getDirection())
	{
		case kCCScrollViewDirectionHorizontal:
			offset = ccp(m_vCellsPositions[index], 0.0f);
			break;
		default:
			offset = ccp(0.0f, m_vCellsPositions[index]);
			break;
	}

	return offset;
}

unsigned int SFTableView::_indexFromOffset(CCPoint offset)
{
	int index = 0;
	int maxIdx = 0;
	if (m_pDataSource)
	{
		maxIdx = m_pDataSource->numberOfCellsInTableView(this)-1;
	}else{
		SFTableData* data = SFTableData::create();
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		int state = pEngine->executeTableViewDataSourceEvent(m_pDataSourceHandler,kNumberOfCellsInTableView,this,1,data);
		if (state != 0)
		{
			maxIdx = data->m_index-1;
		}
		data->release();
	}
	if (m_eVordering == kCCTableViewFillTopDown)
	{
		offset.y = this->getContainer()->getContentSize().height - offset.y;
	}
	index = this->__indexFromOffset(offset);
	if (index != -1)
	{
		index = MAX(0, index);
		if (index > maxIdx)
		{
			index = CC_INVALID_INDEX;
		}
	}

	return index;
}

int SFTableView::__indexFromOffset(CCPoint offset)
{
	int low = 0;
	int high = 0;

	if (m_pDataSource)
	{
		high = m_pDataSource->numberOfCellsInTableView(this)-1;
	}else{
		SFTableData* data = SFTableData::create();
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		int state = pEngine->executeTableViewDataSourceEvent(m_pDataSourceHandler,kNumberOfCellsInTableView,this,1,data);
		if (state != 0)
		{
			high = data->m_index-1;
		}
		data->release();
	}
	float search;
	switch (this->getDirection())
	{
		case kCCScrollViewDirectionHorizontal:
			search = offset.x;
			break;
		default:
			search = offset.y;
			break;
	}

	while (high >= low)
	{
		int index = low + (high - low) / 2;
		float cellStart = m_vCellsPositions[index];
		float cellEnd = m_vCellsPositions[index + 1];

		if (search >= cellStart && search <= cellEnd)
		{
			return index;
		}
		else if (search < cellStart)
		{
			high = index - 1;
		}
		else
		{
			low = index + 1;
		}
	}

	if (low <= 0) {
		return 0;
	}

	return -1;
}

void SFTableView::_moveCellOutOfSight(SFTableViewCell *cell)
{
	if(m_pTableViewDelegate != NULL) {
		m_pTableViewDelegate->tableCellWillRecycle(this, cell);
	}
	cell->setIndex(cell->getIdx());
	m_pCellsFreed->addObject(cell);
	m_pCellsUsed->removeSortedObject(cell);
	m_pIndices->erase(cell->getIdx());
	// [m_pIndices removeIndex:cell.idx];
	cell->reset();
	if (cell->getParent() == this->getContainer()) {
		this->getContainer()->removeChild(cell, true);;
	}
}

void SFTableView::_setIndexForCell(unsigned int index, SFTableViewCell *cell)
{
	cell->setAnchorPoint(ccp(0.0f, 0.0f));
	cell->setPosition(this->_offsetFromIndex(index));
	cell->setIdx(index);
}

void SFTableView::_updateCellPositions() {
	int cellsCount = 0;
	if (m_pDataSource)
	{
		cellsCount = m_pDataSource->numberOfCellsInTableView(this);
	}else{
		SFTableData* data = SFTableData::create();
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		int state = pEngine->executeTableViewDataSourceEvent(m_pDataSourceHandler,kNumberOfCellsInTableView,this,1,data);
		if (state != 0)
		{
			cellsCount = data->m_index;
		}
		data->release();
	}
	m_vCellsPositions.resize(cellsCount + 1, 0.0);

	if (cellsCount > 0)
	{
		float currentPos = 0;
		CCSize cellSize;
		for (int i=0; i < cellsCount; i++)
		{
			m_vCellsPositions[i] = currentPos;
			if (m_pDataSource)
			{
				cellSize = getDataSource()->cellSizeForTable(this);
			}else{
				SFTableData* data = SFTableData::create();
				CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
				int state = pEngine->executeTableViewDataSourceEvent(m_pDataSourceHandler,kCellSizeForTable,this,1,data);
				cellSize = data->m_size;
				data->release();
			}
			switch (this->getDirection())
			{
				case kCCScrollViewDirectionHorizontal:
					currentPos += cellSize.width;
					break;
				default:
					currentPos += cellSize.height;
					break;
			}
		}
		m_vCellsPositions[cellsCount] = currentPos;//1 extra value allows us to get right/bottom of the last cell
	}

}

void SFTableView::scrollViewDidScroll(CCScrollView* view)
{
	unsigned int uCountOfItems = 0;
	if (m_pDataSource)
	{
		uCountOfItems = m_pDataSource->numberOfCellsInTableView(this);
	}else{
		SFTableData* data = SFTableData::create();
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		int state = pEngine->executeTableViewDataSourceEvent(m_pDataSourceHandler,kNumberOfCellsInTableView,this,1,data);
		if (state != 0)
		{
			uCountOfItems = data->m_index;
		}
		data->release();
	}
	if (0 == uCountOfItems)
	{
		return;
	}

	if(m_pTableViewDelegate != NULL) {
		m_pTableViewDelegate->scrollViewDidScroll(this);
	}

	unsigned int startIdx = 0, endIdx = 0, idx = 0, maxIdx = 0;
	CCPoint offset = ccpMult(this->getContentOffset(), -1);
	maxIdx = MAX(uCountOfItems-1, 0);

	if (m_eVordering == kCCTableViewFillTopDown)
	{
		offset.y = offset.y + m_tViewSize.height/this->getContainer()->getScaleY();
	}
	startIdx = this->_indexFromOffset(offset);
	if (startIdx == CC_INVALID_INDEX)
	{
		startIdx = uCountOfItems - 1;
	}

	if (m_eVordering == kCCTableViewFillTopDown)
	{
		offset.y -= m_tViewSize.height/this->getContainer()->getScaleY();
	}
	else
	{
		offset.y += m_tViewSize.height/this->getContainer()->getScaleY();
	}
	offset.x += m_tViewSize.width/this->getContainer()->getScaleX();

	endIdx   = this->_indexFromOffset(offset);
	if (endIdx == CC_INVALID_INDEX)
	{
		endIdx = uCountOfItems - 1;
	}


	if (m_pCellsUsed->count() > 0)
	{
		SFTableViewCell* cell = (SFTableViewCell*)m_pCellsUsed->objectAtIndex(0);

		idx = cell->getIdx();
		while(idx <startIdx)
		{
			this->_moveCellOutOfSight(cell);
			if (m_pCellsUsed->count() > 0)
			{
				cell = (SFTableViewCell*)m_pCellsUsed->objectAtIndex(0);
				idx = cell->getIdx();
			}
			else
			{
				break;
			}
		}
	}
	if (m_pCellsUsed->count() > 0)
	{
		SFTableViewCell *cell = (SFTableViewCell*)m_pCellsUsed->lastObject();
		idx = cell->getIdx();

		while(idx <= maxIdx && idx > endIdx)
		{
			this->_moveCellOutOfSight(cell);
			if (m_pCellsUsed->count() > 0)
			{
				cell = (SFTableViewCell*)m_pCellsUsed->lastObject();
				idx = cell->getIdx();

			}
			else
			{
				break;
			}
		}
	}

	for (unsigned int i=startIdx; i <= endIdx; i++)
	{
		//if ([m_pIndices containsIndex:i])
		if (m_pIndices->find(i) != m_pIndices->end())
		{
			continue;
		}
		this->updateCellAtIndex(i);
	}
}

void SFTableView::ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent)
{
	if (!this->isVisible()) {
		return;
	}

	if (m_pTouchedCell){
		CCRect bb = this->boundingBox();
		if (m_pParent)
		{
			bb.origin = m_pParent->convertToWorldSpace(bb.origin);

			if (bb.containsPoint(pTouch->getLocation()) && m_pTableViewDelegate != NULL)
			{
				CCPoint touchPoint = m_pTouchedCell->convertTouchToNodeSpace(pTouch);
				m_pTableViewDelegate->tableCellUnhighlight(this, m_pTouchedCell);
				m_pTableViewDelegate->tableCellTouched(this, m_pTouchedCell);
				m_pTableViewDelegate->tableCellTouched(this, m_pTouchedCell,touchPoint);
				setSelectedCellIndex(m_pTouchedCell->getIdx());
			}else if (bb.containsPoint(pTouch->getLocation()) &&m_pTableViewHandler)
			{
				CCPoint touchPoint = m_pTouchedCell->convertTouchToNodeSpace(pTouch);
				CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()
					->getScriptEngine();
				pEngine->executeTableViewTouchEvent(m_pTableViewHandler,this,m_pTouchedCell,touchPoint);
			}
		}
		m_pTouchedCell = NULL;
	}

	if (m_pDataSourceHandler != -1) {
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		pEngine->executeTableViewDataSourceEvent(m_pDataSourceHandler, kTableViewTouchEnded, this, -1, NULL);
	}
	CCScrollView::ccTouchEnded(pTouch, pEvent);
}

bool SFTableView::ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent)
{
	if (!this->isVisible()) {
		return false;
	}

	bool touchResult = CCScrollView::ccTouchBegan(pTouch, pEvent);

	if(m_pTouches->count() == 1) {
		unsigned int        index;
		CCPoint           point;

		point = this->getContainer()->convertTouchToNodeSpace(pTouch);

		index = this->_indexFromOffset(point);
		if (index == CC_INVALID_INDEX)
		{
			m_pTouchedCell = NULL;
		}
		else
		{
			m_pTouchedCell  = this->cellAtIndex(index);
		}

		if (m_pTouchedCell && m_pTableViewDelegate != NULL) {
			m_pTableViewDelegate->tableCellHighlight(this, m_pTouchedCell);
		}
	}
	else if(m_pTouchedCell) {
		if(m_pTableViewDelegate != NULL) {
			m_pTableViewDelegate->tableCellUnhighlight(this, m_pTouchedCell);
		}

		m_pTouchedCell = NULL;
	}

	if (m_pDataSourceHandler != -1) {
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		pEngine->executeTableViewDataSourceEvent(m_pDataSourceHandler, kTableViewTouchBegan, this, -1, NULL);
	}
	return touchResult;
}

void SFTableView::ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent)
{
	CCScrollView::ccTouchMoved(pTouch, pEvent);

	if (m_pTouchedCell && isTouchMoved()) {
		if(m_pTableViewDelegate != NULL) {
			m_pTableViewDelegate->tableCellUnhighlight(this, m_pTouchedCell);
		}

		m_pTouchedCell = NULL;
	}
	if (m_pDataSourceHandler != -1) {
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		pEngine->executeTableViewDataSourceEvent(m_pDataSourceHandler, kTableViewTouchMoved, this, -1, NULL);
	}
}

void SFTableView::ccTouchCancelled(CCTouch *pTouch, CCEvent *pEvent)
{
	CCScrollView::ccTouchCancelled(pTouch, pEvent);

	if (m_pTouchedCell) {
		if(m_pTableViewDelegate != NULL) {
			m_pTableViewDelegate->tableCellUnhighlight(this, m_pTouchedCell);
		}

		m_pTouchedCell = NULL;
	}
	if (m_pDataSourceHandler != -1) {
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		pEngine->executeTableViewDataSourceEvent(m_pDataSourceHandler, kTableViewTouchCanceled, this, -1, NULL);
	}
}

void SFTableView::stoppedAnimatedScroll(CCNode* node)
{
	if (m_pDataSourceHandler != -1) {
		CCScriptEngineProtocol* pEngine = CCScriptEngineManager::sharedManager()->getScriptEngine();
		pEngine->executeTableViewDataSourceEvent(m_pDataSourceHandler, kTableViewDidAnimateScrollEnd, this, -1, NULL);
	}
	CCScrollView::stoppedAnimatedScroll(node);
}