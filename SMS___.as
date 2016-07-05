// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package 
{
	import com.ssd.ane.AndroidExtensions;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Capabilities;

	public class SMS___
	{
		public static function Send(receverNumber:*,content:*)
		{
			receverNumber = String(receverNumber);
			content = String(content);
			
			var OS:String = Capabilities.os ;
			if(OS.toLocaleLowerCase().indexOf('linu')==-1)
			{
				var str = "sms:"+receverNumber+"?body="+content; 
				var urlReq:URLRequest = new URLRequest(str); 
				navigateToURL(urlReq);
			}
			else
			{
				AndroidExtensions.sendSMS(content,receverNumber);
			}
		}
	}
}