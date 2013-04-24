package net.psykosoft.psykopaint2.app.view.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.SubGeometry;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;
	import flash.geom.Point;

	import net.psykosoft.psykopaint2.app.utils.DisplayContextManager;
	import net.psykosoft.psykopaint2.app.utils.textures.TextureUtil;

	public class Picture extends ObjectContainer3D
	{
		private var _width:Number;
		private var _height:Number;
		private var _scale:Number = 1;

		private var _plane:Mesh;
		private var _material:TextureMaterial;
		private var _diffuseTexture:BitmapTexture;

		public function Picture( diffuseBitmap:BitmapData ) {

			super();

			_width = diffuseBitmap.width;
			_height = diffuseBitmap.height;

			_plane = TextureUtil.createPlaneThatFitsNonPowerOf2TransparentImage( diffuseBitmap );
			_plane.rotationX = -90;
			_material = _plane.material as TextureMaterial;
			_diffuseTexture = _material.texture as BitmapTexture;
			addChild( _plane );
		}

		override public function dispose():void {

			trace( this, "dispose()" );

			_plane.dispose();
			_material.dispose();
			_diffuseTexture.dispose();

			_diffuseTexture = null;
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
