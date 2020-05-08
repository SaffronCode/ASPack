package mteam
{
	import flash.utils.setTimeout;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.Dictionary;

	public class FuncManager
	{
		private static var asyncFunctionsId:Array = [],
							asyncDelay:uint = 30 ;

		/**function caller*/
		public static function callFunction(myFunc:Function,...params):void
		{
			var cash:Function = myFunc;
			if(cash!=null)
			{
				if(cash.length>0)
					cash.apply(params);
				else
					cash();
			}
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



	//////////////////////////////////

		private static var functList:Dictionary ;

		public static function addFuncToList(func:Function,functionId:uint):void
		{
			if(functList==null)
			{
				functList = new Dictionary() ;
			}
			if(functList[functionId]==undefined)
			{
				functList[functionId] = [] ;
			}
			if(functList[functionId].indexOf(func)==-1)
			{
				functList[functionId].push(func);
			}
		}

		public static function callFuncList(functionId:uint):void
		{
			if(functList!=null && functList[functionId]!=undefined && functList[functionId] is Array)
			{
				var cashedFunctList:Array = functList[functionId].concat();
				functList[functionId] = [] ;

				for(var i:int = 0 ; i<cashedFunctList.length ; i++)
				{
					cashedFunctList[i]();
				}
			}
		}
		
	}
}