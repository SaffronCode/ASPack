/**bug reported : 
 * 		when a field is selected in ios , you can not select other field, i did not understand why but
 * 		it will close the field just after the field is visibled
 * 	>	SoftKeyboard Event Listener is not added To the myStageText if de os is IOS
 * 
 * varsion : 1.0.1 : Do not embed text fields that are show as passworld
 * 			 1.1 : mulitline debugged
 * 
 * 1.1.1 : convert text if you tell him
 * 1.1.2 : global arabic corrector added.
 * 1.2	: performance improved by remove the stageText when it is not using.
 * 
 * 
 * 
 * 
 * 
 * 
 * 
 */

package
{
	import com.mteamapp.StringFunctions;
	
	import contents.alert.Alert;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.text.AutoCapitalize;
	import flash.text.ReturnKeyLabel;
	import flash.text.SoftKeyboardType;
	import flash.text.StageText;
	import flash.text.StageTextInitOptions;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import flash.desktop.Clipboard;

	public class FarsiInputCorrection
	{
		
		
		private static const REMOVE_OLD_TEXT:String = "REMOVE_OLD_TEXT" ;
		
		/**uneable EnterFrame*/
		public static var betterPerformanc:Boolean = false;
		
		/**Dispatch it on a textField that you whant to fucus on*/
		public static const FOCUS_IN:String = "FOCUS_ON" ;
		
		/**Prevent any unicode changing on texts<br>
		 * NOT TEST YET*/
		public static var preventConvertor:Boolean = false ;
		
		/**Set input text to arabic script if it has one arabic character<br>
		 * NOT TEST YET*/
		public static var detectArabic:Boolean = false ;
		
		private var newTextField:TextField,
					myStageText:StageText;
		/**This is the main text field*/
		private var oldTextField:TextField;
		
		private var itsArabic:Boolean,
					keyFormat:String,
					
					returnLable:String;
					
		/**Is text editing?*/
		public var editing:Boolean = false;
					
		/**This value will prevent the convertor to convert the text to Unicode, and the texts will only show on native stage text*/
		private var onlyNativeText:Boolean = false ;
					
		private static var hideAllTexts:EventDispatcher = new EventDispatcher();
		
		private static const HIDE_OTEHER_TEXTS:String = 'hideOtherTexts';
		private var correctNums:Boolean;
		
		/**This is new variable that will cause to reset input text when it's selected at the first time*/
		private var clearInputText:Boolean  ;
		
		/**Works only for native texts and make it editable or not*/
		private var editableNativeText:Boolean;
		
		private var onDone:Function ;
		
		/**Add change listener to the stage text*/
		private var listenToChangesAllTheTime:Boolean = false ;
		private var focusOutTimeOutId:uint;

		public static var clearClipBoardsBeforInsert:Boolean = false ;
		
		/**This text will show on output whenever the input field was empty*/
		private var inputLableText:String = '' ;
					
		/**this function will make your input text edittable with stageText that will show farsi texts correctly on it<br>
		 * remember to ember fonts that used on the textField<br>
		 * CLOSE event dispatches when the keyboard leaved the text area<br>
		 * OnDoneFunction can get the selectedTextField
		 */
		public static function setUp(textField:TextField,softKeyFormat:String = SoftKeyboardType.DEFAULT,convertArabic:Boolean=true,correctingArabicNumbers:Boolean = true,clearAfterClicked:Boolean = false,justShowNativeText:Boolean=false,editableNative:Boolean=true,controllStageChangesTo:Boolean=true,ReturnLable:String=ReturnKeyLabel.DEFAULT,onDoneFunction:Function=null,restrictCharacterRange:String=null):FarsiInputCorrection
		{
			if(softKeyFormat == null)
			{
				softKeyFormat = SoftKeyboardType.DEFAULT ;
			}
			if(ReturnLable == null)
			{
				ReturnLable=ReturnKeyLabel.DEFAULT ;
			}
			return new FarsiInputCorrection(textField,softKeyFormat,convertArabic,correctingArabicNumbers,clearAfterClicked,justShowNativeText,editableNative,controllStageChangesTo,ReturnLable,onDoneFunction,restrictCharacterRange);
		}
		
		/**reset all added effects on this text field*/
		public static function clear(textField:TextField)
		{
			textField.dispatchEvent(new Event(Event.REMOVED_FROM_STAGE));
		}

		
		public function FarsiInputCorrection(textField:TextField,softKeyFormat:String,convertArabic:Boolean=true,correctNumbers:Boolean = true,clearAfterClicked:Boolean = false,justShowNativeText:Boolean = false,editableNative:Boolean=true,controllStageTextsToo:Boolean=false,ReturnLable:String=ReturnKeyLabel.DEFAULT,onDoneFunction:Function=null,restrictCharacterRange:String=null)
		{
			listenToChangesAllTheTime = controllStageTextsToo ;
			clearInputText = clearAfterClicked ;
			correctNums = correctNumbers ;
			oldTextField = textField ;
			keyFormat = softKeyFormat ;
			returnLable = ReturnLable ;
			onlyNativeText = justShowNativeText ;
			editableNativeText = editableNative ;
			onDone = onDoneFunction ;
			if(restrictCharacterRange==null && softKeyFormat!=null)
			{
				switch(softKeyFormat)
				{
					case SoftKeyboardType.DECIMAL:
					case SoftKeyboardType.PHONE:
					case SoftKeyboardType.NUMBER:
					{
						restrictCharacterRange = "0-9.+\\-٠-٩۰-۹"
						break;
					}
				}
			}
			oldTextField.restrict = restrictCharacterRange ;
			if(preventConvertor)
			{
				itsArabic = false ;
			}
			else
			{
				itsArabic = convertArabic ;
			}
			
			//oldTextField.visible = false;
			checkTheItemStage();
		}
		
		/**check if item is added to stage or not*/
		private function checkTheItemStage()
		{
			if(oldTextField.stage == null)
			{
				oldTextField.addEventListener(Event.ADDED_TO_STAGE,manageText);
			}
			else
			{
				manageText();
			}
		}
		
		/**manage text after its added to stage*/
		private function manageText(e=null)
		{
			//trace('item is added to stage');
			
			oldTextField.dispatchEvent(new Event(REMOVE_OLD_TEXT));
			oldTextField.addEventListener(FOCUS_IN,focuseOnStageText);
			
			oldTextField.alpha = 0 ;
			
			var oldText:String = oldTextField.text;
			oldTextField.text = '-';
			oldTextField.selectable =false;
			var textFormat:TextFormat = oldTextField.getTextFormat();
			oldTextField.text = oldText ;
			if(!onlyNativeText)
			{
				newTextField = new TextField();
				newTextField.defaultTextFormat = textFormat ;
				
				
				newTextField.width = oldTextField.width ;
				newTextField.height = oldTextField.height ;
				newTextField.x = oldTextField.x ;
				newTextField.y = oldTextField.y ;
				
				
				newTextField.multiline = oldTextField.multiline;
				newTextField.wordWrap = oldTextField.wordWrap ;
				newTextField.selectable = false;
				newTextField.type = TextFieldType.DYNAMIC ;
				newTextField.displayAsPassword = oldTextField.displayAsPassword ;
				
				newTextField.border = oldTextField.border;			
				newTextField.borderColor = oldTextField.borderColor;
				newTextField.background = oldTextField.background;
				newTextField.backgroundColor = oldTextField.backgroundColor;
				newTextField.textColor = oldTextField.textColor;
				newTextField.maxChars = oldTextField.maxChars;
				//ios has not these bullet on font
				if(oldTextField.displayAsPassword)
				{
					newTextField.embedFonts = false  ;
				}
				else
				{
					newTextField.embedFonts = oldTextField.embedFonts  ;
				}
				
				oldTextField.parent.addChild(newTextField);
				changeTheDisplayedText();
			}
			
			
			if(clearInputText)
			{
				//Reset the input text field if needed.
				inputLableText = oldTextField.text ; 
				oldTextField.text = '' ;
				if(!onlyNativeText)
				{
					newTextField.displayAsPassword = false ;
					newTextField.embedFonts = oldTextField.embedFonts  ;
					newTextField.textColor = grayScale(oldTextField.textColor);
				}
			}
			
			var stageTextOption:StageTextInitOptions = new StageTextInitOptions(oldTextField.multiline);
			myStageText = new StageText(stageTextOption);
			myStageText.stage = oldTextField.stage;
			myStageText.color = oldTextField.textColor ;
			myStageText.restrict = oldTextField.restrict ;
			myStageText.autoCorrect = false ;
			myStageText.autoCapitalize = AutoCapitalize.NONE ;
			
			myStageText.displayAsPassword = oldTextField.displayAsPassword;
			if(editableNativeText)
			{
				myStageText.maxChars = 			oldTextField.maxChars;
			}
			myStageText.editable = editableNativeText ;
			if(DevicePrefrence.isItPC)
			{
				myStageText.fontFamily = textFormat.font.split(" Bold").join("").split(" Regular").join("");
			}
			myStageText.fontSize = Math.round(Number(textFormat.size)*DevicePrefrence.StageScaleFactor());
			//trace("myStageText.fontSize : "+myStageText.fontSize);
			//trace('the key oard is : '+keyFormat);
			if(editableNativeText)
			{
				myStageText.softKeyboardType = keyFormat;
				myStageText.returnKeyLabel = returnLable;
			}
			
			if(textFormat.align == null)
			{
				myStageText.textAlign = TextFormatAlign.CENTER ;
			}
			else
			{
				myStageText.textAlign = textFormat.align ;
			}
			
			//myStageText.addEventListener(FocusEvent.FOCUS_IN,hideTextField);
			//switched with below line to prevent myStage to stay at top↓
			if(!onlyNativeText)
			{
				newTextField.addEventListener(MouseEvent.CLICK,focuseOnStageText);
			}
			else
			{
				//oldTextField.visible = false ;
				myStageText.visible = true ;
				myStageText.stage = oldTextField.stage ;
				myStageText.text = correctNativeNewLines(oldTextField.text) ;
				manageInputPose();
			}
			
			if(!DevicePrefrence.isIOS())
			{
				myStageText.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE,saveChanges);
			}
			if(listenToChangesAllTheTime)
			{
				myStageText.addEventListener(Event.CHANGE,onlyChangeTheCoreText);
			}
			myStageText.addEventListener(FocusEvent.FOCUS_OUT,saveChanges);
			if(clearClipBoardsBeforInsert)
				myStageText.addEventListener(FocusEvent.FOCUS_IN,focus);
			
			
			
			myStageText.addEventListener(KeyboardEvent.KEY_UP,traceTheKeyCode,false,1000);
				
				
			if(!onlyNativeText)
			{
				hideAllTexts.addEventListener(HIDE_OTEHER_TEXTS,saveChanges);
				myStageText.visible = false;
				//Make It faster
				myStageText.stage = null ;
				
				manageInputPose();
				oldTextField.addEventListener(Event.CHANGE,changeTheDisplayedText);	
			}
			else
			{
				oldTextField.addEventListener(Event.CHANGE,changeTheStageText);
			}
			
			if(!betterPerformanc)
			{
				oldTextField.addEventListener(Event.ENTER_FRAME,manageInputPose);
			}
			
			oldTextField.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
			oldTextField.addEventListener(Event.ADDED_TO_STAGE,reloadAgain);
			oldTextField.addEventListener(REMOVE_OLD_TEXT,unLoad);
		}

		/**
		 * On StageText focused
		 */
		private function focus(e:FocusEvent):void
		{
			Clipboard.generalClipboard.clear();
		}
		
		
		private function traceTheKeyCode(e:KeyboardEvent)
		{
			//Only next and Default button type can dispatch this event
			trace("e.keyCode : "+e.keyCode);
			if(e.keyCode == 16777230 || (!oldTextField.multiline && e.keyCode==13))
			{
				trace("On closed event");
				closeSoftKeyBoard();
			}
		}
		
		/**Close the keyboard*/
		public function closeKeyBoard():void
		{
			closeSoftKeyBoard();
			changeTheDisplayedText();
		}
		
		private function closeSoftKeyBoard():void
		{
			if(oldTextField.stage!=null)
			{
				oldTextField.stage.focus = null ;
			}
			dispatchOnDone();
		}
		
			/**This will dispatches on done with delay*/
			private function dispatchOnDone():void
			{
				clearTimeout(focusOutTimeOutId);
				if(onDone!=null)
				{
					focusOutTimeOutId = setTimeout(callDone,1);
				}
			}
				
				/**Call the onDone function in bet way*/
				protected function callDone():void
				{
					if(onDone.length==1)
					{
						onDone.apply(this,[oldTextField]);
					}
					else
					{
						onDone();
					}
				}		
		
		
		
		/**Create grayscale color from the mail color*/
		private function grayScale(textColor:uint):uint
		{
			var R:uint = textColor&0xff0000;//1111111100000000
											//1021010101001010
											//1021010100000000
			var G:uint = textColor&0x00ff00;
			var B:uint = textColor&0x0000ff;
			
			R = Math.min(0xff0000,uint(R+0xff0000)/2&0xff0000);
			G = Math.min(0x00FF00,uint(G+0x00ff00)/2&0x00ff00);
			B = Math.min(0x0000ff,uint(B+0x0000ff)/2&0x0000ff);
			
			return R|G|B;
		}
		
		protected function changeTheStageText(event:Event):void
		{
			
			myStageText.text = oldTextField.text ;
		}
		
		/**This will replace each new line charachter to both \n and \r to make sure that the enter will apprear for that*/
		private function correctNativeNewLines(str:String):String
		{
			//var changedString:String = str.split('\n').join('\r').split('\r').join('\n\r');
			//trace('****************************\n'+visualString(str)+'\n'+visualString(changedString));
			return RemoveEnters(str).split('\n').join('\r');//.split('\r').join('\n\r');
		}
		
		public function RemoveEnters(str:String):String
		{
			return str;//.split('\r').join('');
		}
		
		private function visualString(str:String):String
		{
			return str.split(' ').join('[SPACE]').split('\t').join('[TAB]').split('\r').join('[NEWLINE R]').split('\n').join('[NEWLINE N]');
		}
		
		public function focuseOnStageText(e:*=null)
		{
			//timerFocus.reset();
			//timerFocus.start();
			switchFocuse()
		}
		
		private function switchFocuse(e:TimerEvent=null)
		{
			if(!editing)
			{
				hideAllTexts.dispatchEvent(new Event(HIDE_OTEHER_TEXTS));
				oldTextField.stage.focus = null ;
				myStageText.visible = true ;
				//Make it faster
				myStageText.stage = oldTextField.stage ;
				//trace("visible the textfield");
				hideTextField();
				manageInputPose();
				myStageText.assignFocus();
				myStageText.selectRange(myStageText.text.length,myStageText.text.length);
			}
		}
		
		private function changeTheDisplayedText(e:Event=null)
		{
			if(onlyNativeText)
			{
				trace("This text is only on stageText");
				return ;
			}
			var updatedText:String ;
			var targetColor:uint ;
			if(oldTextField.text!='')
			{
				updatedText = oldTextField.text ;
				targetColor = oldTextField.textColor;
				newTextField.displayAsPassword = oldTextField.displayAsPassword ;
			}
			else
			{
				updatedText = inputLableText ;
				targetColor = grayScale(oldTextField.textColor);
				newTextField.displayAsPassword = false ;
			}
			if(itsArabic ||  ( detectArabic && StringFunctions.isPersian(updatedText)))
			{
				UnicodeStatic.fastUnicodeOnLines(newTextField,updatedText,false);
			}
			else
			{
				newTextField.text = updatedText ;
			}
			newTextField.textColor = targetColor ;
			newTextField.embedFonts = !newTextField.displayAsPassword  ;
		}

		public function reloadAgain(e:Event):void
		{
			if(!oldTextField.hasEventListener(Event.REMOVED_FROM_STAGE))
			{
				new FarsiInputCorrection(oldTextField,keyFormat,itsArabic,correctNums,clearInputText,onlyNativeText,editableNativeText,
					listenToChangesAllTheTime,returnLable,onDone,oldTextField.restrict);
			}
		}
		
		/**Clear the native text */
		public function unLoad(e:Event=null)
		{
			if(!betterPerformanc)
			{
				oldTextField.removeEventListener(Event.ENTER_FRAME,manageInputPose);
			}
			
			oldTextField.removeEventListener(Event.REMOVED_FROM_STAGE,unLoad);
			oldTextField.removeEventListener(REMOVE_OLD_TEXT,unLoad);
			oldTextField.removeEventListener(Event.CHANGE,changeTheDisplayedText);
			oldTextField.removeEventListener(FOCUS_IN,focuseOnStageText);
			
			oldTextField.alpha = 1 ;
			//oldTextField.text = "I'm removed";
			if(!onlyNativeText)
			{
				Obj.remove(newTextField);
			}
			myStageText.stage = null ;
			myStageText = null ;
			clearTimeout(focusOutTimeOutId);
		}
		
		/**start typing*/
		private function hideTextField(e:FocusEvent=null)
		{
			myStageText.text = correctNativeNewLines(oldTextField.text);
			if(!onlyNativeText)
			{
				newTextField.text = '';
			}
			editing = true ;
		}
		
		/***/
		private function onlyChangeTheCoreText(e:*):void
		{
			if(!myStageText.visible)
			{
				return;
			}
			trace("Text changed");
			if(correctNums)
			{
				oldTextField.text = RemoveEnters(UnicodeStatic.numberCorrection(myStageText.text));
			}
			else
			{
				oldTextField.text = RemoveEnters(myStageText.text);
			}
			if(DevicePrefrence.isPC())
			{
				myStageText.text = UnicodeStatic.KaafYe(myStageText.text);
			}
			oldTextField.text = UnicodeStatic.KaafYe(oldTextField.text);
			
			oldTextField.removeEventListener(Event.CHANGE,changeTheDisplayedText);	
			oldTextField.removeEventListener(Event.CHANGE,changeTheStageText);
			
			oldTextField.dispatchEvent(new Event(Event.CHANGE));
			if(!onlyNativeText)
			{
				oldTextField.addEventListener(Event.CHANGE,changeTheDisplayedText);	
			}
			else
			{
				oldTextField.addEventListener(Event.CHANGE,changeTheStageText);
			}
		}
		
		/**finish typing*/
		private function saveChanges(e:*)
		{
			//trace('why save the text?'+e+' \n\t: '+oldTextField.textColor.toString(16));
			//trace(e.currentTarget+' > '+(e.currentTarget == myStageText)+' vs '+(e.target == myStageText));
			if(editing || onlyNativeText)
			{
				editing = false;
				if(correctNums)
				{
					oldTextField.text = RemoveEnters(UnicodeStatic.numberCorrection(myStageText.text));
				}
				else
				{
					oldTextField.text = RemoveEnters(myStageText.text);
				}
				oldTextField.text = UnicodeStatic.KaafYe(oldTextField.text);
				if(!onlyNativeText)
				{
					myStageText.visible = false;
					myStageText.text = '' ;
				}
				//trace('invisible the text '+oldTextField.textColor.toString(16));
				
				oldTextField.dispatchEvent(new Event(Event.CHANGE));
				oldTextField.dispatchEvent(new Event(Event.CLOSE));
			}
		}
									   
		
		/***/
		private function manageInputPose(e:Event=null)
		{
			if(myStageText.visible || onlyNativeText)
			{
				if(!onlyNativeText)
				{
					newTextField.x = oldTextField.x;
					newTextField.y = oldTextField.y;
				}
				else
				{
					//f sdf fsd 
					//trace("Obj.isAccesibleByMouse(oldTextField) : "+Obj.isAccesibleByMouse(oldTextField));
					myStageText.visible = Obj.getVisible(oldTextField) && Obj.isAccesibleByMouse(oldTextField) ;
				}
				var rect:Rectangle = oldTextField.getBounds(oldTextField.stage);
				myStageText.viewPort = rect;
			}
		}
		
		public function showPass():void
		{
			newTextField.displayAsPassword = false ;
			newTextField.embedFonts = true ;
		}
		
		public function hidePass():void
		{
			newTextField.displayAsPassword = oldTextField.displayAsPassword ;	
			newTextField.embedFonts = !newTextField.displayAsPassword ;
		}
	}
}