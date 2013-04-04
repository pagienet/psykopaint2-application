package net.psykosoft.psykopaint2.app.view.rootsprites
{

	import net.psykosoft.psykopaint2.app.view.base.*;

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.app.view.home.HomeView;

	public class Away3dRootSprite extends Away3dViewBase
	{
		public function Away3dRootSprite() {

			super();

			Cc.log( this );

			// Initialize 3d display tree.
			addChild( new HomeView() );
		}
	}
}
