package net.psykosoft.psykopaint2.book.views.book.objects
{

	import net.psykosoft.psykopaint2.book.views.book.*;

	import away3d.containers.ObjectContainer3D;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.textures.BitmapTexture;

	import flash.display.BitmapData;

	import flash.display.Sprite;

	import flash.display.Stage;

	import net.psykosoft.psykopaint2.base.utils.ui.ScrollInteractionManager;
	import net.psykosoft.psykopaint2.base.utils.ui.SnapPositionManager;

	public class Book extends ObjectContainer3D
	{
		private var _pageData:Vector.<PageVO>;
		private var _pageWidth:uint;
		private var _pageHeight:uint;
		private var _positionManager:SnapPositionManager;
		private var _interactionManager:ScrollInteractionManager;
		private var _activePageIndex:uint;
		private var _activePage:Page;
		private var _previousPage:Page;
		private var _nextPage:Page;
		private var _positionOffset:Number;

		private const SNAP_POINT_SPACING:uint = 100;
		private const PREPARE_PAGE_RANGE:uint = 2;

		public function Book( stage:Stage, width:Number, height:Number ) {
			super();

			_pageWidth = width;
			_pageHeight = height;
			_positionOffset = 0;

			_positionManager = new SnapPositionManager();
			_positionManager.minimumThrowingSpeed = 5;

			_interactionManager = new ScrollInteractionManager( _positionManager );
			_interactionManager.stage = stage;

			addChild( _previousPage = new Page( width, height ) );
			addChild( _nextPage = new Page( width, height ) );
			addChild( _activePage = new Page( width, height ) );

			// The position of these pages never moves, instead, their content changes.
			// 0 degrees is a page fully on the right side.
			// 180 degrees ia a page fully on the left side.
			// _activePage will move and always be between 0 and 180 degrees.
			_previousPage.flipAngle = 180;
			_nextPage.flipAngle = 0;

			// A little offset on static pages to avoid z-fighting.
			_previousPage.y -= 1;
			_nextPage.y -= 1;

			_activePageIndex = 1;

			_pageData = new Vector.<PageVO>();
		}

		public function addPage( page:PageVO ):void {
			_pageData.push( page );
			_positionManager.pushSnapPoint( _positionOffset );
			_positionOffset += SNAP_POINT_SPACING;
		}

		public function update():void {

			// Update input and position.
			_interactionManager.update();
			_positionManager.update();

			// Evaluate snap point section index.
			var ratio:Number = _positionManager.position / SNAP_POINT_SPACING;
			ratio = Math.round( ratio * 1000 ) / 1000; // stick to 3 decimals of accuracy.
			var section:uint = Math.floor( ratio );
			// Edges.
			if( ratio < 0 ) ratio = section = 0;
			else if( ratio > _pageData.length - 2 ) ratio = section = _pageData.length - 2;
			var sectionOffset:Number = ratio - section;

			// Need page swap?
			var pageIndex:uint = section + 1;
			if( _activePageIndex != pageIndex ) {
				_activePageIndex = pageIndex;
				updatePageContent();
			}

			// Calculate active page rotation.
			_activePage.flipAngle = sectionOffset * 180;
		}

		public function updatePageContent():void {

			trace( this, "updating page content ------------------------" );
			trace( "active page index: " + _activePageIndex );



			/*// Id. active vo's.
			var previousPageVO:PageVO = _activePageIndex > 0 ? _pageData[ _activePageIndex - 1 ] : null;
			var activePageVO:PageVO = _pageData[ _activePageIndex ];
			var nextPageVO:PageVO = _activePageIndex < _pageData.length - 1 ? _pageData[ _activePageIndex + 1 ] : null;

			// Update the page object's textures.
			if( previousPageVO ) _previousPage.setImages( previousPageVO.frontTexture, previousPageVO.backTexture );
			if( nextPageVO ) _nextPage.setImages( nextPageVO.frontTexture, nextPageVO.backTexture );
			_activePage.setImages( activePageVO.frontTexture, activePageVO.backTexture );

			// TODO: improve gpu memory usage
			// atm, vo's produce textures when content is set, they need to produce textures on demand and keep them while the page is
			// "near active", that is, when its either a previous page, an active page or a next page, even on these states, they could dispose 1 of their 2 images...
			// or, we could dispose textures on a given distance from the active state... the end idea es to keep gpu texture usage to a low value*/
		}

		public function startInteraction():void {
			_interactionManager.startInteraction();
		}

		public function stopInteraction():void {
			_interactionManager.stopInteraction();
		}

		// ---------------------------------------------------------------------
		// Getters.
		// ---------------------------------------------------------------------

		public function get pageWidth():uint {
			return _pageWidth;
		}

		public function get pageHeight():uint {
			return _pageHeight;
		}
	}
}
