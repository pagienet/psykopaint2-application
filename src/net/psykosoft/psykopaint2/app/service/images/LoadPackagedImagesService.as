package net.psykosoft.psykopaint2.app.service.images
{

	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	import org.osflash.signals.Signal;

	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	/*
	* Loads image atlases that contain a bunch of thumbnails ( with their image and descriptor xml files )
	* and regular full size images corresponding to such thumbnails.
	* Dispatches signals with the loaded assets when done. Does not keep any references to any data.
	* */
	public class LoadPackagedImagesService implements IImageService
	{
		private var _imageLoader:Loader;
		private var _imageLoadCallback:Function;
		private var _atlasDescriptorFilePath:String;
		private var _thumbnailsLoadedSignal:Signal;
		private var _imageLoadedSignal:Signal;

		public var imageUrl:String;
		public var xmlUrl:String;
		public var originalImagesPath:String;

		public function LoadPackagedImagesService() {
			super();
			_thumbnailsLoadedSignal = new Signal( TextureAtlas );
			_imageLoadedSignal = new Signal( BitmapData );
		}

		public function loadThumbnails():void {
			trace( this, "loading thumbnails - image url: " + imageUrl + ", descriptor url: " + xmlUrl );
			// Keep track of xml path for step 2.
			_atlasDescriptorFilePath = xmlUrl;
			// Step 1, load the atlas image ( async ).
			loadImage( imageUrl, onThumbnailsAtlasLoaded );
		}

		public function loadFullImage( imageUrl:String ):void {
			trace( this, "loading full image - url: " + imageUrl + ".jpg" );
			loadImage( originalImagesPath + imageUrl + ".jpg", onFullImageLoaded );
		}

		private function onFullImageLoaded( image:BitmapData ):void {
			_imageLoadedSignal.dispatch( image );
			_imageLoadedSignal = null;
		}

		private var _texture:Texture;

		private function onThumbnailsAtlasLoaded( image:BitmapData ):void {
			trace( this, "loadThumbnails()..." );
			// Step 2, load the atlas descriptor xml ( sync ).
			var xml:XML = XML( loadData( _atlasDescriptorFilePath ) );
			_atlasDescriptorFilePath = null;
			// Dispatch signal with image and xml.
			var texture:Texture = Texture.fromBitmapData( image );
			var atlas:TextureAtlas = new TextureAtlas( texture, xml ); // The atlas will be stored and managed in ThumbnailModel.as
			_thumbnailsLoadedSignal.dispatch( atlas );
			_thumbnailsLoadedSignal = null;
		}

		private function loadImage( url:String, callback:Function ):void {
			_imageLoadCallback = callback;
			trace( this, "loading image: " + url );
			var data:ByteArray = loadData( url );
			_imageLoader = new Loader();
			_imageLoader.contentLoaderInfo.addEventListener( Event.INIT, onImageLoaded );
			_imageLoader.loadBytes( data );
		}

		private function loadData( url:String ):ByteArray {
			var path:String = File.applicationDirectory.url + url;
			trace( this, "loading data: " + path );
			var file:File = new File( path );
			var fileStream:FileStream = new FileStream();
			var data:ByteArray = new ByteArray();
			try {
				fileStream.open( file, FileMode.READ );
			} catch( e:Error ) {
				throw new Error( this, "File not found for path. Are you sure the assets are in the bin folder, or packaged within the application?" );
			}
			fileStream.readBytes( data );
			fileStream.close();
			return data;
		}

		private function onImageLoaded( event:Event ):void {
			trace( this, "image loaded." );
			_imageLoader.contentLoaderInfo.removeEventListener( Event.INIT, onImageLoaded );
			var bmd:BitmapData = new BitmapData( _imageLoader.width, _imageLoader.height, false, 0 );
			bmd.draw( _imageLoader );
			_imageLoader = null;
			_imageLoadCallback( bmd );
			_imageLoadCallback = null;
		}

		public function getThumbnailsLoadedSignal():Signal {
			return _thumbnailsLoadedSignal;
		}

		public function getFullImageLoadedSignal():Signal {
			return _imageLoadedSignal;
		}

		public function disposeService():void {
			// There is nothing in particular in this service to dispose.
		}
	}
}
