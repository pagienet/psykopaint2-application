package net.psykosoft.psykopaint2.book.views.book.layout
{
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.geom.Rectangle;

	import net.psykosoft.psykopaint2.base.utils.misc.PlatformUtil;
	import net.psykosoft.psykopaint2.book.BookImageSource;
	import net.psykosoft.psykopaint2.book.views.models.BookData;

	public class NativeSamplesLayout extends LayoutBase
	{
		private const INSERT_WIDTH:uint = 200;
		private const INSERT_HEIGHT:uint = 130;
		private const INSERTS_COUNT:uint = 6;

		private var _insertNRMRect:Rectangle;
		private var _insertNormalmap:BitmapData;
		private var _shadow:BitmapData;

		public function NativeSamplesLayout(stage:Stage)
		{
			super(BookImageSource.SAMPLE_IMAGES, stage);
		}

		override public function loadBookContent(onContentLoaded:Function):void
 		{	
 			prepareBookContent(onContentLoaded, INSERTS_COUNT);
 		}

 		override protected function disposeLayoutElements():void
		{
			_insertNRMRect = null;
		}
 
		//Custom compositing variation per layout and region registration for mouse detection
		override protected function composite(insertSource:BitmapData, data:BookData):void
		{
			var insertRect:Rectangle = new Rectangle(0, 0, INSERT_WIDTH, INSERT_HEIGHT);
			var pageIndex:uint = uint(data.pageIndex);
			var inPageIndex:uint = uint(data.inPageIndex);
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

			var rotation:Number = -1.5+(Math.random()*3);
 
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
			insert(insertSource, diffuseSourceBitmapdata, insertRect, rotation, true, true);
			var offset:Number = (lastHeight*.5);

			diffuseSourceBitmapdata.unlock();
 
			_pagesFilled["pageIndex"+pageIndex].inserted +=1;
			var invalidateContent:Boolean = (_pagesFilled["pageIndex"+pageIndex].inserted >= _pagesFilled["pageIndex"+pageIndex].max)? true : false;
			
			if(!_insertNRMRect) _insertNRMRect = new Rectangle();
 
			_insertNRMRect.x = insertRect.x+((insertRect.width - lastWidth)*.5);
			_insertNRMRect.y = insertRect.y+((insertRect.height - lastHeight)*.5);
			_insertNRMRect.width = lastWidth;
			_insertNRMRect.height = lastHeight;
 
			// no need to update the normalmap if no shader uses it
			if(PlatformUtil.hasRequiredPerformanceRating(2) ) {
				var normalTextureSource:BitmapTexture = BitmapTexture( pageMaterial.normalMap);
				var normalSourceBitmapdata:BitmapData = normalTextureSource.bitmapData;
 
				if(!_insertNormalmap) _insertNormalmap = getInsertNormalMap();
				 
				//insert the normalmap map of the image into the textureNormalmap
				normalSourceBitmapdata.lock();
				insert(_insertNormalmap, normalSourceBitmapdata, _insertNRMRect, rotation, false, false);
				normalSourceBitmapdata.unlock();
				
				if(invalidateContent) {
					normalTextureSource.invalidateContent();
					normalTextureSource.bitmapData = normalSourceBitmapdata;
				}
			}

			//dispatch the rect + object for region. the rect is updated for the shadow, the region will declare its own rect.
			data.inPageIndex = inPageIndex;
			data.pageIndex = pageIndex;
 			dispatchRegion(insertRect, data);

			//insert the shadow map
			if(!_shadow)  _shadow = getShadow();

			insert(_shadow, diffuseSourceBitmapdata, _insertNRMRect, rotation, false, true, 0,0,-5, offset);

 			//update after inserts
 			if(invalidateContent){
 				diffuseTextureSource.invalidateContent();
 				diffuseTextureSource.bitmapData = diffuseSourceBitmapdata;
 			}
 			
		}
	}
}