package com.mteamapp
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	[Event(name="complete", type="flash.events.Event")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	public class InternetCheck extends EventDispatcher
	{
		public static var dispatcher:InternetCheck = new InternetCheck() ;
		
		private static var urlLoader:URLLoader ;
		
		public static var controlDomain:String = "https://www.google.com/" ;
		
		public function InternetCheck()
		{
			super();
		}
		
		/**And wait till an error dispatches on dispatcher*/
		public static function controllConnectionNow():void
		{
			removeConnections();
			
			urlLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE,isConnected);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,noConnectionStablieshed);
			urlLoader.load(new URLRequest(controlDomain));
		}
		
		/**remove old listeners*/
		private static function removeConnections():void
		{
			if(urlLoader)
			{
				urlLoader.removeEventListener(Event.COMPLETE,isConnected);
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR,noConnectionStablieshed);
				try
				{
					urlLoader.close();
				}catch(e){};
			}
		}
		
		/**No internet connection stablished*/
		protected static function noConnectionStablieshed(event:IOErrorEvent):void
		{
			trace("No internet connection stablieshed");
			dispatcher.dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
		}
		
		/**Is connectect*/
		protected static function isConnected(event:Event):void
		{
			trace("Connection stablieshed");
			dispatcher.dispatchEvent(new Event(Event.CONNECT));
		}
	}
}