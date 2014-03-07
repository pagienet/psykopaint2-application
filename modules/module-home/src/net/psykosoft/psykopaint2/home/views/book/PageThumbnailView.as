package net.psykosoft.psykopaint2.home.views.book
{
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.tools.utils.TextureUtils;
	import away3d.utils.Cast;
	
	import net.psykosoft.psykopaint2.core.models.SourceImageProxy;

	public class PageThumbnailView extends ObjectContainer3D
	{
		
		private var _width:Number = 60;
		private var _height:Number = 40;
		
		private var _geometry:PlaneGeometry;
		private var _pageMesh:Mesh;
		private var _data:SourceImageProxy;
		
		public function PageThumbnailView()
		{
			//THIS IS THE CLASS WHERE I ADD THE THUMBNAIL WITH SHADOWS
			
			
			
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
		
		private function autoResizeBitmapData(bmData:BitmapData,smoothing:Boolean = true):BitmapData 
		{
			if (TextureUtils.isBitmapDataValid(bmData))
				return bmData;
			
			var max:Number = Math.max(bmData.width, bmData.height);
			max = TextureUtils.getBestPowerOf2(max);
			var mat:Matrix = new Matrix();
			mat.scale(max/bmData.width, max/bmData.height);
			var bmd:BitmapData = new BitmapData(max, max);
			bmd.draw(bmData, mat, null, null, null, smoothing);
			return bmd;
		} 
		
		private function onThumbnailFail():void
		{
			trace("OUPS THE ASSET FAILED TO LOAD");
		}
		
		private function onThumbnailLoaded(bitmapData : BitmapData):void
		{
			_geometry = new PlaneGeometry(_width,_height,1,1,true,true);
			_pageMesh = new Mesh(_geometry,new TextureMaterial(Cast.bitmapTexture(autoResizeBitmapData(bitmapData))));
			trace("ASSET LOADED"+ _data);
			this.addChild(_pageMesh);
		}		
		 
		
	}
}