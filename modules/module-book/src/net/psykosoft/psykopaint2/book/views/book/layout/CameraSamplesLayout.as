package net.psykosoft.psykopaint2.book.views.book.layout
{
	import net.psykosoft.psykopaint2.book.BookImageSource;
	import net.psykosoft.psykopaint2.book.views.book.layout.LayoutBase;
	import net.psykosoft.psykopaint2.base.utils.misc.PlatformUtil;
	import net.psykosoft.psykopaint2.book.views.models.BookData;

	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.display.Stage;

	import away3d.textures.BitmapTexture;
	import away3d.materials.TextureMaterial;
 
	public class CameraSamplesLayout extends LayoutBase
	{
		private const INSERT_WIDTH:uint = 100;
		private const INSERT_HEIGHT:uint = 100;
		private const INSERTS_COUNT:uint = 16;

		private var _insertNormalmap:BitmapData;
		private var _shadow:BitmapData;
		private var _insertNRMRect:Rectangle;
		 
		public function CameraSamplesLayout(stage:Stage)
		{
			super(BookImageSource.USER_IMAGES, stage);
		}

		override public function loadBookContent(onContentLoaded:Function):void
 		{	
 			prepareBookContent(onContentLoaded, INSERTS_COUNT);
 		}

 		override protected function disposeLayoutElements():void
		{
			_insertNRMRect = null;
		}
		 
		// sample case: we insert 6 images per page
		override protected function composite(insertSource:BitmapData, data:BookData):void
		{
			var insertRect:Rectangle = new Rectangle(0, 0, INSERT_WIDTH, INSERT_HEIGHT);
			var pageIndex:uint = uint(data.pageIndex);
			var inPageIndex:uint = uint(data.inPageIndex);
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
 			
			//the page material
			pageIndex = Math.floor(pageIndex);
			var pageMaterial:TextureMaterial = getPageMaterial(pageIndex);
 			//the destination diffuse texture
			var diffuseTextureSource:BitmapTexture = BitmapTexture(pageMaterial.texture);
 			//the destination diffuse bitmapdata
			var diffuseSourceBitmapdata:BitmapData = diffuseTextureSource.bitmapData;
			diffuseSourceBitmapdata.lock();
			//insert the image loaded into diffuse map. no need to dispose map, its being reused and finally destroyed when all is constructed
			insert(insertSource, diffuseSourceBitmapdata, insertRect, rotation, false, true);
			var lastHeight:Number = lastHeight;
			var lastScaleY:Number = lastScaleY;
			var offset:Number = (lastHeight*.5);
 
			_pagesFilled["pageIndex"+pageIndex].inserted +=1;
			var invalidateContent:Boolean = (_pagesFilled["pageIndex"+pageIndex].inserted >= _pagesFilled["pageIndex"+pageIndex].max)? true : false;
			
			if(!_insertNRMRect) _insertNRMRect = new Rectangle();
 
			_insertNRMRect.x = insertRect.x+((insertRect.width - lastWidth)*.5);
			_insertNRMRect.y = insertRect.y+((insertRect.height - lastHeight)*.5);
			_insertNRMRect.width = lastWidth;
			_insertNRMRect.height = lastHeight;

			// no need to update the nroalmap if no shader uses it
			if(PlatformUtil.hasRequiredPerformanceRating(2)) {

				var normalTextureSource:BitmapTexture = BitmapTexture( pageMaterial.normalMap);
				var normalSourceBitmapdata:BitmapData = normalTextureSource.bitmapData;

				if(!_insertNormalmap) _insertNormalmap = getInsertNormalMap();

				//insert the normalmap map of the image into the textureNormalmap
				normalSourceBitmapdata.lock();
				insert(_insertNormalmap, normalSourceBitmapdata, _insertNRMRect, rotation, false, false);
				normalSourceBitmapdata.unlock();
				
				if(invalidateContent){
					normalTextureSource.invalidateContent();
					normalTextureSource.bitmapData = normalSourceBitmapdata;
				}
			}

			//dispatch the rect + data for region. the rect is updated for the shadow, the region will declare its own rect.
			data.inPageIndex = inPageIndex;
			data.pageIndex = pageIndex;
 			dispatchRegion(insertRect, data);

			//insert the shadow map
			if(!_shadow) _shadow = getShadow();

			insert(_shadow, diffuseSourceBitmapdata, _insertNRMRect, rotation, false, true, 0,0,-5, offset);
			
 			diffuseSourceBitmapdata.unlock();

 			//update after inserts
 			if(invalidateContent){
 				diffuseTextureSource.invalidateContent();
 				diffuseTextureSource.bitmapData = diffuseSourceBitmapdata;
 			}
 			
		}
	}
}