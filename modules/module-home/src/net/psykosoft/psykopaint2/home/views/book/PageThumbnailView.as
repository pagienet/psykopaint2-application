package net.psykosoft.psykopaint2.home.views.book
{
	import flash.display.BitmapData;
	
	import away3d.containers.ObjectContainer3D;
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
		//SIGNALS
		public var thumbnailClicked:Signal;
		
		
		private var _width:Number = 60;
		private var _height:Number = 40;
		
		private var _geometry:PlaneGeometry;
		private var _pageMesh:Mesh;
		private var _data:SourceImageProxy;
		
		
		public function PageThumbnailView()
		{
			//THIS IS THE CLASS WHERE I ADD THE THUMBNAIL WITH SHADOWS
			
			thumbnailClicked = new Signal();
			this.mouseEnabled=true;
			this.addEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown);
		}
		
		
		protected function onMouseDown(event:MouseEvent3D):void
		{
			thumbnailClicked.dispatch(_data);
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
			this.removeEventListener(MouseEvent3D.MOUSE_DOWN,onMouseDown);
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
		}		
		 
		
	}
}