// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

/**version log
 * 1.1 : ios and android detecrion  -  92-12-28
 * 1.2 : Device information functions added. 94-01-27
 * 1.2.1 : appName is added to
 * 
 * 
 */



package
{
	import com.adobe.crypto.MD5;
	
	import dataManager.GlobalStorage;
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Capabilities;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;

	public class DevicePrefrence
	{
		private static var 	fake_not_ios:Boolean = false,
							fake_its_not_tablet:Boolean = false;
		
		/**number are in inches*/
		public static var 	tabletMinimomWidth:Number = 5,
							tabletMinimomHeight:Number = 4;
		
		private static var bigScreen:int = -1 ;
		
		private static const relodDelay:uint = 10000 ;
		
		private static const ranked_sharedObject_id:String = "ranked_id_2",
							cafeBazarSharedObjectId:String="cafeid2",
							myketSharedObjectId:String="myketid3",
							playStoreId:String="playStoreid";
		
		private static var cafeBazarLoader:URLLoader,
							secondCheck_cafe:Boolean = false,
							playStoreLoader:URLLoader,
							secondCheck_play:Boolean = false,
							myketLoader:URLLoader,
							secondCheck_myket:Boolean = false;
							
		private static var androidOtherId:String ;
		
		
		
		/**retuens true if this is big screened tablet*/
		public static function get isTablet():Boolean
		{
			if(fake_its_not_tablet)
			{
				return false;
			}
			if(bigScreen==-1)
			{
				var Width:Number = (Capabilities.screenResolutionX/Capabilities.screenDPI) ;
				var Height:Number = (Capabilities.screenResolutionX/Capabilities.screenDPI) ;
				
				if(Width<tabletMinimomWidth || Height<tabletMinimomHeight)
				{
					bigScreen=0;
				}
				else
				{
					bigScreen = 1; 
				}
			}
			
			return Boolean(bigScreen);
		}

        /**Returns true if the application was landscape*/
        public static function isLandScape():Boolean
        {
            return appDescriptor.toString().indexOf("<aspectRatio>landscape</aspectRatio>")!=-1
        }

        /**Returns true if the application was landscape*/
        public static function isPortrait():Boolean
        {
            return appDescriptor.toString().indexOf("<aspectRatio>portrait</aspectRatio>")!=-1
        }
		
		/**This function calls apple webservice to generate application id to make a download link for*/
		public static function createDownloadLink():void
		{
			if(idCode.data.id == undefined)
			{
				loadToCashAppStoreid();
			}
			else
			{
				trace("The apple id is ready: "+("http://itunes.apple.com/app/id"+idCode.data.id));
			}
			trace("The Android url is : "+"market://details?id=air."+appID);
		//Cafe bazar
			if(idCode.data[cafeBazarSharedObjectId] == undefined)
			{
				loadCafeBazarLink();
			}
			else
			{
				trace("The cafe bazar id is ready: "+downloadLink_cafeBazar);
			}
		//myket
			if(idCode.data[myketSharedObjectId] == undefined)
			{
				loadmyketLink();
			}
			else
			{
				trace("The myket id is ready: "+downloadLink_myketStore);
			}
		//Playstore
			if(idCode.data[playStoreId] == undefined)
			{
				loadPlayStoreLink();
			}
			else
			{
				trace("The playStore id is ready: "+downloadLink_playStore);
			}
		}
		//myket
		private static function loadmyketLink():void
		{
			if(myketLoader)
			{
				try
				{
					myketLoader.close();
				}
				catch(e){};
			}
			myketLoader = new URLLoader();
			myketLoader.addEventListener(Event.COMPLETE,myketContentLoaded);
			myketLoader.addEventListener(IOErrorEvent.IO_ERROR,connectionErrorOnLoadingmyket);
			myketLoader.load(new URLRequest(_downloadLink_myketStore()));
			trace("Control myket for this application .... "+_downloadLink_myketStore());
		}
		
			private static function myketContentLoaded(e:Event):void
			{
				if(String(myketLoader.data).split(appID).length>2)
				{
					idCode.data[myketSharedObjectId] = true ;
					trace("+++++This app is released on myket");
				}
				else
				{
					connectionErrorOnLoadingmyket(null);
				}
			}
			
			private static function connectionErrorOnLoadingmyket(e:*)
			{
				trace("+++++This app is not released on myket");
			}
		//Play store
		private static function loadPlayStoreLink():void
		{
			if(playStoreLoader)
			{
				try
				{
					playStoreLoader.close();
				}
				catch(e){};
			}
			playStoreLoader = new URLLoader();
			playStoreLoader.addEventListener(Event.COMPLETE,playStoreContentLoaded);
			playStoreLoader.addEventListener(IOErrorEvent.IO_ERROR,connectionErrorOnLoadingPlayStore);
			playStoreLoader.load(new URLRequest(_downloadLink_playStore()));
			trace("Control playStore for this application .... "+_downloadLink_playStore());
		}
		
			private static function playStoreContentLoaded(e:Event):void
			{
				trace(">>>>>This app is released on playstore");
				idCode.data[playStoreId] = secondCheck_play ;
			}
			
			private static function connectionErrorOnLoadingPlayStore(e:*)
			{
				if(appCorrectedID!='' && secondCheck_play==false)
				{
					secondCheck_play = true ;
					playStoreLoader.load(new URLRequest(_downloadLink_playStore(true)));
					trace("Control playStore for this application .... "+_downloadLink_playStore(true));
				}
				trace(">>>>>This app is not released on PlayStore");
			}
		//cafe
		private static function loadCafeBazarLink():void
		{
			if(cafeBazarLoader)
			{
				try
				{
					cafeBazarLoader.close();
				}
				catch(e){};
			}
			cafeBazarLoader = new URLLoader();
			cafeBazarLoader.addEventListener(Event.COMPLETE,cafeBazarContentLoaded);
			cafeBazarLoader.addEventListener(IOErrorEvent.IO_ERROR,connectionErrorOnLoadingCafeBazar);
			cafeBazarLoader.load(new URLRequest(_downloadLink_cafeBazar()));
			trace("Control cafe bazar for this application .... "+_downloadLink_cafeBazar());
		}
		
			private static function cafeBazarContentLoaded(e:Event):void
			{
				trace("Cafe bazar loaded");
				/*if(String(cafeBazarLoader.data).split(appID).length>2)
				{*/
				var loadedPage:String = String(cafeBazarLoader.data);
				if(loadedPage.indexOf(appCorrectedID)!=-1 || loadedPage.indexOf(appID)!=-1)
				{
					trace("<<<<Yesss, this app is released on caffe bazar");
					idCode.data[cafeBazarSharedObjectId] = true ;
				}
				else
				{
					trace("<<<<NO CAE BAZAR");
				}
				/*}
				else
				{
					trace("<<<<This app is not released on caffe bazar");
				}*/
			}
		
			protected static function connectionErrorOnLoadingCafeBazar(event:IOErrorEvent):void
			{
				trace("<<<<<<<This app has not published on Caffe Bazar");
			}
		
			private static function loadToCashAppStoreid():void
			{
				if(urlLoader2)
				{
					try
					{
						urlLoader2.close();
					}
					catch(e){};
				}
				urlLoader2 = new URLLoader();
				urlLoader2.addEventListener(Event.COMPLETE,idLoaded);
				urlLoader2.addEventListener(IOErrorEvent.IO_ERROR,loadURLAgain);
				urlLoader2.load(new URLRequest("https://itunes.apple.com/lookup?bundleId="+appID));
				trace("Load apple id : "+urlLoader2);
			}
			
			
			
		////////////////////////////////////
				protected static function idLoaded(event:Event):void
				{
					var info:Object = JSON.parse(urlLoader2.data);
					trace("urlLoader2.data : "+JSON.stringify(info,null,' '));
					if(info.resultCount == 0)
					{
						trace("iOS service bug");
					}
					else
					{
						idCode.data.id = info.results[0].trackId;
						idCode.flush();
						trace("iOS url is ready now");
						trace("The apple id is ready: "+("http://itunes.apple.com/app/id"+idCode.data.id));
					}
				}
			
				/**try to load the id again*/
				private static function loadURLAgain(e:Event):void
				{
					setTimeout(createDownloadLink,relodDelay);
				}
				
					/**Returns iOS download link*/
					public static function get downloadLink_iOS():String
					{
						if(idCode.data.id!=undefined)
						{
							return "http://itunes.apple.com/app/id"+idCode.data.id ;
						}
						return '';
					}
				
					/**Returns the Android download link. but you have to call createDownloadLink() first*/
					public static function get downloadLink_Android():String
					{
						return "market://details?id=air."+appID;
					}
				
					/**Returns the Android download link. but you have to call createDownloadLink() first*/
					public static function get downloadLink_cafeBazar():String
					{
						if(idCode.data[cafeBazarSharedObjectId] != undefined )
						{
							return _downloadLink_cafeBazar();
						}
						return '' ;
					}
					
					/**This will returns the cafe bazar link in any case*/
					private static function _downloadLink_cafeBazar(secondId:Boolean=false):String
					{
						if(secondId)
						{
							return 'https://cafebazaar.ir/app/air.'+appCorrectedID;
						}
						else
						{
							return 'https://cafebazaar.ir/app/air.'+appID;
						}
					}
				
					/**Returns the Android download link. but you have to call createDownloadLink() first*/
					public static function get downloadLink_playStore():String
					{
						if(idCode.data[playStoreId] != undefined )
						{
							return _downloadLink_playStore(idCode.data[playStoreId]);
						}
						return '' ;
					}
					
					/**This will returns the playStore link in any case*/
					private static function _downloadLink_playStore(secondId:Boolean=false):String
					{
						if(secondId)
						{
							return 'https://play.google.com/store/apps/details?id=air.'+appCorrectedID;
						}
						else
						{
							return 'https://play.google.com/store/apps/details?id=air.'+appID;
						}
					}
				
					//myket
					/**Returns the Android download link. but you have to call createDownloadLink() first*/
					public static function get downloadLink_myketStore():String
					{
						if(idCode.data[myketSharedObjectId] != undefined )
						{
							return _downloadLink_myketStore();
						}
						return '' ;
					}
					
					/**This will returns the playStore link in any case*/
					private static function _downloadLink_myketStore(secondId = false):String
					{
						if(secondId)
						{
							return 'https://myket.ir/app/air.'+appCorrectedID;
						}
						else
						{
							return 'https://myket.ir/app/air.'+appID;
						}
					}
		
		/**returns true if it is a pc with ability of quite and etc.<br>
		 * IT HAVE TO COMPLETE ON IOS DEVICES AND MACINTOSH PCS*/
		public static function get isItPC():Boolean
		{
			var os:String = String(Capabilities.os).toLowerCase() ;
			if( os.indexOf('win')!=-1 || os.indexOf('mac')!=-1 )
			{
				return true ;
			}
			else
			{
				return false;
			}
		}
		
		
		/**detecte is it android or not*/
		public static function isAndroid():Boolean
		{
			var os:String = String(Capabilities.os).toLowerCase() ;
			if( os.indexOf('lin')!=-1)
			{
				return true ;
			}
			return false;
		}
		
		
		/**detects if it is an ios device*/
		public static function isIOS():Boolean
		{
			if(fake_not_ios)
			{
				return false;
			}
			var os:String = String(Capabilities.os).toLowerCase() ;
			if( os.indexOf('iph')!=-1)
			{
				return true ;
			}
			return false;
		}
		
		/**this will cause to isIOS function tells that this is not an IOS anyway*/
		public static function itIsNotIOS()
		{
			fake_not_ios = true ;
		}
		
		
	////////////////////////////////////NewFunctions
		private static var cashedApplicationDescriptor:XML ;
		
		private static var cahsedAppName:String ;
		
		/**Returns application's descriptor xml file*/
		public static function get appDescriptor():XML
		{
			if(cashedApplicationDescriptor==null)
			{
				cashedApplicationDescriptor = clearXML(NativeApplication.nativeApplication.applicationDescriptor);
			}
			return cashedApplicationDescriptor ;
		}
		
		
		/**Returns the app id : com.*.* */
		public static function get appID():String
		{
			//return "com.mteamapps.NabatNorooz";
			return NativeApplication.nativeApplication.applicationID ;
		}
		
		/**If the id contains numeric index or -(dash), it will cause problem. so this will returns the id without numeric ids index*/
		public static function get appCorrectedID():String
		{
			if(androidOtherId==null)
			{
				var wrongId:String ;
				if(appID.indexOf('-')!=-1)
				{
					itIsWrong = true ;
					wrongId = appID.split('-').join('_') ;
				}
				else
				{
					wrongId = appID;
				}
				var wrongIdParts:Array = wrongId.split('.');
				var itIsWrong:Boolean = false ;
				for(var i = 0 ; i<wrongIdParts.length ; i++)
				{
					if(String('0123456789').indexOf((wrongIdParts[i] as String).charAt(0))!=-1)
					{
						wrongIdParts[i] = 'A'+wrongIdParts[i] ;
						itIsWrong = true ;
					}
				}
				
				if(itIsWrong)
				{
					androidOtherId = wrongIdParts.join('.');
				}
				else
				{
					androidOtherId = '' ;
				}
			}
			trace("androidOtherId : " +androidOtherId);
			return androidOtherId ;
		}
		
		/**Returns the app name*/
		public static function get appName():String
		{
			if(cahsedAppName==null)
			{
				cahsedAppName = appDescriptor.name ;
			}
			return cahsedAppName ;
		}
		
		/**Returns the application's version string.*/
		public static function get appVersion():String
		{
			return appDescriptor.versionNumber;
		}
		
		/**Removes name spaces from xml*/
		private static function clearXML(str:String):XML
		{
			var i:int = str.indexOf('<');
			i = str.indexOf(' ',i);
			var j:int = str.indexOf('>',i);
			if(!str.indexOf('>')<i)
			{
				str = str.substring(0,i)+str.substring(j);
			}
			
			return XML(str);
		}
		
		/**Returns the publisher id
		 * Test this*/
		public static function get publisherID():String
		{
			return NativeApplication.nativeApplication.publisherID ;
		}
		
		
///////////////////////////////////////////
		
		private static var idCode:SharedObject = SharedObject.getLocal("myIdCode",'/');
		
		private static var onDone:Function,onFaild:Function ;

		private static var 	urlLoader:URLLoader,
							urlLoader2:URLLoader;
		
		/**Open the ranking page for any os*/
		public static function rankThisApp(onCanseled:Function=null,onRedirected:Function=null):void
		{
				onDone = onRedirected ; 
				onFaild = onCanseled ;
			
			
			
			if(DevicePrefrence.isIOS())
			{
				if(idCode.data.id == undefined)
				{
					loadForAppNumericId();
				}
				else
				{
					openItuneStoreFor(idCode.data.id);
				}
			}
			else
			{
				if(onDone!=null)
				{
					onDone();
					onDone = null ;
				}
				navigateToURL(new URLRequest("market://details?id=air."+appID));
				GlobalStorage.save(ranked_sharedObject_id,true);
				trace("The rank url is : "+"market://details?id=air."+appID);
			}
			//https://itunes.apple.com/lookup?bundleId=com.mteamapps.NabatNorooz
		}
		
		private static function loadForAppNumericId(forceToGetId:Boolean=false):void
		{
			
			if(urlLoader)
			{
				try
				{
					urlLoader.close();
				}catch(e){};
			}
			urlLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE,codeLoaded);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,connectionFails);
			urlLoader.load(new URLRequest("https://itunes.apple.com/lookup?bundleId="+appID));
		}
		
		protected static function connectionFails(event:IOErrorEvent):void
		{
			
			if(onFaild!=null)
			{
				onFaild();
				onFaild = null ;
			}
		}
		
		protected static function codeLoaded(event:Event):void
		{
			
			trace('information loaded : '+urlLoader.data);
			var info:Object = JSON.parse(urlLoader.data);
			if(info.resultCount == 0)
			{
				if(onFaild!=null)
				{
					onFaild();
					onFaild = null ;
				}
			}
			else
			{
				idCode.data.id = info.results[0].trackId;
				idCode.flush();
				openItuneStoreFor(info.results[0].trackId);
			}
		}
		
		/**Opening the rank page for this application*/
		private static function openItuneStoreFor(appCodeID:String)
		{
			if(onDone!=null)
			{
				onDone();
				onDone = null ;
			}
			navigateToURL(new URLRequest("http://itunes.apple.com/app/id"+appCodeID));
			
			GlobalStorage.save(ranked_sharedObject_id,true);
		}
		
		/**Returns true if user is ranked to this application befor*/
		public static function isRankedBefor():Boolean
		{
			if(GlobalStorage.load(ranked_sharedObject_id)!=null)
			{
				return true ;
			}
			return false ;
		}
		
		
		///////////////
		public static function openDeveloperPageForIOS():void
		{
			if(DevicePrefrence.isIOS())
			{
				navigateToURL(new URLRequest("https://itunes.apple.com/us/artist/mahnaz-rad/id605676392?uo=4"));
			}
		}
		
		/**Returns true if the application is fullScreen*/
		public static function isFullScreen():Boolean
		{
			return (appDescriptor.toString().indexOf("<fullScreen>true</fullScreen>")!=-1)
		}
		
		
		
	//////////////////////////////////////////////////////
		private static var createdKeyIs:String ;
		private static var uniqueId:String ;
		
		
		/**This function will creates securityKey*/
		private static function createDeviceKeyForMoreSecurity():void
		{
			if(createdKeyIs==null && uniqueId==null)
			{
				var isNativeAdded:Boolean = false ;
				try
				{
					var fPUniqueId:Class = getDefinitionByName("ru.flashpress.uid.FPUniqueId") as Class;
					isNativeAdded = true ;
				}
				catch(e)
				{
					trace("*** To get better security,You can add  ru.flashpress.uid.FPUniqueId  native to your project");
					isNativeAdded = false ;
				}
				if(isNativeAdded)
				{
					uniqueId = (fPUniqueId as Object).id;
					createdKeyIs= '';
				}
				else
				{
					createdKeyIs = appID+Capabilities.cpuArchitecture+Capabilities.manufacturer+Capabilities.screenResolutionX+','+Capabilities.screenResolutionY;
					uniqueId = '' ;
				}	
			}
		}
		
		/**Pass 478239472389 to make it work. (this password created to prevent injection)*/
		public static function DeviceEncryptedKey(passWord:String):String
		{
			trace("***some one needs the DeviceEncryptedKey");
			if(passWord=="478239472389")
			{
				createDeviceKeyForMoreSecurity();
				return MD5.hash(createdKeyIs+uniqueId+'بپ') ;
			}
			return MD5.hash('notmatched'+'بپ');
		}
		
		/**You should have a native code to have this*/
		public static function DeviceUniqueId():String
		{
			createDeviceKeyForMoreSecurity();
			if(uniqueId=='')
			{
				trace("*** To get better security,You can add  ru.flashpress.uid.FPUniqueId  native to your project. get the file from below link:\n\n\thttps://github.com/flashpress/FPUniqueId/\n\nthe xml description:\n\n\t<extensionID>ru.flashpress.FPUniqueId</extensionID>\n\n\n") ;
				return createdKeyIs;
			}
			return uniqueId ;
		}
		
		/**If any problem detected to pare version, it will return Infinty*/
		public static function airVersion():Number
		{
			try
			{
				var version:String = Capabilities.version ;
				var vers:String = version.split(' ')[1];
				var ver:String = vers.split(',')[0];
				return uint(ver);
			}
			catch(e:*)
			{
				trace("Version parsing error : "+e)
			}
			return Infinity ;
		}
	}
}