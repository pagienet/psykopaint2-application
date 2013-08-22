package net.psykosoft.psykopaint2.book.views.book
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.geom.Rectangle;
	//import flash.geom.Vector3D;
	import flash.display3D.textures.Texture;
	import flash.events.MouseEvent;
	import flash.display.BitmapData;
	import flash.utils.setTimeout;

	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.tools.utils.TextureUtils;
	
	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.managers.rendering.RefCountedTexture;
	import net.psykosoft.psykopaint2.core.rendering.CopySubTexture;

	import net.psykosoft.psykopaint2.book.views.book.Book;

	import org.osflash.signals.Signal;
 	 
	public class BookView extends ViewBase
	{
		private var _stage3dProxy:Stage3DProxy;
		private var _view3d:View3D;
	//	private var _origin:Vector3D;
		private var _book:Book;
		//interaction vars
		private var _startMouseX:Number;
		private var _startTime:Number;
		private var _mouseIsDown:Boolean;
		private var _time:Number;
		private var _previousTime:Number;

		public var imageSelectedSignal:Signal;
		public var bookHasClosedSignal:Signal;

		private var _layoutType:String;
		private var _backgroundTexture : RefCountedTexture;

		public function BookView() {
			super();
			bookHasClosedSignal = new Signal();
			initVars();
		}

		public function set stage3dProxy( stage3dProxy:Stage3DProxy ):void
		{
			_stage3dProxy = stage3dProxy;
			setup();
		}

		public function get book():Book
		{
			return _book;
		}

		override protected function onDisabled():void 
		{
			_book.dispose();
			_book = null;

			if (_backgroundTexture) _backgroundTexture.dispose();
			_backgroundTexture = null;

			_view3d.dispose();
			removeChild( _view3d );

			_stage3dProxy = null;
		 
			stage.removeEventListener( MouseEvent.MOUSE_DOWN, onStageMouseDown );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
		}

		private function initVars( ):void
		{
			scalesToRetina = false;
			//_origin = new Vector3D();
			_startMouseX = 0;
			_time = 0;
			imageSelectedSignal = new Signal();
			bookHasClosedSignal = new Signal();
		}

		private function onStageMouseDown( event:MouseEvent ):void
		{
			if(_book.ready){
				_startMouseX = mouseX;
				setTimeout(delayedMouseDown, 100);
			}
		}
		private function delayedMouseDown():void
		{
			var currentX:Number = mouseX;
			_mouseIsDown = true;
			//simple fast movement detection to prevent image picking while intended to turn page fast
			if(Math.abs(currentX-_startMouseX) < 5){
				if(!_book.hitTestRegions(mouseX, mouseY)){
					_startTime = _time;
				}
			} else {
				_book.killSnapTween();
				_startTime = _time;
			}
			
		}

		private function onStageMouseUp( event:MouseEvent ):void
		{
			_mouseIsDown = false;
			if(_book.ready && !_book.isLoadingImage) _time = _book.snapToNearestTime();
		}
 
		override protected function onEnabled():void
		{
			// Initialize view.
			initView3D();
		}

		// Interaction declared on book ready
		public function onBookReady():void
		{
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onStageMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, onStageMouseUp );
		}

		private function initView3D():void
		{
			_view3d = new View3D();
			_view3d.stage3DProxy = _stage3dProxy;
			_view3d.shareContext = true;
			_view3d.width = stage.stageWidth;
			_view3d.height = stage.stageHeight;
			_view3d.camera.lens.far = 5000;
			//_view3d.camera.position = new Vector3D( 0, 50, 1250 );
			//_view3d.camera.lookAt( _origin );
			_view3d.camera.y = 1500;
			_view3d.camera.z = 10;
			addChild( _view3d );
		}

		public function set layoutType(type:String):void
		{
			_layoutType = type;

			_book = new Book(_view3d, stage);

			_book.bookReadySignal.add(onBookReady);
			_book.imagePickedSignal.add(dispatchSelectedImage);
			_book.bookClearedSignal.add(dispatchBookHasClosed);
			_book.layoutType =_layoutType;
		}
 
		public function renderScene(target : Texture):void
		{
			if( !(_isEnabled && _view3d && _view3d.parent) ) return;

			if(_book.ready && _mouseIsDown){
				var doUpdate:Boolean = true;
				var mx:Number = (mouseX-_startMouseX);
				var currentTime:Number =   (mx/ stage.stageWidth) *.7;
				  
				currentTime *=-1;
				if(_previousTime > currentTime){
					_time = _startTime - (- Math.abs(currentTime));
				} else if(_previousTime < currentTime){
					_time = _startTime + (-Math.abs(currentTime));
				} else {
					doUpdate = false;
				}
				_previousTime = currentTime;

				if(doUpdate){
					_time =  currentTime+_startTime;
					if(_time < 0) _time = 0;
					if(_time > 1) _time = 1;
					_book.updatePages(_time);
				}

			}

			if (_backgroundTexture)
				renderBackground();

			_view3d.render(target);

		}

		private function renderBackground() : void
		{
			var context3D : Context3D = _stage3dProxy.context3D;
			context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			context3D.setDepthTest(false, Context3DCompareMode.ALWAYS);

			var widthRatio : Number = CoreSettings.STAGE_WIDTH / TextureUtils.getBestPowerOf2(CoreSettings.STAGE_WIDTH);
			var heightRatio : Number = CoreSettings.STAGE_HEIGHT / TextureUtils.getBestPowerOf2(CoreSettings.STAGE_HEIGHT);
			CopySubTexture.copy(_backgroundTexture.texture, new Rectangle(0, 0, widthRatio, heightRatio), new Rectangle(0, 0, 1, 1), context3D);
//				CopyTexture.copy(_background.texture, context3D, widthRatio, heightRatio);
			context3D.setDepthTest(true, Context3DCompareMode.LESS);
		}

		public function dispatchSelectedImage(selectedImage:BitmapData):void
		{
			imageSelectedSignal.dispatch(selectedImage);
		}

		public function dispatchBookHasClosed():void
		{
			bookHasClosedSignal.dispatch();
		}


		public function set backgroundTexture(backgroundTexture : RefCountedTexture) : void
		{
			_backgroundTexture = backgroundTexture;
		}

		public function get backgroundTexture() : RefCountedTexture
		{
			return _backgroundTexture;
		}
	}
}
