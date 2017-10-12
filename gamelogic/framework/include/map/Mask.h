#ifndef Mask_h__
#define Mask_h__

namespace cocos2d
{
		class MemoryStream;
}

namespace cmap
{

	class Mask 
	{
	public	:
		unsigned char* buffer;
		unsigned int bufferSize;
		unsigned int width;
		unsigned int height;

	public:
		Mask();
		~Mask();

	public:
		void ReloadMask(cocos2d::MemoryStream& stream);

		bool IsMask(int x, int y);
		bool IsValid(int x, int y);
	};
}


#endif // Mask_h__