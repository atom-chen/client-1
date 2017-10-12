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

#ifndef __SFTABLEVIEW_H__
#define __SFTABLEVIEW_H__
#include "cocos2d.h"
#include "cocos-ext.h"
USING_NS_CC;
USING_NS_CC_EXT;

#include "SFTableCell.h"

#include <set>
#include <vector>


class SFTableView;

typedef enum {
	kSFTableViewFillTopDown,
	kSFTableViewFillBottomUp
} SFTableViewVerticalFillOrder;

const int SFTableViewSelectedNone = -1;
/**
 * Sole purpose of this delegate is to single touch event in this version.
 */
class SFTableViewDelegate : public CCScrollViewDelegate
{
public:
	/**
	 * Delegate to respond touch event
	 *
	 * @param table table contains the given cell
	 * @param cell  cell that is touched
	 */
	virtual void tableCellTouched(SFTableView* table, SFTableViewCell* cell){};
	virtual void tableCellTouched(SFTableView* table, SFTableViewCell* cell, CCPoint pt){};
	/**
	 * Delegate to respond a table cell press event.
	 *
	 * @param table table contains the given cell
	 * @param cell  cell that is pressed
	 */
	virtual void tableCellHighlight(SFTableView* table, SFTableViewCell* cell){};

	/**
	 * Delegate to respond a table cell release event
	 *
	 * @param table table contains the given cell
	 * @param cell  cell that is pressed
	 */
	virtual void tableCellUnhighlight(SFTableView* table, SFTableViewCell* cell){};

	/**
	 * Delegate called when the cell is about to be recycled. Immediately
	 * after this call the cell will be removed from the scene graph and
	 * recycled.
	 *
	 * @param table table contains the given cell
	 * @param cell  cell that is pressed
	 */
	virtual void tableCellWillRecycle(SFTableView* table, SFTableViewCell* cell){};
	virtual void scrollViewDidScroll(CCScrollView* view){};
	virtual void scrollViewDidZoom(CCScrollView* view) {}
};

class SFTableData :public CCObject
{
public:
	static SFTableData* create()
	{
		SFTableData* data = new SFTableData();
		if (data)
		{
			data->autorelease();
			data->retain();
			data->m_index = 0;
			data->m_size = CCSizeZero;
			data->m_cell = NULL;
			return data;
		}
		CC_SAFE_DELETE(data);
		return NULL;
	}
	unsigned int m_index;
	void setIndex(int index){m_index = index;};
	void setSize(CCSize size){m_size = size;};
	void setCell(SFTableViewCell* cell){m_cell = cell;};
	CCSize m_size;
	SFTableViewCell* m_cell ;
};

/**
 * Data source that governs table backend data.
 */
class SFTableViewDataSource
{
public:
	virtual ~SFTableViewDataSource() {}

	/**
	 * cell size for a given index
	 *
	 * @param idx the index of a cell to get a size
	 * @return size of a cell at given index
	 */
	virtual CCSize tableCellSizeForIndex(SFTableView *table, unsigned int idx) {
		return cellSizeForTable(table);
	};
	/**
	 * cell height for a given table.
	 *
	 * @param table table to hold the instances of Class
	 * @return cell size
	 */
	virtual CCSize cellSizeForTable(SFTableView *table) {
		return CCSizeZero;
	};
	/**
	 * a cell instance at a given index
	 *
	 * @param idx index to search for a cell
	 * @return cell found at idx
	 */
	virtual SFTableViewCell* tableCellAtIndex(SFTableView *table, unsigned int idx) = 0;
	/**
	 * Returns number of cells in a given table view.
	 *
	 * @return number of cells
	 */
	virtual unsigned int numberOfCellsInTableView(SFTableView *table) = 0;

};


/**
 * UITableView counterpart for cocos2d for iphone.
 *
 * this is a very basic, minimal implementation to bring UITableView-like component into cocos2d world.
 *
 */
class SFTableView : public CCScrollView, public CCScrollViewDelegate
{
public:
	SFTableView();
	virtual ~SFTableView();

	/**
	 * An intialized table view object
	 *
	 * @param dataSource data source
	 * @param size view size
	 * @return table view
	 */
	static SFTableView* create(SFTableViewDataSource* dataSource, CCSize size);
	/**
	 * An initialized table view object
	 *
	 * @param dataSource data source;
	 * @param size view size
	 * @param container parent object for cells
	 * @return table view
	 */
	static SFTableView* create(SFTableViewDataSource* dataSource, CCSize size, CCNode *container);

	/**
	 * data source
	 */
	SFTableViewDataSource* getDataSource() { return m_pDataSource; }
	void setDataSource(SFTableViewDataSource* source) { m_pDataSource = source; }
	void setDataHandler(int nHandler){m_pDataSourceHandler = nHandler;}
	void setTableViewHandler(int nHander){m_pTableViewHandler = nHander;}
	/**
	 * delegate
	 */
	SFTableViewDelegate* getDelegate() { return m_pTableViewDelegate; }
	void setDelegate(SFTableViewDelegate* pDelegate) { m_pTableViewDelegate = pDelegate; }

	/**
	 * determines how cell is ordered and filled in the view.
	 */
	void setVerticalFillOrder(SFTableViewVerticalFillOrder order);
	SFTableViewVerticalFillOrder getVerticalFillOrder();


	bool initWithViewSize(CCSize size, CCNode* container = NULL);
	/**
	 * Updates the content of the cell at a given index.
	 *
	 * @param idx index to find a cell
	 */
	void updateCellAtIndex(unsigned int idx);
	/**
	 * Inserts a new cell at a given index
	 *
	 * @param idx location to insert
	 */
	void insertCellAtIndex(unsigned int idx);
	/**
	 * Removes a cell at a given index
	 *
	 * @param idx index to find a cell
	 */
	void removeCellAtIndex(unsigned int idx);
	/**
	 * reloads data from data source.  the view will be refreshed.
	 */
	void reloadData();
	/**
	 * Dequeues a free cell if available. nil if not.
	 *
	 * @return free cell
	 */
private:
	/************************************************************************/
	/* 不被使用,用带参数的代替                                                                     */
	/************************************************************************/
public:
	SFTableViewCell *dequeueCell(int index);

	SFTableViewCell *dequeueCell();
	/**
	 * Returns an existing cell at a given index. Returns nil if a cell is nonexistent at the moment of query.
	 *
	 * @param idx index
	 * @return a cell at a given index
	 */
	SFTableViewCell *cellAtIndex(unsigned int idx);

	void scroll2Cell(unsigned int idx, bool animated = true);


	virtual void scrollViewDidScroll(CCScrollView* view);
	virtual void scrollViewDidZoom(CCScrollView* view) {}

	virtual bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchCancelled(CCTouch *pTouch, CCEvent *pEvent);
protected:
	
	
	SFTableViewCell *m_pTouchedCell;
	/**
	 * vertical direction of cell filling
	 */
	SFTableViewVerticalFillOrder m_eVordering;

	/**
	 * index set to query the indexes of the cells used.
	 */
	std::set<unsigned int>* m_pIndices;

	/**
	 * vector with all cell positions
	 */
	std::vector<float> m_vCellsPositions;
	//NSMutableIndexSet *indices_;
	/**
	 * cells that are currently in the table
	 */
	CCArrayForObjectSorting* m_pCellsUsed;
	/**
	 * free list of cells
	 */
	CCArrayForObjectSorting* m_pCellsFreed;
	/**
	 * weak link to the data source object
	 */
	SFTableViewDataSource* m_pDataSource;
	/**
	 * weak link to the delegate object
	 */
	SFTableViewDelegate* m_pTableViewDelegate;

	CCScrollViewDirection m_eOldDirection;
	//lua dataSource handler
	int m_pDataSourceHandler;
	//
	int m_pTableViewHandler;
	int __indexFromOffset(CCPoint offset);
	unsigned int _indexFromOffset(CCPoint offset);
	CCPoint __offsetFromIndex(unsigned int index);
	CCPoint _offsetFromIndex(unsigned int index);

	void _moveCellOutOfSight(SFTableViewCell *cell);
	void _setIndexForCell(unsigned int index, SFTableViewCell *cell);
	void _addCellIfNecessary(SFTableViewCell * cell);

	void _updateCellPositions();
	virtual void stoppedAnimatedScroll(CCNode* node);

protected: int m_selectedIndex;
public: virtual int getSelectedCellIndex(void) const { return m_selectedIndex; }
public: virtual void setSelectedCellIndex(int var){ m_selectedIndex = var; }

public:
	void _updateContentSize();

};



#endif /* SFTableView */
