package com.morningglory.shell;

import org.cocos2dx.lib.Cocos2dxActivity;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.os.PowerManager;
import android.os.PowerManager.WakeLock;
import android.view.KeyEvent;

public class BaseActivity extends Cocos2dxActivity {
	private static Activity _mainActivity = null;
	//用于使屏幕常亮
	 PowerManager powerManager = null;  
	 WakeLock wakeLock = null;
	 
	static {
        System.loadLibrary("game");
	}
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //屏幕常亮
        this.powerManager = (PowerManager)this.getSystemService(Context.POWER_SERVICE); 
        this.wakeLock = this.powerManager.newWakeLock(PowerManager.SCREEN_BRIGHT_WAKE_LOCK, "My Lock");
    }

    @Override
    protected void onResume() {
    	super.onResume();
    	this.wakeLock.acquire();
    }
    
    @Override
    protected void onPause() {
    	super.onPause();
    	this.wakeLock.release();
    }
    
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if(keyCode == KeyEvent.KEYCODE_BACK) { 
        	AlertDialog.Builder builder = new Builder(this);
        	  builder.setMessage("是否退出游戏");
        	  builder.setTitle("退出");
        	  
        	  builder.setPositiveButton("确定", new DialogInterface.OnClickListener() {

        	   @Override
        	   public void onClick(DialogInterface dialog, int which) {
        	    dialog.dismiss();
        	    System.exit(0);
        	   }
        	  });

        	  builder.setNegativeButton("取消", new DialogInterface.OnClickListener() {

        	   @Override
        	   public void onClick(DialogInterface dialog, int which) {
        	    dialog.dismiss();
        	   }
        	  });

        	  builder.create().show();
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }
 
}