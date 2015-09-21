// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package 
{
	import flash.geom.Point;

	public class SearchOnString
	{
		private static var 	arabicChars:String = 'ًٌٍَُِّْٰٜٕٖۣٞٝٓٔٗ٘ٙٚٛؕؔؓؐؑؒۖۘۗۙۚۛۜۢ‌ـ?',
							arabicSames:Array = ['ؤو','11','22','33','44','55','66','77','88','99','00','ييیىئ','اإأآ?','کك'],
							arabicWord:String = 'والي';
		
		
		/**returns true if there was to many arabic signes there<br>
		 * if the number of arabic sign was less than 1/4 , this function detect that the str is not arabic*/
		public static function isArabic(str:String)
		{
			var reg:RegExp = new RegExp('['+arabicChars+']','g');
			var founced:uint = 0 ;
			var L:uint = Math.min(50,str.length) ;
			
			var searchResult:Object = reg.exec(str);
			while(searchResult!=null && reg.lastIndex<L)
			{
				founced++ ;
				searchResult = reg.exec(str);
			}
			if(founced>L/4)
			{
				return true ;
			}
			else
			{
				return false ;
			}
		}
		
		/**it will returns list of points that shows index and ofsset of each word founded*/
		public static function search(str:String,searchedWord:String,fineAll:Boolean = true,arabic:Boolean=false, arabic2:Boolean=false):Vector.<Point>
		{
			var founded:Vector.<Point> = new Vector.<Point>();
			if(str == '' || str == ' ')
			{
				return founded ;
			}
			if(arabic)
			{
				//arabic search has problems
				var regularEx:String = '' ;
				var L:int = searchedWord.length ;
				var arabChars:String = arabicChars ;
				if(arabic2)
				{
					arabChars+= arabicWord ;
				}
				for(var i = 0 ; i<L ; i++)
				{
					var char:String = searchedWord.charAt(i); 
					for(var j = 0 ; j<arabicSames.length ; j++)
					{
						if(arabicSames[j].indexOf(char)!=-1)
						{
							char = '['+arabicSames[j]+']' ;
							break ;
						}
					}
					regularEx += char;
					if(i<L-1)
					{
						regularEx+='['+arabChars+']*';
					}
				}
				var reg:RegExp = new RegExp(regularEx,'g');
				var searchResult:Object = reg.exec(str);
				while(searchResult!=null)
				{
					founded.push(new Point(searchResult.index,reg.lastIndex));
					searchResult = reg.exec(str);
					if(!fineAll)
					{
						break ;
					}
				}
			}
			else
			{
				var f:int=-1 ;
				while((f=str.indexOf(searchedWord,f+1))!=-1)
				{
					founded.push(new Point(f,f+searchedWord.length));
					if(!fineAll)
					{
						break ;
					}
				}
			}
			
			return founded ;
		}
	}
}