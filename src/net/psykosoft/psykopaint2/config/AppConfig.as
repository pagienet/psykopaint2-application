package net.psykosoft.psykopaint2.config
{

	import com.junkbyte.console.Cc;

	import net.psykosoft.psykopaint2.config.configurators.CommandsConfig;
	import net.psykosoft.psykopaint2.config.configurators.ModelsConfig;
	import net.psykosoft.psykopaint2.config.configurators.NotificationsConfig;
	import net.psykosoft.psykopaint2.config.configurators.ServicesConfig;
	import net.psykosoft.psykopaint2.config.configurators.ViewMediatorsConfig;
	import net.psykosoft.psykopaint2.util.Debugger;
	import net.psykosoft.psykopaint2.view.away3d.base.Away3dRootSprite;

	import org.swiftsuspenders.Injector;

	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.extensions.signalCommandMap.api.ISignalCommandMap;
	import robotlegs.bender.framework.api.IConfig;
	import robotlegs.bender.framework.api.IContext;

	public class AppConfig implements IConfig
	{
		[Inject]
		public var context:IContext;

		[Inject]
		public var commandMap:ISignalCommandMap;

		[Inject]
		public var mediatorMap:IMediatorMap;

		[Inject]
		public var injector:Injector;

		[Inject]
		public var contextView:ContextView;

		public function AppConfig() {
			super();
		}

		public function configure():void {

			// Debug utility.
			if( Settings.ENABLE_DEBUG_CONSOLE ) {
				new Debugger( contextView.view );
				Cc.log( this, "configuring app - " + Settings.NAME + " " + Settings.VERSION );
			}

			// Run dedicated configurators.
			new CommandsConfig( commandMap );
			new NotificationsConfig( injector );
			new ViewMediatorsConfig( mediatorMap );
			new ModelsConfig( injector );
			new ServicesConfig( injector );

			// Start.
			context.lifecycle.afterInitializing( init );

		}

		private function init():void {

			// Initialize 3d display tree.
			// Note: the 2d display tree ( StarlingRootSprite.as ) is initialized in PsykoPaint.as,
			// with the creation of the Starling object, which requires it at that time.
			contextView.view.addChild( new Away3dRootSprite() );

			Cc.log( this, "*** app ready ***" );

		}
	}
}
