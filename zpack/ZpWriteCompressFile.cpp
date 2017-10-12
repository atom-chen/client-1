#include "ZpWriteCompressFile.h"
#include "zpPackage.h"
#include "zlibEx.h"

namespace zp
{
	ZpWriteCompressFile::ZpWriteCompressFile( Package* package, u64 offset, u32 originalsize, u32 compressSize, u32 chunkSize, u32 flag, u64 nameHash )
		: m_package(package)
		, m_offset(offset)
		, m_originalsize(originalsize)
		, m_chunkSize(chunkSize)
		, m_flag(flag)
		, m_nameHash(nameHash)
		, m_writePos(0)
		, m_compressSize(compressSize)
	{

	}

	ZpWriteCompressFile::~ZpWriteCompressFile()
	{
		if (m_package->m_lastSeekFile == this)
		{
			m_package->m_lastSeekFile = NULL;
		}
	}

	zp::u32 ZpWriteCompressFile::size() const
	{
		return m_compressSize;
	}

	zp::u32 ZpWriteCompressFile::flag() const
	{
		return m_flag;
	}

	void ZpWriteCompressFile::seek( u32 pos )
	{
		if (pos > m_compressSize)
		{
			m_writePos = m_compressSize;
		}
		else
		{
			m_writePos = pos;
		}
	}

	zp::u32 ZpWriteCompressFile::tell() const
	{
		return m_writePos;
	}

	zp::u32 ZpWriteCompressFile::write( const u8* buffer, u32 size )
	{
		if (m_chunkSize == 0)
			m_chunkSize = 48;

		PACKAGE_LOCK;

		//if (m_writePos + size > m_compressSize)
		//{
		//	size = m_compressSize - m_writePos;
		//}
		if (size == 0)
		{
			return 0;
		}
		if (m_package->m_lastSeekFile != this)
		{
			seekInPackage();
		}

		// 根据chunkSize压缩数据
		std::vector<u8> chunkData;
		std::vector<u8> compressBuffer;
		std::vector<u32> chunkPosBuffer;

		u32 chunkCount = (size + m_chunkSize - 1) / m_chunkSize;
		chunkPosBuffer.resize(chunkCount);
		compressBuffer.resize(m_chunkSize);
		chunkData.resize(m_chunkSize);

		u32 packSize = 0;
		if (chunkCount > 1)
		{
			chunkPosBuffer[0] = chunkCount * sizeof(u32);
			fwrite(&chunkPosBuffer[0], chunkCount * sizeof(u32), 1, m_package->m_stream);
		}

		u8* dstBuffer = &compressBuffer[0];
		for (u32 i = 0; i < chunkCount; ++i)
		{
			u32 curChunkSize = m_chunkSize;
			if (i == chunkCount - 1 && size % m_chunkSize != 0)
			{
				curChunkSize = size % m_chunkSize;
			}
			memcpy(&chunkData[0], buffer+i*m_chunkSize, curChunkSize);
			//fread(&chunkData[0], curChunkSize, 1, srcFile);

			u32 dstSize = m_chunkSize;
			int ret = compress(dstBuffer, &dstSize, &chunkData[0], curChunkSize);

			if (ret != Z_OK	|| dstSize >= curChunkSize)
			{
				//compress failed or compressed size greater than origin, write raw data
				fwrite(&chunkData[0], curChunkSize, 1, m_package->m_stream);
				dstSize = curChunkSize;
			}
			else
			{
				fwrite(dstBuffer, dstSize, 1, m_package->m_stream);
			}
			if (i + 1 < chunkCount)
			{
				chunkPosBuffer[i + 1] = chunkPosBuffer[i] + dstSize;
			}
			packSize += dstSize;
		}

		if (chunkCount > 1)
		{
			packSize += chunkCount * sizeof(u32);
			//_fseeki64(dstFile, offset, SEEK_SET);
			seekInPackage();

			fwrite(&chunkPosBuffer[0], chunkCount * sizeof(u32), 1, m_package->m_stream);
		}
		else if (packSize == m_originalsize)
		{
			//only 1 chunk and not compressed, entire file should not be compressed
			m_flag &= (~FILE_COMPRESS);
		}

		//fwrite(buffer, size, 1, m_package->m_stream);
		//assert(m_compressSize != packSize);

		m_writePos += m_compressSize;

		if (!m_package->setFileAvailableSize(m_nameHash, m_writePos))
		{
			//something wrong, stop writing
			m_compressSize = 0;
			return 0;
		}
		return size;
	}

	void ZpWriteCompressFile::seekInPackage()
	{
		if (m_package)
		{
			//_fseeki64(m_package->m_stream, m_offset + m_writePos, SEEK_SET);
			fseek(m_package->m_stream, m_offset + m_writePos, SEEK_SET);
			m_package->m_lastSeekFile = this;
		}
	}

};