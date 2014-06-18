package net.psykosoft.psykopaint2.home.views.book
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;
	
	import away3d.animators.SpriteSheetAnimationSet;
	import away3d.animators.data.SpriteSheetAnimationFrame;
	import away3d.animators.nodes.SpriteSheetClipNode;
	import away3d.entities.Mesh;
	import away3d.hacks.TrackedATFTexture;
	import away3d.hacks.TrackedBitmapTexture;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.ATFTexture;
	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;
	
	import net.psykosoft.psykopaint2.base.utils.gpu.TextureUtil;
	import net.psykosoft.psykopaint2.base.utils.io.QueuedFileLoader;
	import net.psykosoft.psykopaint2.base.utils.io.events.AssetLoadedEvent;
	import net.psykosoft.psykopaint2.core.configuration.PsykoFonts;
	
	import org.osflash.signals.Signal;

	public class HomeMaterialsCache
	{
		
		public static const PAGE_PAPER:String = "PAGE_PAPER";
		public static const RING:String = "RING";
		public static const THUMBNAIL_SHADOW:String = "THUMBNAIL_SHADOW";
		public static const THUMBNAIL_LOADING:String = "THUMBNAIL_LOADING";
		public static const ICON_COMMENT:String = "ICON_COMMENT";
		public static const ICON_HEART:String = "ICON_HEART";
		public static const ICON_PAINTINGMODE:String = "ICON_PAINTINGMODE";
		public static const FRAME_EMPTY:String = "FRAME_EMPTY";
		public static const FRAME_WHITE:String = "FRAME_WHITE";
		
		public static var onCompleteSignal:Signal = new Signal();
		
		private static var _fileLoader:QueuedFileLoader;
		private static var _assetsURLs:Array;
		private static var _textureMaterials:Vector.<TextureMaterial>;
		private static var _bitmapDatas:Vector.<BitmapData>;

		private static var _onComplete:Function;
 		private static var _alreadyLoaded:Boolean = false;
 	
 		
 		
		
		public function HomeMaterialsCache()
		{
			
		}
		
		private static function init():void{
			_fileLoader = new QueuedFileLoader();
			_textureMaterials = new Vector.<TextureMaterial>();
			_bitmapDatas = new Vector.<BitmapData>();
			
			_assetsURLs= [];
			_assetsURLs.push({id:RING,url:"home-packaged/images/book/rings.jpg"});
			_assetsURLs.push({id:PAGE_PAPER,url:"home-packaged/images/page/paperbook2.jpg"});
			_assetsURLs.push({id:THUMBNAIL_SHADOW,url:"home-packaged/images/page/pict_shadow.png"});
			_assetsURLs.push({id:THUMBNAIL_LOADING,url:"home-packaged/away3d/book/loadingThumbnail.png",storeBmd:true});
			_assetsURLs.push({id:ICON_COMMENT,url:"home-packaged/images/layouts/comment.png",storeBmd:true});
			_assetsURLs.push({id:ICON_HEART,url:"home-packaged/images/layouts/heart.png",storeBmd:true});
			_assetsURLs.push({id:ICON_PAINTINGMODE,url:"home-packaged/images/layouts/painting.png",storeBmd:true});
			_assetsURLs.push({id:FRAME_EMPTY,url:"home-packaged/images/frames/emptyFrame.png",storeBmd:false});
			_assetsURLs.push({id:FRAME_WHITE,url:"home-packaged/images/frames/simpleWhite.png",storeBmd:false});
		}
		
		
		
		public static function launch(onComplete:Function):void{
			
			_onComplete = onComplete;
			if(_alreadyLoaded==false){
				
				init();
				
				for (var i:int = 0; i < _assetsURLs.length; i++) 
				{
					trace (_assetsURLs[i].url);
					//IF ASSET IS ATF
					if(_assetsURLs[i].url.indexOf(".atf") > -1){
						_fileLoader.loadBinary(_assetsURLs[i].url, onATFLoadComplete, onError, _assetsURLs[i]);
					}else{
						_fileLoader.loadImage(_assetsURLs[i].url, onBitmapLoadComplete, onError, _assetsURLs[i]);
					}
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
		
		
		private static function onATFLoadComplete( e:AssetLoadedEvent):void
		{
			var assetIndex:int = _assetsURLs.indexOf(e.customData);
			//e.customData.index;
			//trace("BookMaterialsProxy::onImageLoadedComplete assetIndex ="+assetIndex);

			//CREATE THE TEXTURE
			var texture : ATFTexture = new TrackedATFTexture(ByteArray(e.data));
			_textureMaterials.push( new TextureMaterial(texture));

			//WHEN LAST ASSET IS LOADED LAUNCH THE COMPLETE FUNCTION
			completeIfLastAsset(assetIndex);
		}

		private static function onBitmapLoadComplete( e:AssetLoadedEvent):void
		{
			var currentAssetURLObj:Object = e.customData;
			var assetIndex:int = _assetsURLs.indexOf(currentAssetURLObj);

			//CREATE THE TEXTURE
			var bmd:BitmapData = BitmapData(e.data);
			if (currentAssetURLObj.storeBmd==true){
				if (_bitmapDatas.length <= assetIndex)
					_bitmapDatas.length = assetIndex+1;
				_bitmapDatas[assetIndex] = bmd;
				trace("STore bmd for "+ currentAssetURLObj.id);
			}
			var newTexture:BitmapTexture = new TrackedBitmapTexture(TextureUtil.autoResizePowerOf2(bmd));
			var newTextureMaterial:TextureMaterial = new TextureMaterial((newTexture));

			//SET ALPHA BLENDING FOR ALL TEXTURE THAT ARE PNGs //OTHERWISE USE JPG MOFO!!!
			if(currentAssetURLObj.url.indexOf(".png")!=-1){
				newTextureMaterial.alphaBlending = true;
			}
			_textureMaterials.push(newTextureMaterial );

			//WHEN LAST ASSET IS LOADED LAUNCH THE COMPLETE FUNCTION
			completeIfLastAsset(assetIndex);
		}

		public static function getBitmapDataById(id:String):BitmapData{

			var currentBitmapData:BitmapData;
			for (var i:int = 0; i < _assetsURLs.length; i++)
			{
				if(id==_assetsURLs[i].id){
					currentBitmapData = _bitmapDatas[i];
				}
			}
			return currentBitmapData;

		}

		private static function completeIfLastAsset(assetIndex:int):void
		{
			if (assetIndex == _assetsURLs.length - 1) {
				_alreadyLoaded = true;
				_onComplete.call();
				onCompleteSignal.dispatch();
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


		////DRAFT FOR LATER IF I'm MOTIVATED TO MAKE AN ATLAS PARSER
		public function parseAtlasXml(animID:String, textureWidth:uint, textureHeight:uint, atlasXml:XML) : SpriteSheetAnimationSet
		{
			var spriteSheetAnimationSet:SpriteSheetAnimationSet = new SpriteSheetAnimationSet();
			var node:SpriteSheetClipNode = new SpriteSheetClipNode();
			node.name = animID;
			
			spriteSheetAnimationSet.addAnimation(node);
			
			var frame:SpriteSheetAnimationFrame;
			var u:uint, v:uint,i:uint;
			
			var scale:Number = 1;//mAtlasTexture.scale;
			
			for each (var subTexture:XML in atlasXml.SubTexture)
			{
				var name:String = subTexture.attribute("name");
				var x:Number = parseFloat(subTexture.attribute("x")) / scale;
				var y:Number = parseFloat(subTexture.attribute("y")) / scale;
				var width:Number = parseFloat(subTexture.attribute("width")) / scale;
				var height:Number = parseFloat(subTexture.attribute("height")) / scale;
				//  var frameX:Number = parseFloat(subTexture.attribute(“frameX”)) / scale;
				//  var frameY:Number = parseFloat(subTexture.attribute(“frameY”)) / scale;
				//  var frameWidth:Number = parseFloat(subTexture.attribute(“frameWidth”)) / scale;
				//  var frameHeight:Number = parseFloat(subTexture.attribute(“frameHeight”)) / scale;
				
				//  var regionR:Rectangle = new Rectangle(x, y, width, height);
				// var frameR:Rectangle = frameWidth > 0 && frameHeight > 0 ? new Rectangle(frameX, frameY, frameWidth, frameHeight) : null;
				
				
				frame = new SpriteSheetAnimationFrame();
				frame.offsetU = x / textureWidth;
				frame.offsetV = y / textureHeight;
				frame.scaleU = width / textureWidth;
				frame.scaleV = height / textureHeight;
				frame.mapID = i;
				
				node.addFrame(frame, 16);
				i++;
			}
			
			return spriteSheetAnimationSet;
		}
		
		
		
		
		
		
		
	}
}