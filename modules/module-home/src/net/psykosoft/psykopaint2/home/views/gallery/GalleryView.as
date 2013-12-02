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

	import flash.display.BitmapData;

	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import net.psykosoft.psykopaint2.core.models.GalleryImageCollection;

	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.home.model.GalleryImageCache;

	import org.osflash.signals.Signal;

	public class GalleryView extends Sprite
	{
		private static const PAINTING_SPACING : Number = 190;
		private static const PAINTING_WIDTH : Number = 160;

		public var requestImageCollection : Signal = new Signal(int, int, int); // source, start index, amount of images

		private var _imageCache : GalleryImageCache;
		private var _view : View3D;
		private var _stage3DProxy : Stage3DProxy;
		private var _light : LightBase;
		private var _container : ObjectContainer3D;

		private var _paintings : Vector.<Mesh> = new Vector.<Mesh>();

		private var _paintingGeometry : Geometry;
		private var _loadingTexture : BitmapTexture;
		private var _numPaintings : int;

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

		public function setActiveImage(galleryImageProxy : GalleryImageProxy) : void
		{
			const amountOnEachSide : int = 2;
			var min : int = galleryImageProxy.index - amountOnEachSide;
			var amount : int = amountOnEachSide * 2 + 1;

			if (min < 0) {
				amount += min;	// fix amount to still have correct amount of the right
				min = 0;
			}

			_container.x = -(831 - galleryImageProxy.index * PAINTING_SPACING);

			requestImageCollection.dispatch(galleryImageProxy.collectionType, min, amount);
		}

		public function setImageCollection(collection : GalleryImageCollection) : void
		{
			removeSuperfluousPaintings(collection.numTotalPaintings);
			_paintings.length = _numPaintings;
			addPaintings(collection.index, collection.images.length);
			_imageCache.replaceCollection(collection);
		}

		private function addPaintings(start : int, amount : int) : void
		{
			for (var i : int = 0; i < amount; ++i) {
				if (!_paintings[start + i]) {
					var material : TextureMaterial = new TextureMaterial(_loadingTexture);
					var mesh : Mesh = new Mesh(_paintingGeometry, material);
					mesh.x = i * PAINTING_SPACING;
					mesh.z = 260;
					_paintings[start + i] = mesh;
				}

				if (!_paintings[start + i].parent)
					_container.addChild(_paintings[start + i]);
			}
		}

		private function removeSuperfluousPaintings(numTotalPaintings : int) : void
		{
			for (var i : int = _numPaintings; i < numTotalPaintings; ++i)
				removePainting(i);

			_numPaintings = numTotalPaintings;
		}

		public function dispose() : void
		{
			_view.scene.removeChild(_container);
			disposePaintings();
			_container.dispose();
			_imageCache.thumbnailDisposed.removeAll();
			_imageCache.thumbnailLoaded.removeAll();
			_imageCache.clear();
			_paintingGeometry.dispose();
			_loadingTexture.dispose();
		}

		private function disposePaintings() : void
		{
			for (var i : int = 0; i < _numPaintings; ++i)
				removePainting(i);
		}

		private function removePainting(i : int) : void
		{
			if (i < _paintings.length && _paintings[i]) {
				var painting : Mesh = _paintings[i];
				painting.material.dispose();
				painting.dispose();
				if (painting.parent)
					_container.removeChild(painting);
				_paintings[i] = null;
			}
		}

		private function onThumbnailLoaded(imageProxy : GalleryImageProxy, thumbnail : Texture2DBase) : void
		{
			TextureMaterial(_paintings[imageProxy.index].material).texture = thumbnail;
		}

		private function onThumbnailDisposed(imageProxy : GalleryImageProxy) : void
		{
			// this probably also means the painting shouldn't be visible anymore
			var painting : Mesh = _paintings[imageProxy.index];
			TextureMaterial(painting.material).texture = _loadingTexture;
			if (painting.parent)
				_container.removeChild(painting);
		}
	}
}
