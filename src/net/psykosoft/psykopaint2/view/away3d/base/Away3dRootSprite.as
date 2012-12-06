package net.psykosoft.psykopaint2.view.away3d.base
{

	import flash.display.Sprite;

	import net.psykosoft.psykopaint2.view.away3d.wall.Wall3dView;

	public class Away3dRootSprite extends Away3dViewBase
	{
		public function Away3dRootSprite() {
			super();
		}

		override protected function onSetup():void {

			// Initialize 3d display tree.
			addChild( new Wall3dView() );

		}
	}
}
