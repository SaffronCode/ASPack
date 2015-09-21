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
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.SoftKeyboardEvent;
	import flash.geom.ColorTransform;
	import flash.net.getClassByAlias;
	import flash.text.*;
	import flash.utils.getTimer;
	
	
	/**make persian text fields editable with unicode convetor*/
	public class FarsiInputText
	{
		public static var addedTextFieldsName:String = new String("_SistersTextField")
		private static var firstTimeDecoder="_METLF879132FIRSTTIME";
		private static var mylastText:TextField;
		
		public static function steKeyBord(yourTextField:TextField,deleteFirstStringFromIt:Boolean=false)
		{
			yourTextField.embedFonts = false;
			if(yourTextField.parent==null){
				trace(new Error("Your TextFiled Had No Parents Or Its Not Added Yet."))
				return;	
			}
			
			var TextsParent = yourTextField.parent;
			var newTextField:TextField = new TextField();
			var cash
			if((cash = TextsParent.getChildByName(yourTextField.name+addedTextFieldsName))!=null){
				TextsParent.removeChild(cash);
			}
			if((cash = TextsParent.getChildByName(yourTextField.name+addedTextFieldsName+firstTimeDecoder))!=null){
				TextsParent.removeChild(cash);
			}
			//yourTextField.type = TextFieldType.DYNAMIC ;
			
			newTextField.width = yourTextField.width;
			newTextField.height = yourTextField.height ;
			newTextField.x = yourTextField.x ;
			newTextField.y = yourTextField.y ;
			newTextField.multiline = yourTextField.multiline;
			newTextField.wordWrap = yourTextField.wordWrap ;
			newTextField.selectable = false;
			newTextField.type = TextFieldType.DYNAMIC ;
			newTextField.displayAsPassword = yourTextField.displayAsPassword ;
			
			newTextField.border = yourTextField.border;			
			newTextField.borderColor = yourTextField.borderColor;
			newTextField.background = yourTextField.background;
			newTextField.backgroundColor = yourTextField.backgroundColor;
			newTextField.textColor = yourTextField.textColor;
			
			
			
			newTextField.name = yourTextField.name+addedTextFieldsName ;
			newTextField.alpha = 1;
			yourTextField.alpha = 0;
			//debug
			//yourTextField.visible = false
			//debug end
			updateFormat(newTextField,yourTextField);
			MovieClip(TextsParent).addChild(newTextField);
			
			newTextField.mouseEnabled = false;
			//MovieClip(TextsParent).swapChildren(newTextField,yourTextField);
			
			if(mylastText!=null){
				getSister(mylastText).alpha=1;
			}
			mylastText = null;
			
			//languageSwitch.setText(newTextField,yourTextField.text,false,languageSwitch.DEFAULT_FONT);
			//♠
				UnicodeStatic.fastUnicodeOnLines(newTextField,yourTextField.text);
			
			if(deleteFirstStringFromIt){
				newTextField.name=newTextField.name+firstTimeDecoder;
			}
			
			yourTextField.addEventListener(FocusEvent.FOCUS_IN,focused);
			yourTextField.addEventListener(FocusEvent.FOCUS_OUT,focusedOut);
			newTextField.addEventListener(Event.ENTER_FRAME,pakkonCheck);
			newTextField.addEventListener(Event.REMOVED_FROM_STAGE,removver);
			
			yourTextField.addEventListener(Event.CHANGE,manageSisters);
			yourTextField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_ACTIVATING,focused);
			yourTextField.addEventListener(SoftKeyboardEvent.SOFT_KEYBOARD_DEACTIVATE,focusedOut);
			yourTextField.addEventListener(Event.REMOVED_FROM_STAGE,pakkon2);
			yourTextField.needsSoftKeyboard = true ;
		}
		
		private static function softKey(e)
		{
			trace(" - "+e)
		}
		
		private static function pakkon2(e){
			var txt:TextField = e.target;
			txt.removeEventListener(Event.CHANGE,manageSisters);
			txt.removeEventListener(Event.REMOVED_FROM_STAGE,pakkon2);
		}
		
		private static function manageSisters(e){
			//trace('text is changed');
			//e.target.text = languageSwitch.farsiCorrection(e.target.text);
			if(DevicePrefrence.isItPC)
			{
				e.target.text = String(e.target.text).split('ی').join('ي');
			}
			var sis:TextField = getSister(e.target);
			updateFormat(sis,e.target);
			//languageSwitch.setText(sis,TextField(e.target).text,false,languageSwitch.DEFAULT_FONT,'','',true,0,true);
			//♠
				UnicodeStatic.fastUnicodeOnLines(sis,TextField(e.target).text);
		}
		
		private static function pakkonCheck(e){
			var sis:TextField = getSister(e.target);
			if(e.target.parent!=null && (sis == null || sis.parent == null || e.target.name.indexOf(sis.name)==-1)){
				MovieClip(e.target.parent).removeChild(e.target);
			}
		}
		
		private static function removver(e){
			if(mylastText == e.target){
				mylastText = null ;
			}
			getSister(TextField(e.currentTarget)).removeEventListener(FocusEvent.FOCUS_IN,focused);
			getSister(TextField(e.currentTarget)).removeEventListener(FocusEvent.FOCUS_OUT,focusedOut);
			TextField(e.currentTarget).removeEventListener(Event.REMOVED_FROM_STAGE,removver);
			TextField(e.currentTarget).removeEventListener(Event.ENTER_FRAME,pakkonCheck);
		}
		
		
		private static function updateFormat(e,sisterTarget=null){
			var targ:TextField;
			if(e is TextField){
				targ = e ;
			}else{
				targ = e.target;
			}
			var sis:TextField 
			if(sisterTarget==null){
				sis = getSister(TextField(targ)) ;
			}else{
				sis = sisterTarget ;
			}
			
			var textFormat:TextFormat = sis.getTextFormat();
			//trace(textFormat)
			TextField(targ).embedFonts = true ;
			TextField(targ).defaultTextFormat = textFormat;
			TextField(targ).setTextFormat(textFormat);
		}
		
		private static function focused(e:*){
			if(mylastText!=TextField(e.target) && mylastText!=null){
				//getSister(mylastText).alpha=1;
				//mylastText.alpha=0;
				mylastText.dispatchEvent(new Event(FocusEvent.FOCUS_OUT));
			}
			mylastText = TextField(e.target) ;
			
			var sis:TextField = getSister(TextField(e.target)) ;
			if(sis.name.indexOf(firstTimeDecoder)!=-1){
				sis.text = e.target.text;
				e.target.text = '';
			}
			e.target.alpha=1;
			sis.alpha = 0;
		}
		
		private static function focusedOut(e:*){
			var sis = getSister(TextField(e.target)) ;
			e.target.alpha = 0 ;
			sis.alpha = 1 ;
			if(TextField(e.target).text!=''){
				//languageSwitch.setText(sis,TextField(e.target).text,false,languageSwitch.DEFAULT_FONT);
				//♠
					UnicodeStatic.fastUnicodeOnLines(sis,TextField(e.target).text);
				if(sis.name.indexOf(firstTimeDecoder)!=-1){
					sis.name = String(sis.name).substring(0,String(sis.name).length-firstTimeDecoder.length);
				}
			}else if(sis.name.indexOf(firstTimeDecoder)!=-1){
				TextField(e.target).text = sis.text ;
				//languageSwitch.setText(sis,TextField(e.target).text,false,languageSwitch.DEFAULT_FONT);
				//♠
					UnicodeStatic.fastUnicodeOnLines(sis,TextField(e.target).text);
				//sis.text = languageSwitch.toUnicode(TextField(e.target).text);
			}else if(TextField(e.target).text==''){
				//languageSwitch.setText(sis,'',false,languageSwitch.DEFAULT_FONT);
				//♠
					sis.text = '' ;
			}
			if(mylastText == e.target){
				mylastText = null ;
			}
		}
		
		
		
		private static function getSister(targ:TextField):TextField{
			var myParent = targ.parent ;
			if(myParent == null){
				trace('Text is in incorrect place.');
				return new TextField();
			}
			var myName = String(targ.name)+addedTextFieldsName;
			var mySister = myParent.getChildByName(myName);
			//trace('search for : '+myName);
			if(mySister==null){
				myName = String(targ.name)+addedTextFieldsName+firstTimeDecoder;
				mySister = myParent.getChildByName(myName);
				//trace('search for : '+myName);
				if(mySister==null){
					myName = String(targ.name).substring(0,String(targ.name).length-(addedTextFieldsName.length+firstTimeDecoder.length));
					mySister = myParent.getChildByName(myName);
					//trace('search for : '+myName);
					if(mySister==null){
						myName = String(targ.name).substring(0,String(targ.name).length-(addedTextFieldsName.length));
						mySister = myParent.getChildByName(myName);
						//trace('search for : '+myName);
						if(mySister==null){
							trace(new Error('Selected TextField is incorrec.'));
							return new TextField;
						}
					}
				}
			}
			
			return TextField(mySister);
		}
	}
}