package net.psykosoft.psykopaint2.home.views.book.layouts
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.hacks.TrackedATFTexture;
	import away3d.hacks.TrackedBitmapTexture;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.textures.Texture2DBase;
	import away3d.utils.Cast;
	
	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.core.models.FileSourceImageProxy;
	import net.psykosoft.psykopaint2.core.models.SourceImageProxy;
	import net.psykosoft.psykopaint2.home.views.book.BookMaterialsProxy;
	

	public class BookLayoutSampleThumbView extends ObjectContainer3D
	{
		
		private var _width:Number = 60;
		private var _height:Number = 40;
		
		private var _imageProxy:SourceImageProxy;
		
		//THUMBNAIL
		private var _thumbGeometry:PlaneGeometry;
		private var _thumbMesh:Mesh;
		private var _thumbMaterial:TextureMaterial;
		
		//SHADOW
		private var _shadowTextureMaterial:TextureMaterial
		private var _shadowMesh:Mesh;
		
		//LOADING ASSET
		private var _thumbLoadingMaterial:TextureMaterial;
		private var _thumbBmd:BitmapData;
		private var EVENT_LOADED:String = "EVENT_LOADED";
		
		
		
		public function BookLayoutSampleThumbView()
		{
			//THIS IS THE CLASS WHERE WE ADD THE THUMBNAIL WITH SHADOWS			
			_thumbGeometry = new PlaneGeometry(_width,_height,3,3,true,false);
			_thumbMesh = new Mesh(_thumbGeometry,BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.THUMBNAIL_LOADING));
			this.addChild(_thumbMesh);
			_thumbMesh.y= 1;
			_thumbMesh.mouseEnabled=true;
			
		
			_shadowTextureMaterial = BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.THUMBNAIL_SHADOW);
			var newGeometry:Geometry = new PlaneGeometry(64,25,3,3,true,false);
			_shadowMesh = new Mesh(newGeometry,_shadowTextureMaterial);
			this.addChild(_shadowMesh);
			_shadowMesh.z=-18;
			
			
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
			if(_thumbMaterial){ 
				_thumbMaterial.texture.dispose();
				_thumbMaterial.dispose();
			}
			if (_thumbBmd) _thumbBmd.dispose();
			
			_shadowMesh.dispose()
			
			_thumbBmd = null;
			_thumbMesh= null;
			_thumbMaterial = null;
			_thumbGeometry = null;
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
			var texture:Texture2DBase	
			
			//EITHER ATF
//			if(file is ByteArray){
//				//trace("PageThumbnailView::onThumbnailATFLoaded "+file);
//				_thumbTexture = new TrackedATFTexture(ByteArray(file));
//				
//			}else {
				
				if(!_thumbMaterial) {
					_thumbBmd = TextureUtil.ensurePowerOf2ByScaling(BitmapData(file));
					texture = new TrackedBitmapTexture(_thumbBmd);
					_thumbMaterial = new TextureMaterial(Cast.bitmapTexture(texture),false);
					_thumbMaterial.mipmap = false;
					_thumbMesh.material = _thumbMaterial;
					
				}else {
					//trace("replace bitmap");
					
					_thumbBmd.dispose();
					_thumbBmd = null;
					_thumbBmd = TextureUtil.ensurePowerOf2ByScaling(BitmapData(file));
					BitmapTexture(_thumbMaterial.texture).bitmapData = _thumbBmd;
					//previousBmd.dispose();
					_thumbMaterial.mipmap = false;
					_thumbMesh.material = _thumbMaterial;
					
				}
				dispatchEvent(new Event(EVENT_LOADED));
			
		}	
		
		
		
	}
}