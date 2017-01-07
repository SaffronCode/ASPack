package stageManager
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;

	[Event(name="removedFromStage", type="flash.events.Event")]
	
	internal class StageItem extends EventDispatcher
	{
		private static var itemsObject:Array = [] ;
		
		//public static var pureItmes:Array ;
		
		public static function isNew(item:*):Boolean
		{
			if(itemsObject.indexOf(item)==-1)
			{
				return true ;
			}
			else
			{
				return false ;
			}
		}
		
		/**Call this function to make isNew function works with again*/
		public static function remove(item:StageItem)
		{
			var I:int = itemsObject.indexOf(item.object);
			if(I!=-1)
			{
				//trace("Item is removed from cashed list");
				itemsObject.splice(I,1);
			}
		}
		
		public var object:DisplayObject,
					options:StageOption,
					//X0:Number,
					//Y0:Number,
					absolutePosition:Point,
					scaleX0:Number,
					scaleY0:Number;
					
		private var lastStageWDelta:Number,lastStageHDelta:Number;
					
		/**This value will use to detect index of item on the StageManager vector*/
		//public var index:uint ;
		
		public function StageItem(item:*,option:StageOption,Index:uint=0):void
		{
			//index = Index ;
			
			//trace(option.name+' is added to stage');
			
			object = item as DisplayObject ;
			object.addEventListener(Event.REMOVED_FROM_STAGE,dispatchItForMe);
			options = option ;
			
			absolutePosition = object.localToGlobal(new Point());
			
			//X0 = absolutePosition.x ;
			//Y0 = absolutePosition.y ;
			scaleX0 = object.scaleX ;
			scaleY0 = object.scaleY ;
			
			itemsObject.push(item);
		}
		
		protected function dispatchItForMe(event:Event):void
		{
			
			this.dispatchEvent(new Event(Event.REMOVED_FROM_STAGE));
		}
		
		/**Returns item to its first position.
		 * This function will prevent duplicate remove and resizing*/
		public function resetPose(deltaStageWidth:Number,deltaStageHeigth:Number,stageScaleX:Number,stageScaleY:Number):void
		{
			if(lastStageWDelta==deltaStageWidth && lastStageHDelta == deltaStageHeigth)
			{
				//There is no need to reposition this
				return ;
			}
			lastStageWDelta = deltaStageWidth ;
			lastStageHDelta = deltaStageHeigth;
			
			var finalPose:Point = absolutePosition.clone();
			switch(options.XPose)
			{
				case(-1):
					finalPose.x -= deltaStageWidth/2;
					break;
				case(1):
					finalPose.x += deltaStageWidth/2;
			}
			
			switch(options.YPose)
			{
				case(-1):
					finalPose.y -= deltaStageHeigth/2;
					break;
				case(1):
					finalPose.y += deltaStageHeigth/2;
			}
			
			finalPose = object.parent.globalToLocal(finalPose);
			object.x = finalPose.x ;
			object.y = finalPose.y ;
			
			if(options.resizeX)
			{
				object.scaleX = scaleX0*stageScaleX ;
			}
			if(options.resizeY)
			{
				object.scaleY = scaleY0*stageScaleY ;
			}
		}
		
		/**Returns the item position based on stage*/
		public function getAbsolutePose():Point
		{
			return object.localToGlobal(new Point());
		}
	}
}