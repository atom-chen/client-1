/********************************************************************
文件名:SFTouchDispatcher.cpp
创建者:James Ou
创建时间:2013-5-14 10:07
功能描述:
*********************************************************************/

#include "utils/SFTouchDispatcher.h"
#include "ui/control/SFTouchLayer.h"
void SFTouchDispatcher::addTouchEvent( CCTouchDelegate *pTouchDelegate, int nPriority, bool bSwallowsTouchs )
{
}

void SFTouchDispatcher::removeTouchEvent( CCTouchDelegate *pTouchDelegate )
{
}

//#pragma mark- input touche

SFTouchDelegate::SFTouchDelegate( CCNode* pOwner ):
m_pOwner( pOwner ),
	m_bDraging( false )
{
	m_pItemsClaimTouch = CCArray::create();
	assert( m_pItemsClaimTouch );
	m_pItemsClaimTouch->retain();

	m_pMenusClaimTouch = CCArray::create();
	assert( m_pMenusClaimTouch );
	m_pMenusClaimTouch->retain();
}

SFTouchDelegate::~SFTouchDelegate()
{
	CC_SAFE_RELEASE_NULL( m_pItemsClaimTouch );
	CC_SAFE_RELEASE_NULL( m_pMenusClaimTouch );
}

bool SFTouchDelegate::byTouchBegan(CCTouch *pTouch, CCEvent *pEvent)
{
	return false;
	//pass message to all children
	//return passMessage( m_pOwner, pTouch, pEvent );
}

void SFTouchDelegate::byTouchMoved(CCTouch *pTouch, CCEvent *pEvent)
{
	return;
	//special process for menu, we won't pass ccTouchMoved message to menu. Because we think menu doesn't need ccTouchMoved message in ios device where user always want to dray layer instead menu. The fllowing block for menu will only go once.
	int iNumMenus = m_pMenusClaimTouch->count();
	for( int i = 0; i < iNumMenus; ++i )
	{
		( ( CCMenu* )m_pMenusClaimTouch->objectAtIndex( i ) )->ccTouchMoved( pTouch, pEvent );        
	}

// 	if( iNumMenus > 0 )
// 	{
// 		m_pMenusClaimTouch->removeAllObjects();
// 	}


	//pass ccTouchMoved message to un-CCMenu item
	int touchCount = m_pItemsClaimTouch->count();
	for( int i = 0; i < touchCount; ++i )
	{
		CCNode *pNode = ( ( CCNode* )m_pItemsClaimTouch->objectAtIndex( i ) );
		CCTouchDelegate *pTouchDelegate = dynamic_cast< CCTouchDelegate* >( pNode );
		if(pTouchDelegate)
			pTouchDelegate->ccTouchMoved( pTouch, pEvent );
	}
}

void SFTouchDelegate::byTouchEnded(CCTouch *pTouch, CCEvent *pEvent)
{
	return;
	//for menus
	int touchCount = m_pMenusClaimTouch->count();
	for( int i = 0; i < touchCount; ++i )
	{
		( ( CCMenu* )m_pMenusClaimTouch->objectAtIndex( i ) )->ccTouchEnded( pTouch, pEvent );
	}
	m_pMenusClaimTouch->removeAllObjects();

	//for items not menu
	touchCount = m_pItemsClaimTouch->count();
	for( int i = 0; i < touchCount; ++i )
	{
		CCNode *pNode = ( ( CCNode* )m_pItemsClaimTouch->objectAtIndex( i ) );
		CCTouchDelegate *pTouchDelegate = dynamic_cast< CCTouchDelegate* >( pNode );
		if(pTouchDelegate)
			pTouchDelegate->ccTouchEnded( pTouch, pEvent );
//		( ( CCLayer* )m_pItemsClaimTouch->objectAtIndex( i ) )->ccTouchEnded( pTouch, pEvent );
	}
	m_pItemsClaimTouch->removeAllObjects();
}

void SFTouchDelegate::byTouchCancelled(CCTouch *pTouch, CCEvent *pEvent)
{
	//for menus
	int touchCount = m_pMenusClaimTouch->count();
	for( int i = 0; i < touchCount; ++i )
	{
		( ( CCMenu* )m_pMenusClaimTouch->objectAtIndex( i ) )->ccTouchCancelled( pTouch, pEvent );
	}
	m_pMenusClaimTouch->removeAllObjects();

	//for items not menu
	touchCount = m_pItemsClaimTouch->count();
	for( int i = 0; i < touchCount; ++i )
	{
		CCNode *pNode = ( ( CCNode* )m_pItemsClaimTouch->objectAtIndex( i ) );
		CCTouchDelegate *pTouchDelegate = dynamic_cast< CCTouchDelegate* >( pNode );
		if(pTouchDelegate)
			pTouchDelegate->ccTouchCancelled( pTouch, pEvent );
//		( ( CCLayer* )m_pItemsClaimTouch->objectAtIndex( i ) )->ccTouchCancelled( pTouch, pEvent );
	}
	m_pItemsClaimTouch->removeAllObjects();
}



bool SFTouchDelegate::passMessage( CCNode* pParent, CCTouch *pTouch, CCEvent *pEvent )
{
	if( !pParent || !pParent->isVisible() )
	{
		return false;
	}

	CCArray* pChildren = pParent->getChildren();

	if( !pChildren )
	{
		return false;
	}
	
	pParent->sortAllChildren();

	CCObject* pObject = NULL;
	CCARRAY_FOREACH_REVERSE( pChildren, pObject )
	{
		CCNode* pNode = NULL;
		pNode = ( CCNode*  )pObject;
		assert( pNode );

		if( !pNode->isVisible() ) continue;
		
		bool bClaim = false;

		CCLayer* pLayer = NULL;		
		CCTouchDelegate *pTouchDelegate = NULL;
		pNode->retain();
		if( !passMessage( pNode, pTouch, pEvent ) ){
			if(pTouchDelegate = dynamic_cast< CCTouchDelegate* >( pNode ))
			{
				if( ( pLayer = dynamic_cast< CCLayer* >( pNode ) ) )
				{
					if(pLayer->isTouchEnabled())
					{
						bClaim = true;
					}
				}
				else{
					bClaim = true;
				}


				if( bClaim /*&& pNode->getContentSize().width * pNode->getContentSize().height > 1.0f*/ )
				{
					bClaim = false;
// 					CCPoint pt = pNode->convertTouchToNodeSpace(pTouch);//pTouch->getLocation();
// 					CCRect rcBoundingBox( 0, 0, pNode->boundingBox().size.width, pNode->boundingBox().size.height );
// 					
// 					//rcBoundingBox = CCRectApplyAffineTransform( rcBoundingBox, pNode->nodeToWorldTransform() );
// 
// 					if( rcBoundingBox.containsPoint( pt ) || dynamic_cast< CCMenu* >( pNode ) )
// 					{

						bClaim = pTouchDelegate->ccTouchBegan( pTouch, pEvent );
//					}
				}
				else
				{
					bClaim = false;
				}
			}
		}
		else
		{
			pNode->release();
			return true;
		}
		if( bClaim )
		{
			if ( dynamic_cast< CCMenu* >( pNode ) )
			{
				m_pMenusClaimTouch->addObject( pNode );
			}
			else
			{
				m_pItemsClaimTouch->addObject( pNode );
			}
			pNode->release();		
			break;
		}
		pNode->release();
	}

	return m_pItemsClaimTouch->count() + m_pMenusClaimTouch->count() > 0 ? true : false;
}

//#pragma mark- ROOT TOUCH LAYER
RTLayer::RTLayer() : SFTouchDelegate( this ){

}

bool RTLayer::init()
{
	CCLayer::init();

	// layer的优先级是0， 必须必一般的layer要高的优先级
	setTouchMode(kCCTouchesOneByOne);
	setTouchPriority(-1);
	setTouchEnabled( true );
	return true;
}


