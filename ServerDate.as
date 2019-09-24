package
{
	import com.mteamapp.StringFunctions;
	
	import diagrams.calender.MyShamsi;
	
	import flash.utils.getTimer;
	
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
		
		
		/**2015-10-27T10:46:56.9335483+03:30*///2017-05-25T17:27:38.503Z
		public static function dateToServerDate2(date:Date,addTimeZone:Boolean=true):String
		{
			if(date==null)
			{
				return '' ;
			}
			var zone:String = '' ;
            if(addTimeZone)
            {
                zone = TimeToString.timeInString(Math.abs(date.timezoneOffset));
				if(date.timezoneOffset<0)
				{
					zone = '+'+zone ;
				}
				else
				{
					zone = '-'+zone ;
				}
            }
			var stringedDate:String = date.fullYear+'-'+TimeToString.numToString(date.month+1)+'-'+TimeToString.numToString(date.date)+'T' +
				TimeToString.numToString(date.hours)+':'+TimeToString.numToString(date.minutes)+':'+TimeToString.numToString(date.seconds)+zone;
			return stringedDate ;
		}
		
		/**2015-10-27T10:46:56.9335483+03:30<br>
		 * 2018-04-15T17:00:00*/
		public static function serverDateToDate2(date:String):Date
		{
			var myDate:Date = new Date();
			
			try
			{
				/**2015-10-27 , 10:46:56.9335483+03:30*/
				var splitedDateT:Array = date.split('T');
				/**2015 , 10 , 27*/
				var splitedDatePart:Array = splitedDateT[0].split('-');
				/**10 , 46 , 56.9335483+03 <strong>,</strong> 30*/
				var splitedTimePart:Array = splitedDateT[1].split(':');
				/**56.9335483 , 03:30*/
				var splitedZoneAndSecond:Array ;
				/**+ or -*/
				var zoneMinutes:int = 0 ;
				
				var noZoneAvailable:Boolean = true ;
				
				var second:String ;
				if(splitedTimePart[2].indexOf('+')!=-1)
				{
					splitedZoneAndSecond = splitedTimePart[2].split('+');
					if(splitedZoneAndSecond.length>1)
					{
						zoneMinutes = -1*TimeToString.stringToNumBased60(splitedZoneAndSecond[1]+':'+splitedTimePart[3]) ;
					}
					noZoneAvailable = false ;
				}
				else if(splitedTimePart[2].indexOf('-')!=-1)
				{
					splitedZoneAndSecond = splitedTimePart[2].split('-');
					if(splitedZoneAndSecond.length>0)
					{
						zoneMinutes = 1*TimeToString.stringToNumBased60(splitedZoneAndSecond[1]+':'+splitedTimePart[3]) ;
					}
					noZoneAvailable = false ;
				}
				else
				{
					splitedZoneAndSecond = [splitedTimePart[2]]
				}
				
			//	trace("splitedZoneAndSecond : "+splitedZoneAndSecond);
				
				myDate.fullYearUTC = uint(splitedDatePart[0]);
				myDate.monthUTC = uint(splitedDatePart[1])-1;
				myDate.dateUTC = uint(splitedDatePart[2]);
				if(noZoneAvailable)
				{
					myDate.hours = uint(splitedTimePart[0]);
					myDate.minutes = uint(splitedTimePart[1]);
					myDate.seconds = uint(splitedZoneAndSecond[0]);
				}
				else
				{
					myDate.hoursUTC = uint(splitedTimePart[0]);
					myDate.minutesUTC = uint(splitedTimePart[1]);
					myDate.secondsUTC = uint(splitedZoneAndSecond[0]);
					myDate.minutes+=zoneMinutes;
				}
			}
			catch(e:Error)
			{
				trace("Date format is not parsable : "+date);
				return null ;
			}
			
			return myDate ;
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
			if(splitter[2] == "PM" && Number(timeSplitter[0])<12)
			{
				createdDate.hours+=12 ;
			}
			return createdDate ;
		}
		
		/**1396-12-15 10:50:00 
		 * 1396/12/15 10:50:00" 
		 * 1396/12/15 10:50:00 AM
		 * */
		public static function serverDateToShamsiDate(date:String):MyShamsi
		{
			if(date == '' || date==null)
			{
				return new MyShamsi();
			}
			
			var splitter:Array;
			var dateSplitter:Array ;
			var timeSplitter:Array;
			var createdDate:MyShamsi;
			
			date = date.split('/').join('-') ;
			
			splitter = date.split(' ');
			var formatDate:String='/';
			if(date.indexOf(formatDate)==-1)formatDate = '-';
			dateSplitter = (splitter[0] as String).split(formatDate);
			timeSplitter = (splitter[1] as String).split(':');
			
			if(timeSplitter[0]=='12')
			{
				timeSplitter[0] = '0';
			}
			createdDate = new MyShamsi(Number(dateSplitter[0]),Number(dateSplitter[1])-1,Number(dateSplitter[2]),Number(timeSplitter[0]),Number(timeSplitter[1]),(timeSplitter.length>=3)?Number(timeSplitter[2]):null);
			if(splitter[2] == "PM" && Number(timeSplitter[0])<12)
			{
				createdDate.hours+=12 ;
			}
			return createdDate ;
		}
		
		
		
		/**2015-08-30 or 2015/08/30*/
		public static function serverDateToDate3(date:String):Date
		{
			if(date == '' || date==null)
			{
				return new Date();
			}
			
			
			var dateSplitter:Array ;
			var createdDate:Date;
			
			
			if( date.indexOf('/')!=-1)
			{
				dateSplitter = date.split('/');
			}
			else if(date.indexOf('-')!=-1)
			{
				dateSplitter = date.split('-');
			}
			
			
			createdDate = new Date(Number(dateSplitter[0]),Number(dateSplitter[1])-1,Number(dateSplitter[2]),0,0,0);
			
			return createdDate ;
		}
		
		/**2015/11/06 23:00:00 or   2015-11-06 23:00:00*/
		public static function serverDateToDate4(date:String):Date
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
			
			if(date.indexOf('/')!=-1)
			{			
				dateSplitter = (splitter[0] as String).split('/');
			}
			else if(date.indexOf('-')!=-1)
			{			
				dateSplitter = (splitter[0] as String).split('-');
			}
			timeSplitter = (splitter[1] as String).split(':');
			
			if(timeSplitter[0]=='12')
			{
				timeSplitter[0] = '0' ;
			}
			
			createdDate = new Date(Number(dateSplitter[0]),Number(dateSplitter[1])-1,Number(dateSplitter[2]),Number(timeSplitter[0]),Number(timeSplitter[1]),Number(timeSplitter[2]));
			
			return createdDate ;
		}
		
		
		public static function copyDate(date:Date):Date
		{
			
			if(date==null)
			{
				return null;
			}
			var clonedDate:Date = new Date(date.fullYear,date.month,date.date,date.hours,date.minutes,date.seconds,date.milliseconds);
			return clonedDate;
		}
		
	/////////////////////////////////////////////////////////////Shamsi↓
		/**Sample is : 1395/09/06*/
		public static function stringToMyShamsi(stringedDate:String):MyShamsi
		{
			if(stringedDate == null)
			{
				return null ;
			}
			var splited:Array = stringedDate.split('/');
			if(splited.length!=3)
			{
				return null ;
			}
			var createdShamsi:MyShamsi = new MyShamsi(uint(splited[0]),uint(splited[1])-1,uint(splited[2]),0,0,0,0);
			return createdShamsi ;
		}
	}
}