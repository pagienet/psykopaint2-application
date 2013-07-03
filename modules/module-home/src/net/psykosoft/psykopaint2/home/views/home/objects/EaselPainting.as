package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.CompactSubGeometry;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.LightPickerBase;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.ByteArrayTexture;

	import net.psykosoft.psykopaint2.core.data.PaintingVO;
	import net.psykosoft.psykopaint2.core.materials.PaintingDiffuseMethod;
	import net.psykosoft.psykopaint2.core.materials.PaintingNormalMethod;
	import net.psykosoft.psykopaint2.core.materials.PaintingSpecularMethod;

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

		public function EaselPainting( paintingVO : PaintingVO, lightPicker : LightPickerBase) {

			super();

			_width = paintingVO.width;
			_height = paintingVO.height;
			trace( this, "creating picture with dimensions: " + _width + "x" + _height );

			_plane = createPlane(paintingVO, lightPicker);
//			_plane = new Mesh( new PlaneGeometry( _width, _height ), new TextureMaterial( new BitmapTexture( diffuseBitmap ) ) ); // TODO: test non power of 2 textures with air 3.8
			_plane.rotationX = -90;
//			_material.lightPicker = lightPicker;
			addChild( _plane );
		}

		private function createPlane(paintingVO : PaintingVO, lightPicker : LightPickerBase) : Mesh
		{
			var width : int = paintingVO.width;
			var height : int = paintingVO.height;
			var textureWidth : int = paintingVO.textureWidth;
			var textureHeight : int = paintingVO.textureHeight;
			var diffuseTexture : ByteArrayTexture = new ByteArrayTexture(paintingVO.colorImageBGRA, textureWidth, textureHeight);
			var normalSpecularTexture : ByteArrayTexture = new ByteArrayTexture(paintingVO.heightmapImageBGRA, textureWidth, textureHeight);

			// Create material.
			_material = new TextureMaterial( diffuseTexture, true, false, false );
			_material.diffuseMethod = new PaintingDiffuseMethod();
			_material.normalMethod = new PaintingNormalMethod();
			_material.specularMethod = new PaintingSpecularMethod();
			_material.lightPicker = lightPicker;
			_material.ambientColor = 0xffffff;
			_material.ambient = 1;
			_material.specular = .5;
			_material.gloss = 200;
			_material.normalMap = normalSpecularTexture;

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
