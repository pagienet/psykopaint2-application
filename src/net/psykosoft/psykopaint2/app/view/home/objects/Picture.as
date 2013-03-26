package net.psykosoft.psykopaint2.app.view.home.objects
{

	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.SubGeometry;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;

	import net.psykosoft.psykopaint2.app.assets.away3d.textures.vo.Away3dTextureInfoVO;

	public class Picture extends ObjectContainer3D
	{
		private var _width:Number;
		private var _height:Number;
		private var _scale:Number = 1;

		private var _plane:Mesh;
		private var _texture:BitmapTexture;

		public function Picture( textureInfo:Away3dTextureInfoVO, diffuseTexture:BitmapTexture ) {

			super();

			_texture = diffuseTexture;

			var material:TextureMaterial = new TextureMaterial( diffuseTexture );
			material.smooth = true;
			material.mipmap = false;

			// Build plane.
			// Notes: Plane takes original image size ( not power of 2 dimensions ) and shifts and re-scales uvs
			// so that the image perfectly fits in the plane.
			var dw:Number = ( ( textureInfo.textureWidth - textureInfo.imageWidth ) / 2 ) / textureInfo.textureWidth; // TODO: math can be optimized
			var dh:Number = ( ( textureInfo.textureHeight - textureInfo.imageHeight ) / 2 ) / textureInfo.textureHeight;
			var dsw:Number = textureInfo.textureWidth / textureInfo.imageWidth;
			var dsh:Number = textureInfo.textureHeight / textureInfo.imageHeight;
			var planeGeometry:PlaneGeometry = new PlaneGeometry( textureInfo.imageWidth, textureInfo.imageHeight );
			var subGeometry:SubGeometry = planeGeometry.subGeometries[ 0 ];
			var uvs:Vector.<Number> = subGeometry.uvs;
			var newUvs:Vector.<Number> = new Vector.<Number>();
			for( var i:uint = 0; i < uvs.length / 2; i++ ) {
				var index:uint = i * 2;
				newUvs[ index ] = uvs[ index ] / dsw + dw;
				newUvs[ index + 1 ] = uvs[ index + 1 ] / dsh + dh;
			}
			subGeometry.updateUVData( newUvs );
			_plane = new Mesh( planeGeometry, material );
			_plane.rotationX = -90;
			addChild( _plane );

			_width = textureInfo.imageWidth;
			_height = textureInfo.imageHeight;
		}

		override public function dispose():void {

			trace( this, "dispose()" );

			_plane.dispose();
			_plane = null;

//			_texture.dispose();
			_texture = null;

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
