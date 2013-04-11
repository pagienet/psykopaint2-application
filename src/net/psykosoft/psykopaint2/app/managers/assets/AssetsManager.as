package net.psykosoft.psykopaint2.app.managers.assets
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import starling.events.Event;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class AssetsManager
	{
		
		
		
		
		public static function init():void{
			
			
		}
		
		
		/**
		 * RETURN A TEXTURE AS PARAMETER ON THE ONCOMPLETE FUNCTION
		 */
		public static function loadTexture(url:String,onComplete:Function):void{
			
			// create a LoaderContext
			var loaderContext:LoaderContext = new LoaderContext();
			loaderContext.imageDecodingPolicy = ImageDecodingPolicy.ON_DEMAND;
			
			var loader:Loader = new Loader(); 
			loader.load( new URLRequest(url), loaderContext );
			loader.contentLoaderInfo.addEventListener ( Event.COMPLETE, onLoaderComplete );
			function onLoaderComplete ( e : Event ):void
			{
				// grab the loaded bitmap
				var loadedBitmap:Bitmap = LoaderInfo(e.currentTarget).loader.content as Bitmap;
				
				// create a texture from the loaded bitmap
				var texture:Texture = Texture.fromBitmap ( loadedBitmap )
				
				//PASS TEXTURE TO FUNCTION ON COMPLETE
				onComplete.call(null,texture);
			}
		}
		
		
		
	
		
	}
}