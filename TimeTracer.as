package 
{
	import flash.utils.getTimer;

	public class TimeTracer
	{
		public static function tr(id:*):void
		{
			trace("• "+String(id)+" : "+getTimer());
		}
	}
}