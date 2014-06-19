package net.psykosoft.psykopaint2.base.utils.misc
{
	import flash.display3D.textures.Texture;

	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;
	import net.psykosoft.psykopaint2.core.debug.UndisposedObjects;

	public class TrackedTexture
	{
		private var _texture : Texture;

		public function TrackedTexture(texture : Texture)
		{
			_texture = texture;
			trace("TrackedTexture::create"+this+" ");
			
			if (CoreSettings.TRACK_NON_GCED_OBJECTS)
				UndisposedObjects.getInstance().add(this);
		}

		public function get texture() : Texture
		{
			return _texture;
		}
		
		public function get size():int
		{
			return -1
		}
		
		public function dispose():void
		{
			_texture.dispose();
			trace("TrackedTexture::dispose"+this);
			if (CoreSettings.TRACK_NON_GCED_OBJECTS)
				UndisposedObjects.getInstance().remove(this);
		}
	}
}