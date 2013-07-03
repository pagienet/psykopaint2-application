package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.CompactSubGeometry;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.textures.ByteArrayTexture;

	import flash.display.BitmapData;
	import flash.geom.Point;

	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.core.data.PaintingVO;

	/*
	* Represents just the "paper" rectangle of a painting with no frame or glass.
	* */
	public class EaselPainting extends ObjectContainer3D
	{
		private var _width:Number;
		private var _height:Number;
		private var _scale:Number = 1;

		private var _plane:Mesh;
		private var _material:TextureMaterial;

		public function EaselPainting( paintingVO : PaintingVO, view:View3D) {

			super();

			_width = paintingVO.width;
			_height = paintingVO.height;
			trace( this, "creating picture with dimensions: " + _width + "x" + _height );

			_plane = createPlane(paintingVO);
//			_plane = new Mesh( new PlaneGeometry( _width, _height ), new TextureMaterial( new BitmapTexture( diffuseBitmap ) ) ); // TODO: test non power of 2 textures with air 3.8
			_plane.rotationX = -90;
//			_material.lightPicker = lightPicker;
			addChild( _plane );
		}

		private function createPlane(paintingVO : PaintingVO) : Mesh
		{
			var width : int = paintingVO.width;
			var height : int = paintingVO.height;
			var textureWidth : int = paintingVO.textureWidth;
			var textureHeight : int = paintingVO.textureHeight;
			var diffuseTexture : ByteArrayTexture = new ByteArrayTexture(paintingVO.colorImageBGRA, textureWidth, textureHeight);

			// Create material.
			_material = new TextureMaterial( diffuseTexture, true, false, false );

			// Build geometry.
			var planeGeometry:PlaneGeometry = new PlaneGeometry( width, height );
			var subGeometry:CompactSubGeometry = CompactSubGeometry(planeGeometry.subGeometries[0]);
			subGeometry.scaleUV(width/textureWidth, height/textureHeight);

			return new Mesh( planeGeometry, _material );
		}

		override public function dispose():void {

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
