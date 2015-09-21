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
	import flash.events.MouseEvent;
	
	
	/**estart()
	 */
	public class scroll_mc extends MovieClip {
		public static var SCROLL_START_EV:String='scrolled';
		public static var SCROLL_STOP_EV:String='scrollStoped';
		public static var SCROLLING_EV:String='isScrolling';
		
		/**it will be true if the scroller is locked*/
		private var isLocked:Boolean = false;
		
		private var DeltaD=10;
		private var V=0;
		private var F=10;
		private var mu = 0.6;
		private var Yn;
		private var mV = 0;
		private var mF=false
		private var lastMY,lastMX
		private var target
		private var ev1:Event = new Event(SCROLL_START_EV,true);
		private var ev2:Event = new Event(SCROLL_STOP_EV,true);
		private var ev3:Event = new Event(SCROLLING_EV,true);
		private var LRF:Boolean = false;
		private var movingFlag:Boolean = false;
		private var LTRF:Boolean = false;
		private var upBTN,dnBTN;
		
		private var sMC:MovieClip,suMC:MovieClip,sdMC:MovieClip;
		
		public function scroll_mc(W=null,H=null,animF:Number=-1,animMu:Number=-1) {
			if(animF!=-1)
			{
				F = animF ;
			}
			if(animMu!=-1)
			{
				mu = animMu ;
			}
			if(W!=null){
				this.width = W
			}
			if(H!=null){
				this.height = H
			}
			
			sMC = Obj.get('s',this);
			suMC = Obj.get('su',this);
			sdMC = Obj.get('sd',this);
			
			this.sMC.alpha = this.suMC.alpha = this.sdMC.alpha = 1;
			this.suMC.scaleX = 1/this.scaleX;
			this.suMC.scaleY = 1/this.scaleY;
			
			this.sdMC.scaleX = 1/this.scaleX;
			this.sdMC.scaleY = 1/this.scaleY;
			
			suMC.x = 0;
			suMC.y = 0;
			suMC.width = sMC.width;
			//this.y+=su.height*this.scaleY;
			
			sMC.height-=(suMC.height+sdMC.height);
			sdMC.x = 0;
			sdMC.width = sMC.width;
			
			suMC.y += suMC.height
			sMC.y += suMC.height;
			sdMC.y += suMC.height;
			
			sdMC.y = sMC.height+sMC.y;
			
			this.visible = false;
		}
		
		/**it will lock the scroller
		 * <br>unlock it with unlock() funciton */
		public function lock()
		{
			Yn = target.y;
			V=0;
			isLocked = true ;
		}
		
		/**unlock the locked scroller<br>lock it with lock() function */
		public function unlock()
		{
			isLocked = false;
		}
		
		public function paiin(e){
			if(isLocked)
			{
				return ;
			}
			dispatchEvent(ev3);
			Yn-=100;
			if(Yn>this.y){
				Yn = this.y;
			}else if(Yn<this.y-Math.max(target.height,this.height)+this.height/2){
				Yn = this.y-target.height+this.height/2
			}
		}
		public function bala(e){
			if(isLocked)
			{
				return ;
			}
			Yn+=100;
			dispatchEvent(ev3);
			if(Yn>this.y){
				Yn = this.y;
			}else if(Yn<this.y-Math.max(target.height,this.height)+this.height/2){
				Yn = this.y-target.height+this.height/2
			}
		}
		public function pakkCh(){
			if(upBTN!=null){
				upBTN.removeEventListener(MouseEvent.MOUSE_DOWN,paiin)
				dnBTN.removeEventListener(MouseEvent.MOUSE_DOWN,bala)
				//parent.removeChild(dnBTN)
				//parent.removeChild(upBTN)
			}
		}
		public function pakkCh2(e){
			
		}
		public function estart(targ,leftToRightFlag:Boolean=false,nextBTN=null,prevBTN=null,useBitmapEffect:Boolean=false){
			LTRF = leftToRightFlag ;
			
			this.visible = true;
			
			//debug↓
			//return
			if(useBitmapEffect)
			{
				this.cacheAsBitmap = true;
				targ.cacheAsBitmap = true;
			}
			else
			{
				//sd.visible = false;
				/*s.height = s.heigth+sd.height;
				trace('♠ : '+sd.height);
				sd.heigth = 1 ;*/
				//sd.height = 1 ;
				//sd.width = 0 ;
			}
			targ.mask = this;
			
			if(nextBTN!=null && prevBTN!=null){
				nextBTN.addEventListener(MouseEvent.MOUSE_DOWN,paiin)
				prevBTN.addEventListener(MouseEvent.MOUSE_DOWN,bala)
				upBTN = nextBTN;
				dnBTN = prevBTN;
				upBTN.visible = false;
				dnBTN.visible = false;
			}else{
				
				upBTN = new MovieClip();
				dnBTN = new MovieClip();
				upBTN.visible = false;
				dnBTN.visible = false;
			}
			
			if(leftToRightFlag){
				mu = 0.7
				
				sMC.height+=Number(suMC.height+sdMC.height);
				this.y-=suMC.height*this.scaleY;
				
				sdMC.x = 0;
				sdMC.y = 0;
				sdMC.width = Number(sMC.height) ;
				sdMC.rotation = 90;
				
				suMC.width = Number(sMC.height) ;
				suMC.rotation = 90
				suMC.x = sMC.width;
				suMC.y = 0;
				
				//LRF = true
				targ.y = this.y ;
				Yn = targ.x ;
				this.addEventListener(Event.ENTER_FRAME,doIt2);
				stage.addEventListener(MouseEvent.MOUSE_DOWN,down_fu2)
			}else{
				targ.y = this.y ;
				Yn = targ.y ;
				this.removeEventListener(Event.ENTER_FRAME,doIt);
				stage.removeEventListener(MouseEvent.MOUSE_DOWN,down_fu);
				
				this.addEventListener(Event.ENTER_FRAME,doIt);
				stage.addEventListener(MouseEvent.MOUSE_DOWN,down_fu);
			}
			
			stage.addEventListener(MouseEvent.MOUSE_UP,removeMouseMoves);
			
			var max;
			var min;
			//max = Math.max(this.parent.getChildIndex(this),this.parent.getChildIndex(targ));
			//min = Math.min(this.parent.getChildIndex(this),this.parent.getChildIndex(targ));
			//this.parent.setChildIndex(this,min);
			//this.parent.setChildIndex(targ,max);
			target = targ;
			this.addEventListener(Event.REMOVED,pakon)
			this.addEventListener(Event.REMOVED_FROM_STAGE,pakon)
			stage.addEventListener(MouseEvent.MOUSE_UP,up_fu)
			
			stage.addEventListener(MouseEvent.MOUSE_WHEEL,manageDirection);
		}
		
		private function removeMouseMoves(e)
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,mov_fu)
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,mov_fu2)
		}
		
		/**reset the position of this scroll*/
		public function reset()
		{
			target.y = this.y ;
			Yn = target.y ;
			V = 0 ;
		}
		
		
		/**scroll the page with scroller*/
		private function manageDirection(e:MouseEvent)
		{
			if(!this.hitTestPoint(root.mouseX,root.mouseY)){
				return
			}
			if(e.delta<0)
			{
				paiin(e);
			}
			else
			{
				bala(e);
			}
			
		}
		
		
		private function pakon(e){
			pakkCh()
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL,manageDirection);
			dispatchEvent(ev2)
			this.removeEventListener(Event.ENTER_FRAME,doIt);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN,down_fu)
			stage.removeEventListener(MouseEvent.MOUSE_DOWN,down_fu2)
			stage.removeEventListener(MouseEvent.MOUSE_UP,up_fu)
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,mov_fu)
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,mov_fu2)
			stage.removeEventListener(MouseEvent.MOUSE_UP,removeMouseMoves);
		}
		private function mov_fu(e){
			if(false){//Math.abs(lastMY-parent.mouseY)<Math.abs(lastMX-parent.mouseX)){
				up_fu(e)
			}else{
				dispatchEvent(ev1)
			}
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,mov_fu);
		}
		
		
		private function mov_fu2(e){
			if(false){//Math.abs(lastMY-parent.mouseY)>Math.abs(lastMX-parent.mouseX)){
				up_fu(e)
			}else{
				dispatchEvent(ev1)
			}
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,mov_fu2)
		}
		
		private function down_fu(e){
			if(!target.hitTestPoint(root.mouseX,root.mouseY)||!this.hitTestPoint(root.mouseX,root.mouseY)||(target.height+DeltaD<this.height)){
				return
			}
			stage.addEventListener(MouseEvent.MOUSE_MOVE,mov_fu)
			////trace('OK')
			//trace('yek : '+LTRF)
			mF = true
			//V = 0
			lastMY = parent.mouseY;
			lastMX = parent.mouseX;
			
		}
		
		private function down_fu2(e){
			if(!target.hitTestPoint(root.mouseX,root.mouseY)||!this.hitTestPoint(root.mouseX,root.mouseY)||(target.width+DeltaD<this.width)){
				return
			}
			stage.addEventListener(MouseEvent.MOUSE_MOVE,mov_fu2)
			////trace('man?')
			//trace('do : '+LTRF)
			mF = true
			//V = 0
			lastMY = parent.mouseY;
			lastMX = parent.mouseX;
			
		}
		
		private function up_fu(e){
			dispatchEvent(ev2)
			if(!mF){
				return;
			}
			mF = false
			////trace('KO')
			
			//trace('se : '+LTRF)
			//V += parent.mouseY-lastMY
		}
		private function doIt(e){
			if(isLocked)
			{
				return ;
			}
			
			if(target.height+DeltaD<this.height){
				target.y = this.y;
				Yn = this.y
				if(upBTN!=null){
					upBTN.visible = false;
					dnBTN.visible = false;
				}
				return
			}
			else
			{
				if(upBTN!=null){
					upBTN.visible = true;
					dnBTN.visible = true;
				}
			}
			if(!mF){
				/*if(Yn>this.y){
				Yn = this.y;
				}else if(Yn<this.y-Math.max(target.height,this.height)+this.height){
				Yn = this.y-Math.max(target.height,this.height)+this.height
				}*/
			}else{
				dispatchEvent(ev3);
				//////trace('jabeja : '+(parent.mouseY-lastMY))
				Yn += parent.mouseY-lastMY
				//Yn = target.y
				lastMY = parent.mouseY
			}
			if(Yn>=this.y){
				if(dnBTN.visible){
					Yn = this.y;
				}
				dnBTN.visible = false;
			}else if(Yn<=this.y-Math.max(target.height,this.height)+this.height){
				if(upBTN.visible){
					Yn = this.y-Math.max(target.height,this.height)+this.height;
				}
				upBTN.visible = false;
			}
			V += (Yn-target.y)/F ;
			V *= mu ;
			
			target.y += V ;
			if(target.y>this.y){
				
				//target.y -= V ;↓
				target.y=this.y;
				
				V = Math.abs(V)*-0.5;
			}
			if(target.y<this.y-Math.max(target.height,this.height)+this.height){
				//target.y -= V ;↓
				target.y = this.y-Math.max(target.height,this.height)+this.height;
				
				V = Math.abs(V)*0.5;
			}
		}
		
		private function doIt2(e){
			if(isLocked || target.width+DeltaD<this.width){
				//target.y = this.y;
				//Yn = this.y
				//////trace('ammam')
				//dispatchEvent(ev2)
				return
			}
			if(!mF){
				if(Yn>this.x){
					Yn = this.x;
				}else if(Yn<this.x-Math.max(target.width,this.width)+this.width-this.width/50){
					Yn = this.x-target.width+this.width-this.width/50
				}
			}else{
				dispatchEvent(ev3);
				//////trace('jabeja : '+(parent.mouseY-lastMY))
				Yn += parent.mouseX-lastMX
				//Yn = target.y
				lastMX = parent.mouseX
			}
			V += (Yn-target.x)/F ;
			V *= mu ;
			target.x += V ;
			//trace('VV'+V)
			if(Math.abs(V)<DeltaD/5){
				movingFlag=false
				//trace('pan : '+LTRF)
				dispatchEvent(ev2)
			}else if(movingFlag==false){
				movingFlag=true;
				dispatchEvent(ev1)
			}
		}
	}
	
}
