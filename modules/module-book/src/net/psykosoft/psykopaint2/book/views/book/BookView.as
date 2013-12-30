package net.psykosoft.psykopaint2.book.views.book
{
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;

	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;

	import flash.display.BitmapData;
	import flash.display3D.Context3DClearMask;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.base.ui.base.ViewBase;
	import net.psykosoft.psykopaint2.book.views.book.debug.BookDebug;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.managers.gestures.GrabThrowController;
	import net.psykosoft.psykopaint2.core.managers.gestures.GrabThrowEvent;
	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.SourceImageCollection;

	import org.osflash.signals.Signal;

	//debug
	public class BookView extends ViewBase
	{
		private static const BOOK_HIDDEN_Z_MIN : Number = -900;
		private static const BOOK_HIDDEN_Z_MAX : Number = -1400;
		private static const HIDDEN_INTERACTION_RECT_HEIGHT_MIN : Number = 270 * CoreSettings.GLOBAL_SCALING;
		private static const HIDDEN_INTERACTION_RECT_HEIGHT_MAX : Number = 0;
		private static const MOUSE_XTRA : uint = 5;

		//debug
		private static const BOOK_DEBUG : Boolean = false;
		private var _bookDebug : BookDebug;

		private var _stage3dProxy : Stage3DProxy;
		private var _view3d : View3D;
		private var _book : Book;
		private var _startMouseX : Number;
		private var _mouseRange : Number;
		private var _startMouseY : Number;
		private var _startTime : Number;
		private var _mouseIsDown : Boolean;
		private var _time : Number;
		private var _previousTime : Number;
		private var _pageIndexOnMouseDown : uint = 0;
		private var _pageSideIndexOnMouseDown : uint = 0;
		private var _mouseBooster : Number = 1;

		public var imageSelectedSignal : Signal;
		public var galleryImageSelectedSignal : Signal;
		public var bookHasClosedSignal : Signal;
		public var bookDisposedSignal : Signal;

		public var onGalleryCollectionRequestedSignal : Signal;
		public var onImageCollectionRequestedSignal : Signal;
		private var _bookEnabled : Boolean = true;

		// related to hiding / showing of gallery book (maybe put this in its own controller)
		private var _grabThrowController : GrabThrowController;
		private var _tween : TweenLite;
		private var _hasEnterFrame : Boolean;
		private var _wasOpenBeforeDrag : Boolean;
		private var _friction : Number;
		private var _tweenTime : Number;
		private var _dragVelocity : Number;
		private var _startPos : Number;
		private var _targetPos : Number;

		private static const UNDECIDED : int = 0;
		private static const PAGE_SWIPE : int = 1;
		private static const HIDE_SWIPE : int = 2;
		private var _swipeMode : int;
		private var _hidingEnabled : Boolean;

		public var bookHiddenSignal : Signal = new Signal();
		public var bookShownSignal : Signal = new Signal();

		private var _bookHiddenZ : Number = BOOK_HIDDEN_Z_MIN;

		private var _hiddenInterActionRectHeight : Number = HIDDEN_INTERACTION_RECT_HEIGHT_MIN;

		public function BookView()
		{
			super();
			bookHasClosedSignal = new Signal();
			bookDisposedSignal = new Signal();

			onGalleryCollectionRequestedSignal = new Signal();
			onImageCollectionRequestedSignal = new Signal();

			initVars();
		}

		public function set stage3dProxy(stage3dProxy : Stage3DProxy) : void
		{
			_stage3dProxy = stage3dProxy;
			setup();
		}

		public function get book() : Book
		{
			return _book;
		}

		override protected function onDisabled() : void
		{
			disableVerticalSwipe();
			_book.bookReadySignal.remove(onBookReady);
			_book.imagePickedSignal.remove(dispatchSelectedImage);
			_book.galleryImagePickedSignal.remove(dispatchSelectedGalleryImage);
			_book.bookClearedSignal.remove(dispatchBookHasClosed);
			_book.collectionRequestedSignal.remove(dispatchCollectionRequest);
			_view3d.scene.removeChild(_book);
			_book.dispose();
			_book = null;

			_grabThrowController.stop();

			_view3d.dispose();
			removeChild(_view3d);

			if (BOOK_DEBUG) {
				removeChild(_bookDebug);
				_bookDebug.dispose();
				_bookDebug = null;
			}

			_stage3dProxy = null;

			if (CoreSettings.RUNNING_ON_iPAD) {
				stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onStageTouchBegin);
				stage.removeEventListener(TouchEvent.TOUCH_END, onStageTouchEnd);
			}
			else {
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageTouchBegin);
				stage.removeEventListener(MouseEvent.MOUSE_UP, onStageTouchEnd);
			}

			bookDisposedSignal.dispatch();
		}

		private function initVars() : void
		{
			scalesToRetina = false;
			_startMouseX = 0;

			_time = 0;
			imageSelectedSignal = new Signal();
			galleryImageSelectedSignal = new Signal();
			bookHasClosedSignal = new Signal();
		}

		private function onStageTouchBegin(event : *) : void
		{
			event.stopImmediatePropagation();
			if (!_book.ready) return;
			_book.killSnapTween();

			_swipeMode = UNDECIDED;

			_mouseIsDown = true;
			_startMouseX = mouseX;
			_startMouseY = mouseY;

			_pageIndexOnMouseDown = _book.currentPageIndex;
			_pageSideIndexOnMouseDown = _book.currentPageSide;
			if (_time < _book.minTime) _time = _book.minTime;
			_startTime = _previousTime = _time;
		}

		private function onStageTouchEnd(event : *) : void
		{
			if (!_book.ready) return;
			_mouseIsDown = false;

			if (!_book.isLoadingImage) {
				var currentX : Number = mouseX;
				if (Math.abs(currentX - _startMouseX) < 5 && _book.currentDegrees < 3) {
					if (!_book.hitTestRegions(mouseX, mouseY, _pageIndexOnMouseDown, _pageSideIndexOnMouseDown)) {
						_time = _book.snapToNearestTime();
					}
				} else {
					_time = _book.snapToNearestTime();
				}
			}
		}

		override protected function onEnabled() : void
		{
			if (!_book) {
				_mouseRange = stage.stageHeight / 4;
				initView3D();
				initBook();

				_grabThrowController = new GrabThrowController(stage);
			}
		}

		private function initBook() : void
		{
			_book = new Book(_view3d, stage);
			_view3d.scene.addChild(_book);
			_book.bookReadySignal.add(onBookReady);
			_book.imagePickedSignal.add(dispatchSelectedImage);
			_book.galleryImagePickedSignal.add(dispatchSelectedGalleryImage);
			_book.bookClearedSignal.add(dispatchBookHasClosed);
			_book.collectionRequestedSignal.add(dispatchCollectionRequest);
		}

		// gives the book a ratio between "how off screen" it should be, so we can hide it when zooming in on the gallery etc
		public function setHiddenOffScreenRatio(value : Number) : void
		{
			_bookHiddenZ = BOOK_HIDDEN_Z_MIN + value * (BOOK_HIDDEN_Z_MAX - BOOK_HIDDEN_Z_MIN);
			_hiddenInterActionRectHeight = HIDDEN_INTERACTION_RECT_HEIGHT_MIN + value * (HIDDEN_INTERACTION_RECT_HEIGHT_MAX - HIDDEN_INTERACTION_RECT_HEIGHT_MIN);

			if (!_bookEnabled && _book) {
				_book.z = _bookHiddenZ;
				_grabThrowController.interactionRect = new Rectangle(0, CoreSettings.STAGE_HEIGHT - _hiddenInterActionRectHeight, CoreSettings.STAGE_WIDTH, _hiddenInterActionRectHeight);
			}
		}

		// Interaction declared on book ready
		public function onBookReady() : void
		{
			_mouseBooster = MOUSE_XTRA / _book.pagesCount;

			if (_bookEnabled)
				switchToNormalMode();
			else
				switchToHiddenMode();

			if (BOOK_DEBUG) {
				_bookDebug = new BookDebug(_view3d, _book.regionManager);
				addChild(_bookDebug);
			}
		}

		private function initView3D() : void
		{
			_view3d = new View3D();
			_view3d.stage3DProxy = _stage3dProxy;
			_view3d.shareContext = true;
			_view3d.width = stage.stageWidth;
			_view3d.height = stage.stageHeight;
			_view3d.camera.lens.far = 5000;
			_view3d.camera.y = 1300;
			_view3d.camera.z = 10;
			addChild(_view3d);
		}

		public function renderScene(target : Texture) : void
		{
			if (!(_isEnabled && _view3d && _view3d.parent)) return;

			if (_book.ready) {

				if (_mouseIsDown) {

					var doUpdate : Boolean = isPageFlipActive();
					var mx : Number = (mouseX - _startMouseX);
					var currentTime : Number = ((mx * _mouseBooster) / stage.stageWidth ) * .7;

					currentTime *= -1;
					if (_previousTime > currentTime) {
						_time = _startTime - (-Math.abs(currentTime));
					} else if (_previousTime < currentTime) {
						_time = _startTime + (-Math.abs(currentTime));
					} else {
						doUpdate = false;
					}
					_previousTime = currentTime;

					if (doUpdate) {

						var angle : Number = -1 + (1 - ( (mouseY + (_mouseRange * .5) - _startMouseY) / _mouseRange)) * 2;
						angle *= .5;

						_book.rotateFold(-angle);

						_time = currentTime + _startTime;
						if (_time < 0) _time = 0;

						_book.updatePages(_time);
					}

					//works only on desktop, as we cannot have on finger move if its not touching the screen
				} else if (BOOK_DEBUG) {
					var currPageIndex : uint = _book.currentPageIndex;
					var currPageSideIndex : uint = _book.currentPageSide;
					_bookDebug.debugMouse(mouseX, mouseY, currPageIndex, currPageSideIndex);
				}

			}

			// this can sometimes be null upon disposal at the end
			if (_stage3dProxy.context3D)
				_stage3dProxy.context3D.clear(0, 0, 0, 1, 1, 0, Context3DClearMask.DEPTH);
			_view3d.render(target);
		}

		private function isPageFlipActive() : Boolean
		{
			updateSwipeMode();

			return _swipeMode == PAGE_SWIPE;
		}

		private function isDraggingVisibility() : Boolean
		{
			updateSwipeMode();

			return _swipeMode == HIDE_SWIPE;
		}

		private function updateSwipeMode() : void
		{
			if (_swipeMode == UNDECIDED) {
				if (!_bookEnabled) {
					_swipeMode = HIDE_SWIPE;
					return;
				}
				if (!_hidingEnabled) {
					_swipeMode = PAGE_SWIPE;
					return;
				}

				var dx : Number = Math.abs(_startMouseX - stage.mouseX) * CoreSettings.GLOBAL_SCALING;
				var dy : Number = Math.abs(_startMouseY - stage.mouseY) * CoreSettings.GLOBAL_SCALING;

				if (dx > 20 && dy < 20) {
					_swipeMode = PAGE_SWIPE;
				}
				else if (dy > 20 && dx < 20) {
					_swipeMode = HIDE_SWIPE;
				}
			}
		}

		public function dispatchSelectedImage(selectedImage : BitmapData) : void
		{
			imageSelectedSignal.dispatch(selectedImage);
		}

		public function dispatchSelectedGalleryImage(selectedGalleryImage : GalleryImageProxy) : void
		{
			galleryImageSelectedSignal.dispatch(selectedGalleryImage);
		}

		public function dispatchBookHasClosed() : void
		{
			bookHasClosedSignal.dispatch();
		}

		public function setSourceImages(collection : SourceImageCollection) : void
		{
			_book.setSourceImages(collection);
		}

		public function setGalleryImageCollection(collection : GalleryImageCollection) : void
		{
			_book.setGalleryImageCollection(collection);
		}

		//requests for paging
		public function dispatchCollectionRequest(vo : Object, startIndex : uint, maxItems : uint) : void
		{
			if (vo is GalleryImageCollection) {
				onGalleryCollectionRequestedSignal.dispatch(GalleryImageCollection(vo).type, startIndex, maxItems);
			} else {
				onImageCollectionRequestedSignal.dispatch(vo.source, startIndex, maxItems);
			}
		}

		public function setHiddenMode() : void
		{
			_book.z = _bookHiddenZ;
			switchToHiddenMode();
		}

		public function transitionToHiddenMode() : void
		{
			TweenLite.to(_book,.25,
					{	z: _bookHiddenZ,
						ease:Quad.easeIn
					});
			switchToHiddenMode();
		}

		public function enableVerticalSwipe() : void
		{
			_hidingEnabled = true;
			_grabThrowController.addEventListener(GrabThrowEvent.DRAG_STARTED, onDragStarted);
			_grabThrowController.start(20000, true);
		}

		public function disableVerticalSwipe() : void
		{
			_hidingEnabled = false;
			_grabThrowController.stop();
			_grabThrowController.removeEventListener(GrabThrowEvent.DRAG_STARTED, onDragStarted);
		}

		private function switchToHiddenMode() : void
		{
			_wasOpenBeforeDrag = false;
			_bookEnabled = false;
			_grabThrowController.interactionRect = new Rectangle(0, CoreSettings.STAGE_HEIGHT - _hiddenInterActionRectHeight, CoreSettings.STAGE_WIDTH, _hiddenInterActionRectHeight);
			if (CoreSettings.RUNNING_ON_iPAD) {
				stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onStageTouchBegin);
				stage.removeEventListener(TouchEvent.TOUCH_END, onStageTouchEnd);
			}
			else {
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, onStageTouchBegin);
				stage.removeEventListener(MouseEvent.MOUSE_UP, onStageTouchEnd);
			}
			bookHiddenSignal.dispatch();
		}

		private function switchToNormalMode() : void
		{
			_wasOpenBeforeDrag = true;
			_bookEnabled = true;
			_grabThrowController.interactionRect = new Rectangle(0, 56 * CoreSettings.GLOBAL_SCALING, CoreSettings.STAGE_WIDTH, 564 * CoreSettings.GLOBAL_SCALING);
			if (CoreSettings.RUNNING_ON_iPAD) {
				stage.addEventListener(TouchEvent.TOUCH_BEGIN, onStageTouchBegin, false, 10000);
				stage.addEventListener(TouchEvent.TOUCH_END, onStageTouchEnd);
			}
			else {
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageTouchBegin, false, 10000);
				stage.addEventListener(MouseEvent.MOUSE_UP, onStageTouchEnd);
			}
			bookShownSignal.dispatch();
		}

		private function onDragStarted(event : GrabThrowEvent) : void
		{
			killTween();
			_grabThrowController.addEventListener(GrabThrowEvent.DRAG_UPDATE, onDragUpdate);
			_grabThrowController.addEventListener(GrabThrowEvent.RELEASE, onDragRelease);
		}

		private function onDragUpdate(event : GrabThrowEvent) : void
		{
			if (!isDraggingVisibility())
				return;
			var minPos : Number = _bookHiddenZ;
			var maxPos : Number = 0;
			var bookPos : Number = _book.z - event.velocityY*2 / CoreSettings.GLOBAL_SCALING;
			if (bookPos < minPos) bookPos = minPos;
			if (bookPos > maxPos) bookPos = maxPos;
			_book.z = bookPos;
		}

		private function onDragRelease(event : GrabThrowEvent) : void
		{
			if (!isDraggingVisibility()) {
				_grabThrowController.removeEventListener(GrabThrowEvent.DRAG_UPDATE, onDragUpdate);
				_grabThrowController.removeEventListener(GrabThrowEvent.RELEASE, onDragRelease);
				return;
			}

			var velocity : Number = event.velocityY / CoreSettings.GLOBAL_SCALING;

			if (Math.abs(velocity) < 5) {
				var target : Number;

				if ((!_wasOpenBeforeDrag && _book.z > -700) || (_wasOpenBeforeDrag && _book.z < 200)) {
					switchToNormalMode();
					target = 0;
				}
				else {
					switchToHiddenMode();
					target = _bookHiddenZ;
				}

				_tween = TweenLite.to(_book,.5,
									{	z: target,
										ease:Quad.easeOut
									});
			}
			else {
				// convert per frame to per second
				// scaling by 2 because of the screen space -> view space mapping
				_dragVelocity = -velocity * 2 * 60;
				_startPos = _book.z;
				if (_dragVelocity < 0) {
					switchToHiddenMode();
					_targetPos = _bookHiddenZ;
				}
				else {
					switchToNormalMode();
					_targetPos = 0;
				}
				// solving:
				// p(t) = p(0) + v(0)*t + a*t^2 / 2 = target
				// v(t) = v(0) + a*t = 0
				// for 'a' (acceleration, ie negative friction) and 't'

				_tweenTime = 2 * (_targetPos - _startPos) / _dragVelocity;
				_friction = -_dragVelocity/_tweenTime;

				_startTime = getTimer();

				_hasEnterFrame = true;
				stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}

		private function killTween() : void
		{
			if (_tween) {
				_tween.kill();
				_tween = null;
			}

			if (_hasEnterFrame) {
				stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				_hasEnterFrame = false;
			}
		}

		private function onEnterFrame(event : Event) : void
		{
			var t : Number = (getTimer() - _startTime)/1000;

			if (t > _tweenTime) {
				_book.z = _targetPos;
				killTween();
			}
			else {
				_book.z = _startPos + (_dragVelocity + .5 * _friction * t) * t;
			}
		}
	}
}
