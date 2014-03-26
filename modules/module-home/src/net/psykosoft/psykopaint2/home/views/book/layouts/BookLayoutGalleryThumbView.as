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
	import net.psykosoft.psykopaint2.core.models.FileGalleryImageProxy;
	import net.psykosoft.psykopaint2.core.models.GalleryImageProxy;
	import net.psykosoft.psykopaint2.home.views.book.BookMaterialsProxy;

	public class BookLayoutGalleryThumbView  extends ObjectContainer3D
	{
		public static const EVENT_LOADED:String = "EVENT_LOADED";
		
		private var _width:Number = 60;
		private var _height:Number = 40;
		
		private var _imageProxy:GalleryImageProxy;
		
		//THUMBNAIL
		private var _thumbGeometry:PlaneGeometry;
		private var _thumbMesh:Mesh;
		private var _thumbMaterial:TextureMaterial;
		//private var _thumbTexture:Texture2DBase;
		
		//SHADOW
		private var _shadowMesh:Mesh;
		
		//LOADING IMAGE
		private var _thumbBmd:BitmapData;
		private var _commentMesh:Mesh;
		private var _likeMesh:Mesh;
		private var _onComplete:Function;
		
		
		
		public function BookLayoutGalleryThumbView()
		{
			//THIS IS THE CLASS WHERE WE ADD THE THUMBNAIL WITH SHADOWS
			
			_thumbGeometry = new PlaneGeometry(_width,_height,1,1,true,true);
			_thumbMesh = new Mesh(_thumbGeometry,BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.THUMBNAIL_LOADING));
			this.addChild(_thumbMesh);
			_thumbMesh.y=1;
		
			//ADDING MOUSE ENABLING ON THIS ASSET HERE SO IT CAN DISPATCH TO PARENT
			_thumbMesh.mouseEnabled=true;
			
			var newGeometry:Geometry = new PlaneGeometry(64,25,1,1,true,true);
			_shadowMesh = new Mesh(newGeometry,BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.THUMBNAIL_SHADOW));
			
			this.addChild(_shadowMesh);
			//_shadowMesh.y=3;
			_shadowMesh.z=-18;
			
			
			//COMMENT ICON
			var commentPlaneGeometry:PlaneGeometry = new PlaneGeometry(5,5,1,1,true,true);
			_commentMesh = new Mesh(commentPlaneGeometry,BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.ICON_COMMENT));
			_commentMesh.y=2;
			_commentMesh.z=-25;
			_commentMesh.x=10;
			this.addChild(_commentMesh);
			
			//LIKE ICON
			var likePlaneGeometry:PlaneGeometry = new PlaneGeometry(5,5,1,1,true,true);
			_likeMesh = new Mesh(likePlaneGeometry,BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.ICON_HEART));
			_likeMesh.y=3;
			_likeMesh.z=-25;
			_likeMesh.x=25;
			this.addChild(_likeMesh);
		}
		

		protected function onMouseDown(event:MouseEvent3D):void
		{
			trace("Thumbnail "+_imageProxy['id']);
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

		public function set imageProxy(value:GalleryImageProxy):void{

						
			if(_imageProxy == null || (_imageProxy.id) != (value.id))
			{
				
				_imageProxy = value;
				
				//SHOW THE LOADING THUMBNAIL
				_thumbMesh.material =   BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.THUMBNAIL_LOADING)
				
			}
			
		}
		
		
		public function load(onComplete:Function=null):void{
			_onComplete = onComplete;
			if(!_imageProxy) trace("BookLayoutGalleryThumbView::WARNING!! Trying to load but there's no data");
			_imageProxy.loadThumbnail(onThumbnailLoaded,onThumbnailFail,1 /* 1= large thumbnail */);

		}
		
		
		override public function dispose():void{
			
			trace("BookLayoutGalleryThumbView::dispose "+FileGalleryImageProxy(_imageProxy).id);
			
			_imageProxy.cancelLoading();
			_imageProxy= null;
			
			_likeMesh.dispose();
			_commentMesh.dispose();
			_thumbMesh.dispose();
			_shadowMesh.dispose();
			
			/*//IF ASSET HAVEN'T FINISHED LOADING THE THOSE GUYS WILL STILL BE NULL */
			if(_thumbMaterial){ 
				_thumbMaterial.texture.dispose();
				_thumbMaterial.dispose();
			}
			if (_thumbBmd) _thumbBmd.dispose();
			
			
			_commentMesh = null;
			_thumbBmd = null;
			_thumbMesh= null;
			_thumbMaterial.texture = null;
			_thumbMaterial = null;
			_thumbGeometry = null;
			_shadowMesh = null;
			_onComplete= null;
			
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
			
			//trace("BookLayoutGalleryThumbView::loaded "+_imageProxy.id);
			
			//EITHER ATF
//			if(file is ByteArray){
//				texture = new TrackedATFTexture(ByteArray(file));
//				
//			}else {
//				
				//WE DON'T RECREATE a BITMAPTEXTURE IF ALREADY EXIST
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
				
				
				if(_onComplete)_onComplete.call();
		//	}
			
			
			
		}	
		
	}
}