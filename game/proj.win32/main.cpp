#include "main.h"
#include "AppDelegate.h"
#include "CCEGLView.h"

//Juchao@20131209: to open vld memory leak checking in windows
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
//#include "vld.h"
#endif 
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
#include <DbgHelp.h>

#pragma comment(lib, "Dbghelp.lib")

LONG WINAPI MyUnhandledExceptionFilter(struct _EXCEPTION_POINTERS* lpExceptionInfo)
{
	TCHAR szProgramPath[MAX_PATH] = {0};

	if(GetModuleFileName(NULL, szProgramPath, MAX_PATH))
	{
		LPTSTR lpSlash = _tcsrchr(szProgramPath, '\\');
		if(lpSlash)
		{
			*(lpSlash + 1) = '\0';
		}
	}

	TCHAR szDumpFile[MAX_PATH] = {0};

	_stprintf(szDumpFile, _T("%s%d.dmp"), szProgramPath, time(NULL));

	TCHAR szReportFile[MAX_PATH] = {0};

	//_stprintf(szReportFile, _T("%sBugReport.exe"), szProgramPath);

	HANDLE hDumpFile = CreateFile(szDumpFile, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL ,NULL);

	MINIDUMP_EXCEPTION_INFORMATION stMiniDumpExceptionInfo;

	stMiniDumpExceptionInfo.ExceptionPointers = lpExceptionInfo;

	stMiniDumpExceptionInfo.ThreadId = GetCurrentThreadId();

	stMiniDumpExceptionInfo.ClientPointers = TRUE;

	MiniDumpWriteDump(GetCurrentProcess(), GetCurrentProcessId(), hDumpFile,
		MiniDumpNormal, &stMiniDumpExceptionInfo, NULL, NULL);
	CloseHandle(hDumpFile);
	return EXCEPTION_EXECUTE_HANDLER;
}


#endif


USING_NS_CC;

// uncomment below line, open debug console
#define  USE_WIN32_CONSOLE 


int APIENTRY _tWinMain(HINSTANCE hInstance,
                       HINSTANCE hPrevInstance,
                       LPTSTR    lpCmdLine,
                       int       nCmdShow)
{
    UNREFERENCED_PARAMETER(hPrevInstance);
    UNREFERENCED_PARAMETER(lpCmdLine);
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
	SetUnhandledExceptionFilter(MyUnhandledExceptionFilter);
#endif
#ifdef USE_WIN32_CONSOLE
    AllocConsole();
    freopen("CONIN$", "r", stdin);
    freopen("CONOUT$", "w", stdout);
    freopen("CONOUT$", "w", stderr);
#endif

    // create the application instance
    AppDelegate app;
    CCEGLView* eglView = CCEGLView::sharedOpenGLView();
    eglView->setFrameSize(960, 640);
	//eglView->setFrameZoomFactor(0.5f);
	//eglView->setFrameSize(1024, 768);
    int ret = CCApplication::sharedApplication()->run();

#ifdef USE_WIN32_CONSOLE
    FreeConsole();
#endif

    return ret;
}
