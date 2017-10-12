#ifndef DreamSweepAndPrune_h__
#define DreamSweepAndPrune_h__
#include "sofia/SofiaMacro.h"
#include "ccTypes.h"
#include "SAPDefinition.h"
#include "SAPPairManager.h"
#include "kazmath/aabb.h"
#include "SAPBitset.h"
#include <vector>
#include <set>


#define SF_SAP_GROUP_SCENE_OBJECT 1
#define SF_SAP_GROUP_CAMERA       2

#define SF_SAP_MAP_CAMARE	1<<2
#define SF_SAP_MAP_TILE	1<<3
#define SF_SAP_MAP_PLAYER	1<<4
#define SF_SAP_MAP_COSTUM	1<<5

	// Forward declarations
	class ASAP_EndPoint;
	class ASAP_Box;
	struct InnerAABB;
	struct CreateData;

	class  SAPCommonListner
	{
	public:
		virtual void* OnPairCreate(const void* pObject0, const void* pObject1){return NULL;}
		virtual void OnPairDelete(const void* pObject0, const void* pObject1, void* pPairData){}
	};

	class  SAPQueryListner
	{
	public:
		virtual void OnQueryObject(const void* pObject){};
	};
	class  ArraySAP
	{
	public:

	private:
		struct				BPMinPosInfo		//temp struct for box pruning 
		{
			ValType			minPos;
			unsigned int boxIndex;
		};
		typedef std::vector<BPMinPosInfo> BPMinPosInfoList;
	private:
		PairManager mPairManager;

		typedef std::vector<unsigned int> IDList;
		typedef std::set<unsigned int> IDSet;
		IDSet				mOperatePairSet;

		typedef std::vector<SAPBox> SAPBoxList;
		SAPBoxList			mBoxList;
		IDList				mFreeBoxIdList;

		////boost::object_pool<SAPEndPoint> mEndPointPool;

		////SAPEndPointSortMap  mEndPointMap[3];

		SAPEndPointArray   mEndPointArrays[3];



		// For batch creation
		typedef std::map<unsigned int,CreateData> CreateDataMap;
		//typedef std::vector<CreateData> CreateDataList;
		CreateDataMap		mCreateDataMap;



		// For batch removal
		IDList				mRemoveList;

		////SapCreatePairFunc   mPairCreateFunc;
		////SapDeletePairFunc   mPairDeleteFunc;

		SAPCommonListner* m_pCommonListner;
		////boost::dynamic_bitset<> mCreatesDbFlags;
		Bitset mCreatesDbFlags;
	public:
		ArraySAP();
		~ArraySAP();

		unsigned int AddObject(void* object, const kmAABB& box, unsigned short groupFlag = 0xffff, unsigned short collisionFlag = 0xffff);
		bool RemoveObject(unsigned int handle);
		bool UpdateObject(unsigned int handle, const kmAABB& box);

		unsigned int DumpPairs();
	
		void SetCommonListner(SAPCommonListner* pListner);
		////void SetOnPairCreateFunc(SapCreatePairFunc onCreateFunc) {mPairCreateFunc = onCreateFunc;}
		////void SetOnPairDeleteFunc(SapDeletePairFunc onDeleteFunc) {mPairDeleteFunc = onDeleteFunc;}

		unsigned int QueryObjectsByAABB(const kmAABB& queryBox, SAPQueryListner* pQueryListner, unsigned short collisionFlag = 0xffff);

		PairList QueryObjectAssociatePairs(unsigned int handle);
	private:
		inline void AddPair(const void* object0, const void* object1, unsigned short id0, unsigned short id1)
		{
			Pair* UP = mPairManager.AddPair(id0, id1, object0, object1);

			if(UP->lastCreate==0)
			{
				// Persistent pair
			}
			else
			{
				UP->lastCreate = 0;
				////UP->object0 = object0;
				////UP->object1 = object1;
				UP->SetInArray();
				mOperatePairSet.insert(mPairManager.GetPairKey(UP));
				UP->SetNew();
			}
			UP->ClearRemoved();
		}

		inline void RemovePair(const void* object0, const void* object1, unsigned short id0, unsigned short id1)
		{
			Pair* UP = mPairManager.FindPair(id0, id1);
			if(UP)
			{
				if(!UP->IsInArray())
				{
					UP->SetInArray();
					mOperatePairSet.insert(mPairManager.GetPairKey(UP));
				}
				UP->SetRemoved();
			}
		}

		inline SAPBox* RequestNewBox()
		{
			if(!mFreeBoxIdList.empty())
			{
				unsigned int boxIndex = mFreeBoxIdList[mFreeBoxIdList.size()-1];
				mFreeBoxIdList.pop_back();
				return &mBoxList[boxIndex];
			}
			else
			{
				SAPBox tmpBox;
				////memset(&tmpBox,0,sizeof(tmpBox));
				tmpBox.mBoxIndex = mBoxList.size();
				mBoxList.push_back(tmpBox);
				return &mBoxList[mBoxList.size()-1];
			}
		}

		inline void	FreeBox(SAPBox* pBox)
		{
			mFreeBoxIdList.push_back(pBox->mBoxIndex);
		}


		void BoxPruningBetweenTwoSet(const BPMinPosInfoList& boxCircleSet, const BPMinPosInfoList& boxBeenDetectSet);
		void BoxPruningForBatchCreate(CreateDataMap& batchDataMap);
		void BatchCreate();
			

		void BatchRemove();
			
		void InsertEndPointToArray(const SAPEndPoint& endPoint,unsigned int axis);
		void InsertEndPointToArrayBatch(const SAPEndPointArray& insertArray,unsigned int axis);

		void UpdateIndexForEndPointArray(unsigned int axis, unsigned int fromIndex);

		inline unsigned int GetPropIndexFromEndPointArray(unsigned int axis, ValType val, unsigned int currentIndex);

		inline void ShiftOneItemInEndPointArray(unsigned int axis,unsigned int srcIndex,unsigned int dstIndex);
		
		inline void ChangeEndPointValue(SAPBox& srcBox, InnerAABB& updateBox, unsigned int axis, bool bMaxEndPoint, ValType newValue);
	
		inline SAPEndPoint* GetBoxEndPoint(SAPBox& srcBox, unsigned int axis,bool bMaxEndPoint);
	
		inline ValType GetBoxEndPointValue(SAPBox& srcBox, unsigned int axis,bool bMaxEndPoint);

		inline bool Intersect( SAPBox& a,  SAPBox& b, unsigned int axis);

		inline bool Intersect2D( SAPBox& a,  SAPBox& b, unsigned int axis1, unsigned int axis2);
			
		inline bool Intersect1D_Min(InnerAABB& a, SAPBox& b, unsigned int axis);

		inline bool IntersectValType(ValType aMin, ValType aMax, ValType bMin, ValType bMax);
	};


#endif // DreamSweepAndPrune_h__
