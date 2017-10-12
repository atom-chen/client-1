#ifndef __SCENE_BASE_H__
#define __SCENE_BASE_H__
#include <map>
#include <list>
#include <string>
#include "SceneData.h"
#include "core/GameSimulatorObject.h"

typedef std::list<cmap::TransferOutInfo*> TransferOutList;//所有跳出点区域

namespace cmap
{
	typedef std::map<int, IntIdPointListInfo*> IdForPointListSet;
	typedef std::map<int, ReviveRegionInfo*> IdForReviveListSet;
	typedef std::map<int, TransferOutInfo*> IdForTransferOutListSet;
	typedef std::vector<MonsterPoint*> MonsterVector;
	typedef std::vector<NpcPoint*> NpcVector;
	class SceneBase : public GameSimulatorObject
	{
	public:
		SceneBase();
		virtual ~SceneBase();

		void		setSceneRefId(const char* str);
		const char* getSceneRefId() const;
		void		setMapId(int id);
		int			getMapId() const;
		void		setMapType(int type);
		int			getMapType() const;
	
	public:
		//propertyData blob
		//from base class
		//monsterData blob
		bool	loadMonsterFromBlob(char* buf, int size);
		std::string	saveMonsterToBlob();
		//npcData blob
		bool	loadNPCFromBlob(char* buf, int size);
		std::string	saveNPCToBlob();
		//transferInData blob
		bool	loadTransferInFromBlob(char* buf, int size);
		std::string	saveTransferInToBlob();
		//tranferOutData blob
		bool	loadTransferOutFromBlob(char* buf, int size);
		std::string	saveTransferOutToBlob();
		//reviveRegionData blob
		bool	loadReviveRegionDataFromBlob(char* buf, int size);
		std::string	saveReviveRegionDataToBlob();
		//safeRegionData blob
		bool	loadSafeRegionDataFromBlob(char* buf, int size);
		std::string	saveSafeRegionDataToBlob();
		//birthRegionData blob
		bool	loadBirthRegionDataFromBlob(char* buf, int size);
		std::string	saveBirthRegionDataToBlob();
	public:
		MonsterVector m_uniqueMonsters;
		NpcVector m_uniqueNpcs;
		const NpcVector& curUniqueNpcList();
		const MonsterVector& curUniqueMonsterList();
		//monsterData
		bool AddMonster(MonsterPoint* data);
		bool RemoveMonster( int x, int y);
		MonsterPoint* GetMonster( int x, int y);
		const MonsterPoint* GetMonster(const char* id);			//don't delete
		const MonsterVector GetMonsterVector(const char* id);	//don't delete
		//NPC
		bool AddNpc(const char* id, int x, int y);
		void RemoveNpc( int x, int y);
		void RemoveNpc( const char* id);
		NpcPoint* GetNpc( int x, int y);					//don't delete
		NpcPoint* GetNpc(const char* id);
		const NpcVector GetNpcList(const char* id);			//don't delete
		//tranferIn	
		void			setTranferIn(int id, IntIdPointListInfo* data);
		bool			romoveTranferIn(int id);
		const IdForPointListSet&	getTranferIn() const;
		//tranferOut
		void			setTranferOut(int id, TransferOutInfo* data);
		bool			romoveTranferOut(int id);
		const IdForTransferOutListSet&	getTranferOut() const;
		//reviveRegion
		void			setReviveRegion(int id, ReviveRegionInfo* data);
		bool			romoveReviveRegion(int id);
		const IdForReviveListSet&	getReviveRegion() const;
		//safeRegion
		void			setSafeRegion(int id, IntIdPointListInfo* data);
		bool			romoveSafeRegion(int id);
		const IdForPointListSet&	getSafeRegion() const;
		//birthRegion
		void			setBirthRegion(PointListInfo data);
		const PointListInfo&	getBirthRegion() const;
	public:
		void			clearAll();
	private:
		cocos2d::MemoryStream* getMemoryStream();
	//  Luofuwen 需要对各个vector循环取数据
	//protected: 
	public:


		MonsterVector mMonsters;
		NpcVector mNpcs;

		IdForTransferOutListSet mTransferOutPoints;
		IdForReviveListSet mReviveRegions;
		IdForPointListSet mTransferInPoints;
		IdForPointListSet mSafeRegions;
		PointListInfo mBirthRegion;

		std::string mSceneId;
		int			m_mapId;
		int			m_mapType;
	public:
		SceneBase(char* blob, int size)
		{
			m_dictionary->loadDictionary(blob, size);
		}
		std::string get_name();

		std::string get_description();
		char get_opposeState();
		int get_openLevel();
		std::string get_openQuest();
		std::string get_openTime();
		int get_musicID();
		char get_camp();
		char get_type();
		std::string mSceneName;
		int				mSceneWidth;
		int				mSceneHeight;

	};
	inline char SceneBase::get_type()
	{
		SimulatorProperty<char>* property = getProperty<char>(Symbol_MapType_Id);
		if(property)
			return property->getValue();
		return 0;
	}

	inline char SceneBase::get_camp()
	{
		SimulatorProperty<char>* property = getProperty<char>(Symbol_Camp_Id);
		if(property)
			return property->getValue();
		return 0;
	}

	inline std::string SceneBase::get_name()
	{
		SimulatorProperty<std::string>* property = getProperty<std::string>(Symbol_Name_Id);
		if(property)
			return property->getValue();
		return "";
	}

	inline std::string SceneBase::get_description()
	{
		SimulatorProperty<std::string>* property = getProperty<std::string>(Symbol_Description_Id);
		if(property)
			return property->getValue();
		return "";
	}

	inline char SceneBase::get_opposeState()
	{
		SimulatorProperty<char>* property = getProperty<char>(Symbol_OpposeState_Id);
		if(property)
			return property->getValue();
		return 0;
	}

	inline int SceneBase::get_openLevel()
	{
		SimulatorProperty<int>* property = getProperty<int>(Symbol_OpenLevel_Id);
		if(property)
			return property->getValue();
		return 0;
	}

	inline std::string SceneBase::get_openQuest()
	{
		SimulatorProperty<std::string>* property = getProperty<std::string>(Symbol_OpenQuest_Id);
		if(property)
			return property->getValue();
		return "";
	}

	inline std::string SceneBase::get_openTime()
	{
		SimulatorProperty<std::string>* property = getProperty<std::string>(Symbol_OpenTime_Id);
		if(property)
			return property->getValue();
		return "";
	}

	inline int SceneBase::get_musicID()
	{
		SimulatorProperty<int>* property = getProperty<int>(Symbol_MusicId_Id);
		if(property)
			return property->getValue();
		return 0;
	}
}


#endif