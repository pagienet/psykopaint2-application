package net.psykosoft.psykopaint2.home.views.book
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;
	
	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.base.utils.images.BitmapDataUtils;
	import net.psykosoft.psykopaint2.base.utils.io.QueuedFileLoader;
	import net.psykosoft.psykopaint2.base.utils.io.events.AssetLoadedEvent;

	public class BookMaterialsProxy
	{
		
		public static const PAGE_PAPER:String = "PAGE_PAPER";
		public static const RING:String = "RING";
		public static const THUMBNAIL_SHADOW:String = "THUMBNAIL_SHADOW";
		
		private static var _fileLoader:QueuedFileLoader;
		private static var _assetsURLs:Array;
		private static var _textureMaterials:Vector.<TextureMaterial>;

		private static var _onComplete:Function;
 		private static var _alreadyLoaded:Boolean = false;
 		
		
		public function BookMaterialsProxy()
		{
			
		}
		
		private static function init():void{
			_fileLoader = new QueuedFileLoader();
			_textureMaterials = new Vector.<TextureMaterial>();
			
			_assetsURLs= [];
			_assetsURLs.push({index:0,id:RING,url:"book-packaged/images/book/rings.jpg"});
			_assetsURLs.push({index:1,id:PAGE_PAPER,url:"home-packaged/away3d/book/paperbook512.jpg"});
			_assetsURLs.push({index:2,id:THUMBNAIL_SHADOW,url:"book-packaged/images/page/pict_shadow.png"});
			
		}
		
		
		public static function launch(onComplete:Function):void{
			
			_onComplete = onComplete;
			if(_alreadyLoaded==false){
				
				init();
				
				for (var i:int = 0; i < _assetsURLs.length; i++) 
				{
					_fileLoader.loadImage(_assetsURLs[i].url, onImageLoadedComplete, onError, _assetsURLs[i]);
				}
			}else {
				_onComplete.call();
			}
				
		}
		
		public static function dispose():void{
			_alreadyLoaded=false;
			for (var i:int = 0; i < _textureMaterials.length; i++) 
			{
				_textureMaterials[i].dispose();
				_textureMaterials[i] = null;
			}
			init();
		}
		
		
		private static function onError( e:AssetLoadedEvent):void
		{
			throw new Error("BookMaterialsProxy:: Couldn't find asset "+e.customData.url);
			
		}
		
		
		
		private static function onImageLoadedComplete( e:AssetLoadedEvent):void
		{	
			
			
			var assetIndex:int = e.customData.index;
			trace("BookMaterialsProxy::onImageLoadedComplete assetIndex ="+assetIndex);
			//var bmd:BitmapData= BitmapData(e.data);
			//bmd.transparent=true;
			trace("is transparent ="+BitmapData(e.data).transparent);
			
			//CREATE THE TEXTURE
			var newTexture:BitmapTexture = new BitmapTexture(TextureUtil.autoResizePowerOf2(BitmapData(e.data)));
			_textureMaterials.push( new TextureMaterial(Cast.bitmapTexture(newTexture)));
			
			//WHEN LAST ASSET IS LOADED LAUNCH THE COMPLETE FUNCTION
			if(assetIndex==_assetsURLs.length-1){
				_alreadyLoaded = true;
				_onComplete.call();
			}
			
			
		}
		
		
		public static function getTextureMaterialById(id:String):TextureMaterial{
			
			var textureMaterial:TextureMaterial;
			for (var i:int = 0; i < _assetsURLs.length; i++) 
			{
				if(id==_assetsURLs[i].id){
					textureMaterial = _textureMaterials[i];
				}
			}
			return textureMaterial;
			
		}
	}
}