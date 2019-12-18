package mteam
{
	import flash.utils.setTimeout;

	public class FuncManager
	{
		private static var asyncFunctionsId:Array = [],
							asyncDelay:uint = 30 ;

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


		public static function callAsync(...functionSlist):uint
		{
			var asyncIndex:uint = asyncFunctionsId.length ;
			var calledFunctionIndex:uint = 0 ;
			functionCaller();
			function functionCaller():void
			{
				functionSlist[calledFunctionIndex]();
				calledFunctionIndex++;
				if(functionSlist.length>calledFunctionIndex)
				{
					asyncFunctionsId[asyncIndex] = setTimeout(functionCaller,asyncDelay);
				}
			}
			return asyncIndex ;
		}
	}
}