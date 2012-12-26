package net.psykosoft.psykopaint2.assets.away3d.textures.vo
{

	/*
	* Away3dTextureAssetsManager always returns power of 2 images and when the asset used does not
	* have power of 2 dimensions, it returns images with transparency.
	* This utility is useful to store and verify if the raw image differs in dimensions with the
	* GPU texture.
	* */
	public class Away3dTextureInfoVO
	{
		public var imageWidth:Number;
		public var imageHeight:Number;
		public var textureWidth:Number;
		public var textureHeight:Number;

		public function Away3dTextureInfoVO( bitmapWidth:Number, bitmapHeight:Number, textureWidth:Number, textureHeight:Number ) {
			this.imageWidth = bitmapWidth;
			this.imageHeight = bitmapHeight;
			this.textureWidth = textureWidth;
			this.textureHeight = textureHeight;
		}
	}
}
