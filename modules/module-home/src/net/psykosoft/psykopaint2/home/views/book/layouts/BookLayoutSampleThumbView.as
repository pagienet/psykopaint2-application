package net.psykosoft.psykopaint2.home.views.book.layouts
{
	import away3d.core.managers.Stage3DProxy;

	import flash.display.BitmapData;
	import flash.events.Event;

	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.entities.Mesh;
	import away3d.hacks.TrackedBitmapTexture;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;
	import away3d.textures.Texture2DBase;
	import away3d.utils.Cast;
	
	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.core.models.SourceImageProxy;
	import net.psykosoft.psykopaint2.home.views.book.BookGeometryProxy;
	import net.psykosoft.psykopaint2.home.views.book.BookMaterialsProxy;
	

	public class BookLayoutSampleThumbView extends ObjectContainer3D
	{
		
		private var _width:Number = 60;
		private var _height:Number = 40;
		
		private var _imageProxy:SourceImageProxy;
		
		//THUMBNAIL
		private var _thumbMesh:Mesh;
		private var _thumbMaterial:TextureMaterial;
		
		//SHADOW
		private var _shadowTextureMaterial:TextureMaterial
		private var _shadowMesh:Mesh;
		
		//LOADING ASSET
		private var EVENT_LOADED:String = "EVENT_LOADED";

		private var _thumbTexture:TrackedBitmapTexture;
		private var _stage3DProxy:Stage3DProxy;
		
		
		
		public function BookLayoutSampleThumbView(stage3DProxy:Stage3DProxy)
		{
			_stage3DProxy = stage3DProxy;

			//THIS IS THE CLASS WHERE WE ADD THE THUMBNAIL WITH SHADOWS			
			var cardGeom : Geometry = BookGeometryProxy.getGeometryById(BookGeometryProxy.CARD_GEOMETRY);
			_thumbMesh = new Mesh(cardGeom, BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.THUMBNAIL_LOADING));
			_thumbMesh.scaleX = _width;
			_thumbMesh.scaleZ = _height;
			_thumbMesh.y = 1;
			_thumbMesh.mouseEnabled=true;
			addChild(_thumbMesh);

			_shadowTextureMaterial = BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.THUMBNAIL_SHADOW);
			_shadowMesh = new Mesh(cardGeom,_shadowTextureMaterial);
			_shadowMesh.scaleX = 64;
			_shadowMesh.scaleZ = 25;
			_shadowMesh.z = -18;
			addChild(_shadowMesh);

			_thumbTexture = new TrackedBitmapTexture(null, false);
			_thumbMaterial = new TextureMaterial(_thumbTexture, true, false, false);
		}
		
		public function get height():Number
		{
			return _height;
		}

		public function get width():Number
		{
			return _width;
		}

		public function get imageProxy():SourceImageProxy
		{
			return _imageProxy;
		}

		public function set imageProxy(value:SourceImageProxy):void{
			_imageProxy = value;
			_imageProxy.loadThumbnail(onThumbnailLoaded,onThumbnailFail,1 /* 1= large thumbnail */);
		}
		
		override public function dispose():void{
			
			//trace("BookThumbnailView::dispose "+FileSourceImageProxy(_imageProxy).id);
			_imageProxy.cancelLoading();
			_imageProxy = null;
		
			/*//IF ASSET HAVEN'T FINISHED LOADING THE THOSE GUYS WILL STILL BE NULL */
			_thumbMaterial.dispose();
			_thumbTexture.dispose();

			_shadowMesh.dispose()
			
			_thumbMesh= null;
			_thumbTexture = null;
			_thumbMaterial = null;
			_shadowMesh = null;
			
			//WE DON'T DISPOSE OF THE SHADOW MATERIAL. TO DISPOSE IN BookMaterialsProxy
			
			super.dispose();
		}
		
		
		
		private function onThumbnailFail():void
		{
			trace("OUPS THE ASSET FAILED TO LOAD "+_imageProxy);
		}
		
		private function onThumbnailLoaded(file : Object):void
		{
			var sourceBmd:BitmapData = BitmapData(file);
			var bitmapData:BitmapData = TextureUtil.ensurePowerOf2ByScaling(BitmapData(file));
			sourceBmd.dispose();
			_thumbTexture.bitmapData = bitmapData;
			_thumbTexture.getTextureForStage3D(_stage3DProxy);
			_thumbMesh.material = _thumbMaterial;
			bitmapData.dispose();

			dispatchEvent(new Event(EVENT_LOADED));
		}

	}
}