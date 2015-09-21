// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************
/**varsion log 1.1
 * version 1.2 : dispatch events changed to controll if file is not exists
 * varsion 1.3 : 11/19/2014 events problem resolved
 * varsion 1.4 : 11/23/2014 new function added forgetWithDilay() to delete downloaded files when it loads from difrent users
 * 				duplicate file controller accuricy improved
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 * */
package com.mteamapp.downloadManager
{
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import flash.utils.Timer;

	public class DownloadManager
	{
		/**all events will dispatch here*/
		public static var contentLoaderInfo:DownLoadManagerDispatcher = new DownLoadManagerDispatcher();
		
		/**list of available download stream files*/
		private static var downloadList:Vector.<CashedDownloadData> ;

		private static var reservedURLs:Array;

		private static var deleteTimer:Timer;
		
		
		public static var autoReload:Boolean = true;
		
		
		/***start to download this file , check the correction of target , because this 
		 * class will not ever drop downloading , it will try and try and try till download completed*/
		public static function download(urlTarget:String):void
		{
			if(downloadList == null)
			{
				downloadList = new Vector.<CashedDownloadData>();
			}
			
			var oldFile:Boolean = false;
			for(var i:uint = 0 ; i<downloadList.length ; i++)
			{
				if(downloadList[i].myURL == urlTarget)
				{
					downloadList[i].resume();
					oldFile = true ;
					break ;
				}
			}
			if(!oldFile)
			{
				trace('file is new');
				var downlaodCatcher:CashedDownloadData = new CashedDownloadData();
				downloadList.push(downlaodCatcher);
				downlaodCatcher.addEventListener(DownloadManagerEvents.DOWNLOAD_PROGRESS,manageProgress);
				downlaodCatcher.addEventListener(DownloadManagerEvents.DOWNLOAD_COMPLETE,manageFinished);
				downlaodCatcher.addEventListener(DownloadManagerEvents.URL_IS_NOT_EXISTS,manageWrongURLs);
				downlaodCatcher.addEventListener(DownloadManagerEvents.NO_INTERNET_CONNECTION_AVAILABLE,manageWrongURLs);
				downlaodCatcher.setUp(urlTarget);
			}
			else
			{
				trace("file was downloading");
			}
		}
		
		
		/**stop the downloader for this file*/
		public static function stopDwonload(urlTarget:String):void
		{
			if(downloadList != null)
			{
				for(var i:uint = 0 ; i<downloadList.length ; i++)
				{
					if(downloadList[i].myURL == urlTarget)
					{
						downloadList[i].stop();
					}
				}
			}
		}
		
		
		
		public static function forgetWithDilay(urlTarget:String):void
		{
			if(reservedURLs == null)
			{
				reservedURLs = [] ;
			}
			reservedURLs.push(urlTarget);
			if(deleteTimer!=null)
			{
				deleteTimer.stop();
			}
			deleteTimer = new Timer(100,1) ;
			deleteTimer.addEventListener(TimerEvent.TIMER_COMPLETE,deleteReservedURLs) ;
			deleteTimer.start() ;
		}
		
		/**forget all reserved urls*/
		protected static function deleteReservedURLs(event:TimerEvent):void
		{
			// TODO Auto-generated method stub
			for(var i:int = 0 ; i<reservedURLs.length ; i++)
			{
				forget(reservedURLs[i]);
			}
			reservedURLs = [] ;
		}		
		
		/**forget the downloaded file*/
		public static function forget(urlTarget:String):void
		{
			
			if(downloadList!=null)
			{
				for(var i:uint = 0 ; i<downloadList.length ; i++)
				{
					if(downloadList[i].myURL == urlTarget)
					{
						downloadList[i].forget();
						downloadList.splice(i,1);
					}
				}
			}
			else
			{
				var closer:CashedDownloadData = new CashedDownloadData();
				//closer.setUp(urlTarget);
				closer.forget(urlTarget);
				closer = null ;
			}
		}
		
		/**forget the downloaded file*/
		public static function forgetAll():void
		{
			if(downloadList!=null)
			{
				for(var i:uint = 0 ; i<downloadList.length ; i++)
				{
					downloadList[i].forget();
				}
				downloadList = new Vector.<CashedDownloadData>();
			}
			else
			{
				var closer:CashedDownloadData = new CashedDownloadData();
				closer.forgetAll();
				closer = null ;
			}
		}
		
		
		
		
		
		
		
		/**send feed back of any rpogress*/
		private static function manageProgress(e:DownloadManagerEvents):void
		{
			//trace('loading ... ');
			contentLoaderInfo.dispatchEvent(new DownloadManagerEvents(DownloadManagerEvents.DOWNLOAD_PROGRESS,e.precent,null,e.urlID));
		}
		
		
		/**send feed back of any download finishing*/
		private static function manageFinished(e:DownloadManagerEvents):void
		{
			//trace('load finished');
			contentLoaderInfo.dispatchEvent(new DownloadManagerEvents(DownloadManagerEvents.DOWNLOAD_COMPLETE,e.precent,e.loadedFile,e.urlID));
		}
		
		
		/**send feed back of any download finishing*/
		private static function manageWrongURLs(e:DownloadManagerEvents):void
		{
			trace('file url is wrong : '+e.urlID);
			forget(e.urlID);
			contentLoaderInfo.dispatchEvent(new DownloadManagerEvents(DownloadManagerEvents.URL_IS_NOT_EXISTS,0,null,e.urlID));
		}	
		
	}
}