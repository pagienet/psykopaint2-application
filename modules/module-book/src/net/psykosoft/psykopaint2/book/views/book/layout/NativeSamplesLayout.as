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
	import net.psykosoft.psykopaint2.book.views.book.layout.LayoutBase;

	public class NativeSamplesLayout extends LayoutBase
	{
		public static const INSERTS_COUNT:uint = 6;
		
		private const INSERT_WIDTH:uint = 220;
		private const INSERT_HEIGHT:uint = 152;

		private var _insertNRMRect:Rectangle;
		private var _insertNormalmap:BitmapData;
		private var _shadow:BitmapData;
		private var _baseMask:BitmapData;

		public function NativeSamplesLayout(stage:Stage, previousLayout:LayoutBase = null)
		{
			super(BookImageSource.SAMPLE_IMAGES, stage, previousLayout);
		}

		override public function loadBookContent(onContentLoaded:Function):void
 		{	
 			prepareBookContent(onContentLoaded, INSERTS_COUNT);
 		}

 		override protected function disposeLayoutElements():void
		{
			_insertNRMRect = null;
			if(_baseMask)_baseMask.dispose();
		}
 
		//Custom compositing variation per layout and region registration for mouse detection
		override protected function composite(insertSource:BitmapData, data:BookData):void
		{
			var insertRect:Rectangle = new Rectangle(0, 0, INSERT_WIDTH, INSERT_HEIGHT);
			var pageIndex:uint = uint(data.pageIndex);
			var inPageIndex:uint = uint(data.inPageIndex);
			var isRecto:Boolean = (pageIndex %2 == 0)? true : false;
			var hasPower:Boolean = PlatformUtil.hasRequiredPerformanceRating(2);
				
			if(isRecto){

				if(inPageIndex %2 == 0){
					insertRect.x = 35;
				} else {
					insertRect.x = 260;
				}

			} else {

				if(inPageIndex %2 == 0){
					insertRect.x = 40;
				} else {
					insertRect.x = 265;
				}

			}

			var col:uint = Math.floor(inPageIndex/2);

			switch(col){
				case 0:
					insertRect.y = 5;
					break;
				case 1:
					insertRect.y = 172;
					break;
				case 2:
					insertRect.y = 342;
					break;
			}

			//random variations
			insertRect.x += -3+(Math.random()*6);
			insertRect.y += -3+(Math.random()*6);

			var rotation:Number = -1.5+(Math.random()*3);

			//the page material
			pageIndex = Math.floor(pageIndex);
			var pageMaterial:TextureMaterial = getPageMaterial(pageIndex);
 			//the destination diffuse texture
			var diffuseTextureSource:BitmapTexture = BitmapTexture(pageMaterial.texture);
 			//the destination diffuse bitmapdata
			var diffuseSourceBitmapdata:BitmapData = diffuseTextureSource.bitmapData;
			diffuseSourceBitmapdata.lock();
			
			//insert brighter reflection
			if(hasPower){
				var btMask:BitmapTexture = getEnviroMaskTexture(pageIndex);
				var maskBMD:BitmapData = btMask.bitmapData;

				if(_baseMask && (_baseMask.width != insertSource.width || _baseMask.height != insertSource.height) ){
					_baseMask.dispose();
					_baseMask = new BitmapData(insertSource.width, insertSource.height, false, 0xBBBBBB);

				} else if(!_baseMask){
					_baseMask = new BitmapData(insertSource.width, insertSource.height, false, 0xBBBBBB);
				}

				//insert the image loaded into diffuse map
				insert(insertSource, diffuseSourceBitmapdata, insertRect, rotation, true, true);
				insert(_baseMask, maskBMD, insertRect, rotation, false, true);

			} else {
				insert(insertSource, diffuseSourceBitmapdata, insertRect, rotation, true, true);
			}
			

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
			if(hasPower) {
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

					btMask.invalidateContent();
 					btMask.bitmapData = maskBMD;
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