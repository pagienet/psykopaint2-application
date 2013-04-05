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

	public class Picture extends ObjectContainer3D
	{
		private var _width:Number;
		private var _height:Number;
		private var _scale:Number = 1;

		private var _plane:Mesh;
		private var _material:TextureMaterial;
		private var _diffuseTexture:BitmapTexture;

		public function Picture( diffuseBitmap:BitmapData, imageDimensions:Point, textureDimensions:Point ) {

			super();

			_diffuseTexture = new BitmapTexture( diffuseBitmap );
			_diffuseTexture.getTextureForStage3D( DisplayContextManager.stage3dProxy );
			_diffuseTexture.name = "pictureTexture";
			diffuseBitmap.dispose();

			_material = new TextureMaterial( _diffuseTexture );
			_material.smooth = true;
			_material.mipmap = false;

			// Build plane.
			// Note: Plane takes original image size ( not power of 2 dimensions ) and shifts and re-scales uvs
			// so that the image perfectly fits in the plane.
			var dw:Number = ( ( textureDimensions.x - imageDimensions.x ) / 2 ) / textureDimensions.x; // TODO: math can be optimized
			var dh:Number = ( ( textureDimensions.y - imageDimensions.y ) / 2 ) / textureDimensions.y;
			var dsw:Number = textureDimensions.x / imageDimensions.x;
			var dsh:Number = textureDimensions.y / imageDimensions.y;
			var planeGeometry:PlaneGeometry = new PlaneGeometry( imageDimensions.x, imageDimensions.y );
			var subGeometry:SubGeometry = planeGeometry.subGeometries[ 0 ];
			var uvs:Vector.<Number> = subGeometry.uvs;
			var newUvs:Vector.<Number> = new Vector.<Number>();
			for( var i:uint = 0; i < uvs.length / 2; i++ ) {
				var index:uint = i * 2;
				newUvs[ index ] = uvs[ index ] / dsw + dw;
				newUvs[ index + 1 ] = uvs[ index + 1 ] / dsh + dh;
			}
			subGeometry.updateUVData( newUvs );
			_plane = new Mesh( planeGeometry, _material );
			_plane.rotationX = -90;
			addChild( _plane );

			_width = imageDimensions.x;
			_height = imageDimensions.y;
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
