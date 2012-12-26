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

		public function Picture( lightPicker:StaticLightPicker, textureDescription:Away3dTextureInfoVO, diffuseTexture:BitmapTexture, normalsTexture:BitmapTexture = null ) {

			super();

			var material:TextureMaterial = new TextureMaterial( diffuseTexture );
			material.smooth = true;

			if( textureDescription.imageWidth != textureDescription.textureWidth || textureDescription.imageHeight != textureDescription.textureHeight ) {
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
			var plane:Mesh = new Mesh( new PlaneGeometry( textureDescription.textureWidth, textureDescription.textureHeight ), material );
			plane.rotationX = -90;
			addChild( plane );

			_width = textureDescription.imageWidth;
			_height = textureDescription.imageHeight;
		}

		public function get width():Number {
		 	return _width;
		}

		public function get height():Number {
			return _height;
		}
	}
}
