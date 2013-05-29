package net.psykosoft.psykopaint2.core.resources
{
	public interface ITextureManager
	{
		function initTexture(textureProxy : TextureProxy) : void;
		function freeTexture(textureProxy : TextureProxy) : void;
	}
}
