package com.morningglory.shell;

import android.app.Application;
import android.content.Context;

public class GameApplication extends Application {
	private static GameApplication _instance;

	public static Context getContext()
	{
		return _instance;
	}
	
    @Override  
    public void onCreate() {  
        super.onCreate();  
        _instance=this;  
    }
}
