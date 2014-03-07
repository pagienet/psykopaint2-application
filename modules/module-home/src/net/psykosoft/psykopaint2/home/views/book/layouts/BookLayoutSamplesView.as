package net.psykosoft.psykopaint2.home.views.book.layouts
{
	import net.psykosoft.psykopaint2.core.models.SourceImageCollection;
	import net.psykosoft.psykopaint2.core.models.SourceImageProxy;
	import net.psykosoft.psykopaint2.home.views.book.PageThumbnailView;
	
	public class BookLayoutSamplesView extends BookLayoutAbstractView
	{
		public static const COLUMNS:int=2;
		public static const ROWS:int=3;
		
		private var _data:SourceImageCollection;
		private var _pageThumbnailViews:Vector.<PageThumbnailView>;
		
		private var _pageIndex:int;
		
		public function BookLayoutSamplesView()
		{
			//THIS IS THE STANDARD LAYOUT VIEW FOR THE SAMPLES
			
			super();
		}
		
		public function setData(data:SourceImageCollection):void{
			this._data = data;
			
			_pageThumbnailViews = new Vector.<PageThumbnailView>();
			
			var currentSourceImageProxy:SourceImageProxy;
			for (var i:int = 0; i < _data.images.length; i++) 
			{
				currentSourceImageProxy = _data.images[i];
				var newPageThumbnailView:PageThumbnailView = new PageThumbnailView();
				newPageThumbnailView.setData(currentSourceImageProxy);
				
				_pageThumbnailViews.push(newPageThumbnailView);
				
				trace("BookLayoutSamplesView::setData::i="+i);
				this.addChild(newPageThumbnailView);
				newPageThumbnailView.x = (i%COLUMNS)*(newPageThumbnailView.width +10);
				newPageThumbnailView.z = Math.floor(i/COLUMNS)*-(newPageThumbnailView.height +10);
				//newPageThumbnailView.rotationY= Math.random()*5-2.5;
				
			}
			
			
		}
		
		static public  function get LENGTH():int{
			return  COLUMNS*ROWS;
		}
	}
}