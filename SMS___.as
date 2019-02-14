// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package 
{
	//import com.ssd.ane.AndroidExtensions;
	import flash.utils.getDefinitionByName;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Capabilities;


	public class SMS___
	{
		
		private static var AndroidExtensionsClass:Class ;
		private static var urlReq:URLRequest;
		private static var str;
		
		public static function Send(receverNumber:*,content:*)
		{
			receverNumber = String(receverNumber);
			content = String(content);
			
			try
			{
				AndroidExtensionsClass = getDefinitionByName("com.ssd.ane.AndroidExtensions") as Class ;
			}
			catch (e){
				AndroidExtensionsClass = null ;
			}
			
			var OS:String = Capabilities.os ;
			if (AndroidExtensionsClass)
			{
				(AndroidExtensionsClass as Object).sendSMS(content,receverNumber);
			}
			if(DevicePrefrence.isAndroid())
			{
				str = "sms:"+receverNumber+"?body="+content; 
				urlReq = new URLRequest(str); 
				navigateToURL(urlReq);
			}
			else
			{
				str = "sms:"+receverNumber+"&body="+content; 
				urlReq = new URLRequest(str); 
				navigateToURL(urlReq);
			}
		}
	}
}