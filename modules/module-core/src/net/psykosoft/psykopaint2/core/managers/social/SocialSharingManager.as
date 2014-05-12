package net.psykosoft.psykopaint2.core.managers.social
{

import com.milkmangames.nativeextensions.GVFacebookAppEvent;
import com.milkmangames.nativeextensions.GVFacebookFriend;
import com.milkmangames.nativeextensions.GVHttpMethod;
import com.milkmangames.nativeextensions.GVSocialServiceType;
import com.milkmangames.nativeextensions.GoViral;
import com.milkmangames.nativeextensions.events.GVFacebookEvent;
import com.milkmangames.nativeextensions.events.GVShareEvent;
import com.milkmangames.nativeextensions.events.GVTwitterEvent;

import flash.display.BitmapData;
import flash.events.EventDispatcher;

import net.psykosoft.psykopaint2.core.models.UserConfigModel;

public class SocialSharingManager extends EventDispatcher
	{
		
		public static const FACEBOOK_APP_ID:String="503384473059408";
		
		
		[Inject]
		public var userConfigModel:UserConfigModel;
		
		
		public function SocialSharingManager()
		{
		}
		
		[PostConstruct]
		public function init() : void
		{
			//initialized = true;
			if (!GoViral.isSupported())
			{
				trace("SocialSharingManager: GoViral is not supported on this platform.");
				return;
			}
			
			trace("SocialSharingManager: initializing GoViral..");	
			
			GoViral.create();
			
			trace("SocialSharingManager: GoViral Initialized.");
			
			
			trace("SocialSharingManager:Init facebook...");
			// as of April 2013, Facebook is dropping support for iOS devices with a version below 5.  You can check this with isFacebookSupported():
			trace("SocialSharingManager - instance: " + GoViral.goViral);
//			trace(describeType(GoViral.goViral));
			if (GoViral.goViral.isFacebookSupported())
			{
				GoViral.goViral.initFacebook(FACEBOOK_APP_ID, "");
				trace("SocialSharingManager: initialized.");
			}
			else
			{
				trace("SocialSharingManager: Warning: Facebook not supported on this device.");
			}
				
			
			
			// set up all the event listeners.
			// you only need the ones for the services you want to use.		
			
			
			
			// facebook events
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_CANCELED,onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FAILED,onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_DIALOG_FINISHED,onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_IN,onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_OUT,onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_CANCELED,onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_FAILED,onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_FAILED,onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_REQUEST_RESPONSE, onFacebookEvent);
			GoViral.goViral.addEventListener(GVFacebookEvent.FB_AD_ID_RESPONSE, onFacebookEvent);
			
			// twitter events
			GoViral.goViral.addEventListener(GVTwitterEvent.TW_DIALOG_CANCELED,onTwitterEvent);
			GoViral.goViral.addEventListener(GVTwitterEvent.TW_DIALOG_FAILED,onTwitterEvent);
			GoViral.goViral.addEventListener(GVTwitterEvent.TW_DIALOG_FINISHED,onTwitterEvent);
			
			// Generic sharing events
			GoViral.goViral.addEventListener(GVShareEvent.GENERIC_MESSAGE_SHARED,onShareEvent);
			GoViral.goViral.addEventListener(GVShareEvent.SOCIAL_COMPOSER_CANCELED,onShareEvent);
			GoViral.goViral.addEventListener(GVShareEvent.SOCIAL_COMPOSER_FINISHED,onShareEvent);
			
		}
		
		// facebook
		
		/** Login to facebook */
		public function loginFacebook():void
		{
			trace("Login facebook...");
			if(!GoViral.goViral.isFacebookAuthenticated())
			{			
				// you must set at least one read permission.  if you don't know what to pick, 'basic_info' is fine.
				// PUBLISH PERMISSIONS are NOT permitted by Facebook here anymore.
				GoViral.goViral.authenticateWithFacebook("user_likes,user_photos"); 
			}
			trace("done.");
		}
		
		/** Logout of facebook */
		public function logoutFacebook():void
		{
			trace("logout fb.");
			GoViral.goViral.logoutFacebook();
			trace("done logout.");
		}
		
		/** Post to the facebook wall / feed via dialog */
		public function postFeedFacebook():void
		{
			if (!checkLoggedInFacebook()) return;
			
			trace("posting fb feed...");
			GoViral.goViral.showFacebookFeedDialog(
				"Posting from AIR",
				"This is a caption",
				"This is a message!",
				"This is a description",
				"http://www.milkmangames.com",
				"http://www.milkmangames.com/blog/wp-content/uploads/2012/01/v202.jpg"
			);
			
			trace("done feed post.");
		}
		
		/** Get a list of all your facebook friends */
		public function getFriendsFacebook():void
		{
			if (!checkLoggedInFacebook()) return;
			
			trace("getting friends.(finstn)..");
			GoViral.goViral.requestFacebookFriends({fields:"installed,first_name"});
			trace("sent friend list request.");		
		}
		
		/** Get your own facebook profile */
		public function getMeFacebook():void
		{
			if (!checkLoggedInFacebook()) return;
			
			trace("Getting profile...");
			GoViral.goViral.requestMyFacebookProfile();
			trace("sent profile request.");
		}
		
		/** Get Facebook Access Token */
		public function getFacebookToken():void
		{
			trace("Retrieving access token...");
			var accessToken:String=GoViral.goViral.getFbAccessToken();
			var accessExpiry:Number=GoViral.goViral.getFbAccessExpiry();
			trace("expiry:"+accessExpiry+",Token is:"+accessToken);
		}
		
		
		
		/** Make a post graph request */
		public function postGraphFacebook():void
		{
			if (!checkLoggedInFacebook()) return;
			
			trace("Graph posting...");
			var params:Object={};
			params.name="Name Test";
			params.caption="Caption Test";
			params.link="http://www.google.com";
			params.picture="http://www.milkmangames.com/blog/wp-content/uploads/2012/01/v202.jpg";
			params.actions=new Array();
			params.actions.push({name:"Link NOW!",link:"http://www.google.com"});
			
			// notice the "publish_actions", a required publish permission to write to the graph!
			GoViral.goViral.facebookGraphRequest("me/feed",GVHttpMethod.POST,params,"publish_actions");
			trace("post complete.");
		}
		
		/** Show a facebook friend invite dialog */
		public function inviteFriendsFacebook():void
		{
			if (!checkLoggedInFacebook()) return;
			
			trace("inviting friends.");
			GoViral.goViral.showFacebookRequestDialog("This is just a test","My Title","somedata");
			trace("sent friend invite.");
		}
		
		/** Post a photo to the facebook stream */
		public function postPhotoFacebook( bitmapData:BitmapData ):void
		{
			if (!checkLoggedInFacebook()) return;
			
			trace("post facebook pic...");
			
			GoViral.goViral.facebookPostPhoto("posted from mobile sdk",bitmapData);
			
			trace("posted fb pic.");
			
		}	
		
		/** Check you're logged in to facebook before doing anything else. */
		public function checkLoggedInFacebook():Boolean
		{
			// make sure you're logged in first
			if (!GoViral.goViral.isFacebookAuthenticated())
			{
				trace("Not logged in!");
				return false;
			}
			return true;
		}
		
		/** Show a Facebook page by ID (request like) */
		private function likePageFacebook():void
		{
			trace("Sending to Page...");
			// the page ID can be determined from the page URL;
			// for instance Milkman Games' Facebook page URL is 
			// https://www.facebook.com/pages/Milkman-Games-LLC/215322531827565,
			// so the ID is 215322531827565.
			GoViral.goViral.presentFacebookPageOrProfile("215322531827565");
			trace("Sent to FB Page.");
		}
		
		//
		// Facebook Games Tracking Features
		//
		
		/** Submit a new high score to Facebook */
		private function submitFacebookScore():void
		{
			// make sure you're logged in first!
			if (!checkLoggedInFacebook()) return;
			
			trace("Sending facebook high score...");
			GoViral.goViral.postFacebookHighScore(2000);
			trace("Waiting for high score response...");
		}
		
		/** Submit a new achievement to Facebook */
		private function submitFacebookAchievement():void
		{
			// make sure you're logged in first!
			if (!checkLoggedInFacebook()) return;
			
			// for this to work, you need to create the achievement HTML on your own website and register it
			// with facebook, refer to https://developers.facebook.com/docs/games/achievements 
			trace("Sending facebook achievement...");
			GoViral.goViral.postFacebookAchievement("http://www.friendsmash.com/opengraph/achievement_50.html");
			trace("Waiting for achievement response...");		
		}
		
		//
		// Facebook Ad Tracking Features
		//
		
		/** trace Facebook Ad Events */
		private function logFacebookEvents():void
		{
			// example of logging a level achieved event
			var levelAppEvent:GVFacebookAppEvent=new GVFacebookAppEvent(GVFacebookAppEvent.EVENT_NAME_ACHIEVED_LEVEL);
			levelAppEvent.setParameter(GVFacebookAppEvent.EVENT_PARAM_LEVEL, "32");
			trace("Sending example level achieved app event...");
			GoViral.goViral.logFacebookAppEvent(levelAppEvent);
			
			// example of logging a spent credits event
			var creditsEvent:GVFacebookAppEvent=new GVFacebookAppEvent(GVFacebookAppEvent.EVENT_NAME_SPENT_CREDITS);
			creditsEvent.setValueToSum(15);
			creditsEvent.setParameter(GVFacebookAppEvent.EVENT_PARAM_CONTENT_TYPE, "music");
			creditsEvent.setParameter(GVFacebookAppEvent.EVENT_PARAM_CONTENT_ID, "somesong");
			trace("Sending example spend credits app event...");
			GoViral.goViral.logFacebookAppEvent(creditsEvent);
			
			// example of sending a custom event
			var customEvent:GVFacebookAppEvent=new GVFacebookAppEvent("customEventName");
			trace("Sending example custom app event...");
			GoViral.goViral.logFacebookAppEvent(customEvent);
			
			trace("Sent 3 test app events.");
		}
		
		/** Request a facebook custom audience advertising ID */
		private function requestFacebookAdId():void
		{
			trace("Requesting custom fb ad id...");
			GoViral.goViral.requestFacebookMobileAdID();
			trace("Waiting for fb ad id response...");
		}
		
		//
		// Email
		//
		
		/** Send Test Email */
		public function sendTestEmail():void
		{
			if (GoViral.goViral.isEmailAvailable())
			{
				trace("Opening email composer...");
				GoViral.goViral.showEmailComposer("This is a subject!","who@where.com,john@doe.com","This is the body of the message.",false);
				trace("Composer opened.");
			}
			else
			{
				trace("Email is not set up on this device.");
			}
		}
		
		/** Send Email with attached image */
		public function sendImageEmail( bitmapData:BitmapData):void
		{
			trace("Email composer w/image...");
			if (GoViral.goViral.isEmailAvailable())
			{
				GoViral.goViral.showEmailComposerWithBitmap("This has an attachment!","john@doe.com","I think youll like my pic",false,bitmapData);
			}
			else
			{
				trace("Email is not available on this device.");
				return;
			}
			trace("Mail composer opened.");
		}
		
		//
		// Android Generic Sharing
		//
		
		/** Send Generic Message */
		public function sendGenericMessage():void
		{
			if (!GoViral.goViral.isGenericShareAvailable())
			{
				trace("Generic share doesn't work on this platform.");
				return;
			}
			
			trace("Sending generic share intent...");
			GoViral.goViral.shareGenericMessage("The Subject","The message!",false);
			trace("done send share intent.");
		}
		
		/** Send Generic Message */
		public function sendGenericMessageWithImage( bitmapData:BitmapData):void
		{
			if (!GoViral.goViral.isGenericShareAvailable())
			{
				trace("Generic share doesn't work on this platform.");
				return;
			}
			
			trace("Sending generic share img intent...");
			GoViral.goViral.shareGenericMessageWithImage("The Subject","The message!",false,bitmapData);
			trace("done send share img intent.");
		}
		
		/** iOS 6 only sharing */
		public function shareSocialComposer(bitmapData:BitmapData):void
		{
			// note that SINA_WEIBO and TWITTER are also available...
			if (GoViral.goViral.isSocialServiceAvailable(GVSocialServiceType.FACEBOOK))
			{
				trace("launch ios 6 social composer...");
				GoViral.goViral.displaySocialComposerView(GVSocialServiceType.FACEBOOK,"Social Composer message",bitmapData,"http://www.psykpaint.com");
			}
			else
			{
				trace("social composer service not available on device.");
			}
		}
		//
		// twitter
		//
		
		/** Post a status message to Twitter */
		public function postTwitter():void
		{
			trace("posting to twitter.");
			
			// You should check GoViral.goViral.isTweetSheetAvailable() to determine
			// if you're able to use the built-in iOS Twitter UI.  If the phone supports it
			// (because its running iOS 5.0+, or an Android device with Twitter) it will return true and you can call
			// 'showTweetSheet'. 
			
			if (GoViral.goViral.isTweetSheetAvailable())
			{
				GoViral.goViral.showTweetSheet("This is a native twitter post!");
			}
			else
			{
				trace("Twitter not available on this device.");
				return;
			}
		}
		
		/** Post a picture to twitter */
		public function postTwitterPic( bitmapData:BitmapData ):void
		{
			trace("post twitter pic.");
			
			// You should check GoViral.goViral.isTweetSheetAvailable() to determine
			// if you're able to use the built-in iOS Twitter UI.  If the phone supports it
			// (because its running iOS 5.0+, or an Android device with Twitter) it will return true and you can call
			// 'showTweetSheetWithImage'.
			if (GoViral.goViral.isTweetSheetAvailable())
			{
				GoViral.goViral.showTweetSheetWithImage("This is a twitter post with a pic!",bitmapData);
			}
			else
			{
				trace("Twitter not available on this device.");
				return;
			}
			trace("done show tweet.");
		}
		
		
		//
		// Events
		//
		
		/** Handle Facebook Event */
		private function onFacebookEvent(e:GVFacebookEvent):void
		{
			switch(e.type)
			{
				case GVFacebookEvent.FB_DIALOG_CANCELED:
					trace("Facebook dialog '"+e.dialogType+"' canceled.");
					break;
				case GVFacebookEvent.FB_DIALOG_FAILED:
					trace("dialog err:"+e.errorMessage);
					break;
				case GVFacebookEvent.FB_DIALOG_FINISHED:
					trace("fin dialog '"+e.dialogType+"'="+e.jsonData);
					break;
				case GVFacebookEvent.FB_LOGGED_IN:
					trace("Logged in to facebook!");
					break;
				case GVFacebookEvent.FB_LOGGED_OUT:
					trace("Logged out of facebook.");
					break;
				case GVFacebookEvent.FB_LOGIN_CANCELED:
					trace("Canceled facebook login.");
					break;
				case GVFacebookEvent.FB_LOGIN_FAILED:
					trace("Login failed:"+e.errorMessage+"(notify? "+e.shouldNotifyFacebookUser+" "+e.facebookUserErrorMessage+")");
					break;
				case GVFacebookEvent.FB_REQUEST_FAILED:
					trace("Facebook '"+e.graphPath+"' failed:"+e.errorMessage);
					break;
				case GVFacebookEvent.FB_REQUEST_RESPONSE:
					// handle a friend list- there will be only 1 item in it if 
					// this was a 'my profile' request.				
					if (e.friends!=null)
					{					
						// 'me' was a request for own profile.
						if (e.graphPath=="me")
						{
							var myProfile:GVFacebookFriend=e.friends[0];
							trace("Me: name='"+myProfile.name+"',gender='"+myProfile.gender+"',location='"+myProfile.locationName+"',bio='"+myProfile.bio+"'");
							return;
						}
						
						// 'me/friends' was a friends request.
						if (e.graphPath=="me/friends")
						{					
							var allFriends:String="";
							for each(var friend:GVFacebookFriend in e.friends)
							{
								allFriends+=","+friend.name;
							}
							
							trace(e.graphPath+"= ("+e.friends.length+")="+allFriends+",json="+e.jsonData);
						}
						else
						{
							trace(e.graphPath+" res="+e.jsonData);	
						}
					}
					else
					{
						trace(e.graphPath+" res="+e.jsonData);
					}
					break;
				case GVFacebookEvent.FB_AD_ID_RESPONSE:
					trace("Facebook Ad ID Response:"+e.facebookMobileAdId);
					break;
			}

			dispatchEvent(e);
		}
		
		/** Handle Twitter Event */
		private function onTwitterEvent(e:GVTwitterEvent):void
		{
			switch(e.type)
			{
				case GVTwitterEvent.TW_DIALOG_CANCELED:
					trace("Twitter canceled.");
					break;
				case GVTwitterEvent.TW_DIALOG_FAILED:
					trace("Twitter failed: "+e.errorMessage);
					break;
				case GVTwitterEvent.TW_DIALOG_FINISHED:
					trace("Twitter finished.");
					break;
			}
		}
		
		
		
		/** Handle Generic Share Event */
		private function onShareEvent(e:GVShareEvent):void
		{
			trace("share finished.");
		}
		
		
	}

}