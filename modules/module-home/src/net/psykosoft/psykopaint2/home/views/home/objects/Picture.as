package net.psykosoft.psykopaint2.home.views.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;

	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;

	public class Picture extends ObjectContainer3D
	{
		private var _width:Number;
		private var _height:Number;
		private var _scale:Number = 1;

		private var _plane:Mesh;
		private var _material:TextureMaterial;
		private var _diffuseTexture:BitmapTexture;

		public function Picture( diffuseBitmap:BitmapData, view:View3D ) {

			super();

			_width = diffuseBitmap.width;
			_height = diffuseBitmap.height;
			trace( this, "creating picture with dimensions: " + _width + "x" + _height );

			_plane = TextureUtil.createPlaneThatFitsNonPowerOf2TransparentImage( diffuseBitmap, view.stage3DProxy );
//			_plane = new Mesh( new PlaneGeometry( _width, _height ), new TextureMaterial( new BitmapTexture( diffuseBitmap ) ) ); // TODO: test non power of 2 textures with air 3.8
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
