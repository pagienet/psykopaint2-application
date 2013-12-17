package net.psykosoft.psykopaint2.home.views.gallery
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.Geometry;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.lights.LightBase;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.textures.Texture2DBase;

	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;

	import flash.display.BitmapData;

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.managers.gestures.GrabThrowController;
	import net.psykosoft.psykopaint2.core.managers.gestures.GrabThrowEvent;

	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;

	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.home.model.GalleryImageCache;

	import org.osflash.signals.Signal;

	public class GalleryView extends Sprite
	{
		private static const PAINTING_OFFSET : Number = 831;
		private static const PAINTING_SPACING : Number = 190;
		private static const PAINTING_WIDTH : Number = 160;

		public var requestImageCollection : Signal = new Signal(int, int, int); // source, start index, amount of images
		public var requestActiveImageSignal : Signal = new Signal(int, int); // source, index

		private var _imageCache : GalleryImageCache;
		private var _view : View3D;
		private var _stage3DProxy : Stage3DProxy;
		private var _light : LightBase;
		private var _container : ObjectContainer3D;

		private var _paintings : Vector.<Mesh> = new Vector.<Mesh>();

		private var _paintingGeometry : Geometry;
		private var _loadingTexture : BitmapTexture;
		private var _numPaintings : int;
		private var _activeImageProxy : GalleryImageProxy;

		private var _swipeController : GrabThrowController;
		private var _cameraZoomController : GalleryCameraZoomController;

		private var _minSwipe : Number;
		private var _maxSwipe : Number;

		// for throwing:
		private var _tween : TweenLite;
		private var _hasEnterFrame : Boolean;
		private var _friction : Number;
		private var _tweenTime : Number = .5;
		private var _startTime : Number;
		private var _startPos : Number;
		private var _velocity : Number;
		private var _targetPos : Number;
		private var _enableSwiping : Boolean;
		private var _visibleStartIndex : int;
		private var _visibleEndIndex : int;

		public static const CAMERA_FAR_POSITION : Vector3D = new Vector3D(-814, -1.14, 450);
		public static const CAMERA_NEAR_POSITION : Vector3D = new Vector3D(-831, -1.14, -120);



		public function GalleryView(view : View3D, light : LightBase, stage3dProxy : Stage3DProxy)
		{
			_view = view;
			_stage3DProxy = stage3dProxy;
			_light = light;
			_imageCache = new GalleryImageCache(_stage3DProxy);
			_imageCache.thumbnailLoaded.add(onThumbnailLoaded);
			_imageCache.thumbnailDisposed.add(onThumbnailDisposed);
			_container = new ObjectContainer3D();
			_container.rotationY = 180;
			_view.scene.addChild(_container);
			initGeometry();
			initLoadingTexture();

			if (stage)
				initInteraction(stage);
			else
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}

		private function initInteraction(stage : Stage) : void
		{
			_swipeController = new GrabThrowController(stage);
			_swipeController.addEventListener(GrabThrowEvent.DRAG_STARTED, onDragStarted, false, 0, true);

			_cameraZoomController = new GalleryCameraZoomController(stage, _view.camera, CAMERA_FAR_POSITION, CAMERA_NEAR_POSITION);
			_cameraZoomController.start();
		}


		private function onDragStarted(event : GrabThrowEvent) : void
		{
			killTween();
			_swipeController.addEventListener(GrabThrowEvent.DRAG_UPDATE, onDragUpdate, false, 0, true);
			_swipeController.addEventListener(GrabThrowEvent.RELEASE, onDragRelease, false, 0, true);
		}

		private function onEnterFrame(event : Event) : void
		{
			var t : Number = (getTimer() - _startTime)/1000;

			updateVisibility();

			if (t > _tweenTime) {
				_container.x = _targetPos;
				killTween();
			}
			else {
				_container.x = _startPos + (_velocity + .5*_friction * t) * t;
			}
		}

		private function onDragUpdate(event : GrabThrowEvent) : void
		{
			constrainSwipe(_container.x - event.velocityX / CoreSettings.GLOBAL_SCALING);
			updateVisibility();
		}

		private function killTween() : void
		{
			if (_tween) {
				_tween.kill();
				_tween = null;
			}

			if (_hasEnterFrame) {
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				_hasEnterFrame = false;
			}
		}

		private function constrainSwipe(position : Number) : void
		{
			if (position > _maxSwipe) position = _maxSwipe;
			else if (position < _minSwipe) position = _minSwipe;

			_container.x = position;
		}

		private function onDragRelease(event : GrabThrowEvent) : void
		{
			_swipeController.removeEventListener(GrabThrowEvent.DRAG_UPDATE, onDragUpdate);
			_swipeController.removeEventListener(GrabThrowEvent.RELEASE, onDragRelease);

			var velocity : Number = event.velocityX / CoreSettings.GLOBAL_SCALING;
			if (Math.abs(velocity) < 5) {
				moveToNearest();
			}
			else {
				throwToPainting(velocity);
			}
		}

		private function throwToPainting(velocity : Number) : void
		{
			// convert per frame to per second, and reduce speed (doesn't feel good otherwise)
			_velocity = -velocity * 60 / 2;
			_startPos = _container.x;
			var targetTime : Number = .25;
			var targetFriction : Number = .8;
			var targetIndex : int;
			if (_velocity > 0) targetFriction = -targetFriction;

			// where would the target end up with the current speed after aimed time with aimed friction?
			_targetPos = _startPos + _velocity * targetTime + targetFriction * targetTime * targetTime;

			if (_targetPos > _maxSwipe) {
				targetIndex = _numPaintings - 1;
				_targetPos = _maxSwipe;
			}
			else if (_targetPos < _minSwipe) {
				targetIndex = 0;
				_targetPos = _minSwipe;
			}
			else {
				targetIndex = getNearestPaintingIndex(_targetPos);
				_targetPos = targetIndex*PAINTING_SPACING - PAINTING_OFFSET;
			}

			requestActiveImage(targetIndex);

			// solving:
			// p(t) = p(0) + v(0)*t + a*t^2 / 2 = target
			// v(t) = v(0) + a*t = 0
			// for 'a' (acceleration, ie negative friction) and 't'

			_tweenTime = 2 * (_targetPos - _startPos) / _velocity;
			_friction = -_velocity/_tweenTime;

			_startTime = getTimer();
			_hasEnterFrame = true;
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function moveToNearest() : void
		{
			var index : int = getNearestPaintingIndex(_container.x);
			requestActiveImage(index);
			_tween = TweenLite.to(_container, .5,
								{	x : index * PAINTING_SPACING - PAINTING_OFFSET,
									ease: Quad.easeInOut,
									onUpdate: updateVisibility
								});
		}

		private function getNearestPaintingIndex(position : Number) : Number
		{
			return Math.round((position + PAINTING_OFFSET) / PAINTING_SPACING);
		}

		private function initGeometry() : void
		{
			var aspectRatio : Number = CoreSettings.STAGE_HEIGHT/CoreSettings.STAGE_WIDTH;
			_paintingGeometry = new PlaneGeometry(PAINTING_WIDTH, PAINTING_WIDTH*aspectRatio, 1, 1, false);
			_paintingGeometry.scaleUV(1, aspectRatio);
		}

		private function initLoadingTexture() : void
		{
			var bitmapData : BitmapData = new BitmapData(16, 16);
			bitmapData.perlinNoise(4, 4, 8, 6, false, true, 7, true);

			_loadingTexture = new BitmapTexture(bitmapData);
			_loadingTexture.getTextureForStage3D(_stage3DProxy);
			bitmapData.dispose();
		}

		public function setImmediateActiveImage(galleryImageProxy : GalleryImageProxy) : void
		{
			setActiveImage(galleryImageProxy);

			_container.x = -(PAINTING_OFFSET - galleryImageProxy.index * PAINTING_SPACING);
		}

		public function setActiveImage(galleryImageProxy : GalleryImageProxy) : void
		{
			if (_activeImageProxy && _activeImageProxy.collectionType != galleryImageProxy.collectionType)
				resetPaintings();

			_activeImageProxy = galleryImageProxy;

			const amountOnEachSide : int = 2;
			var min : int = galleryImageProxy.index - amountOnEachSide;
			var amount : int = amountOnEachSide * 2 + 1;

			if (min < 0) {
				amount += min;	// fix amount to still have correct amount of the right
				min = 0;
			}

			requestImageCollection.dispatch(galleryImageProxy.collectionType, min, amount);
		}

		private function requestActiveImage(index : int) : void
		{
			requestActiveImageSignal.dispatch(_activeImageProxy.collectionType, index);
		}

		private function resetPaintings() : void
		{
			_imageCache.thumbnailLoaded.remove(onThumbnailLoaded);
			_imageCache.thumbnailDisposed.remove(onThumbnailDisposed);
			disposePaintings();
			_visibleEndIndex = -1;
			_visibleStartIndex = -1;
			_imageCache.clear();
			_imageCache.thumbnailLoaded.add(onThumbnailLoaded);
			_imageCache.thumbnailDisposed.add(onThumbnailDisposed);
		}

		public function setImageCollection(collection : GalleryImageCollection) : void
		{
			_numPaintings = collection.numTotalPaintings;
			_paintings.length = _numPaintings;
			updateVisibility();
			_imageCache.replaceCollection(collection);

			_minSwipe = -PAINTING_OFFSET;
			_maxSwipe = -(PAINTING_OFFSET - (_numPaintings - 1) * PAINTING_SPACING);
		}

		private function updateVisibility() : void
		{
			if (_numPaintings == 0) return;
			var index : int = getNearestPaintingIndex(_container.x);
			var visibleStart : int = index - 1;
			var visibleEnd : int = index + 2;
		    var i : int;

			if (visibleStart < 0) visibleStart = 0;
			if (visibleEnd >= _numPaintings) visibleEnd = _numPaintings;

			for (i = _visibleStartIndex; i < visibleStart; ++i) {
				if (_paintings[i])
					destroyPainting(i);
			}

			for (i = visibleStart; i < visibleEnd; ++i) {
				if (!_paintings[i])
					createPainting(i);
			}

			for (i = visibleEnd; i < _visibleEndIndex; ++i) {
				if (_paintings[i])
					destroyPainting(i);
			}

			_visibleStartIndex = visibleStart;
			_visibleEndIndex = visibleEnd;
		}

		private function createPainting(index : int) : void
		{
			var texture : Texture2DBase = _imageCache.getThumbnail(index);
			texture ||= _loadingTexture;
			var material : TextureMaterial = new TextureMaterial(texture);
			var mesh : Mesh = new Mesh(_paintingGeometry, material);
			mesh.x = index * PAINTING_SPACING;
			mesh.z = 260;
			_paintings[index] = mesh;
			_container.addChild(_paintings[index]);
		}

		public function dispose() : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			_view.scene.removeChild(_container);
			disposePaintings();
			_container.dispose();
			_imageCache.thumbnailDisposed.removeAll();
			_imageCache.thumbnailLoaded.removeAll();
			_imageCache.clear();
			_paintingGeometry.dispose();
			_loadingTexture.dispose();

			if (_swipeController) {
				_swipeController.removeEventListener(GrabThrowEvent.DRAG_STARTED, onDragStarted);
				_swipeController.removeEventListener(GrabThrowEvent.DRAG_UPDATE, onDragUpdate);
				_swipeController.removeEventListener(GrabThrowEvent.RELEASE, onDragRelease);
			}

			if (_cameraZoomController) {
				_cameraZoomController.stop();
			}
		}

		private function disposePaintings() : void
		{
			for (var i : int = 0; i < _numPaintings; ++i) {
				if (_paintings[i])
					destroyPainting(i);
			}
		}

		private function destroyPainting(i : int) : void
		{
			var painting : Mesh = _paintings[i];
			_container.removeChild(painting);
			painting.material.dispose();
			painting.dispose();
			_paintings[i] = null;
		}

		private function onThumbnailLoaded(imageProxy : GalleryImageProxy, thumbnail : Texture2DBase) : void
		{
			if (_paintings[imageProxy.index])
				TextureMaterial(_paintings[imageProxy.index].material).texture = thumbnail;
		}

		private function onThumbnailDisposed(imageProxy : GalleryImageProxy) : void
		{
			// this probably also means the painting shouldn't be visible anymore
			var painting : Mesh = _paintings[imageProxy.index];
			if (painting) {
				TextureMaterial(painting.material).texture = _loadingTexture;
				if (painting.parent)
					_container.removeChild(painting);
			}
		}

		private function onAddedToStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			initInteraction(stage);
		}

		public function get enableSwiping() : Boolean
		{
			return _enableSwiping;
		}

		public function set enableSwiping(enableSwiping : Boolean) : void
		{
			_enableSwiping = enableSwiping;
			if (enableSwiping)
				_swipeController.start();
			else
				_swipeController.stop();
		}
	}
}
