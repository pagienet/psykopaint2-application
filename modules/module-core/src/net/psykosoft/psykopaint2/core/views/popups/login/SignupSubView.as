package net.psykosoft.psykopaint2.core.views.popups.login
{

	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.utils.setTimeout;
	
	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.base.utils.io.CameraRollUtil;
	import net.psykosoft.psykopaint2.base.utils.misc.MathUtil;
	import net.psykosoft.psykopaint2.base.utils.misc.TrackedBitmapData;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.views.components.button.FoldButton;
	import net.psykosoft.psykopaint2.core.views.components.input.PsykoInput;
	import net.psykosoft.psykopaint2.core.views.components.input.PsykoInputValidationUtil;
	import net.psykosoft.psykopaint2.core.views.debug.ConsoleView;
	
	import org.osflash.signals.Signal;

	public class SignupSubView extends Sprite
	{
		// Declared in Flash.
		public var emailTf:PsykoInput;
		public var passwordTf:PsykoInput;
		public var firstNameTf:PsykoInput;
		public var lastNameTf:PsykoInput;
		public var signupBtn:FoldButton;
		public var cameraHit:Sprite;
		public var folderHit:Sprite;
		public var photoHolder:Sprite;
		public var photoContour:Sprite;
		public var videoView:Sprite;
		

		public var viewWantsToRegisterSignal:Signal;

		private var _cameraUtil:DeviceCameraUtil;
		private var _rollUtil:CameraRollUtil;
		private var _photoBitmap:Bitmap;
		private var _photoLarge:BitmapData;
		private var _photoSmall:BitmapData;
		private var _photoRetrieved:Boolean;
		private var _satelliteMessages:Vector.<LoginMessageLabel>;
		private var _video:Video;
		private var _camera:Camera = new Camera();
		private var _videoViewContainer:Sprite;
		
		private const LARGE_PHOTO_SIZE:int = 256;
		private const SMALL_PHOTO_SIZE:int = 128;

		public var canRequestSignUp:Boolean = true;

		public function SignupSubView() {
			super();

			viewWantsToRegisterSignal = new Signal();

			signupBtn.labelText = "SIGN UP";

			emailTf.defaultText = "email";
			passwordTf.defaultText = "password";
			firstNameTf.defaultText = "first name";
			lastNameTf.defaultText = "last name";
			
			passwordTf.behavesAsPassword( true );

			emailTf.setChainedTextField(passwordTf);
			passwordTf.setChainedTextField(firstNameTf);
			firstNameTf.setChainedTextField(lastNameTf);
			lastNameTf.enterPressedSignal.add( onLastNameInputEnterPressed );

			emailTf.focusedOutSignal.add( onEmailFocusOut );
			passwordTf.focusedOutSignal.add( onPasswordFocusOut );
			firstNameTf.focusedOutSignal.add( onFirstNameFocusOut );
			lastNameTf.focusedOutSignal.add( onLastNameFocusOut );

			cameraHit.alpha = 0;
			folderHit.alpha = 0;
			photoContour.visible = false;
			
			//CREATE A CONTAINER FOR THE VIDEO VIEW TO TAKE THE SNAPSHOT WITH THE SCALING
			_videoViewContainer = new Sprite();
			var index:int= this.getChildIndex(videoView)
			this.addChildAt(_videoViewContainer,index);
			_videoViewContainer.x = videoView.x;
			_videoViewContainer.y = videoView.y;
			videoView.x=0;
			videoView.y=0;
			_videoViewContainer.addChild(videoView);

			_photoBitmap = new Bitmap();
			_photoBitmap.visible = false;
			_photoBitmap.bitmapData = new TrackedBitmapData( 115, 115, false, 0xFF0000 );
			photoHolder.addChild( _photoBitmap );

			cameraHit.addEventListener( MouseEvent.CLICK, onCameraHitClick );
			folderHit.addEventListener( MouseEvent.CLICK, onFolderHitClick );
			signupBtn.addEventListener( MouseEvent.CLICK, onSignupBtnClick );
		}
		
		
		public function init():void
		{
			if(!_video){
				//SETUP CAMERA
				_video = new Video();
				videoView['videoContainer'].addChild(_video);
				//IF WE'RE ON IPAD WE TAKE THE FRONT WEBCAM : 1 OR 0 OTHERWISE
				_camera = Camera.getCamera( CoreSettings.RUNNING_ON_iPAD?"1":"0" );
				//NEED TO TAKE THE FRONT CAMERA ON IPAD FIRST
				if( _camera ) {
					_camera.setMode(   512 * CoreSettings.GLOBAL_SCALING, 384 * CoreSettings.GLOBAL_SCALING, 30, true );
					trace( "camera set, dims: " + _camera.width, _camera.height );
					_video.attachCamera( _camera );
					_video.height = 256;
					_video.width = _video.height*3/2;
					
				}
			}
		}
		

		public function dispose():void {

			cameraHit.removeEventListener( MouseEvent.CLICK, onCameraHitClick );
			folderHit.removeEventListener( MouseEvent.CLICK, onFolderHitClick );
			signupBtn.removeEventListener( MouseEvent.CLICK, onSignupBtnClick );

			lastNameTf.enterPressedSignal.remove( onLastNameInputEnterPressed );

			emailTf.focusedOutSignal.remove( onEmailFocusOut );
			passwordTf.focusedOutSignal.remove( onPasswordFocusOut );
			firstNameTf.focusedOutSignal.remove( onFirstNameFocusOut );
			lastNameTf.focusedOutSignal.remove( onLastNameFocusOut );

			signupBtn.dispose();
			emailTf.dispose();
			passwordTf.dispose();
			firstNameTf.dispose();
			lastNameTf.dispose();
			
			if(_camera) _camera = null;
			if(_video){_video.attachCamera(null);
				_video=null;
			}
			if( _cameraUtil ) _cameraUtil.dispose();
			if( _rollUtil ) _rollUtil.dispose();
			if( _photoSmall ) _photoSmall.dispose();
			if( _photoLarge ) _photoLarge.dispose();

			_photoRetrieved = false;
		}

		private function onLastNameFocusOut():void {
			clearAllSatelliteMessages();
			validateLastNameFormat();
		}

		private function onFirstNameFocusOut():void {
			clearAllSatelliteMessages();
			validateFirstNameFormat();
		}

		private function onPasswordFocusOut():void {
			clearAllSatelliteMessages();
			validatePasswordFormat();
		}

		private function onEmailFocusOut():void {
			clearAllSatelliteMessages();
			validateEmailFormat();
		}

		// -----------------------
		// Interface.
		// -----------------------

		public function displaySatelliteMessage( targetSource:Sprite, msg:String, offsetX:Number = 0, offsetY:Number = 0, rotation:Number = 0 ):void {
			var label:LoginMessageLabel = new LoginMessageLabel();
			label.labelText = msg;
			label.x = targetSource.x + targetSource.width / 2 + 5 + offsetX;
			label.y = targetSource.y + MathUtil.rand( -10, 10 ) + offsetY;
			if( rotation == 0 ) {
				label.rotation = MathUtil.rand( -10, 10 );
			}
			else label.rotation = rotation;
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
			if( !canRequestSignUp ) return;
			photoContour.visible = false;
			clearAllSatelliteMessages();
			if( !validateEmailFormat() ) return;
			if( !validatePasswordFormat() ) return;
			if( !validateFirstNameFormat() ) return;
			if( !validateLastNameFormat() ) return;
			if( !validatePhoto() ) return;
			viewWantsToRegisterSignal.dispatch( emailTf.text, passwordTf.text, firstNameTf.text, lastNameTf.text, _photoLarge, _photoSmall );
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
			if( valid == 2 ) displaySatelliteMessage( passwordTf, LoginCopy.PASSWORD_6_CHARS_MIN );
			return valid == 0;
		}

		private function validateFirstNameFormat():Boolean {
			var valid:int = PsykoInputValidationUtil.validateNameFormat( firstNameTf );
			if( valid == 1 ) displaySatelliteMessage( firstNameTf, LoginCopy.NO_FIRST_NAME );
			return valid == 0;
		}

		private function validateLastNameFormat():Boolean {
			var valid:int = PsykoInputValidationUtil.validateNameFormat( lastNameTf );
			if( valid == 1 ) displaySatelliteMessage( lastNameTf, LoginCopy.NO_LAST_NAME );
			return valid == 0;
		}

		private function validatePhoto():Boolean {
			if( !CoreSettings.RUNNING_ON_iPAD ) {
				photoContour.visible = true;
				_photoLarge = new BitmapData( LARGE_PHOTO_SIZE, LARGE_PHOTO_SIZE, false, 0xFF0000 );
				_photoSmall = new BitmapData( SMALL_PHOTO_SIZE, SMALL_PHOTO_SIZE, false, 0xFF0000 );
				hueContour( photoContour, -106 );
				return true;
			}
			if( !_photoRetrieved ) {
				photoContour.visible = true;
				hueContour( photoContour, 133 );
				displaySatelliteMessage( photoHolder, LoginCopy.NO_PHOTO, 115 / 2 + 5, 115 / 2 );
			}
			else {
				photoContour.visible = true;
				hueContour( photoContour, 133 );
			}
			return _photoRetrieved;
		}

		// -----------------------
		// Photo stuff.
		// -----------------------

		private function loadPhoto():void {
			photoContour.visible = false;
			if( !CoreSettings.RUNNING_ON_iPAD ) return;
			_rollUtil = new CameraRollUtil();
			_rollUtil.imageRetrievedSignal.add( onPhotoRetrieved );
			var w:Number = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 1024 : 512;
			var h:Number = CoreSettings.RUNNING_ON_RETINA_DISPLAY ? 512 : 256;
			_rollUtil.launch( new Rectangle( folderHit.x, folderHit.y, folderHit.width, folderHit.height ), w, h );
		}

		private function takePhoto():void {
			photoContour.visible = false;
			//if( !CoreSettings.RUNNING_ON_iPAD ) return;
			ConsoleView.instance.log( this, "taking photo..." );
			/*_cameraUtil = new DeviceCameraUtil( stage );
			_cameraUtil.imageRetrievedSignal.add( onPhotoRetrieved );
			_cameraUtil.launch();*/
			
			//var videoViewPosition:Point = new Point(videoView.x,videoView.y);
			
			var snapshotBmd:BitmapData = new BitmapData(256,256,false,0);
			//SCALE UP THE VIDEO VIEW TEMPORARILY
			videoView.height=256;
			videoView.scaleX = videoView.scaleY;
			snapshotBmd.draw(_videoViewContainer);
			videoView.height = 115;
			videoView.scaleX = videoView.scaleY;
		
			onPhotoRetrieved(snapshotBmd,0);
			
		}

		private function onPhotoRetrieved( bmd:BitmapData, orientation:int ):void {

			trace( this, "photo retrieved: " + bmd.width + "x" + bmd.height );

			_photoLarge = BitmapDataUtils.resizeAndCrop( bmd, LARGE_PHOTO_SIZE,LARGE_PHOTO_SIZE );
			_photoSmall = BitmapDataUtils.resizeAndCrop( bmd, SMALL_PHOTO_SIZE,SMALL_PHOTO_SIZE );

			_photoBitmap.bitmapData = _photoLarge;
			_photoBitmap.width=115;
			_photoBitmap.height=115;
			
			_photoRetrieved = true;

			_photoBitmap.visible = true;
			photoContour.visible = false;
			//_videoViewContainer.visible=false;
			_videoViewContainer.alpha = 0.3;
			
			bmd.dispose();

			//_cameraUtil.dispose();
		}

		// -----------------------
		// Event handlers.
		// -----------------------

		private function onCameraHitClick( event:MouseEvent ):void {
			takePhoto();
		}

		private function onFolderHitClick( event:MouseEvent ):void {
			loadPhoto();
		}

		private function onSignupBtnClick( event:MouseEvent ):void {
			register();
		}

		private function onLastNameInputEnterPressed():void {
			register();
		}

		// -----------------------
		// Utils.
		// -----------------------

		private function hueContour( clip:Sprite, hue:Number, saturation:Number = 1 ):void {
			TweenLite.to( clip, 0, { colorMatrixFilter: { hue: hue, saturation: saturation } } );
		}
		
	}
}
