package net.psykosoft.psykopaint2.book.views.book.data
{
	import net.psykosoft.psykopaint2.book.views.models.BookPage;

	import away3d.materials.TextureMaterial;
	import away3d.entities.Mesh;
	import away3d.containers.ObjectContainer3D;
	import away3d.materials.TextureMaterial;
 
 	public class PagesManager
 	{
 		private const OPEN:int = -1;
 		private const CLOSE:int = 1;

 		private var _pages:Vector.<Mesh>;
 		private var _pagesContent:Vector.<BookPage>;
 		private var _container:ObjectContainer3D;
 		private var _pageHeight:uint;
 		private var _pageWidth:uint;
 
     		public function PagesManager(container:ObjectContainer3D)
 		{
 			_container = container;
 		}

 		public function get pageWidth():uint
 		{
 			return _pageWidth;
 		}
 		public function get pageHeight():uint
 		{
 			return _pageHeight;
 		}
 		public function get pagesCount():uint
 		{
 			return _pagesContent.length;
 		}
  
 		public function addPage(index:uint, totalPages:uint, materialRecto:TextureMaterial, marginRectoMaterial:TextureMaterial, materialVerso:TextureMaterial, marginVersoMaterial:TextureMaterial, isBlankRecto:Boolean = false):BookPage
 		{
 			if(!_pages){
 				_pages = new Vector.<Mesh>();
 				_pagesContent = new Vector.<BookPage>();
 			}

 			var page:BookPage;
 			
 			if(_pagesContent.length>0){
 				page = new BookPage(materialRecto, marginRectoMaterial, materialVerso, marginVersoMaterial, _pagesContent[0], isBlankRecto);
			} else {
				page = new BookPage(materialRecto, marginRectoMaterial, materialVerso, marginVersoMaterial, null, isBlankRecto);
				_pageHeight = page.pageWidth;
 				_pageWidth = page.pageHeight;
			}
 			
 			_container.addChild(page);
 			_pagesContent.push(page);
 			
 			var y:Number = ((totalPages-index)*4);

 			page.recto.y = page.verso.y = page.marginRecto.y = page.marginVerso.y = y;
 			//page.shade.y = y - 1;

 			_pages.push(page.verso, page.recto);

 			return page;
 		}
 
 		public function getPage(index:uint):BookPage
 		{	
 			if(index>_pagesContent.length-1) return null;
 			return _pagesContent[index];
 		}

 		public function hidePage(index:uint):void
 		{
 			_pagesContent[index].hide();
 		}
		public function showPage(index:uint):void
 		{
 			_pagesContent[index].show();
 		}

 		//public function shadeScale(index:uint, value:Number):void
 		//{
 		//	_pagesContent[index].shadeScale = value;
 		//}
 
 		public function rotatePage(index:uint, degrees:Number, foldRotation:Number):void
 		{
 			var bookPage:BookPage = _pagesContent[index];
 			
 			var force:Number;
	 		var origin:Number;

	 		//0-1
 			if(degrees < 0.5 || degrees > 179.5){
 				force = 0;
 				origin = 1;
 			} else {

 				 var direction:int = (bookPage.lastRotation<degrees)? OPEN : CLOSE;
				bookPage.direction = direction;

				var zeroOne:Number = 1- degrees /180;

				//-1 / 1
				var half:Number =   (zeroOne * 2 ) - 1 ;

				var reverse:Number;
				if(half<0){
					reverse = Math.abs(half+1);
				} else {
					reverse = Math.abs(half-1);
				}

				origin = Math.abs(half)/1.5  -  reverse*.2;

				var offset:Number = .5;
				half = (half<0)? half-offset : half+offset;

				force = half;
				force *= reverse*1.6;
 
				if(direction == OPEN && degrees<90) force = -force ;
				if(direction == CLOSE && degrees>90) force = -force;
 			}

 			bookPage.rotation = degrees;
 			bookPage.bend(force, origin, foldRotation);
		}

 		public function getPageSide(index:uint):Mesh
 		{
 			return _pages[index];
 		}

 		public function dispose():void
 		{
 			for(var i:uint = 0;i<_pages.length;++i){
 				_pages[i] = null;
 			}

 			for(i = 0;i<_pagesContent.length;++i){
 				_pagesContent[i].disposeContent();
 				_pagesContent[i] = null;
 			}

 			_pages = null;
 			_pagesContent = null;
 		}

 		public function removePages( count:uint):void
 		{
			var page:BookPage;

		 	for(var i:uint = count;i<_pagesContent.length;++i){
				page = _pagesContent[i];
				page.lock = (i>count)? true : false ;
			}
 		}
 
 	}
 } 