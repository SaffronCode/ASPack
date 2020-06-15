package com.mteamapp
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class VersionController
	{
		/*private static var onDone:Function,
							onFaild:Function;*/
							
		/*private static var currentVersion:String;

		private static var versionControll:URLLoader;*/
		
		private static var lastData:SharedObject = SharedObject.getLocal('versionControll','/');
		
		/**Hint text*/
		public static var hintText:String ;
		/**App store url*/
		public static var appStoreURL:String ;
		
		/**You can receive the hint text as the first parameter for thisIsOldVersion function and application download URL based on your OD on the second input parameter.*/
		public static function controllVersion(currectVersion:Function,thisIsOldVersion:Function,versionURL:URLRequest,appVersion:String=null,controllEveryApplicationOpenning:Boolean=false)
		{
			var onDone:Function = currectVersion ;
			var onFaild:Function = thisIsOldVersion ;
			
			if(appVersion==null)
				appVersion = DevicePrefrence.appVersion;
			
			var currentVersion:String = appVersion ;
			
			var versionControll:URLLoader = new URLLoader();
			versionControll.addEventListener(Event.COMPLETE,onVersinoStringReceved);
			versionControll.addEventListener(IOErrorEvent.IO_ERROR,noConnection);
			versionControll.load(versionURL);
			SaffronLogger.log("Load this : "+versionURL.url);
			
			if(controllEveryApplicationOpenning)
			{
				NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE,function(e)
					{
						versionControll.load(versionURL);
					}
				);
			}
			
			/**xml sample :<br>
			 * <version>
			 <id>1.7.2</id>
			 <text>نسخه ی 2 همکنون آماده ی دانلود می باشد</text>
			 <url_ios>http://www.apple.com</url_ios>
			 <url_android>http://www.google.com</url_android>
			 </version>*/
			function onVersinoStringReceved(event:Event):void
			{
				
				SaffronLogger.log("XML is receved");
				var xmlController:XML = new XML();
				try
				{
					xmlController = XML(versionControll.data);
				}
				catch(e)
				{
					onDone();
					SaffronLogger.log("xml version controller is crash");
					return ;
				}
				lastData.data["version"+versionURL] = versionControll.data ;
				lastData.flush();
				
				controllCashedDatas();
			}
			
			function controllCashedDatas():void
			{
				
				var xmlController:XML ;
				
				if(lastData.data["version"+versionURL] == undefined)
				{
					onDone();
					return ;
				}
				
				try
				{
					xmlController = XML(lastData.data["version"+versionURL] );
				}
				catch(e)
				{
					onDone();
					return ;
				}
				var serverVersion:String = xmlController.id ;
				var currentVersion2:String = currentVersion ;
				
				var serVerArr:Array = serverVersion.split('.');
				var appVerArr:Array = currentVersion.split('.');
				
				if(serVerArr.length>2)
				{
					serverVersion = serVerArr[0]+'.'+TimeToString.numToString(serVerArr[1],5); 
				}
				if(appVerArr.length>2)
				{
					currentVersion2 = appVerArr[0]+'.'+TimeToString.numToString(appVerArr[1],5); 
				}
				
				SaffronLogger.log("Controll version : "+serverVersion+" vs "+currentVersion2);
				
				var myNumbericVersion:Number = Number(currentVersion2);
				var serverNumericVersion:Number = Number(serverVersion);
				
				if(((isNaN(serverNumericVersion) || isNaN(myNumbericVersion)) &&  serverVersion == currentVersion2) || myNumbericVersion>=serverNumericVersion )
				{
					onDone();
				}
				else
				{
					var storeURL:String ;
					if(DevicePrefrence.isIOS())
					{
						storeURL = xmlController.url_ios ;
					}
					else
					{
						storeURL = xmlController.url_android ;
					}
					hintText = xmlController.text ;
					appStoreURL = storeURL ;
					if(onFaild.length==1)
					{
						onFaild(hintText);
					}
					else if(hintText.length>1)
					{
						onFaild(hintText,appStoreURL);
					}
					else
					{
						onFaild();
					}
				}
			}
			
			function noConnection(event:IOErrorEvent):void
			{
				SaffronLogger.log("No connection stablished");
				
				controllCashedDatas();
			}
		}
		
	}
}