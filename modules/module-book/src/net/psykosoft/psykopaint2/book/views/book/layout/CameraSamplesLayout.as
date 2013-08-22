package net.psykosoft.psykopaint2.book.views.book.layout
{
	import net.psykosoft.psykopaint2.book.BookImageSource;
	import net.psykosoft.psykopaint2.book.views.book.layout.LayoutBase;
	import net.psykosoft.photos.UserPhotosExtension;
	import net.psykosoft.psykopaint2.core.configuration.CoreSettings;

	import flash.utils.Dictionary;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.Stage;

	import away3d.textures.BitmapTexture;
	import away3d.materials.TextureMaterial;
 
	public class CameraSamplesLayout extends LayoutBase
	{
		private const INSERT_WIDTH:uint = 100;
		private const INSERT_HEIGHT:uint = 100;

		private var _content:Vector.<Object>;
		private var _insertNormalmap:BitmapData;
		private var _shadow:BitmapData;
		private var _pagesFilled:Dictionary;
		private var _shadowRect:Rectangle;
		private var _ane:UserPhotosExtension;
		private var _aneReady:Boolean;

		public function CameraSamplesLayout(stage:Stage)
		{
			super(BookImageSource.USER_IMAGES, stage);

			_ane = new UserPhotosExtension();
			_ane.initialize( onUserLibraryReady );
		}

		//override protected function initDefaultAssets():void
		//{
		//	//debug no ane
		//	onUserLibraryReady();
		//}
		 
  
		private function onUserLibraryReady():void
		{
			_aneReady = true;
			var thumbsCount:uint = _ane.getNumberOfLibraryItems();
 
			_content = new Vector.<Object>();
			var data:Object;

			_pagesFilled = new Dictionary();
			var destPageIndex:uint;

			for(var i:uint = 0; i < thumbsCount;++i){
				 
				data = {name:""+i, index:i};
				_content.push(data);

				destPageIndex = uint(i/16);

				if(!_pagesFilled["pageIndex"+destPageIndex]){
					_pagesFilled["pageIndex"+destPageIndex] = {max:0, inserted:0};
				}
				_pagesFilled["pageIndex"+destPageIndex].max++;
			}
 
			//we have 16 images for this layout, 2 sides;
			var sides:uint = Math.ceil(thumbsCount/16);

			if(sides%2 != 0) sides+=1;
			pageCount = sides*.5;
		}

		override public function loadBookContent(cb:Function):void
 		{
 			if(_aneReady) cb();
 		}
 
		override public function loadContent():void
		{
			switchToHighDrawQuality();

			var bmd:BitmapData;
			var tmpBitmaps:Dictionary = new Dictionary();
			var size:Point;
			var index:uint;
 
			for(var i:uint = 0; i < _content.length;++i){
				// we could use i, but we may need async at some point
				index = _content[i].index;

				size = _ane.getThumbDimensionsAtIndex( index );

				if(tmpBitmaps[size.x+"x"+size.y]){
					bmd = tmpBitmaps[size.x+"x"+size.y];
				} else {
					bmd = new BitmapData( size.x, size.y, false, 0xFF0000 );
					tmpBitmaps[size.x+"x"+size.y] = bmd;
				}
  				 
				bmd = _ane.getThumbnailAtIndex( index, bmd );

				composite(bmd, _content[i]);
			}

			_content = null;

			for(var key:String in tmpBitmaps){
				tmpBitmaps[key].dispose();
			}

			tmpBitmaps = null;

			restoreQuality();
		}
  
 
		//Custom compositing variation per layout and region registration for mouse detection
		//
		// sample case: we insert 6 images per page
		override protected function composite(insertSource:BitmapData, object:Object):void
		{

			var insertRect:Rectangle = new Rectangle(0, 0, INSERT_WIDTH, INSERT_HEIGHT);
			var pageIndex:uint = uint(object.index/16);
			var inPageIndex:uint =  object.index - (pageIndex*16);
			var isRecto:Boolean = (pageIndex %2 == 0)? true : false;
			
			var col:uint = Math.floor(inPageIndex/4);

			var spaceCol:Number = 19;
			var spaceRow:Number = 15;

			var row:uint = Math.floor( inPageIndex%4);

			if(isRecto){				
				insertRect.x = 33+ ( (INSERT_WIDTH+spaceCol)*row );
			} else {
				insertRect.x = 25+ ( (INSERT_WIDTH+spaceCol)*row );
			}

			insertRect.y = 30 + ( (INSERT_HEIGHT+spaceRow)*col );
 

			//random variations
			insertRect.x += -2+(Math.random()*4);
			insertRect.y += -2+(Math.random()*4);
			 
			var rotation:Number =  -1.5+(Math.random()*3);
 			 
			//row layout recto: 50+200+31+200+31
			//the page material
			pageIndex = Math.floor(pageIndex);
			var pageMaterial:TextureMaterial = getPageMaterial(pageIndex);
 			//the destination diffuse texture
			var diffuseTextureSource:BitmapTexture = BitmapTexture(pageMaterial.texture);
 			//the destination diffuse bitmapdata
			var diffuseSourceBitmapdata:BitmapData = diffuseTextureSource.bitmapData;
			diffuseSourceBitmapdata.lock();
			//insert the image loaded into diffuse map. no need to dispose map, its being reused and finally destroyed when all is constructed
			insert(insertSource, diffuseSourceBitmapdata, insertRect, rotation, false);
 
			_pagesFilled["pageIndex"+pageIndex].inserted +=1;
			var invalidateContent:Boolean = (_pagesFilled["pageIndex"+pageIndex].inserted >= _pagesFilled["pageIndex"+pageIndex].max)? true : false;
			
			// no need to update the nroalmap if no shader uses it
			if(CoreSettings.RUNNING_ON_RETINA_DISPLAY) {

				var normalTextureSource:BitmapTexture = BitmapTexture( pageMaterial.normalMap);
				var normalSourceBitmapdata:BitmapData = normalTextureSource.bitmapData;

				if(!_insertNormalmap) _insertNormalmap = getInsertNormalMap();

				//insert the normalmap map of the image into the textureNormalmap
				normalSourceBitmapdata.lock();
				insert(_insertNormalmap, normalSourceBitmapdata, insertRect, rotation, false);
				normalTextureSource.bitmapData = normalSourceBitmapdata;
				normalSourceBitmapdata.unlock();
				if(invalidateContent) normalTextureSource.invalidateContent();
			}

			//dispatch the rect + object for region. the rect is updated for the shadow, the region will declare its own rect.
			object.inPageIndex = inPageIndex;
			object.pageIndex = pageIndex;
 			dispatchRegion(insertRect, object);

			//insert the shadow map
			if(!_shadow) _shadow = getShadow();
			if(!_shadowRect)  _shadowRect = new Rectangle(0, 0, INSERT_WIDTH, INSERT_HEIGHT);
			// because shadow is partly covering the image, update the insertRect
			// we need keep the insertRect intact for regions
			_shadowRect = new Rectangle(0, 0, INSERT_WIDTH, INSERT_HEIGHT);
			_shadowRect.x = insertRect.x - 5;
 			_shadowRect.y = insertRect.y + 35;
 			_shadowRect.width = INSERT_WIDTH+10;
 			_shadowRect.height = 75;
			insert(_shadow, diffuseSourceBitmapdata, _shadowRect, rotation, false, insertRect.x-_shadowRect.x, insertRect.y-_shadowRect.y);
			
 			diffuseSourceBitmapdata.unlock();

 			//update after inserts
 			if(invalidateContent){
 				diffuseTextureSource.invalidateContent();
 				diffuseTextureSource.bitmapData = diffuseSourceBitmapdata;
 			}
 			
		}

		override public function loadFullImage( fileName:String, cb:Function ):void
		{
			var index:uint = parseInt(fileName);
			var bmd:BitmapData = _ane.getFullImageAtIndex( index);
			cb(bmd);
		}

	}
}