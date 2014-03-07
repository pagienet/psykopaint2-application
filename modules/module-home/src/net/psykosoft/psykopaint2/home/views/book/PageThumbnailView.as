package net.psykosoft.psykopaint2.home.views.book
{
	import flash.display.BitmapData;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.entities.Mesh;
	import away3d.events.MouseEvent3D;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.utils.Cast;
	
	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.core.models.SourceImageProxy;
	
	import org.osflash.signals.Signal;

	public class PageThumbnailView extends ObjectContainer3D
	{
		
		private var _width:Number = 60;
		private var _height:Number = 40;
		
		private var _geometry:PlaneGeometry;
		private var _pageMesh:Mesh;
		private var _data:SourceImageProxy;
		private var _shadowTextureMaterial:TextureMaterial
		
		private var _shadowMesh:Mesh;
		public function PageThumbnailView()
		{
			//THIS IS THE CLASS WHERE WE ADD THE THUMBNAIL WITH SHADOWS
			
		
			_shadowTextureMaterial = BookMaterialsProxy.getTextureMaterialById(BookMaterialsProxy.THUMBNAIL_SHADOW);
			_shadowTextureMaterial.alphaBlending=true;
			var newGeometry:Geometry = new PlaneGeometry(64,25,1,1,true,true);
			_shadowMesh = new Mesh(newGeometry,_shadowTextureMaterial);
			
			this.addChild(_shadowMesh);
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
			 
			_data.loadThumbnail(onThumbnailLoaded,onThumbnailFail,1);
			
		}
		
		override public function dispose():void{
			_data= null;
			//_pageMesh.removeEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown);
			super.dispose();
		}
		
		
		
		private function onThumbnailFail():void
		{
			trace("OUPS THE ASSET FAILED TO LOAD");
		}
		
		private function onThumbnailLoaded(bitmapData : BitmapData):void
		{
			_geometry = new PlaneGeometry(_width,_height,1,1,true,true);
			_pageMesh = new Mesh(_geometry,new TextureMaterial(Cast.bitmapTexture(TextureUtil.ensurePowerOf2ByScaling(bitmapData))));
			trace("ASSET LOADED"+ _data);
			this.addChild(_pageMesh);
			_pageMesh.mouseEnabled=true;
			//_pageMesh.addEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown);
		}		
		 
		
	}
}