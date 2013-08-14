package net.psykosoft.psykopaint2.book.views.book.data
{
	import net.psykosoft.psykopaint2.book.views.models.BookPage;

	import away3d.materials.TextureMaterial;
	import away3d.entities.Mesh;
	import away3d.containers.ObjectContainer3D;

 	public class PagesManager
 	{
 		private var _pages:Vector.<Mesh>;
 		private var _pagesContent:Vector.<BookPage>;
 		private var _container:ObjectContainer3D;
 
     		public function PagesManager(container:ObjectContainer3D)
 		{
 			_container = container;
 		}

 		public function addPage(index:uint, totalPages:uint, materialRecto:TextureMaterial, materialVerso:TextureMaterial):void
 		{
 			if(!_pages){
 				_pages = new Vector.<Mesh>(totalPages*2, true);
 				_pagesContent = new Vector.<BookPage>(totalPages, true);
 			}

 			var page:BookPage;
 			if(_pagesContent.length>0){
 				page = new BookPage(materialRecto, materialVerso, _pagesContent[0]);
			} else {
				page = new BookPage(materialRecto, materialVerso);
			}
 			
 			_container.addChild(page);
 			_pagesContent[index] = page;
 			
 			var y:Number = totalPages-index;
 			page.recto.y = page.verso.y = y;
 			
 			_pages[index*2] = page.recto;
 			_pages[(index*2)+1] = page.verso;
 		}

 		public function getPage(index:uint):BookPage
 		{
 			return _pagesContent[index];
 		}

 		public function rotatePage(index:uint, deg:Number):void
 		{
 			var bookPage:BookPage = _pagesContent[index];
 			 bookPage.rotationZ = deg;
 		}

 		public function getPageSide(index:uint):Mesh
 		{
 			return _pages[index];
 		}

 		public function dispose():void
 		{
 			var i:uint;

 			for(i = 0;i<_pages.length;++i){
 				_pages[i] = null;
 			}
 			for(i = 0;i<_pagesContent.length;++i){
 				_pagesContent[i].disposeContent();
 				_pagesContent[i] = null;
 			}

 			_pages = null;
 			_pagesContent = null;
 		
 		}

 
 	}
 } 