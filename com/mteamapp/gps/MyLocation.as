package com.mteamapp.gps
{
	import com.mteamapp.StringFunctions;
	import flash.events.GeolocationEvent;
	import flash.events.PermissionEvent;
	import flash.permissions.PermissionStatus;
	import flash.sensors.Geolocation;
	import flash.utils.getDefinitionByName;
	
	public class MyLocation
	{
		private static const roundLevel:uint = 100000;
		
		public static var GPSLatitude:Number = 0, GPSLongitude:Number = 0
		
		public static var geo:Geolocation;
		
		/**This will returns the round number for gps Longitude*/
		public static function get GPSLongitudeRound():Number
		{
			return Math.round(GPSLongitude * roundLevel) / roundLevel;
		}
		
		/**This will returns the round number for gps latitude*/
		public static function get GPSLatitudeRound():Number
		{
			return Math.round(GPSLatitude * roundLevel) / roundLevel;
		}
		
		/**com.distriqt.extension.location.Location*/
		private static var distriqtLocationClass:Class;
		
		public static function start(distriqtCode:String = null, DebugGPS:Boolean = false):void
		{
			if (DebugGPS && DevicePrefrence.isItPC)
			{
				GPSLatitude = 35.7137559;
				GPSLongitude = 51.4149215;
			}
			if (geo == null)
			{
				trace("*************** Geo created**********");
				recreateGeo()
				
				try
				{
					distriqtLocationClass = getDefinitionByName("com.distriqt.extension.location.Location") as Class;
				}
				catch (e)
				{
					distriqtLocationClass = null;
				}
				;
				
				if (distriqtCode != null)
				{
					trace("\n\n*****************************\n\n\nIf you whant to use distriqt location abilities, you should add below ane files to your project:" + "\t<extensionID>com.distriqt.Core</extensionID>" + "\t<extensionID>com.distriqt.androidsupport.V4</extensionID>" + 
					//"\t<extensionID>com.distriqt.androidsupport.AppCompatV7</extensionID>"+
					//"\t<extensionID>com.distriqt.androidsupport.CustomTabs</extensionID>"+
					"\t<extensionID>com.distriqt.playservices.Base</extensionID>" + "\t<extensionID>com.distriqt.playservices.Location</extensionID>" + "\t<extensionID>com.distriqt.Location</extensionID>\n\n\n*****************************\n\n\n");
					//controllPermission();
					if (distriqtLocationClass != null)
					{
						(distriqtLocationClass as Object).init(distriqtCode)
					}
				}
				else
				{
					controllDefaultPermission();
					distriqtLocationClass = null;
				}
			}
		}
		
		/**Re create geoLocation class and its listeners*/
		public static function recreateGeo():void
		{
			geo = new Geolocation();
			if (DevicePrefrence.isIOS())
			{
				geo.requestPermission(); //this would request for WHEN_IN_USE permission
				//geo.locationAlwaysUsePermission=true; //applicable for iOS11
				//geo.requestPermission(); //this would request for WHEN_IN_USE and ALWAYS permission
				getLoacationCreated();
			}
			else
			{
				if (Geolocation.permissionStatus != PermissionStatus.GRANTED)
				{
					geo.addEventListener(PermissionEvent.PERMISSION_STATUS, function(e:PermissionEvent):void
					{
						if (e.status == PermissionStatus.GRANTED)
						{
							getLoacationCreated();
						}
						else
						{
							// permission denied
						}
					});
					
					try
					{
						geo.requestPermission();
					}
					catch (e:Error)
					{
						// another request is in progress
					}
				}
				else
				{
					getLoacationCreated();
				}
			}
			function getLoacationCreated():void
			{
				
				geo.addEventListener(GeolocationEvent.UPDATE, iGotGeo);
			}
		}
		
		private static function controllDefaultPermission():void
		{
			if (DevicePrefrence.isItPC)
			{
				var myManifest:String = DevicePrefrence.appDescriptor.toString();
				myManifest = StringFunctions.clearSpacesAndTabs(myManifest);
				
				var iosManifest:String = "<key>NSLocationAlwaysUsageDescription</key>\n\t<string>The application needs your location</string>\n<key>NSLocationWhenInUseUsageDescription</key>\n\t<string>The application needs your location</string>"
				var manifest2:String = '<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>';
				var manifest3:String = '<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>';
				
				if (myManifest.indexOf(StringFunctions.clearSpacesAndTabs(manifest2)) == -1 || myManifest.indexOf(StringFunctions.clearSpacesAndTabs(manifest3)) == -1)
				{
					trace( "You have to add below permisions on the Android manifest:\n\n\t" + manifest2 + '\n\t' + manifest3 + '\n\n');
				}
				if (myManifest.indexOf(StringFunctions.clearSpacesAndTabs(iosManifest)) == -1)
				{
					trace( "Add below permition to <InfoAdditions> tag for iOS versions\n\n\n" + iosManifest + '\n\n\n');
				}
			}
		}
		
		private static function controllPermission():void
		{
			var myManifest:String = DevicePrefrence.appDescriptor.toString();
			myManifest = StringFunctions.clearSpacesAndTabs(myManifest);
			
			var manifest1:String = '<uses-permission android:name="android.permission.INTERNET"/>';
			var manifest2:String = '<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>';
			var manifest3:String = '<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>';
			
			var AndroidlocationManifest:String = '<meta-data android:name="com.google.android.gms.version" android:value="@integer/google_play_services_version" />' + '<receiver android:name="com.distriqt.extension.location.receivers.GeofenceTransitionReceiver">' + '	<intent-filter>' + '		<action android:name="air.com.distriqt.test.GEOFENCE_TRANSITION_ACTION" />' + '	</intent-filter>' + '</receiver>' + '<receiver android:name="com.distriqt.extension.location.receivers.LocationReceiver" >' + '	<intent-filter>' + '		<action android:name="air.com.distriqt.test.LOCATION_UPDATE" />' + '	</intent-filter>' + '</receiver>' + '<activity android:name="com.distriqt.extension.location.permissions.AuthorisationActivity" android:theme="@android:style/Theme.Translucent.NoTitleBar" />';
			
			var AndroidLocationManifestWithoutSpace:String = StringFunctions.clearSpacesAndTabs(AndroidlocationManifest);
			
			var erros:String = '';
			trace('myManifest :', XML(myManifest))
			if (myManifest.indexOf(StringFunctions.clearSpacesAndTabs(manifest1)) == -1 || myManifest.indexOf(StringFunctions.clearSpacesAndTabs(manifest2)) == -1 || myManifest.indexOf(StringFunctions.clearSpacesAndTabs(manifest3)) == -1)
			{
				trace( "You have to add below permisions on the Android manifest:\n\n\t" + manifest1 + '\n\t' + manifest2 + '\n\t' + manifest3 + '\n\n');
			}
			else if (myManifest.indexOf(AndroidLocationManifestWithoutSpace) == -1)
			{
				trace( "You have to add below permision on the Android manifest on tag <application>:\n\n" + AndroidlocationManifest);
			}
			
			var iosManifest:String = '	<key>UIRequiredDeviceCapabilities</key>' + '<array>' + '	<string>location-services</string>' + '</array>';
			
			var iosClearManifest:String = StringFunctions.clearSpacesAndTabs(iosManifest);
			if (myManifest.indexOf(iosClearManifest) == -1)
			{
				trace( "You have to add below manifest for iOS to make it able to use distriqt functions:\n\n" + iosManifest);
			}
		}
		
		/**Returns true if location setting is supported*/
		public static function openLocationSetting():Boolean
		{
			if (isProfesionalLocationSupports())
			{
				(distriqtLocationClass as Object).service.displayLocationSettings();
				return true;
			}
			return false;
		}
		
		/**Returns true if distriqt is supported*/
		public static function isProfesionalLocationSupports():Boolean
		{
			if (distriqtLocationClass != null && (distriqtLocationClass as Object).isSupported)
			{
				return true;
			}
			return false;
		}
		
		private static function iGotGeo(e:GeolocationEvent):void
		{
			trace("*******Geo updated********");
			GPSLatitude = e.latitude;
			GPSLongitude = e.longitude;
		}
		
		public static function calculateDistance(Latitude:String, Longitude:String):Number
		{
			//TODO Complete the distance
			return Math.sqrt(Math.pow(Number(Latitude) - GPSLatitudeRound, 2) + Math.pow(Number(Longitude) - GPSLongitudeRound, 2));
		}
		
		/**Returns true if the geo location service is on*/
		public static function isOn():Boolean
		{
			return GPSLatitude != 0 || GPSLongitude != 0;
		}
	}
}