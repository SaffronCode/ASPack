package
{
	public class ServerDate
	{
		/**11/6/2014 1:10:14 AM*/
		public static function dateToServerDate(date:Date):String
		{
			if(date == null)
			{
				return '' ;
			}
			var AM_PM:String = "AM";
			if(date.hours>=12)
			{
				AM_PM = "PM";
			}
			var houre:Number = date.hours ;
			if(houre == 0)
			{
				houre = 12 ;
			}
			if(houre >= 13)
			{
				houre -= 12 ;
			}
			
			var createdDate:String = (date.month+1)+'/'+date.date+'/'+date.fullYear+' '+houre+':'+date.minutes+':'+date.seconds+' '+AM_PM;
			
			return createdDate ;
		}
		
		/**11/6/2014 1:10:14 AM*/
		public static function serverDateToDate(date:String):Date
		{
			if(date == '' || date==null)
			{
				return new Date();
			}
			
			var splitter:Array;
			var dateSplitter:Array ;
			var timeSplitter:Array;
			var createdDate:Date;
			
			splitter = date.split(' ');
			
			dateSplitter = (splitter[0] as String).split('/');
			timeSplitter = (splitter[1] as String).split(':');
			
			if(timeSplitter[0]=='12')
			{
				timeSplitter[0] = '0' ;
			}
			
			createdDate = new Date(Number(dateSplitter[2]),Number(dateSplitter[0])-1,Number(dateSplitter[1]),Number(timeSplitter[0]),Number(timeSplitter[1]),Number(timeSplitter[2]));
			if(splitter[2] == "PM")
			{
				createdDate.hours+=12 ;
			}
			return createdDate ;
		}
		
		public static function copyDate(date:Date):Date
		{
			// TODO Auto Generated method stub
			var clonedDate:Date = new Date(date.fullYear,date.month,date.date,date.hours,date.minutes,date.seconds,date.milliseconds);
			return clonedDate;
		}
	}
}