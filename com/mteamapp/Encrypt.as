package com.mteamapp
{
	import restDoaService.RestDoaServiceCaller;

	public class Encrypt
	{
		public static function encrypt(text:String,key:String,revert:Boolean=false):String
		{RestDoaServiceCaller
			if(text===null)
				return '' ;
			var newText:String = '' ;
			for(var i:uint = 0 ; i<text.length ; i++)
			{
				newText += String.fromCharCode(text.charCodeAt(i)+(revert?key.charCodeAt(Math.abs(key.length-i)%key.length):key.charCodeAt(i%key.length)));
			}
			return newText ;
		}
		
		public static function decrypt(text:String,key:String,revert:Boolean=false):String
		{
			if(text==null)
				return '' ;
			var newText:String = '' ;
			for(var i:Number = 0 ; i<text.length ; i++)
			{
				newText += String.fromCharCode(text.charCodeAt(i)-(revert?key.charCodeAt(Math.abs(key.length-i)%key.length):key.charCodeAt(i%key.length)));
			}
			return newText ;
		}
	}
}