package net.psykosoft.psykopaint2.core.views.popups.login
{

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
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
		public var photoHit:Sprite;
		public var photoHolder:Sprite;

		public var viewWantsToRegisterSignal:Signal;

		private var _photoUtil:DeviceCameraUtil;
		private var _photoBitmap:Bitmap;
		private var _photoRetrieved:Boolean;

		public function SignupSubView() {
			super();

			viewWantsToRegisterSignal = new Signal();

			signupBtn.labelText = "SIGN UP";

			emailTf.defaultText = "email";
			passwordTf.defaultText = "password";
			firstNameTf.defaultText = "first name";
			lastNameTf.defaultText = "last name";

			emailTf.enterPressedSignal.add( onEmailInputEnterPressed );
			passwordTf.enterPressedSignal.add( onPasswordInputEnterPressed );
			firstNameTf.enterPressedSignal.add( onFirstNameInputEnterPressed );
			lastNameTf.enterPressedSignal.add( onLastNameInputEnterPressed );

			photoHit.alpha = 0;

			_photoBitmap = new Bitmap();
			_photoBitmap.bitmapData = new BitmapData( 115, 115, false, 0xFF0000 );
			photoHolder.addChild( _photoBitmap );

			photoHit.addEventListener( MouseEvent.CLICK, onPhotoHitClick );
			signupBtn.addEventListener( MouseEvent.CLICK, onSignupBtnClick );
		}

		public function dispose():void {

			photoHit.removeEventListener( MouseEvent.CLICK, onPhotoHitClick );
			signupBtn.removeEventListener( MouseEvent.CLICK, onSignupBtnClick );

			emailTf.enterPressedSignal.remove( onEmailInputEnterPressed );
			passwordTf.enterPressedSignal.remove( onPasswordInputEnterPressed );
			firstNameTf.enterPressedSignal.remove( onFirstNameInputEnterPressed );
			lastNameTf.enterPressedSignal.remove( onLastNameInputEnterPressed );

			signupBtn.dispose();
			emailTf.dispose();
			passwordTf.dispose();
			firstNameTf.dispose();
			lastNameTf.dispose();

			if(_photoUtil)  _photoUtil.dispose();
			if( _photoBitmap.bitmapData ) _photoBitmap.bitmapData.dispose();

			_photoRetrieved = false;
		}

		// -----------------------
		// Interface.
		// -----------------------

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
			if( !validateEmailFormat() ) return;
			if( !validatePasswordFormat() ) return;
			if( !validateFirstNameFormat() ) return;
			if( !validateLastNameFormat() ) return;
			if( !validatePhoto() ) return;
			viewWantsToRegisterSignal.dispatch( emailTf.text, passwordTf.text, firstNameTf.text, lastNameTf.text, _photoBitmap.bitmapData );
		}

		private function validateEmailFormat():Boolean {
			var valid:int = PsykoInputValidationUtil.validateEmailFormat( emailTf );
//			if( valid == 1 ) displayMessage( LoginCopy.NO_EMAIL );
//			if( valid == 2 ) displayMessage( LoginCopy.EMAIL_INVALID );
			return valid == 0;
		}

		private function validatePasswordFormat():Boolean {
			var valid:int = PsykoInputValidationUtil.validatePasswordFormat( passwordTf );
//			if( valid == 1 ) displayMessage( LoginCopy.NO_PASSWORD );
			return valid == 0;
		}

		private function validateFirstNameFormat():Boolean {
			var valid:int = PsykoInputValidationUtil.validateNameFormat( firstNameTf );
			return valid == 0;
		}

		private function validateLastNameFormat():Boolean {
			var valid:int = PsykoInputValidationUtil.validateNameFormat( lastNameTf );
			return valid == 0;
		}

		private function validatePhoto():Boolean {
			if( !CoreSettings.RUNNING_ON_iPAD ) return true;
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
		}

		// -----------------------
		// Event handlers.
		// -----------------------

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
