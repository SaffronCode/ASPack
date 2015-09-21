package {
	public class Shamsi {
	    

	    private static function Divides(a:Number, b:Number):Number {
	        return (int(a/b));
	    }
	    public static function MiladiToShamsi(YYYY_Miladi:Number, MM_Miladi:Number, DD_Miladi:Number):Array {
			DD_Miladi+=8;
	        var Month_Miladi:Array = new Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
	        var Day_Miladi:Array = new Array(31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29);
	        var YYYY_Temp_Miladi:int = int(YYYY_Miladi-1600);
	        var Month_Temp_Miladi:int = int(MM_Miladi-1);
	        var Day_Temp_Miladi:int = int(DD_Miladi-1);
	        var DD_Miladi_no:int = int(int(365)*YYYY_Temp_Miladi+Divides(YYYY_Temp_Miladi+3, 4)-Divides((YYYY_Temp_Miladi+99), 100)+Divides((YYYY_Temp_Miladi+399), 400));
	        for (var i = 0; i<Month_Temp_Miladi; ++i) {
	            DD_Miladi_no += Month_Miladi[i];
	        }
	        if (Month_Temp_Miladi>1 && ((YYYY_Temp_Miladi%4 == 0 && YYYY_Temp_Miladi%100 != 0) || (YYYY_Temp_Miladi%400 == 0))) {
	            DD_Miladi_no++;
	        }
	        DD_Miladi_no += Day_Temp_Miladi;
	        var Day_Result_Milady:Number = DD_Miladi_no-80-(12-5);
	        var Result_Milady:Number = Divides(Day_Result_Milady, 12053);
	        Day_Result_Milady = Day_Result_Milady%12053;
	        var Year_Result_Milady:Number = 979+33*Result_Milady+4*Divides(Day_Result_Milady, 1461);
	        Day_Result_Milady %= 1461;
	        if (Day_Result_Milady>=366) {
	            Year_Result_Milady += Divides(Day_Result_Milady-1, 365);
	            Day_Result_Milady = (Day_Result_Milady-1)%365;
	        }
	        for (i = 0; i<11 && Day_Result_Milady>=int(Day_Miladi[i]); ++i) {
	            Day_Result_Milady -= Day_Miladi[i];
	        }
	        var Month_Result_Milady:Number = i+1;
	        var day_Result_Milady:Number = Day_Result_Milady+1;
	        return new Array(Year_Result_Milady, Month_Result_Milady, day_Result_Milady);
	    }
	   	public static function ShamsiToMiladi(j_y:Number, j_m:Number, j_d:Number):Array {
			j_d-=8
	        var Month_Miladi:Array = new Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
	        var Day_Miladi:Array = new Array(31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29);
	        var Year_Result_Milady:Number = j_y-979;
	        var Month_Result_Milady:Number = j_m-1;
	        var day_Result_Milady:Number = j_d-1;
	        var Day_Result_Milady:Number = 365*Year_Result_Milady+Divides(Year_Result_Milady, 33)*8+Divides(Year_Result_Milady%33+3, 4);
	        for (var i = 0; i<int(Month_Result_Milady); ++i) {
	            Day_Result_Milady += Day_Miladi[i];
	        }
	        Day_Result_Milady += day_Result_Milady;
	        var DD_Miladi_no:Number = Day_Result_Milady+80+(12-5);
	        var YYYY_Temp_Miladi:Number = 1600+400*Divides(DD_Miladi_no, 146097);
	        DD_Miladi_no = DD_Miladi_no%146097;
	        var leap:Boolean = true;
	        if (DD_Miladi_no>=36525) {
	            DD_Miladi_no--;
	            YYYY_Temp_Miladi += 100*Divides(DD_Miladi_no, 36524);
	            DD_Miladi_no = DD_Miladi_no%36524;
	            if (DD_Miladi_no>=365) {
	                DD_Miladi_no++;
	            } else {
	                leap = false;
	            }
	        }
	        YYYY_Temp_Miladi += 4*Divides(DD_Miladi_no, 1461);
	        DD_Miladi_no %= 1461;
	        if (DD_Miladi_no>=366) {
	            leap = false;
	            DD_Miladi_no--;
	            YYYY_Temp_Miladi += Divides(DD_Miladi_no, 365);
	            DD_Miladi_no = DD_Miladi_no%365;
	        }
	        for (i = 0; DD_Miladi_no>=Month_Miladi[i]+(i == 1 && leap); i++) {
	            DD_Miladi_no -= Month_Miladi[i]+(i == 1 && leap);
	        }
	        var Month_Temp_Miladi:Number = i+1;
	        var Day_Temp_Miladi:Number = DD_Miladi_no+1;
	        return new Array(YYYY_Temp_Miladi, Month_Temp_Miladi, Day_Temp_Miladi);
	    }
	}
}