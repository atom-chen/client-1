// @brief: data deflate
// @author: typ77
// @data: [9/5/2013 typ77]

//Even though I walk  through the valley of the shadow of death,  I will fear no evil,  for you are with me;  your rod and your staff,  they comfort me. 

#ifndef _SF_SAPDefinition_h__
#define _SF_SAPDefinition_h__

#include "sofia/SofiaMacro.h"
#include "ccTypes.h"
#include "kazmath/vec3.h"
#include "kazmath/aabb.h"
#include <vector>


	# define USE_INTEGERS
	////# define USE_SHORT_INDEX

#		ifdef USE_INTEGERS
		typedef unsigned int	ValType;
#		else
		typedef float	ValType;
#		endif

#		ifdef USE_SHORT_INDEX
		typedef unsigned short IndexType;
		typedef unsigned int KeyType;
#			define	INVALID_INDEX	0xffff
#		else
		typedef unsigned int IndexType;
		typedef unsigned long long KeyType;
#			define	INVALID_INDEX	0xffffffff
#		endif

	enum AxisIndex
	{
		X_					= 0,
		Y_					= 1,
		Z_					= 2,
		W_					= 3,

		AXIS_FORCE_DWORD	= 0x7fffffff
	};

	enum AxisOrder
	{
		AXES_XYZ			= (X_)|(Y_<<2)|(Z_<<4),
		AXES_XZY			= (X_)|(Z_<<2)|(Y_<<4),
		AXES_YXZ			= (Y_)|(X_<<2)|(Z_<<4),
		AXES_YZX			= (Y_)|(Z_<<2)|(X_<<4),
		AXES_ZXY			= (Z_)|(X_<<2)|(Y_<<4),
		AXES_ZYX			= (Z_)|(Y_<<2)|(X_<<4),

		AXES_FORCE_DWORD	= 0x7fffffff
	};

	class Axes 
	{
	public:

		Axes(AxisOrder order)
		{
			mAxis0 = (order   ) & 3;
			mAxis1 = (order>>2) & 3;
			mAxis2 = (order>>4) & 3;
		}
		~Axes()		{}

		unsigned int mAxis0;
		unsigned int mAxis1;
		unsigned int mAxis2;
	};



	struct InnerAABB
	{
		ValType mMinX;
		ValType mMinY;
		ValType mMinZ;
		ValType mMaxX;
		ValType mMaxY;
		ValType mMaxZ;

		inline ValType	GetMin(unsigned int i)	const	{	return (&mMinX)[i];	}
		inline ValType	GetMax(unsigned int i)	const	{	return (&mMaxX)[i];	}
	};

	struct CreateData
	{
		unsigned int mHandle;
		kmAABB mBox;
	};

	struct SAPEndPoint
	{
	public:
		SAPEndPoint()
			:flagMax(0)
			,ownerIndex(0)
			,mValue(0)
		{

		}

		~SAPEndPoint()
		{

		}

		inline bool operator < ( const SAPEndPoint& rhs ) const
		{
			return (mValue < rhs.mValue);
		}

		ValType	mValue;		// Min or Max value
		unsigned int  ownerIndex:31;
		////UINT32  flagSentinel:1;
		unsigned int  flagMax:1;
	};

	typedef std::vector<SAPEndPoint> SAPEndPointArray;
	typedef SAPEndPointArray::iterator SAPEndPointArrayIter;

	class SAPBox
	{
	public:
		SAPBox()
			:mCollisionFlag(0xffff),
			mGroupFlag(0xffff)
		{
			for (int i=0;i<3;i++)
			{
				mMin[i] = INVALID_INDEX;
				mMax[i] = INVALID_INDEX;
			}
		}
		~SAPBox()	
		{

		}

		IndexType mMin[3];
		IndexType mMax[3];

		unsigned short mGroupFlag;
		unsigned short mCollisionFlag;

		void*     mObject;
		unsigned int    mBoxIndex;

		inline ValType GetMaxValue(unsigned int i, const SAPEndPoint* baseAddr)	const
		{
			return baseAddr[mMax[i]].mValue;
		}

		inline ValType GetMinValue(unsigned int i, const SAPEndPoint* baseAddr) const
		{
			return baseAddr[mMin[i]].mValue;
		}

		inline bool CanCollideWith(const SAPBox& otherBox)
		{
			return ((otherBox.mGroupFlag&mCollisionFlag) && (otherBox.mCollisionFlag&mGroupFlag));
		}
	};

	//! Integer representation of a floating-point value.
#		define IR(x)					((unsigned int&)(x))

	//! Floating-point representation of an integer value.
#		define FR(x)					((float&)(x))
	
	inline unsigned int EncodeFloat(const float val)
	{
		// We may need to check on -0 and 0
		// But it should make no practical difference.
		unsigned int ir = IR(val);

		if(ir & 0x80000000) //negative?
			ir = ~ir;//reverse sequence of negative numbers
		else
			ir |= 0x80000000; // flip sign

		return ir;
	}

	inline float DecodeFloat(unsigned int ir)
	{
		unsigned int rv;

		if(ir & 0x80000000) //positive?
			rv = ir & ~0x80000000; //flip sign
		else
			rv = ~ir; //undo reversal

		return FR(rv);
	}

	// From Jon Watte IIRC
	inline void Prefetch(void const* ptr)
	{ 
		(void)*(char const volatile *)ptr;	
	}

#endif // DreamSAPDefinition_h__