package mteam
{
	import flash.utils.setTimeout;
	import flash.display.MovieClip;
	import flash.events.Event;

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

		private static var funcQue:Array,asyncCallerMC:MovieClip;
		
		private static function setUpAsyncFunctions():void
		{
			if(funcQue==null)
			{
				funcQue = [] ;
				asyncCallerMC = new MovieClip();
				asyncCallerMC.addEventListener(Event.ENTER_FRAME,callNextFunction);
			}
		}

			private static function callNextFunction(e:Event):void
			{
				if(funcQue.length>0)
				{
					funcQue.shift()();
				}
			}

		public static function callAsyncOnFrame(...functionSlist):void
		{
			setUpAsyncFunctions();
			funcQue = funcQue.concat(functionSlist);
		}
		
	}
}