package com.mteamapp
{
	import flash.utils.getTimer;

	public class PerformanceTest
	{
		private static var lastTime:uint ;
		
		public static function traceDelay(lable:*='')
		{
			trace((getTimer()-lastTime)+' ********* '+String(lable)+'\t'+getTimer());
			lastTime = getTimer();
		}


		public static function whoCalledMe():String
		{
			try
			{
				throw new Error("StackTrace finder");
			}
			catch(e:Error)
			{
				return e.getStackTrace();
			}
			return 'UNKNOWN';
		}
	}
}