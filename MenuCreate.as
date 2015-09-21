// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

package 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class MenuCreate extends MovieClip
	{
		private var menuItemsObjects:Array,
					menuY:Array,
					menuX:Array,
					indexs:Array,
					
					onClick:Function;
					
		/**0 for not moving , 1 for ltr and -1 for rtl*/
		public var directionX:int = -1,
					directionY:int = 0;
		
		/**distance between two menus*/
		public var 	dx:Number = 20,
					dy = 20 ;
		
		/**set the zero position*/
		public var 	X0 = 0,
					Y0 = 0 ;
		
		/**mouse position*/
		private var mousePoseX:Number,
					mousePoseY:Number;
		
		/**speed of animation*/
		public var animSpeed:Number = 10 ;
		
		/**this will tells that selection is acceptable*/
		private var selectAcssepted:Boolean = false;
		
		public function MenuCreate()
		{
			super();
			reset();
			this.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
		}
		
		/**reset app*/
		public function reset()
		{
			this.graphics.clear();
			this.graphics.beginFill(0,0);
			this.graphics.drawCircle(0,0,10);
			menuItemsObjects = [];
			menuY = [];
			menuX = [];
			indexs = [] ;
			removeChildren();
			
			this.addEventListener(MouseEvent.MOUSE_UP,buttonSelected);	
			this.addEventListener(MouseEvent.MOUSE_DOWN,startSelection);	
			
			try
			{
				//stage.addEventListener(scroll_mc.SCROLL_START_EV,premevtSelectiom);
				//switch these line s to prevent lock on small screend devices↨
					stage.addEventListener(MouseEvent.MOUSE_MOVE,premevtSelectiom2);
			}
			catch(e){};
			
			this.removeEventListener(Event.ENTER_FRAME,anim);
			this.addEventListener(Event.ENTER_FRAME,anim);
		}
		
		private function unLoad(e)
		{
			this.removeEventListener(MouseEvent.MOUSE_UP,buttonSelected);
			this.removeEventListener(MouseEvent.MOUSE_DOWN,startSelection);
			
			//stage.removeEventListener(scroll_mc.SCROLL_START_EV,premevtSelectiom);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,premevtSelectiom2);
			
			this.removeEventListener(Event.ENTER_FRAME,anim);
		}
		
		
		/**sends parameter to specified menu item*/
		public function param(parameter:*,ItemID:uint)
		{
			try
			{
				menuItemsObjects[ItemID].param(parameter);
			}
			catch(e)
			{
				trace('specified item is not existed');
			}
		}
		
		/**set up the menus here <br>
		 * menuItems : array of any thing that you whant to pass it to yout menuItemClass <br>
		 * afterCalls : the function that will receve selected index of menu item<br>
		 * itemsClass : the class with public setUp fnction definition on it to receve its menuItem <br>
		 * firstPositionMulty : this number will multiply on the begin position of item to generate animation from first and final position of the menuObjects<br>
		 * lastActiveMenu : this is last active menuNumber. this class will deactive all menus with indexes uooer than this number<br>
		 * deltaX : destination between any two menus in X<br>
		 * deltaY : destination between any two menus in Y<br>
		 * DirectionX : 0 means no delta x between each Menus , -1 for left floating , 1 for right floating<br>
		 * DirectionY : 0 means no delta y between each Menus , -1 for down to top floating , 1 for top down floating<br>
		 * zeroPositionX-Y : base position of first menu itme<br>
		 * AnimSpeed : 1 mean instance move , bigger numbers will slow down the moving animation*/
		public function setUp(menuItems:Array,
							  afterCalls:Function,
							  itemsClass:Class,
							  firstPositionMulty:Number=1,
							  lastActiveMenu:Number = Infinity,
							  deltaX:Number=Infinity,
							  deltaY:Number=Infinity,
								DirectionX:int=-10,
								DirectionY:int=-10,
								zeroPositionX:Number=Infinity,
								zeroPositionY:Number=Infinity,
								AnimSpeed:Number=-1):void
		{
			reset();
			onClick = afterCalls ;
			
			if(DirectionX!=-10)
			{
				directionX = DirectionX;
			}
			if(DirectionY!=-10)
			{
				directionY = DirectionY;
			}
			
			if(zeroPositionX!=Infinity)
			{
				X0 = zeroPositionX;
			}
			if(zeroPositionY!=Infinity)
			{
				Y0 = zeroPositionY;
			}
			
			if(AnimSpeed>0)
			{
				animSpeed = AnimSpeed;
			}
			
			if(menuItemsObjects.length>0)
			{
				return ;
			}
			
			if(deltaX != Infinity)
			{
				dx = deltaX ;
			}
			
			if(deltaY != Infinity)
			{
				dy = deltaY ;
			}
			
			var item;
			
			for(var i = 0 ; i < menuItems.length ; i++)
			{
				item = new itemsClass();
				item.mouseChildren = false;
				this.addChildAt(item,0);
				(item).setUp(menuItems[i]);
				menuItemsObjects.push(item);
				//menuY.push(0);
				//item.y = menuY[menuY.length-1]*firstPositionMulty ;
				if(i==0)
				{
					menuX.push(X0/*+(item.width/2)*directionX*/);
					item.x = menuX[menuX.length-1]*firstPositionMulty;
					
					menuY.push(Y0/*+(item.height/2)*directionY*/);
					item.y = menuY[menuY.length-1]*firstPositionMulty;
				}
				else
				{
					menuX.push((item.width/2*directionX)+
								(menuX[menuX.length-1])+
								(directionX*menuItemsObjects[menuItemsObjects.length-2].width/2)+
								(dx*directionX) );
					
					item.x = menuX[menuX.length-1]*firstPositionMulty;
					
					
					menuY.push((item.height/2*directionY)+
						(menuY[menuY.length-1])+
						(directionY*menuItemsObjects[menuItemsObjects.length-2].height/2)+
						(dy*directionY) );
					
					item.y = menuY[menuY.length-1]*firstPositionMulty;
				}
				item.mouseChildren = false;
				if(i<lastActiveMenu)
				{
					item.buttonMode = true ;
				}
				else
				{
					item.mouseEnabled = false;
					item.alpha = 0.7;
				}
				indexs.push(i);
			}
		}
		
		/**button selected*/
		public function buttonSelected(e:MouseEvent)
		{
			if(!selectAcssepted)
			{
				return ;
			}
			var index:int = menuItemsObjects.indexOf(e.target);
			if(index!=-1)
			{
				onClick(index);
			}
			selectAcssepted = false;
		}
		
		private function premevtSelectiom(e)
		{
			trace('cilick prevented');
			selectAcssepted = false;
		}
		
		private function premevtSelectiom2(e)
		{
			//trace(mousePoseX+' vs '+stage.mouseX);
			if(selectAcssepted && (Math.abs(mousePoseX-stage.mouseX)>30 || Math.abs(mousePoseY-stage.mouseY)>30) )
			{
				trace('dont let click');
				selectAcssepted = false;
			}
		}
		
		private function startSelection(e)
		{
			mousePoseX = stage.mouseX ;
			mousePoseY = stage.mouseY ;
			selectAcssepted = true;
		}
		
		
		public function anim(e)
		{
			for(var i = 0 ; i < menuItemsObjects.length ; i++)
			{
				menuItemsObjects[i].x+=(menuX[i]-menuItemsObjects[i].x)/animSpeed;
				menuItemsObjects[i].y+=(menuY[i]-menuItemsObjects[i].y)/animSpeed;
			}
		}
		
		
		public function selected(id:uint)
		{
			try
			{
				trace('select this item');
				menuItemsObjects[id].selected();
			}
			catch(e)
			{
				trace('item has not selected Function');
			};
		}
	}
}