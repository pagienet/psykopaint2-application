package away3d.hacks
{

	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Matrix;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.debug.UndisposedObjects;

	public class TrackedBitmapTexture extends BitmapTexture
	{
		public function TrackedBitmapTexture(bitmapData:BitmapData, generateMipmaps:Boolean = true)
		{
			super(bitmapData, generateMipmaps);

			if (CoreSettings.TRACK_NON_GCED_OBJECTS)
				UndisposedObjects.getInstance().add(this);
		}

		override public function dispose():void
		{
			super.dispose();

			if (CoreSettings.TRACK_NON_GCED_OBJECTS)
				UndisposedObjects.getInstance().remove(this);
		}
	}
}
