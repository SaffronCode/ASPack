package mteam
{
	public class FuncManager
	{
		/**function caller*/
		public static function callFunction(myFunc:Function)
		{
			var cash:Function = myFunc
		}
		
		/**create funtion and auto insert these args into it*/
		public static function create(handler:Function,args:*):Function
		{
			return function(...innerArgs):void
			{
				handler.apply(this,[args]);
			}
		}
	}
}