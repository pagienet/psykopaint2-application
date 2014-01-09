package net.psykosoft.psykopaint2.home.views.gallery
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.Geometry;
	import away3d.core.managers.Stage3DProxy;
	import away3d.entities.Mesh;
	import away3d.hacks.MaskingMethod;
	import away3d.hacks.StencilMethod;
	import away3d.lights.LightBase;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.textures.ByteArrayTexture;
	import away3d.textures.Texture2DBase;
	import away3d.tools.utils.TextureUtils;

	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DStencilAction;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.managers.gestures.GrabThrowController;
	import net.psykosoft.psykopaint2.core.managers.gestures.GrabThrowEvent;
	import net.psykosoft.psykopaint2.core.materials.PaintingDiffuseMethod;
	import net.psykosoft.psykopaint2.core.materials.PaintingNormalMethod;
	import net.psykosoft.psykopaint2.core.materials.PaintingSpecularMethod;
	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.PaintingGalleryVO;
	import net.psykosoft.psykopaint2.home.model.GalleryImageCache;

	import org.osflash.signals.Signal;

	public class GalleryView extends Sprite
	{
		public static const CAMERA_FAR_POSITION : Vector3D = new Vector3D(-814, -1.14, 450);
		public static const CAMERA_NEAR_POSITION : Vector3D = new Vector3D(-831, -10, 0);

		private static const PAINTING_OFFSET : Number = 831;
		private static const PAINTING_SPACING : Number = 250;
		private static const PAINTING_WIDTH : Number = 210;
		private static const PAINTING_Z : Number = -160;

		public var requestImageCollection : Signal = new Signal(int, int, int); // source, start index, amount of images
		public var requestActiveImageSignal : Signal = new Signal(int, int); // source, index

		private var _imageCache : GalleryImageCache;
		private var _view : View3D;
		private var _stage3DProxy : Stage3DProxy;
		private var _light : LightBase;
		private var _container : ObjectContainer3D;

		private var _paintings : Vector.<Mesh> = new Vector.<Mesh>();
		private var _lowQualityMaterials : Vector.<TextureMaterial> = new Vector.<TextureMaterial>();

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
		private var _visibleStartIndex : int;
		private var _visibleEndIndex : int;

		private var _paintingOccluder : Mesh;

		private var _highQualityMaterial : TextureMaterial;
		private var _highQualityNormalSpecularTexture : ByteArrayTexture;
		private var _highQualityColorTexture : BitmapTexture;
		private var _showHighQuality:Boolean;

		public function GalleryView(view : View3D, light : LightBase, stage3dProxy : Stage3DProxy)
		{
			_view = view;
			_stage3DProxy = stage3dProxy;
			_light = light;
			_imageCache = new GalleryImageCache(_stage3DProxy);
			_imageCache.thumbnailLoaded.add(onThumbnailLoaded);
			_imageCache.thumbnailDisposed.add(onThumbnailDisposed);
			_imageCache.loadingComplete.add(onThumbnailLoadingComplete);
			_container = new ObjectContainer3D();
			_container.z = PAINTING_Z;
			_container.rotationY = 180;
			_view.scene.addChild(_container);
			initGeometry();
			initLoadingTexture();
			initOccluder();
			initHighQualityMaterial();
		}

		public function get showHighQuality() : Boolean
		{
			return _showHighQuality;
		}

		public function set showHighQuality(value:Boolean):void
		{
			if (_showHighQuality == value) return;
			_showHighQuality = value;

			if (_showHighQuality) {
				showHighQualityMaterial();
			}
			else {
				removeHighQualityMaterial();
				disposeHighQualityMaterial();
			}
		}

		private function showHighQualityMaterial():void
		{
			if (!_highQualityMaterial)
				initHighQualityMaterial();

			if (_activeImageProxy) {
				trace ("Loading high quality image data");
				_activeImageProxy.loadSurfaceData(onSurfaceDataComplete, onSurfaceDataError);
			}
		}

		private function initHighQualityMaterial():void
		{
			_highQualityColorTexture = new BitmapTexture(null);
			_highQualityNormalSpecularTexture = new ByteArrayTexture(null, 0, 0);

			_highQualityMaterial = new TextureMaterial(null, true, false, false);
			_highQualityMaterial.normalMethod = new PaintingNormalMethod();
			_highQualityMaterial.diffuseMethod = new PaintingDiffuseMethod();
			_highQualityMaterial.specularMethod = new PaintingSpecularMethod();
			_highQualityMaterial.lightPicker = new StaticLightPicker([_light]);
			_highQualityMaterial.ambientColor = 0xffffff;
			_highQualityMaterial.ambient = 1;
			_highQualityMaterial.specular = 1.5;
			_highQualityMaterial.gloss = 200;
			_highQualityMaterial.texture = _highQualityColorTexture;
			_highQualityMaterial.normalMap = _highQualityNormalSpecularTexture;
			_highQualityMaterial.specularMap = _highQualityNormalSpecularTexture;

			var stencilMethod : StencilMethod = new StencilMethod();
			stencilMethod.referenceValue = 40;
			stencilMethod.compareMode = Context3DCompareMode.NOT_EQUAL;
			_highQualityMaterial.addMethod(stencilMethod);
		}

		// this creates a geoemtry that prevents paintings from being rendered outside the gallery area
		private function initOccluder():void
		{
			var occluderGeometry : PlaneGeometry = new PlaneGeometry(500, 200, 1, 1, false);
			var occluderMaterial : ColorMaterial = new ColorMaterial();
			var maskingMethod : MaskingMethod = new MaskingMethod();
			maskingMethod.disableAll();
			var stencilMethod : StencilMethod = new StencilMethod();
			stencilMethod.referenceValue = 40;
			stencilMethod.actionDepthAndStencilPass = Context3DStencilAction.SET;
			stencilMethod.actionDepthFail = Context3DStencilAction.SET;
			stencilMethod.actionDepthPassStencilFail = Context3DStencilAction.SET;
			occluderMaterial.addMethod(maskingMethod);
			occluderMaterial.addMethod(stencilMethod);
			_paintingOccluder = new Mesh(occluderGeometry, occluderMaterial);
			_paintingOccluder.x = -300;
			_paintingOccluder.z = PAINTING_Z - 100;
			_paintingOccluder.rotationY = 180;
			_view.scene.addChild(_paintingOccluder);
		}

		public function initInteraction() : void
		{
			_swipeController ||= new GrabThrowController(stage);
			_cameraZoomController ||= new GalleryCameraZoomController(stage, _view.camera, PAINTING_WIDTH, PAINTING_Z, CAMERA_FAR_POSITION, CAMERA_NEAR_POSITION);

			_swipeController.addEventListener(GrabThrowEvent.DRAG_STARTED, onDragStarted, false, 0, true);
			_swipeController.start();

			_cameraZoomController.start();
		}

		public function stopInteraction() : void
		{
			if (_swipeController) {
				_swipeController.stop();
				_swipeController.removeEventListener(GrabThrowEvent.DRAG_STARTED, onDragStarted);
				_swipeController.removeEventListener(GrabThrowEvent.DRAG_UPDATE, onDragUpdate);
				_swipeController.removeEventListener(GrabThrowEvent.RELEASE, onDragRelease);
			}

			if (_cameraZoomController)
				_cameraZoomController.stop();
		}

		public function get onZoomUpdateSignal() : Signal
		{
			return _cameraZoomController? _cameraZoomController.onZoomUpdateSignal : null;
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
			constrainSwipe(_container.x - unprojectVelocity(event.velocityX));
			updateVisibility();
		}

		private function unprojectVelocity(screenSpaceVelocity : Number) : Number
		{
			var matrix : Vector.<Number> = _view.camera.lens.matrix.rawData;
			var z : Number = _view.camera.z - _container.z;
			return screenSpaceVelocity / CoreSettings.STAGE_WIDTH * 2 * z / matrix[0];
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

			var velocity : Number = unprojectVelocity(event.velocityX);
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
			if (_activeImageProxy) {
				if (_activeImageProxy.collectionType != galleryImageProxy.collectionType)
					resetPaintings();

				if (_activeImageProxy.id != galleryImageProxy.id)
					removeHighQualityMaterial();
			}

			// make sure to clone so we can load while the book is loading
			_activeImageProxy = galleryImageProxy.clone();

			const amountOnEachSide : int = 2;
			var min : int = galleryImageProxy.index - amountOnEachSide;
			var amount : int = amountOnEachSide * 2 + 1;

			if (min < 0) {
				amount += min;	// fix amount to still have correct amount of the right
				min = 0;
			}

			requestImageCollection.dispatch(galleryImageProxy.collectionType, min, amount);
		}

		private function removeHighQualityMaterial():void
		{
			// also test if painting hasn't been destroyed yet due to panning
			if (_activeImageProxy && _paintings[_activeImageProxy.index]) {
				_activeImageProxy.cancelLoading();
				var index:uint = _activeImageProxy.index;
				_paintings[index].material = _lowQualityMaterials[index];
			}
		}

		private function requestActiveImage(index : int) : void
		{
			if (_activeImageProxy && _activeImageProxy.index != index) {
				removeHighQualityMaterial();
				requestActiveImageSignal.dispatch(_activeImageProxy.collectionType, index);
			}
		}

		private function resetPaintings() : void
		{
			_imageCache.thumbnailLoaded.remove(onThumbnailLoaded);
			_imageCache.thumbnailDisposed.remove(onThumbnailDisposed);
			_imageCache.loadingComplete.remove(onThumbnailLoadingComplete);
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
			_lowQualityMaterials.length = _numPaintings;
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
				if (_paintings[i]) {
					destroyPainting(i);
				}
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
			var stencilMethod : StencilMethod = new StencilMethod();
			stencilMethod.referenceValue = 40;
			stencilMethod.compareMode = Context3DCompareMode.NOT_EQUAL;
			material.addMethod(stencilMethod);

			_lowQualityMaterials[index] = material;

			var mesh : Mesh = new Mesh(_paintingGeometry, material);
			mesh.x = index * PAINTING_SPACING;
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
			_paintingOccluder.material.dispose();
			_paintingOccluder.geometry.dispose();
			_paintingOccluder.dispose();
			disposeHighQualityMaterial();
			stopInteraction();
		}

		private function disposeHighQualityMaterial():void
		{
			if (_highQualityMaterial) {
				_highQualityMaterial.dispose();
				_highQualityColorTexture.dispose();
				_highQualityNormalSpecularTexture.dispose();
				_highQualityMaterial = null;
				_highQualityColorTexture = null;
				_highQualityNormalSpecularTexture = null;
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
			painting.dispose();
			_lowQualityMaterials[i].dispose();
			_paintings[i] = null;
			_lowQualityMaterials[i] = null;
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

		private function onThumbnailLoadingComplete():void
		{
			// we can load the high resolution now for
			if (_showHighQuality)
				showHighQualityMaterial();
		}

		private function onSurfaceDataComplete(galleryVO : PaintingGalleryVO):void
		{
			var width : Number = TextureUtils.getBestPowerOf2(galleryVO.colorData.width);
			var height : Number = TextureUtils.getBestPowerOf2(galleryVO.colorData.height);
			var legalBitmap : BitmapData = new BitmapData(width, height, false);
			legalBitmap.copyPixels(galleryVO.colorData, galleryVO.colorData.rect, new Point());

			_highQualityColorTexture.bitmapData = legalBitmap;
			_highQualityColorTexture.getTextureForStage3D(_stage3DProxy);
			legalBitmap.dispose();

			galleryVO.normalSpecularData.length = width*height*4;
			_highQualityNormalSpecularTexture.setByteArray(galleryVO.normalSpecularData, width, height);
			_highQualityNormalSpecularTexture.getTextureForStage3D(_stage3DProxy);

			_paintings[_activeImageProxy.index].material = _highQualityMaterial;

			galleryVO.dispose();
		}

		private function onSurfaceDataError():void
		{
			// TODO: Show error
		}

		private function onAddedToStage(event : Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
	}
}
