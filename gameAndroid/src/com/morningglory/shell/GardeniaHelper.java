package com.morningglory.shell;

import java.io.File;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.AlertDialog.Builder;
import android.content.Context;
import android.content.DialogInterface;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Environment;
import android.os.Handler;

public class GardeniaHelper {
	private static BaseActivity mAcitivity = null;
	private static Handler handler = new Handler();
	private static Builder mAlertDialog = null;
	
	public static void init(BaseActivity activity){
		mAcitivity = activity;
	}
	
	public static BaseActivity getActivity(){
		return mAcitivity;
	}

	public static String getExtStoragePath(){
		String result = "";
		File sdDir = null; 
		boolean sdCardExist = Environment.getExternalStorageState()
		.equals(android.os.Environment.MEDIA_MOUNTED);
		if (sdCardExist) 
		{
			sdDir = Environment.getExternalStorageDirectory();
			result = sdDir.toString() + "/lyzt/";
		}
		else
		{
			Context context = GameApplication.getContext();
			result = "/data/data/" + context.getPackageName();
		}
		
		return result;
	}
	
	public static String getVersion(){
		String version = "";
		
		if (mAcitivity != null){
			try {
				version = mAcitivity.getPackageManager().getPackageInfo(mAcitivity.getPackageName(), 0).versionName;
			} catch (NameNotFoundException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		return version;
	}
	
	public static void updateClient(String url, String newVersion, boolean bForce){
		if (url != null && newVersion != null)
		{
			
		}
	}
	
	public static void showExitDialog(){
		Runnable mRunnable = new Runnable() {
			public void run() {
				processExit();
            }
		};
		
        handler.post(mRunnable);
    }
	
	private static void processExit(){
		if (mAcitivity != null){
			if (mAlertDialog == null){
				mAlertDialog = new AlertDialog.Builder(mAcitivity)
		        .setTitle("提示")
		        .setMessage("确定要退出吗？")
		        .setPositiveButton("确定", new DialogInterface.OnClickListener() {
		            @Override
		            public void onClick(DialogInterface dialog, int which) {
		            	dialog.dismiss();
		                mAcitivity.finish();
		                System.exit(0);
		            }
		        })
		        .setNegativeButton("取消", new DialogInterface.OnClickListener() {
		            @Override
		            public void onClick(DialogInterface dialog, int which) {

		                dialog.dismiss();
		            }
		        });
			}
	        
			mAlertDialog.show();
		}
	}
}
