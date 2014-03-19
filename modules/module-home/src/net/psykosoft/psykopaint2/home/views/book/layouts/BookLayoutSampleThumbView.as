package net.psykosoft.psykopaint2.home.views.book.layouts
{
	import flash.display.BitmapData;
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
		
		private var _data:SourceImageProxy;
		
		//THUMBNAIL
		private var _thumbGeometry:PlaneGeometry;
		private var _thumbMesh:Mesh;
		private var _thumbMaterial:TextureMaterial;
		private var _thumbTexture:Texture2DBase;
		
		//SHADOW
		private var _shadowTextureMaterial:TextureMaterial
		private var _shadowMesh:Mesh;
		
		//LOADING ASSET
		private var _thumbLoadingMaterial:TextureMaterial;
		private var _thumbBmd:BitmapData;
		
		
		
		public function BookLayoutSampleThumbView()
		{
			//THIS IS THE CLASS WHERE WE ADD THE THUMBNAIL WITH SHADOWS
			
			
			_thumbGeometry = new PlaneGeometry(_width,_height,3,3,true,false);
			_thumbMesh = new Mesh(_thumbGeometry,BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.THUMBNAIL_LOADING));
			this.addChild(_thumbMesh);
			//_thumbMesh.y= 1;
			
		
			_shadowTextureMaterial = BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.THUMBNAIL_SHADOW);
		//	_shadowTextureMaterial.alphaBlending=true;
			//_shadowTextureMaterial.alphaBlending=true;
			//_shadowTextureMaterial.alphaPremultiplied=true;
			var newGeometry:Geometry = new PlaneGeometry(64,25,3,3,true,false);
			_shadowMesh = new Mesh(newGeometry,_shadowTextureMaterial);
			
			
			
			_thumbMesh.addChild(_shadowMesh);
			//_shadowMesh.y=1
			_shadowMesh.y=-1;
			_shadowMesh.z=-18;
			
			
		}
		
		
		protected function onMouseDown(event:MouseEvent3D):void
		{
			trace("Thumbnail "+_data['id']);
		}
		
		public function get height():Number
		{
			return _height;
		}

		public function get width():Number
		{
			return _width;
		}

		public function setData(data:SourceImageProxy):void{
			this._data = data;
			 
			
			var fileSourceImageProxy:FileSourceImageProxy = 	FileSourceImageProxy(_data);
			//fileSourceImageProxy.load(fileSourceImageProxy.highResThumbnailFilename,onThumbnailATFLoaded,onThumbnailFail,1);
			fileSourceImageProxy.loadThumbnail(onThumbnailLoaded,onThumbnailFail,1 /* 1= large thumbnail */);
			
		}
		
		override public function dispose():void{
			
			//trace("BookThumbnailView::dispose "+FileSourceImageProxy(_data).id);
			_data= null;
		
			//_shadowTextureMaterial.dispose();
			if (_thumbBmd) _thumbBmd.dispose();
			_thumbMesh.dispose();
			_thumbMaterial.dispose();
			_thumbTexture.dispose();
			
			_shadowMesh.dispose()
			
			_thumbBmd = null;
			_thumbTexture = null;
			_thumbMesh= null;
			_thumbMaterial = null;
			_thumbGeometry = null;
			_shadowMesh = null;
			
			//WE DON'T DISPOSE OF THE SHADOW MATERIAL. TO DISPOSE IN BookMaterialsProxy
			
			super.dispose();
		}
		
		
		
		private function onThumbnailFail():void
		{
			trace("OUPS THE ASSET FAILED TO LOAD "+_data);
		}
		
		private function onThumbnailLoaded(file : Object):void
		{
			
			_thumbGeometry = new PlaneGeometry(_width,_height,1,1,true,true);
			
			//trace("BookThumbnailView::onThumbnailATFLoaded "+FileSourceImageProxy(_data).id);
			
			//EITHER ATF
			if(file is ByteArray){
				//trace("PageThumbnailView::onThumbnailATFLoaded "+file);
				_thumbTexture = new TrackedATFTexture(ByteArray(file));
				
			}else {
				
				//WE DON'T RECREATE a BITMAPTEXTURE IF ALREADY EXIST
				if(!_thumbTexture) {
					_thumbBmd = TextureUtil.ensurePowerOf2ByScaling(BitmapData(file));
					_thumbTexture = new TrackedBitmapTexture(_thumbBmd);
				
				}else {
					BitmapTexture(_thumbTexture).bitmapData = TextureUtil.ensurePowerOf2ByScaling(BitmapData(file));
				}
				
			}
			
			//_thumbMaterial = new TextureMaterial(_thumbTexture);
			_thumbMaterial = new TextureMaterial(Cast.bitmapTexture(_thumbTexture));
			_thumbMesh.material = _thumbMaterial;
			_thumbMesh.material.smooth= true;

			
			this.addChild(_thumbMesh);
			
			//ADDING MOUSE ENABLING ON THIS ASSET HERE SO IT CAN DISPATCH TO PARENT
			_thumbMesh.mouseEnabled=true;
		}	
		
		
		
	}
}