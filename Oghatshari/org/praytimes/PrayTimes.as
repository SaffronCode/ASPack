package org.praytimes
{
	import org.praytimes.constants.CalculationMethod;
	import org.praytimes.constants.HighLatMethod;
	import org.praytimes.constants.JuristicMethod;
	import org.praytimes.constants.MidnightMode;
	import org.praytimes.utils.DMath;
	
	
	//--------------------- Copyright Block ----------------------
	/* 
	
	PrayTimes.js: Prayer Times Calculator (ver 2.3)
	Copyright (C) 2007-2011 PrayTimes.org
	
	Developer: Hamid Zarrabi-Zadeh
	License: GNU LGPL v3.0
	
	TERMS OF USE:
	Permission is granted to use this code, with or 
	without modification, in any website or application 
	provided that credit is given to the original work 
	with a link back to PrayTimes.org.
	
	This program is distributed in the hope that it will 
	be useful, but WITHOUT ANY WARRANTY. 
	
	PLEASE DO NOT REMOVE THIS COPYRIGHT BLOCK.
	
	*/ 
	
	
	//--------------------- Help and Manual ----------------------
	/*
	
	User's Manual: 
	http://praytimes.org/manual
	
	Calculation Formulas: 
	http://praytimes.org/calculation
	
	
	
	//------------------------ User Interface -------------------------
	
	
	getTimes (date, coordinates [, timeZone [, dst [, timeFormat]]]) 
	
	setMethod (method)       // set calculation method 
	adjust (parameters)      // adjust calculation parameters	
	tune (offsets)           // tune times by given offsets 
	
	getMethod ()             // get calculation method 
	getSetting ()            // get current calculation parameters
	getOffsets ()            // get current time offsets
	
	
	//------------------------- Sample Usage --------------------------
	
	
	var PT = new PrayTimes('ISNA');
	var times = PT.getTimes(new Date(), [43, -80], -5);
	document.write('Sunrise = '+ times.sunrise)
	
	
	*/
	
	
	public class PrayTimes
	{
		private var numIterations:int = 1;
		private var calculationMethod:CalculationMethod;
		//private var offset:Object;
		
		// coordinates
		private var lat:Number;
		private var lng:Number;
		private var elv:Number;
		private var highLats:String;
		// time variables
		private var timeZone:Number;
		private var jDate:Number;
		private var date:Date;
		
		public function PrayTimes(calculationMethod:CalculationMethod, lat:Number, lng:Number, elv:Number=0, timeZone:Number=NaN, highLats:String="NightMiddle")
		{
			this.calculationMethod = calculationMethod;
			this.lat = lat;
			this.lng = lng; 
			this.elv = elv;
			this.timeZone = timeZone;
			this.highLats = highLats;
			/*if (date.constructor === Date)
			date = [date.getFullYear(), date.getMonth()+ 1, date.getDate()];
			if (typeof(timezone) == 'undefined' || timezone == 'auto')
			timezone = this.getTimeZone(date);
			if (typeof(dst) == 'undefined' || dst == 'auto') 
			dst = this.getDst(date);
			timeZone = 1* timezone+ (1* dst ? 1 : 0);*/
		}
			
		/*
		//----------------------- Public Functions ------------------------
		
		// set calculation method 
		setMethodprivate function  (method) {
			if (methods[method]) {
				this.adjust(methods[method].params);
				calculationMethod = method;
			}
		}
		
		// set calculating parameters
		adjustprivate function  (params) {
			for (var id in params)
				setting[id] = params[id];
		}
		
		// set time offsets
		tuneprivate function  (timeOffsets) {
			for (var i in timeOffsets)
				offset[i] = timeOffsets[i];
		}
		
		// get current calculation method
		getMethodprivate function  () { return calculationMethod; },
		
		// get current setting
		getSettingprivate function  () { return setting; },
		
		// get current time offsets
		getOffsetsprivate function  () { return offset; },
		
		// get default calc parametrs
		getDefaultsprivate function  () { return methods; },
		*/
		
	
	
	
		// return prayer times for a given date
		public function getTimes(date:Date=null):Times
		{/*, dst*/
			if(date==null)
				date = new Date();
			this.date = date;
			
			timeZone = isNaN(timeZone) ?-date.getTimezoneOffset()/60 : timeZone;
			jDate = this.julian(date.fullYear, date.month+1, date.date)- lng / (15* 24);
			return this.computeTimes();
		}
		
		
		//---------------------- Calculation Functions -----------------------
		
		
		// compute mid-day time
		private function midDay (time:Number):Number 
		{
			var eqt:Number = this.sunPosition(jDate+ time).equation;
			var noon:Number = DMath.fixHour(12- eqt);
			return noon;
		}
		
		// compute the time at which sun reaches a specific angle below horizon
		private function sunAngleTime (angle:Number, time:Number, direction:String="cw"):Number
		{
			var decl:Number = this.sunPosition(jDate+ time).declination;
			var noon:Number = this.midDay(time);
			var t:Number = 1/15* DMath.arccos((-DMath.sin(angle)- DMath.sin(decl)* DMath.sin(lat))/ (DMath.cos(decl)* DMath.cos(lat)));
			return noon+ (direction == 'ccw' ? -t : t);
		}

		// compute asr time 
		private function asrTime (factor:Number, time:Number):Number
		{ 
			var decl:Number = this.sunPosition(jDate+ time).declination;
			var angle:Number = -DMath.arccot(factor+ DMath.tan(Math.abs(lat- decl)));
			return sunAngleTime(angle, time);
		}
		
		// compute declination angle of sun and equation of time
		// Ref: http://aa.usno.navy.mil/faq/docs/SunApprox.php
		private function sunPosition (jd:Number):Position 
		{
			var D:Number = jd - 2451545.0;
			var g:Number = DMath.fixAngle(357.529 + 0.98560028* D);
			var q:Number = DMath.fixAngle(280.459 + 0.98564736* D);
			var L:Number = DMath.fixAngle(q + 1.915* DMath.sin(g) + 0.020* DMath.sin(2*g));
			
			var R:Number = 1.00014 - 0.01671* DMath.cos(g) - 0.00014* DMath.cos(2*g);
			var e:Number = 23.439 - 0.00000036* D;
			
			var RA:Number = DMath.arctan2(DMath.cos(e)* DMath.sin(L), DMath.cos(L))/ 15;
			var eqt:Number = q/15 - DMath.fixHour(RA);
			var decl:Number = DMath.arcsin(DMath.sin(e)* DMath.sin(L));
			
			return new Position(decl, eqt);
		}
		
		// convert Gregorian date to Julian day
		// Ref: Astronomical Algorithms by Jean Meeus
		private function julian (year:Number, month:Number, day:Number):Number
		{
			if (month <= 2)
			{
				year -= 1;
				month += 12;
			}
			var A:Number = Math.floor(year/ 100);
			var B:Number = 2- A+ Math.floor(A/ 4);
			
			return Math.floor(365.25* (year + 4716)) + Math.floor(30.6001* (month+ 1)) + day + B - 1524.5;
		}

		
		//---------------------- Compute Prayer Times -----------------------
		
		// compute prayer times at given julian date
		private function computePrayerTimes (times:Times):Times
		{
			times = this.dayPortion(times);
			
			var ret:Times = new Times(times.date);
			
			ret.fajr    = this.sunAngleTime(calculationMethod.fajrAngle, times.fajr, 'ccw');
			ret.sunrise = this.sunAngleTime(this.riseSetAngle(), times.sunrise, 'ccw');  
			ret.dhuhr   = this.midDay(times.dhuhr);
			ret.asr     = this.asrTime(this.asrFactor(calculationMethod.asrMethod), times.asr);
			ret.sunset  = this.sunAngleTime(this.riseSetAngle(), times.sunset);
			ret.maghrib = this.sunAngleTime(calculationMethod.maghribAngle, times.maghrib);
			ret.isha    = this.sunAngleTime(calculationMethod.ishaAngle, times.isha);
			
			return ret;
		}
		
		// compute prayer times 
		private function computeTimes ():Times
		{
			// default times
			var times:Times = new Times(date);
			
			// main iterations
			for (var i:uint=1 ; i<=numIterations ; i++) 
				times = this.computePrayerTimes(times);
			
			times = this.adjustTimes(times);
			
			// add midnight time
			times.midnight = (calculationMethod.midnightMethod == MidnightMode.JAFARI) ? times.sunset+ this.timeDiff(times.sunset, times.fajr)/ 2 : times.sunset+ this.timeDiff(times.sunset, times.sunrise)/ 2;
			
			times = this.tuneTimes(times);
			return this.modifyFormats(times);
		}
		
		// adjust times 
		private function adjustTimes (times:Times):Times
		{
			//for each(var n:String in times.names)
			//	trace( n , times[n]);
			//var params = setting;
			for each(var s:String in times.names)
				times[s] += timeZone - lng/ 15;
			
			if (highLats != HighLatMethod.NONE)
				times = this.adjustHighLats(times);
			
			/*if (this.isMin(params.imsak))
			times.imsak = times.fajr- this.eval(params.imsak)/ 60;
			if (this.isMin(params.maghrib))
			times.maghrib = times.sunset+ this.eval(params.maghrib)/ 60;
			if (this.isMin(params.isha))
			times.isha = times.maghrib+ this.eval(params.isha)/ 60;
			times.dhuhr += this.eval(params.dhuhr)/ 60; */
			
			times.imsak = times.fajr - calculationMethod.imsakOffset/60;
			
			if(!isNaN(calculationMethod.maghribOffset))
				times.maghrib = times.sunset + calculationMethod.maghribOffset / 60;

			if(!isNaN(calculationMethod.ishaOffset))
				times.isha = times.maghrib + calculationMethod.ishaOffset / 60;
			
			times.dhuhr += calculationMethod.dhuhrOffset / 60; 
			
			return times;
		}
		
		// get asr shadow factor
		private function asrFactor (asrParam:String):Number
		{
			return asrParam==JuristicMethod.HANAFI ? 2 : 1;
			//var factor = {Standard: 1, Hanafi: 2}[asrParam];
			//return factor || this.eval(asrParam);
		}
		
		// return sun angle for sunset/sunrise
		private function riseSetAngle ():Number
		{
			//var earthRad = 6371009; // in meters
			//var angle = DMath.arccos(earthRad/(earthRad+ elv));
			var angle:Number = 0.0347* Math.sqrt(elv); // an approximation
			return 0.833+ angle;
		}
		
		// apply offsets to the times
		private function tuneTimes (times:Times):Times
		{
			//for each(var t:Number in times.values)
			//	times[i] += offset[i]/ 60; 
			return times;
		}
		
		// convert times to given time format
		private function modifyFormats (times:Times):Times
		{
			//for each(var t:Number in times.values)
			//	t = this.getFormattedTime(t, timeFormat); 
			return times;
		}
		
		// adjust times for locations in higher latitudes
		private function adjustHighLats (times:Times):Times
		{
			var nightTime:Number = this.timeDiff(times.sunset, times.sunrise); 
			
			times.imsak = this.adjustHLTime(times.imsak, times.sunrise, calculationMethod.imsakOffset, nightTime, 'ccw');
			times.fajr  = this.adjustHLTime(times.fajr, times.sunrise, calculationMethod.fajrAngle, nightTime, 'ccw');
			times.isha  = this.adjustHLTime(times.isha, times.sunset, calculationMethod.ishaAngle, nightTime);
			times.maghrib = this.adjustHLTime(times.maghrib, times.sunset, calculationMethod.maghribAngle, nightTime);
			
			return times;
		}
		
		// adjust a time for higher latitudes
		private function adjustHLTime (time:Number, base:Number, angle:Number, night:Number, direction:String="cw"):Number
		{
			var portion:Number = this.nightPortion(angle, night);
			var timeDif:Number = (direction == 'ccw') ? timeDiff(time, base) : timeDiff(base, time);
			if ( isNaN(time) || timeDif > portion ) 
				time = base + (direction == 'ccw' ? -portion : portion);
			return time;
		}		
		
		// the night portion used for adjusting times in higher latitudes
		private function nightPortion (angle:Number, night:Number):Number
		{
			var portion:Number = 0.5; // MidNight
			if (highLats == HighLatMethod.ANGLE_BASED)
				portion = 1/60* angle;
			else if (highLats == HighLatMethod.ONE_SEVENTH)
				portion = 1/7;
			return portion * night;
		}
		
		// convert hours to day portions 
		private function dayPortion (times:Times):Times
		{
			for each(var n:String in times.names)
				times[n] /= 24;
			return times;
		}
		
		/*
		//---------------------- Time Zone Functions -----------------------
		
		
		// get local time zone
		getTimeZoneprivate function  (date) {
			var year = date[0];
			var t1 = this.gmtOffset([year, 0, 1]);
			var t2 = this.gmtOffset([year, 6, 1]);
			return Math.min(t1, t2);
		},
		
		
		// get daylight saving for a given date
		getDstprivate function  (date) {
			return 1* (this.gmtOffset(date) != this.getTimeZone(date));
		},
		
		
		// GMT offset for a given date
		gmtOffsetprivate function  (date) {
			var localDate = new Date(date[0], date[1]- 1, date[2], 12, 0, 0, 0);
			var GMTString = localDate.toGMTString();
			var GMTDate = new Date(GMTString.substring(0, GMTString.lastIndexOf(' ')- 1));
			var hoursDiff = (localDate- GMTDate) / (1000* 60* 60);
			return hoursDiff;
		},
		*/
		
		//---------------------- Misc Functions -----------------------
		
		// convert given string into a number
		private function eval (str) : Number 
		{
			return 1* (str+ '').split(/[^0-9.+-]/)[0];
		}
		
		// detect if input contains 'min'
		/*private function isMin (arg) : Boolean 
		{
			return String(arg).indexOf("min") != -1;
		}*/
		
		// compute the difference between two times 
		private function timeDiff (time1:Number, time2:Number) : Number 
		{
			return DMath.fixHour(time2 - time1);
		}
		

		
	}
}

internal class Position
{
	public var declination:Number;
	public var equation:Number;
	
	public function Position(declination:Number, equation:Number)
	{
		this.declination = declination;
		this.equation = equation;
	}
}
