package net.psykosoft.psykopaint2.book.views.book.data
{
	import net.psykosoft.psykopaint2.book.views.book.layout.Region;
	import net.psykosoft.psykopaint2.book.views.book.data.BookPageSize;
	import net.psykosoft.psykopaint2.book.views.models.BookPage;

	import flash.geom.Rectangle;
	import flash.geom.Vector3D;

	import away3d.containers.View3D;
	import away3d.entities.Mesh;

	import net.psykosoft.psykopaint2.book.views.models.BookThumbnailData;

	public class RegionManager
 	{
 		private var _regions:Vector.<Region>;
 		private var _view:View3D;
 		private var _pagesManager:PagesManager;
 
 		private const _extremeX:Number = 1024;
 		private const _extremeZ:Number = 512;

 		private var _np:Vector3D;
 		private var _a:Number = 0;
		private var _b:Number = 0;
		private var _c:Number = 0;
		private var _d:Number = 1;
		private var _middle:Number;
		private var _regionZoffset:Number = 0;
 
     		public function RegionManager(view:View3D, pagesManager:PagesManager)
 		{
 			_pagesManager = pagesManager;
 			_view = view;
 			_middle = _view.stage.stageWidth * .5;
 			_regions = new Vector.<Region>();
 		}

 		public function set regionZoffset(val:Number):void
 		{
 			_regionZoffset = val;
 		}
 		public function get regionZoffset():Number
 		{
 			return _regionZoffset;
 		}

 		public function addRegion(rect:Rectangle, data:BookThumbnailData):void
 		{
 			var region:Region = new Region();
 			region.data = data;
 			region.UVRect = new Rectangle(rect.x/BookPageSize.WIDTH, rect.y/BookPageSize.HEIGHT, rect.width/BookPageSize.WIDTH, rect.height/BookPageSize.WIDTH);
 			region.pageIndex = data.pageIndex;
 			//should not happend if the book was propperly cleared
 			if(!_regions)_regions = new Vector.<Region>();
 			_regions.push(region);
 		}
 
 		public function hitTestRegions(x:Number, y:Number, pageIndex:uint):BookThumbnailData
 		{
 			if(_regions.length == 0) return null;
 			
 			var isRecto:Boolean = (x>_middle) ? true : false;

 			if(pageIndex == 0 && !isRecto) return null
 
 			var pageSideIndex:uint = ( isRecto)? pageIndex*2 : (pageIndex*2)-1;
 			var bookPage:BookPage = _pagesManager.getPage((isRecto)? pageIndex :  pageIndex-1 );
 			if(!bookPage) return null;

 			if(!_np) _np = new Vector3D(0.0, 1, 0.1);
 			 
 			_a = -0.001;
			_b = -bookPage.recto.y;
			_c = 0;//-regionZoffset;
			_d = -(_a*_np.x + _b*_np.y + _c*_np.z);

 			var pMouse:Vector3D = _view.unproject(x, y, 1);

 			var cam:Vector3D = _view.camera.position;
			var d0:Number = _np.x*cam.x + _np.y*cam.y + _np.z*cam.z - _d;
			var d1:Number = _np.x*pMouse.x + _np.y*pMouse.y + _np.z*pMouse.z - _d;
			var m:Number = d1/( d1 - d0 );
			
			var hitX:Number = pMouse.x + ( cam.x - pMouse.x )*m;
			var hitZ:Number = pMouse.z + ( cam.z - pMouse.z )*m;
 
			hitZ -= regionZoffset;
 
 			if(hitX > _extremeX || hitX < -_extremeX || hitZ< -_extremeZ || hitZ > _extremeZ) return null;

			hitZ += _extremeZ;
 
 			var u:Number = (isRecto)? Math.abs(hitX / _extremeX) : 1 - (Math.abs(hitX) / _extremeX);
 			var v:Number = 1-(Math.abs(hitZ) / (_extremeZ*2));
 
 			var region:Region;
 			for(var i:uint = 0; i <_regions.length;++i){
 				region = _regions[i];
 				if(region.pageIndex == pageSideIndex){
					if(region.UVRect.contains(u, v)){
						return region.data;
					}	
				}
 			}

 			return null;
 		}
 

 		public function dispose():void
 		{
 			if(_regions){
 				for(var i:uint = 0;i<_regions.length;++i){
 					_regions[i].UVRect = null;
 					_regions[i].data = null;
 					_regions[i] = null;
 				}
 				_regions = null;
 			}
 			
 			if(_np) _np = null;
 		}
 
 	}
 } 