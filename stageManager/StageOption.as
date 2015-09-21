package stageManager
{
	internal class StageOption
	{
		/**The elements name*/
		public var name:String;
		
		/**-1 opposite side, 0 not depends, 1 current side*/
		public var XPose:int,
					YPose:int;
					
					
		/**false : don't resize, true : resize*/
		public var resizeX:Boolean,
					resizeY:Boolean ;
		
		public function StageOption(itemName:String,
									xPosition:int=0,
									yPosition:int=0,
									resizeByX:Boolean=false,
									resizeByY:Boolean=false)
		{
			name = itemName ;
			XPose = xPosition ;
			YPose = yPosition;
			resizeX = resizeByX ;
			resizeY = resizeByY ;
		}
	}
}