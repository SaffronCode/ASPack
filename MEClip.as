// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package {
	import flash.display.MovieClip;

	public class MEClip extends MovieClip
	{
		private var Listeners:Array = new Array();
		private var Func:Array = new Array();
		public function MEClip(){
			
		}
		public function MEListener(yourEvent,yourFunction:Function){
			Listeners.push(yourEvent)
			Func.push(yourFunction)
			this.addEventListener(yourEvent,yourFunction)
		}
		public function MERemoveThis(){
			for(var i=0;i<Listeners.length;i++){
				if(this.hasEventListener(Listeners[i])){
					this.removeEventListener(Listeners[i],Func[i])
				}
				this.parent.removeChild(this)
			}
		}
		public function MERemoveListener(yourListener){
			for(var i=0;i<Listeners.length;i++){
				if(Listeners[i]==yourListener&&this.hasEventListener(Listeners[i])){
					this.removeEventListener(Listeners[i],Func[i])
				}
			}
		}
	}
}