package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;

	/*
	* Represents just the "paper" rectangle of a painting with no frame or glass.
	* */
	public class Painting extends ObjectContainer3D
	{
		private var _width:Number;
		private var _height:Number;
		private var _scale:Number = 1;

		private var _plane:Mesh;
		private var _material:TextureMaterial;

		public function Painting( diffuseBitmap:BitmapData, normalBitmap:BitmapData, view:View3D, lightPicker : StaticLightPicker ) {

			super();

			_width = diffuseBitmap.width;
			_height = diffuseBitmap.height;
			trace( this, "creating picture with dimensions: " + _width + "x" + _height );

			_plane = TextureUtil.createPlaneThatFitsNonPowerOf2TransparentImage( diffuseBitmap, normalBitmap, view.stage3DProxy );
//			_plane = new Mesh( new PlaneGeometry( _width, _height ), new TextureMaterial( new BitmapTexture( diffuseBitmap ) ) ); // TODO: test non power of 2 textures with air 3.8
			_plane.rotationX = -90;
			_material = TextureMaterial(_plane.material);
//			_material.lightPicker = lightPicker;
			addChild( _plane );
		}

		override public function dispose():void {

			trace( this, "dispose()" );

			_plane.dispose();
			_material.dispose();
			_material.texture.dispose();
			if (_material.normalMap) _material.normalMap.dispose();

			_plane = null;
			_material = null;

			super.dispose();
		}

		public function get width():Number {
		 	return _width * _scale;
		}

		public function get height():Number {
			return _height * _scale;
		}

		public function scalePainting( value:Number ):void {
			_scale = _plane.scaleX = _plane.scaleZ = value;
		}
	}
}
