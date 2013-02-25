package net.psykosoft.psykopaint2.app.view.away3d.base
{

	import net.psykosoft.psykopaint2.app.view.away3d.wall.WallView;

	public class Away3dRootSprite extends Away3dViewBase
	{
		public function Away3dRootSprite() {

			super();

			// Initialize 3d display tree.
			addChild( new WallView() );
		}
	}
}
