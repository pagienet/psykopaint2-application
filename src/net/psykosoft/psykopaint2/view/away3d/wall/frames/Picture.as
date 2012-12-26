package net.psykosoft.psykopaint2.view.away3d.wall.frames
{

	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;

	import net.psykosoft.psykopaint2.assets.away3d.textures.vo.Away3dTextureInfoVO;

	import net.psykosoft.psykopaint2.config.Settings;

	public class Picture extends ObjectContainer3D
	{
		private var _width:Number;
		private var _height:Number;
		private var _scale:Number = 1;

		private var _plane:Mesh;

		public function Picture( lightPicker:StaticLightPicker, textureInfo:Away3dTextureInfoVO, diffuseTexture:BitmapTexture, normalsTexture:BitmapTexture = null ) {

			super();

			var material:TextureMaterial = new TextureMaterial( diffuseTexture );
			material.smooth = true;

			if( textureInfo.imageWidth != textureInfo.textureWidth || textureInfo.imageHeight != textureInfo.textureHeight ) {
				material.alphaBlending = true;
			}

			if( Settings.USE_COMPLEX_ILLUMINATION_ON_PAINTINGS && normalsTexture ) {
				material.lightPicker = lightPicker;
				material.gloss = 10;
				material.ambient = 0.75;
				material.specular = 0.2;
				material.normalMap = normalsTexture;
			}

			// TODO: used shared geometry
			_plane = new Mesh( new PlaneGeometry( textureInfo.textureWidth, textureInfo.textureHeight ), material );
			_plane.rotationX = -90;
			addChild( _plane );

			_width = textureInfo.imageWidth;
			_height = textureInfo.imageHeight;
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
