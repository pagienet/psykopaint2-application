package net.psykosoft.psykopaint2.home.views.book.layouts
{
	import away3d.core.managers.Stage3DProxy;
	import away3d.hacks.BookThumbTextureMaterial;
	import away3d.hacks.TrackedBitmapRectTexture;

	import flash.display.BitmapData;
	import flash.events.Event;

	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.entities.Mesh;
	import away3d.hacks.TrackedBitmapTexture;
	import away3d.materials.TextureMaterial;

	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.ImageThumbnailSize;
	import net.psykosoft.psykopaint2.home.views.book.BookGeometryProxy;
	import net.psykosoft.psykopaint2.home.views.book.BookMaterialsProxy;

	public class BookLayoutGalleryThumbView extends ObjectContainer3D
	{
		public static const EVENT_LOADED:String = "EVENT_LOADED";

		private var _width:Number = 60;
		private var _height:Number = 40;

		private var _imageProxy:GalleryImageProxy;

		//THUMBNAIL
		private var _thumbMesh:Mesh;
		private var _thumbMaterial:BookThumbTextureMaterial;

		//SHADOW
		private var _shadowMesh:Mesh;

		//LOADING IMAGE
		private var _thumbTexture:TrackedBitmapRectTexture;
		private var _commentMesh:Mesh;
		private var _likeMesh:Mesh;
		private var _onComplete:Function;

		private var _stage3DProxy:Stage3DProxy;


		public function BookLayoutGalleryThumbView(stage3DProxy:Stage3DProxy)
		{
			_stage3DProxy = stage3DProxy;

			// TODO: Merge all geometries into one Mesh?
			var cardGeom : Geometry = BookGeometryProxy.getGeometryById(BookGeometryProxy.CARD_GEOMETRY);

			_thumbMesh = new Mesh(cardGeom, BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.THUMBNAIL_LOADING));
			_thumbMesh.scaleX = _width;
			_thumbMesh.scaleZ = _height;
			_thumbMesh.y = 1;
			_thumbMesh.mouseEnabled = true;
			addChild(_thumbMesh);

			_thumbTexture = new TrackedBitmapRectTexture(null);
			_thumbMaterial = new BookThumbTextureMaterial(_thumbTexture);

			//ADDING MOUSE ENABLING ON THIS ASSET HERE SO IT CAN DISPATCH TO PARENT

			_shadowMesh = new Mesh(cardGeom, BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.THUMBNAIL_SHADOW));
			_shadowMesh.scaleX = 64;
			_shadowMesh.scaleZ = 25;
			//_shadowMesh.y=3;
			_shadowMesh.z = -18;
			addChild(_shadowMesh);


			//COMMENT ICON
			_commentMesh = new Mesh(cardGeom, BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.ICON_COMMENT));
			_commentMesh.scaleX = 5;
			_commentMesh.scaleZ = 5;
			_commentMesh.x = 10;
			_commentMesh.y = 2;
			_commentMesh.z = -25;
			addChild(_commentMesh);

			//LIKE ICON
			_likeMesh = new Mesh(cardGeom, BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.ICON_HEART));
			_commentMesh.scaleX = 5;
			_commentMesh.scaleZ = 5;
			_likeMesh.x = 25;
			_likeMesh.y = 3;
			_likeMesh.z = -25;
			addChild(_likeMesh);
		}

		public function get height():Number
		{
			return _height;
		}

		public function get width():Number
		{
			return _width;
		}

		public function get imageProxy():GalleryImageProxy
		{
			return _imageProxy;
		}

		public function set imageProxy(value:GalleryImageProxy):void
		{
			_imageProxy = value;
		}

		public function load(onComplete:Function = null):void
		{
			_onComplete = onComplete;
			if (!_imageProxy)
				trace("BookLayoutGalleryThumbView::WARNING!! Trying to load but there's no data");
			_thumbMesh.material = BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.THUMBNAIL_LOADING)
			_imageProxy.loadThumbnail(onThumbnailLoaded, onThumbnailFail, ImageThumbnailSize.SMALL);
		}


		override public function dispose():void
		{
			_imageProxy.cancelLoading();
			_imageProxy = null;

			_likeMesh.dispose();
			_commentMesh.dispose();
			_thumbMesh.dispose();
			_shadowMesh.dispose();

			_thumbMaterial.dispose();
			_thumbTexture.dispose();

			_commentMesh = null;
			_thumbMesh = null;
			_thumbTexture = null;
			_thumbMaterial = null;
			_shadowMesh = null;
			_onComplete = null;

			//WE DON'T DISPOSE OF THE SHADOW MATERIAL. TO DISPOSE IN BookMaterialsProxy

			super.dispose();
		}

		private function onThumbnailFail():void
		{
			trace("OUPS THE ASSET FAILED TO LOAD " + _imageProxy);
		}

		private function onThumbnailLoaded(file:Object):void
		{
			var bitmapData:BitmapData = BitmapData(file);
			_thumbTexture.bitmapData = bitmapData;
			_thumbTexture.getTextureForStage3D(_stage3DProxy);
			_thumbMesh.material = _thumbMaterial;
			bitmapData.dispose();

			dispatchEvent(new Event(EVENT_LOADED));

			if (_onComplete)
				_onComplete.call();
		}
	}
}