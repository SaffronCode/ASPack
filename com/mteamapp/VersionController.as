package com.mteamapp
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class VersionController
	{
		private static var onDone:Function,
							onFaild:Function;
							
		private static var currentVersion:String;

		private static var versionControll:URLLoader;
		
		private static var lastData:SharedObject = SharedObject.getLocal('versionControll','/');
		
		/**Hint text*/
		public static var hintText:String ;
		/**App store url*/
		public static var appStoreURL:String ;
		
		public static function controllVersion(currectVersion:Function,thisIsOldVersion:Function,versionURL:URLRequest,appVersion:String)
		{
			onDone = currectVersion ;
			onFaild = thisIsOldVersion ;
			
			currentVersion = appVersion ;
			
			versionControll = new URLLoader();
			versionControll.addEventListener(Event.COMPLETE,onVersinoStringReceved);
			versionControll.addEventListener(IOErrorEvent.IO_ERROR,noConnection);
			versionControll.load(versionURL);
			trace("Load this : "+versionURL.url);
		}
		
		/**xml sample :<br>
		 * <version>
				<id>1.7.2</id>
				<text>نسخه ی 2 همکنون آماده ی دانلود می باشد</text>
				<url_ios>http://www.apple.com</url_ios>
				<url_android>http://www.google.com</url_android>
			</version>*/
		protected static function onVersinoStringReceved(event:Event):void
		{
			// TODO Auto-generated method stub
			trace("XML is receved");
			var xmlController:XML = new XML();
			try
			{
				xmlController = XML(versionControll.data);
			}
			catch(e)
			{
				onDone();
				trace("xml version controller is crash");
				return ;
			}
			lastData.data.version = versionControll.data ;
			lastData.flush();
			
			controllCashedDatas();
		}
		
		private static function controllCashedDatas():void
		{
			// TODO Auto Generated method stub
			var xmlController:XML ;
			
			if(lastData.data.version == undefined)
			{
				onDone();
				return ;
			}
			
			try
			{
				xmlController = XML(lastData.data.version);
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
			
			trace("Controll version : "+serverVersion+" vs "+currentVersion2);
			
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
				onFaild(/*hintText,appStoreURL*/);
			}
		}
		
		protected static function noConnection(event:IOErrorEvent):void
		{
			trace("No connection stablished");
			// TODO Auto-generated method stub
			controllCashedDatas();
		}
		
	}
}