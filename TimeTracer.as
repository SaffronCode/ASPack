package 
{
	import contents.alert.Alert;
	
	import flash.utils.getTimer;

	public class TimeTracer
	{
		private static var lastTime:Number ;
		public static function tr(id:*,useAlert:Boolean=false):void
		{
			var str:String = ("• "+String(id)+" : "+getTimer()+" > delay : "+(getTimer()-lastTime));
			if(useAlert)
			{
				Alert.show(str);
			}
			else
			{
				SaffronLogger.log(str);
			}
			lastTime = getTimer();
		}
	}
}