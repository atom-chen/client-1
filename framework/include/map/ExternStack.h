#ifndef _ENGINE_EXTERN_STACK_H_
#define _ENGINE_EXTERN_STACK_H_

namespace cmap
{
	class  CExternStackVar
	{
	public:
		CExternStackVar(unsigned int cbSize);
		~CExternStackVar();
		void* m_ptr;
	};

#define EXTERN_STACK_VAR(_type, _varname, _size) \
	cmap::CExternStackVar hugestack__##_varname(_size); _type _varname = (_type)hugestack__##_varname.m_ptr;

}
#endif

