package net.psykosoft.psykopaint2.book.views.book.layout
{
	import net.psykosoft.psykopaint2.book.BookImageSource;
	import net.psykosoft.psykopaint2.book.views.book.layout.LayoutBase;
	import net.psykosoft.psykopaint2.book.views.book.layout.InsertRef;

	import net.psykosoft.psykopaint2.book.views.book.data.FileLoader;
	import net.psykosoft.psykopaint2.book.views.book.data.events.AssetLoadedEvent;
	import net.psykosoft.psykopaint2.book.views.book.data.ImageRes;

	import flash.utils.Dictionary;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.display.Stage;

	import away3d.textures.BitmapTexture;
	import away3d.materials.TextureMaterial;

	public class NativeSamplesLayout extends LayoutBase
	{
		private const INSERT_WIDTH:uint = 200;
		private const INSERT_HEIGHT:uint = 130;

		private var _loadedResources:uint = 0;
		private var _resourcesCount:uint;
		private var _fileLoader:FileLoader;
		private var _content:Vector.<Object>;

		private var _insertNormalmap:BitmapData;
		private var _shadow:BitmapData;

		public function NativeSamplesLayout(stage:Stage)
		{
			_fileLoader = new FileLoader();

			super(BookImageSource.SAMPLE_IMAGES, stage);
		}

		//override protected function initDefaultAssets():void
		//{
			//needs to occur before parsexml to retrieve

			//var url:String = path to dedicated resources map + id;
			//_fileLoader.loadImage(url, onImageLoadedComplete, onImageLoadError, {url:url, name:id, index:index, type:ImageRes.LOWRES});
			//add resource count _loadedResources += 2
		//}

		// we first collect the content before loading it to be able to define the pages first in Book Class.
		// load content is then called after default pages data is generated
		override public function parseXml( xml:XML ):void
		{
			_content = new Vector.<Object>();
			var paths:XMLList = xml.descendants("path");

			_originalsPath = paths.child("originals");
			_thumbsHighResPath = paths.child("highRes");
			_thumbsLowResPath = paths.child("lowRes");

 			var images:XMLList = xml.descendants("images");
 			var loop :uint = images.child("image").length();
			var node:Object;
			var name:String;
			var data:Object;
			var url:String;

			for(var i:uint = 0; i < loop;++i){
				node = images.child("image")[i];
				name = node.attribute("name")
				//url = _thumbsLowResPath+name;
				url = _thumbsHighResPath+name;
				 
				data = {	url:url, 
						name:name, 
						index:i, 
						type:ImageRes.HIGHRES};

				_content.push(data);
			}

			_resourcesCount = loop;
			//we have 6 images for this layout, 2 sides;
			var sides:uint = Math.ceil(loop/6);

			if(sides%2 != 0) sides+=1;
			pageCount = sides*.5;
		}

		override public function loadContent():void
		{
			for(var i:uint = 0; i < _content.length;++i){
				loadImage(_content[i]);
			}
			_content = null;
		}

		private function loadImage( object:Object):void
		{
			_fileLoader.loadImage(object.url, onImageLoadedComplete, onImageLoadError, object);
		}
 
		private function onImageLoadedComplete( e:AssetLoadedEvent):void
		{
			var name:String = e.customData.name;
			
			composite(e.data, e.customData);

			if(e.customData.type == ImageRes.LOWRES){
				var url:String = _thumbsHighResPath+name;
				e.customData.type = ImageRes.HIGHRES;
				e.customData.url = url;
				_fileLoader.loadImage(url, onImageLoadedComplete, onImageLoadError, e.customData);
			}
			
			clearFileloader();
		}

		private function onImageLoadError(e:AssetLoadedEvent):void
		{
			clearFileloader();
		}

		private function clearFileloader():void
		{
			_loadedResources++;
			if(_resourcesCount == _loadedResources){
				_fileLoader = null;
			}
		}

		//Custom compositing variation per layout and region registration for mouse detection
		//
		// sample case: we insert 6 images per page
		override protected function composite(insertSource:BitmapData, object:Object):void
		{
 			switchToHighDrawQuality();

 			var insertRef:InsertRef;
 			var insertRect:Rectangle;
 			var pageIndex:uint;
			var inPageIndex:uint;
			var isNewInsert:Boolean;
			var rotation:Number;
			var itemIndex:String = ""+object.index;

 			if(_inserts[itemIndex]){
 				insertRef = _inserts[itemIndex];
 				//if lowres arrives after highres for some reasons --> no need to continue
 				// we did it all already
 				if(insertRef.hasHighres){
 					insertSource.dispose();
 					return;
 				}

 				insertRect = insertRef.rectangle;
 				pageIndex = insertRef.pageIndex;
				inPageIndex =  insertRef.inPageIndex;
				rotation = insertRef.rotation;

 			} else {
 				
 				isNewInsert = true;
 				insertRef= new InsertRef();
 				insertRect = new Rectangle(0, 0, INSERT_WIDTH, INSERT_HEIGHT);

 				pageIndex = insertRef.pageIndex = object.index/6;
				inPageIndex =  insertRef.inPageIndex = object.index - (pageIndex*6);

				if(object.type == ImageRes.HIGHRES) insertRef.hasHighres = true;

 				var isRecto:Boolean = (pageIndex %2 == 0)? true : false;

				if(isRecto){

					if(inPageIndex %2 == 0){
						insertRect.x = 50;
					} else {
						insertRect.x = 281;
					}

				} else {

					if(inPageIndex %2 == 0){
						insertRect.x = 31;
					} else {
						insertRect.x = 262;
					}

				}

				//col layout recto: 31+130+31+130+31+130
				var col:uint = Math.floor(inPageIndex/2);
				switch(col){
					case 0:
						insertRect.y = 31;
						break;
					case 1:
						insertRect.y = 192;
						break;
					case 2:
						insertRect.y = 353;
						break;

				}

				//random variations
				insertRect.x += -3+(Math.random()*6);
				insertRect.y += -3+(Math.random()*6);
 				insertRef.rectangle = insertRect;

 				_inserts[itemIndex] = insertRef;
 				rotation = insertRef.rotation = -2+(Math.random()*4);
 			}
 			

			//row layout recto: 50+200+31+200+31
  
			//the page material
			pageIndex = Math.floor(pageIndex);
			var pageMaterial:TextureMaterial = getPageMaterial(pageIndex);
 			//the destination diffuse texture
			var diffuseTextureSource:BitmapTexture = BitmapTexture(pageMaterial.texture);
 			//the destination diffuse bitmapdata
			var diffuseSourceBitmapdata:BitmapData = diffuseTextureSource.bitmapData;
			diffuseSourceBitmapdata.lock();
			//insert the image loaded into diffuse map
			insert(insertSource, diffuseSourceBitmapdata, insertRect, rotation, true);

			//because shadow and normalmap are high res, we do not need do this twice
			// and we catch the unlikely event where a lowres would be loaded after the highres.
			if(isNewInsert){

				var normalTextureSource:BitmapTexture = BitmapTexture( pageMaterial.normalMap);
				var normalSourceBitmapdata:BitmapData = normalTextureSource.bitmapData;
 
				if(!_insertNormalmap) _insertNormalmap = getInsertNormalMap();

				//insert the normalmap map of the image into the textureNormalmap
				insert(_insertNormalmap, normalSourceBitmapdata, insertRect, rotation, false);
				normalTextureSource.bitmapData = normalSourceBitmapdata;

				//dispatch the rect + object for region. the rect is updated for the shadow, the region will declare its own rect.
				//object.inPageIndex = inPageIndex;
				object.pageIndex = pageIndex;
	 			dispatchRegion(insertRect, object);

				//insert the shadow map
				if(!_shadow) _shadow = getShadow();
				// because shadow is partly covering the image, update the insertRect
				// we need keep the insertRect intact for regions
				var shadowRect:Rectangle = new Rectangle(0, 0, INSERT_WIDTH, INSERT_HEIGHT);
				shadowRect.x = insertRect.x - 10;
	 			shadowRect.y = insertRect.y + 40;
	 			shadowRect.width = INSERT_WIDTH+15;
	 			shadowRect.height = 105;
				insert(_shadow, diffuseSourceBitmapdata, shadowRect, rotation, false, insertRect.x-shadowRect.x, insertRect.y-shadowRect.y);
			}	 			

 			diffuseSourceBitmapdata.unlock();

 			//update after inserts
 			diffuseTextureSource.bitmapData = diffuseSourceBitmapdata;
 			
 			restoreQuality();
 			
		}

	}
}