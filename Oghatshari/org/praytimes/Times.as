package org.praytimes 
{
	import org.praytimes.utils.DMath;

	public class Times
	{
		/*public static const NAME_IMSAK:String = "Imsak";
		public static const NAME_FAJR:String = "Fajr";
		public static const NAME_SUNRISE:String = "Sunrise";
		public static const NAME_DHUHR:String = "Dhuhr";
		public static const NAME_ASR:String = "Asr";
		public static const NAME_SUNSET:String = "Sunset";
		public static const NAME_MAGHRIB:String = "Maghrib";
		public static const NAME_ISHA:String = "Isha";
		public static const NAME_MIDNIGHT:String = "Midnight";*/
		
		
		/**24-hour format<br>Value: "24h"*/
		public static const FORMAT_H24:String = "24h";
		/**12-hour format<br>Value: "12h"*/
		public static const FORMAT_H12:String = "12h";
		/**12-hour format with no suffix<br>Value: "12hNS"*/
		public static const FORMAT_HNS12:String = "12hNS";
		/**floating point number<br>Value: "Float"*/
		public static const FORMAT_FLOAT:String = "Float";
		
		
		public static const SUFFIXES_AM:String = "am";
		public static const SUFFIXES_PM:String = "pm";
		
		
		// convert float time to the given format (see timeFormats)
		public static function getFormattedTime (time:Number, format:String="24h"):String
		{
			if (isNaN(time))
				return "--Invalid time--";
			
			if (format == FORMAT_FLOAT)
				return time.toString();
			
			time = DMath.fixHour(time+ 0.5/ 60);  // add 0.5 minutes to round
			var hours:Number = Math.floor(time); 
			var minutes:Number = Math.floor((time- hours)* 60);
			var suffix:String = (format == '12h') ? hours < 12 ? SUFFIXES_AM : SUFFIXES_PM : "";
			var hour:String = (format == '24h') ? twoDigitsFormat(hours) : ((hours+ 12 -1)% 12+ 1).toString();
			return hour+ ':'+ twoDigitsFormat(minutes)+ (suffix ? ' '+ suffix : '');
		}
		
		
		
		public function getDate (time:Number):Date
		{
			if (isNaN(time))
				return null;
			
			var ret:Date = new Date(date.fullYear, date.month, date.date);
			if(time>=24)
			{
				time-= 24;
				ret.setTime(ret.getTime() + (1000 * 60 * 60 * 24));
			}
			ret.hours = Math.floor(time);
			var min:Number = (time- ret.hours)* 60;
			ret.minutes = Math.floor(min);
			var sec:Number = (min-ret.minutes)* 60;
			ret.seconds =  Math.floor(sec);
			ret.milliseconds = Math.floor((sec-ret.seconds)*1000);
			
			return ret;
		}

		
		// add a leading 0 if necessary
		public static function twoDigitsFormat (num:Number):String
		{
			return (num <10) ? "0"+ num : num+"";
		}
		
		
		
		public var names:Array = ["imsak", "fajr", "sunrise", "dhuhr", "asr", "sunset", "maghrib", "isha", "midnight"];
		//public var values:Array = [imsak, fajr, sunrise, dhuhr, asr, sunset, maghrib, isha, midnight];
		public var imsak:Number = 5;
		public var fajr:Number = 5;
		public var sunrise:Number = 6;
		public var dhuhr:Number = 12;
		public var asr:Number = 13;
		public var sunset:Number = 18;
		public var maghrib:Number = 18;
		public var isha:Number = 10;
		public var midnight:Number = 0;
		
		public var date:Date;
		
		public function Times(date:Date)
		{
			this.date = date;
		}

		public function toString():String
		{
			return "imsak: "+imsak + ", fajr: "+fajr + ", sunrise: "+sunrise + ", dhuhr: "+dhuhr + ", asr: "+asr + ", sunset: "+sunset + ", maghrib: "+maghrib + ", isha: "+isha + ", midnight: "+midnight ;
		}
		
		public function toTimeFormatString(format:String="24h"):String
		{
			return "imsak: " +		getFormattedTime(imsak, format) + 
				", fajr: " + 		getFormattedTime(fajr, format) + 
				", sunrise: " + 	getFormattedTime(sunrise, format) + 
				", dhuhr: " + 		getFormattedTime(dhuhr, format) + 
				", asr: " + 		getFormattedTime(asr, format) + 
				", sunset: " + 		getFormattedTime(sunset, format) + 
				", maghrib: " +		getFormattedTime(maghrib, format) + 
				", isha: " + 		getFormattedTime(isha, format) + 
				", midnight: " +	getFormattedTime(midnight, format) ;
		}
		
		public function toDates():Vector.<Date>
		{
			var ret:Vector.<Date> = new Vector.<Date>();
			for each(var t:String in names)
				ret.push(getDate(this[t] as Number));
			return ret;
		}

	}
}