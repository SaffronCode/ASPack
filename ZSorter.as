// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************


package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class ZSorter {

		
		public static function sort(target:MovieClip){
			var chi
			var sorter:Array = new Array()
			for(var i=target.numChildren-1 ; i>=0 ; i--){
				chi = target.getChildAt(i)
				sorter[i] = (chi.y)
			}
			for(i=0;i<sorter.length;i++){
				for(var j=i;j<sorter.length;j++){
					if(sorter[j-1]>sorter[j]){
						swip(sorter,j)
						target.swapChildrenAt(j-1,j)
					}
				}
			}
		}
		private static function swip(arr:Array , I:int){
			var komaki = arr[I-1]
			arr[I-1] = arr[I]
			arr[I] = komaki
		}
		
		
		/**this class will automaticly sort all children of this target at each frame*/
		public static function autoSort(target:MovieClip)
		{
			target.addEventListener(Event.ENTER_FRAME,auto);
			target.addEventListener(Event.REMOVED_FROM_STAGE,unLoaded);
		}
		
		/**on enter frame*/
		private static function auto(e:Event)
		{
			sort((e.target as MovieClip));
		}
		/**automatic target is unloaded*/
		private static function unLoaded(e:Event)
		{
			e.target.remoevEventListener(Event.ENTER_FRAME,auto);
			e.target.remoevEventListener(Event.REMOVED_FROM_STAGE,unLoaded);
		}

	}
	
}
