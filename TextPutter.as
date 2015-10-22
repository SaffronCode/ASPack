// *************************
// * COPYRIGHT
// * DEVELOPER: MTEAM ( info@mteamapp.com )
// * ALL RIGHTS RESERVED FOR MTEAM
// * YOU CAN'T USE THIS CODE IN ANY OTHER SOFTWARE FOR ANY PURPOSE
// * YOU CAN'T SHARE THIS CODE
// *************************

/**version log
 * varsion 1.1 - cash supports OnButton() function   -  92-12-28
 * 					arabic number support is added on onButton() function, this will change all numbers in arabic
 * version 	1.2 - replace with bitmap added to onBigTexts function		
 * 			1.3 - capture the textField added to OnBigField function 
 * 				- selective resolution for captured fields added to functions		
 * 			1.4 - It uses CaptureBitmap Class to capture huge textFields to
 * 			1.4.1 - arabic numbers can requested without using convertor itself.
 * 			1.4.2 - Text controller line added to on Button function to prevent Error when you pass null as text to it.
 * 
 */


package
{
	import com.mteamapp.StringFunctions;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.text.TextField;

	/**for the menus and objects that has'nt enaugh space for larg strings , you can use this class
	 * to add your thex in to a TextField. it will check if the string is larger than TextField area
	 * it will resize that text field to accomodate it in your area.<br>
	 * this class can capture your textField to a bitmap for ipad s devices<br>
	 * 
	 * the object must have this parameters:<br>
	 * 1- the specified text field have to be the only child of its parent.
	 * 2- text fields had to be on single line state
	 * 
	 * <br>
	 * <br>
	 * 
	 * you can useCash*/
	public class TextPutter
	{
		public var target:MovieClip ;
		public var txt:TextField ;
		
		/**Last info variables*/
		public static var 	lastInfo_numLines:uint,
							lastInfo_textWidth:Number,
							lastInfo_textHeidth:Number;
		
		
		public function TextPutter(targ:MovieClip)
		{
			super();
			target = targ ;
			txt = Obj.findThisClass(TextField,target);
		}
		
		
		
//////////////////////////////////////////////////////////////
		
		
		private static const mustRemove:String = 'removeThis';
		
		private static const debugVersion:Boolean = false;
		
		/**default resolution for captured images*/
		public static var defaultResolution:Number = 2 ;
		
		
		/**Split extra text is not working .*/
		public static function OnButton(textField:TextField,text:String,arabic:Boolean=false,replaceWithBitmap:Boolean=false,useCash:Boolean=false,arabicNumber:Boolean=false,captureResolution:Number=0,splitTheExtraText:Boolean=false):void
		{
			/**the object that have to remove befor star, it added from last tryes*/
			if(captureResolution<=0)
			{
				captureResolution = defaultResolution ;
			}
			
			//This is new line to prevent error on English app when you passed undefined value trow this functin to te TextField.
			if(text == null)
			{
				text = '' ;
			}
			
			textField.wordWrap = false ;
			textField.multiline = false;
			
			var size:Number = textField.width ;
			textField.multiline = false;
			textField.scaleX = textField.scaleY = 1 ;
			textField.width = size ;
			textField.x = textField.y = 0 ;
			textField.visible = true ;
			
			var removeThis = textField.parent.getChildByName(mustRemove);
			if(removeThis!=null)
			{
				textField.parent.removeChild(removeThis);
			}
			
			if(arabic)
			{
				textField.text = UnicodeStatic.convert(text,useCash,arabicNumber);
			}
			else
			{
				if(arabicNumber)
				{
					text = UnicodeStatic.arabicNumber(text);
				}
				textField.text = text;
			}
			
			/*if(splitTheExtraText)
			{
				textField.
			}*/
			
			//manage ing text field size
			if( textField.textWidth > textField.width-5 )
			{
				var maxW:Number = textField.width ;
				var maxH:Number = textField.height ;
				
				textField.width = textField.textWidth+10 ;
				textField.scaleX = textField.scaleY = maxW/textField.width ;
				
				textField.y = (maxH-textField.height)/2 ;
				textField.x = 0 ;
			}
			
			
			lastInfo_numLines = textField.numLines ;
			lastInfo_textWidth = textField.textWidth;
			lastInfo_textHeidth = textField.textHeight;
			
			//capture the textfield
			if(replaceWithBitmap)
			{
				var bitmapData:BitmapData = new BitmapData((textField.x+textField.width)*captureResolution
					,(textField.y+textField.height)*captureResolution,true,0);
				bitmapData.draw(textField.parent,new Matrix(captureResolution,0,0,captureResolution),null,null,null,true);
				var bitmap:Bitmap = new Bitmap(bitmapData,"auto",true);
				textField.visible = false;
				bitmap.scaleX = bitmap.scaleY = 1/captureResolution;
				bitmap.name = mustRemove;
				textField.parent.addChild(bitmap);
			}
		}
		
		/**put texts on the big textField areas*/
		public static function OnBigField(textField:TextField,text:String,arabic:Boolean=false,captureBitmap:Boolean = false,captureResolution:Number=0)
		{
			if(captureResolution<=0)
			{
				captureResolution = defaultResolution ;
			}
			
			textField.multiline = false;
			
			textField.multiline = true;
			textField.wordWrap = true ;
			textField.visible = true ;
			
			var removeThis = textField.parent.getChildByName(mustRemove);
			
			if(arabic)
			{
				UnicodeStatic.htmlText(textField,text,false,true,false);
			}
			else
			{
				textField.text = text ;
			}
			
			
			
			
			textField.height = textField.textHeight+20 ;
			
			lastInfo_numLines = textField.numLines ;
			lastInfo_textWidth = textField.textWidth;
			lastInfo_textHeidth = textField.textHeight;
			
			if(captureBitmap)
			{
				var bitmapData:BitmapData = new BitmapData((textField.x+textField.width)*captureResolution
					,(textField.y+textField.height)*captureResolution,true,0);
				bitmapData.draw(textField.parent,new Matrix(captureResolution,0,0,captureResolution),null,null,null,true);
				var bitmap:Bitmap = new Bitmap(bitmapData,"auto",true);
				textField.visible = false;
				bitmap.scaleX = bitmap.scaleY = 1/captureResolution;
				bitmap.name = mustRemove;
				textField.parent.addChild(bitmap);
			}
		}
		
		
		/**Return textwidth*/
		public static function onTextArea(textField:TextField,text:String,arabic:Boolean=false,replaceWithBitmap:Boolean=false,useCash:Boolean = false,captureResolution:Number=0,align:Boolean = true,convertSerevHTML:Boolean=false,linksColor:int=-1,generateLinksForURLs:Boolean=false):Number
		{
			//I dont need the extra line any more. please controll the scroller size your self
			//text+=' \n ';
			if(captureResolution<=0)
			{
				captureResolution = defaultResolution ;
			}
			
			if(convertSerevHTML)
			{
				var fontSize:Number = Number(textField.defaultTextFormat.size) ;
				text = Unicode.htmlCorrect(text,linksColor,!replaceWithBitmap,fontSize);
			}
			
			if(generateLinksForURLs)
			{
				text = StringFunctions.generateLinks(text,linksColor);//Unicode.htmlCorrect(text,linksColor,!replaceWithBitmap,fontSize);
				//trace("Text changed to : "+text)
			}
			
			//textField.multiline = true;
			//textField.wordWrap = true;
			
			/*var removeThis = textField.parent.getChildByName(mustRemove);
			if(removeThis!=null)
			{
				textField.parent.removeChild(removeThis);
			}*/
			
			//Replaced with this function
			CaptueBitmap.deleteCapturedBigText(textField);
			
			textField.visible = true ;
			
			if(arabic)
			{
				UnicodeStatic.htmlText(textField,text,useCash,true,align);
			}
			else
			{
				textField.text = text ;
			}
			
			lastInfo_numLines = textField.numLines ;
			lastInfo_textWidth = textField.textWidth;
			lastInfo_textHeidth = textField.textHeight;
			
			var textWidth:Number = textField.textWidth ;
			
			
			//textField.multiline = true ;
			//textField.wordWrap = true ;
			
			
			textField.height = textField.textHeight+20 ;
			
			
			
			//capture the textfield
			if(replaceWithBitmap)
			{
				/*var bitmapData:BitmapData = new BitmapData((textField.x+textField.width)*captureResolution
					,(textField.y+textField.height)*captureResolution,true,0);
				bitmapData.draw(textField.parent,new Matrix(captureResolution,0,0,captureResolution),null,null,null,true);
				var bitmap:Bitmap = new Bitmap(bitmapData,"auto",true);
				textField.visible = false;
				bitmap.scaleX = bitmap.scaleY = 1/captureResolution;
				bitmap.name = mustRemove;
				textField.parent.addChild(bitmap);*/
				
				//Added on version 1.5
				CaptueBitmap.captureBigTextFields(textField,captureResolution);
			}
			
			return textWidth ;
		}
		
		
		public static function onStaticArea(textField:TextField,text:String,arabic:Boolean=false,replaceWithBitmap:Boolean=false,useCash:Boolean = false,captureResolution:Number=0,justify:Boolean=true)
		{
			var firstHeight:Number = textField.height ;
			
			if(captureResolution<=0)
			{
				captureResolution = defaultResolution ;
			}
			//textField.multiline = true;
			//textField.wordWrap = true;
			
			var removeThis = textField.parent.getChildByName(mustRemove);
			if(removeThis!=null)
			{
				textField.parent.removeChild(removeThis);
			}
			
			textField.visible = true ;
			
			if(arabic)
			{
				UnicodeStatic.htmlText(textField,text,useCash,true,justify);
			}
			else
			{
				textField.text = text ;
			}
			
			
			//textField.multiline = true ;
			//textField.wordWrap = true ;
			
			
			textField.height = firstHeight ;
			
			while(textField.maxScrollV>1)
			{
				textField.text = textField.text.substring(0,textField.text.lastIndexOf('\n'));
			}
			
			
			lastInfo_numLines = textField.numLines ;
			lastInfo_textWidth = textField.textWidth;
			lastInfo_textHeidth = textField.textHeight;
			
			
			//capture the textfield
			if(replaceWithBitmap)
			{
				var bitmapData:BitmapData = new BitmapData((textField.x+textField.width)*captureResolution
					,(textField.y+textField.height)*captureResolution,true,0);
				bitmapData.draw(textField.parent,new Matrix(captureResolution,0,0,captureResolution),null,null,null,true);
				var bitmap:Bitmap = new Bitmap(bitmapData,"auto",true);
				textField.visible = false;
				bitmap.scaleX = bitmap.scaleY = 1/captureResolution;
				bitmap.name = mustRemove;
				textField.parent.addChild(bitmap);
			}
		}
	}
}