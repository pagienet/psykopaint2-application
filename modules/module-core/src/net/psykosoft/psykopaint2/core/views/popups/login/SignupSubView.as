package net.psykosoft.psykopaint2.core.views.popups.login
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.base.utils.misc.MathUtil;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import net.psykosoft.psykopaint2.core.views.components.button.FoldButton;

	import net.psykosoft.psykopaint2.core.views.components.input.PsykoInput;
	import net.psykosoft.psykopaint2.core.views.components.input.PsykoInputValidationUtil;

	import org.osflash.signals.Signal;

	public class SignupSubView extends Sprite
	{
		// Declared in Flash.
		public var emailTf:PsykoInput;
		public var passwordTf:PsykoInput;
		public var firstNameTf:PsykoInput;
		public var lastNameTf:PsykoInput;
		public var signupBtn:FoldButton;
		public var backBtn:FoldButton;
		public var photoHit:Sprite;
		public var photoHolder:Sprite;
		public var photoContour:MovieClip;

		public var viewWantsToRegisterSignal:Signal;
		public var backBtnClickedSignal:Signal;

		private var _photoUtil:DeviceCameraUtil;
		private var _photoBitmap:Bitmap;
		private var _photoRetrieved:Boolean;
		private var _satelliteMessages:Vector.<LoginMessageLabel>;

		public function SignupSubView() {
			super();

			viewWantsToRegisterSignal = new Signal();
			backBtnClickedSignal = new Signal();

			signupBtn.labelText = "SIGN UP";
			backBtn.labelText = "BACK";

			emailTf.defaultText = "email";
			passwordTf.defaultText = "password";
			firstNameTf.defaultText = "first name";
			lastNameTf.defaultText = "last name";

			emailTf.enterPressedSignal.add( onEmailInputEnterPressed );
			passwordTf.enterPressedSignal.add( onPasswordInputEnterPressed );
			firstNameTf.enterPressedSignal.add( onFirstNameInputEnterPressed );
			lastNameTf.enterPressedSignal.add( onLastNameInputEnterPressed );

			photoHit.alpha = 0;
			photoContour.visible = false;

			_photoBitmap = new Bitmap();
			_photoBitmap.visible = false;
			_photoBitmap.bitmapData = new BitmapData( 115, 115, false, 0xFF0000 );
			photoHolder.addChild( _photoBitmap );

			photoHit.addEventListener( MouseEvent.CLICK, onPhotoHitClick );
			signupBtn.addEventListener( MouseEvent.CLICK, onSignupBtnClick );
			backBtn.addEventListener( MouseEvent.CLICK, onBackBtnClick );
		}

		public function dispose():void {

			photoHit.removeEventListener( MouseEvent.CLICK, onPhotoHitClick );
			signupBtn.removeEventListener( MouseEvent.CLICK, onSignupBtnClick );
			backBtn.removeEventListener( MouseEvent.CLICK, onBackBtnClick );

			emailTf.enterPressedSignal.remove( onEmailInputEnterPressed );
			passwordTf.enterPressedSignal.remove( onPasswordInputEnterPressed );
			firstNameTf.enterPressedSignal.remove( onFirstNameInputEnterPressed );
			lastNameTf.enterPressedSignal.remove( onLastNameInputEnterPressed );

			signupBtn.dispose();
			emailTf.dispose();
			passwordTf.dispose();
			firstNameTf.dispose();
			lastNameTf.dispose();
			backBtn.dispose();

			if( _photoUtil ) _photoUtil.dispose();
			if( _photoBitmap.bitmapData ) _photoBitmap.bitmapData.dispose();

			_photoRetrieved = false;
		}

		// -----------------------
		// Interface.
		// -----------------------

		public function displaySatelliteMessage( targetSource:Sprite, msg:String, offsetX:Number = 0, offsetY:Number = 0 ):void {
			var label:LoginMessageLabel = new LoginMessageLabel();
			label.labelText = msg;
			label.x = targetSource.x + targetSource.width / 2 + 5 + offsetX;
			label.y = targetSource.y + MathUtil.rand( -10, 10 ) + offsetY;
			label.rotation = MathUtil.rand( -10, 10 );
			addChild( label );
			if( !_satelliteMessages ) _satelliteMessages = new Vector.<LoginMessageLabel>();
			_satelliteMessages.push( label );
		}

		public function clearAllSatelliteMessages():void {
			if( !_satelliteMessages ) return;
			var label:LoginMessageLabel;
			var length:uint = _satelliteMessages.length;
			for(var i:uint; i < length; ++i) {
				label = _satelliteMessages[ i ];
				removeChild( label );
			}
			_satelliteMessages = null;
		}

		public function rejectEmail():void {
			emailTf.showRedHighlight();
		}

		public function rejectPassword():void {
			passwordTf.showRedHighlight();
		}

		// -----------------------
		// Register stuff.
		// -----------------------

		private function register():void {
			photoContour.visible = false;
			clearAllSatelliteMessages();
			if( !validateEmailFormat() ) return;
			if( !validatePasswordFormat() ) return;
			if( !validateFirstNameFormat() ) return;
			if( !validateLastNameFormat() ) return;
			if( !validatePhoto() ) return;
			viewWantsToRegisterSignal.dispatch( emailTf.text, passwordTf.text, firstNameTf.text, lastNameTf.text, _photoBitmap.bitmapData );
		}

		private function validateEmailFormat():Boolean {
			var valid:int = PsykoInputValidationUtil.validateEmailFormat( emailTf );
			if( valid == 1 ) displaySatelliteMessage( emailTf, LoginCopy.NO_EMAIL );
			if( valid == 2 ) displaySatelliteMessage( emailTf, LoginCopy.EMAIL_INVALID );
			return valid == 0;
		}

		private function validatePasswordFormat():Boolean {
			var valid:int = PsykoInputValidationUtil.validatePasswordFormat( passwordTf );
			if( valid == 1 ) displaySatelliteMessage( passwordTf, LoginCopy.NO_PASSWORD );
			return valid == 0;
		}

		private function validateFirstNameFormat():Boolean {
			var valid:int = PsykoInputValidationUtil.validateNameFormat( firstNameTf );
			if( valid == 1 ) displaySatelliteMessage( firstNameTf, LoginCopy.NO_FIELD );
			return valid == 0;
		}

		private function validateLastNameFormat():Boolean {
			var valid:int = PsykoInputValidationUtil.validateNameFormat( lastNameTf );
			if( valid == 1 ) displaySatelliteMessage( lastNameTf, LoginCopy.NO_FIELD );
			return valid == 0;
		}

		private function validatePhoto():Boolean {
			if( !CoreSettings.RUNNING_ON_iPAD ) {
				photoContour.visible = true;
				photoContour.gotoAndStop( 1 );
				return true;
			}
			if( !_photoRetrieved ) {
				photoContour.visible = true;
				photoContour.gotoAndStop( 2 );
				displaySatelliteMessage( photoHit, LoginCopy.NO_PHOTO, photoHit.width / 2 + 5, photoHit.height / 2 );
			}
			else {
				photoContour.visible = true;
				photoContour.gotoAndStop( 1 );
			}
			return _photoRetrieved;
		}

		// -----------------------
		// Photo stuff.
		// -----------------------

		private function loadPhoto():void {
			trace( this, "retrieving photo..." );
			_photoUtil = new DeviceCameraUtil();
			_photoUtil.imageRetrievedSignal.add( onPhotoRetrieved );
			_photoUtil.launch();
		}

		private function onPhotoRetrieved( bmd:BitmapData ):void {
			trace( this, "photo retrieved: " + bmd.width + "x" + bmd.height );
			var wRatio:Number = 115 / bmd.width;
			var hRatio:Number = 115 / bmd.height;
			var ratio:Number = Math.max( wRatio, hRatio );
			_photoBitmap.bitmapData = BitmapDataUtils.scaleBitmapData( bmd, ratio );
			_photoBitmap.x = 115 / 2 - _photoBitmap.width / 2;
			_photoBitmap.y = 115 / 2 - _photoBitmap.height / 2;
			_photoUtil.dispose();
			_photoRetrieved = true;
			_photoBitmap.visible = true;
			photoContour.visible = false;
		}

		// -----------------------
		// Event handlers.
		// -----------------------

		private function onBackBtnClick( event:MouseEvent ):void {
			backBtnClickedSignal.dispatch();
		}

		private function onPhotoHitClick( event:MouseEvent ):void {
			loadPhoto();
		}

		private function onSignupBtnClick( event:MouseEvent ):void {
			register();
		}

		private function onLastNameInputEnterPressed():void {
			register();
		}

		private function onFirstNameInputEnterPressed():void {
			lastNameTf.focusIn();
		}

		private function onPasswordInputEnterPressed():void {
			firstNameTf.focusIn();
		}

		private function onEmailInputEnterPressed():void {
			passwordTf.focusIn();
		}
	}
}
