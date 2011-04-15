/*
 * Copyright (c) 2009 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.base
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.getDefinitionByName;
	
	import org.robotlegs.core.IMediator;
	
	/**
	 * An abstract <code>IMediator</code> implementation
	 */
	public class MediatorBase implements IMediator
	{
		/**
		 * Flex framework work-around part #1
		 */
		protected static var UIComponentClass:Class;
		
		/**
		 * Mobile framework work-around part #1
		 */
		protected static var ViewClass:Class
		
		/**
		 * Flex framework work-around part #2
		 */
		protected static const flexAvailable:Boolean = checkFlex();

		/**
		 * Flex framework work-around part #2
		 */
		protected static const mobileAvailable:Boolean = checkMobile();
		
		/**
		 * Internal
		 *
		 * <p>This Mediator's View Component - used by the RobotLegs MVCS framework internally.
		 * You should declare a dependency on a concrete view component in your
		 * implementation instead of working with this property</p>
		 */
		protected var viewComponent:Object;
		
		/**
		 * Internal
		 *
		 * <p>In the case of deffered instantiation, onRemove might get called before
		 * onCreationComplete has fired. This here Bool helps us track that scenario.</p>
		 */
		protected var removed:Boolean;
		
		//---------------------------------------------------------------------
		//  Constructor
		//---------------------------------------------------------------------
		
		/**
		 * Creates a new <code>Mediator</code> object
		 */
		public function MediatorBase()
		{
		}
		
		//---------------------------------------------------------------------
		//  API
		//---------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function preRegister():void
		{
			removed = false;
			
			if (flexAvailable && (viewComponent is UIComponentClass))
			{
				if (mobileAvailable && (viewComponent is ViewClass))	//mediating a mobile View
				{
					if (!viewComponent['isActive'])
					{
						//needs to cleanup on onRemove
						IEventDispatcher(viewComponent).addEventListener('viewActivate', onViewActivate);
					} else
					{
						//deactivate needs to cleanup onRemove
						IEventDispatcher(viewComponent).addEventListener('viewDeactivate', onViewDeactivate);
					}
					
					IEventDispatcher(viewComponent).addEventListener('deactivate', onDeactivate);
					IEventDispatcher(viewComponent).addEventListener('removing', onRemoving);
				}
				else if (!viewComponent['initialized'])
				{
					IEventDispatcher(viewComponent).addEventListener('creationComplete', onCreationComplete, false, 0, true);
				}				
				//if the mobile view is active or the component is initialized 
				if (viewComponent['initialized'] || viewComponent['isActive'])
				{
					onRegister();	
				}
				
			}
			else
			{
				onRegister();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function onRegister():void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function preRemove():void
		{
			removed = true;
			onRemove();
		}
		
		/**
		 * @inheritDoc
		 */
		public function onRemove():void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function getViewComponent():Object
		{
			return viewComponent;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setViewComponent(viewComponent:Object):void
		{
			this.viewComponent = viewComponent;
		}
		
		//---------------------------------------------------------------------
		//  Internal
		//---------------------------------------------------------------------
		
		/**
		 * Flex framework work-around part #3
		 *
		 * <p>Checks for availability of the Flex framework by trying to get the class for UIComponent.</p>
		 */
		protected static function checkFlex():Boolean
		{
			try
			{
				UIComponentClass = getDefinitionByName('mx.core::UIComponent') as Class;
			}
			catch (error:Error)
			{
				// do nothing
			}
			return UIComponentClass != null;
		}
		
		/**
		 * Mobile framework work-around part #1
		 *
		 * <p>Checks for availability of the Mobile framework by trying to get the class for View.</p>
		 */
		protected static function checkMobile():Boolean
		{
			try
			{
				ViewClass = getDefinitionByName('spark.components::View') as Class;
			}
			catch (error:Error)
			{
				// do nothing
			}
			return ViewClass != null;
		}
		
		/**
		 * Flex framework work-around part #4
		 *
		 * <p><code>FlexEvent.CREATION_COMPLETE</code> handler for this Mediator's View Component</p>
		 *
		 * @param e The Flex <code>FlexEvent</code> event
		 */
		protected function onCreationComplete(e:Event):void
		{
			IEventDispatcher(e.target).removeEventListener('creationComplete', onCreationComplete);
			
			if (!removed)
				onRegister();
		}
		
		public function onActivate(event:Event):void
		{
			trace(this, 'app activate');
			IEventDispatcher(event.target).removeEventListener('activate', onActivate, false);
			
			preRegister();
		}
		
		public function onDeactivate(event:Event):void
		{
			trace(this, 'app deactivate');
			IEventDispatcher(event.target).addEventListener('activate', onActivate);
			IEventDispatcher(event.target).removeEventListener('deactivate', onDeactivate);
		}
		
		public function onViewActivate(event:Event):void
		{
			trace(this, 'view activate');
			IEventDispatcher(event.target).removeEventListener('viewActivate', onViewActivate);

			if (!removed)
				onRegister();
		}
		
		public function onViewDeactivate(event:Event):void
		{
			trace(this, 'view deactivate');
			IEventDispatcher(event.target).removeEventListener('viewDeactivate', onViewDeactivate);
			//need to dispose of other handlers
			preRemove();
		}
		
		public function onRemoving(event:Event):void
		{
			trace(this, 'removing all mobile handlers');
			removeMobileHandlers(IEventDispatcher(event.target));
		}
		
		public function removeMobileHandlers(dispatcher:IEventDispatcher):void
		{
			IEventDispatcher(dispatcher).removeEventListener('activate', onActivate);
			IEventDispatcher(dispatcher).removeEventListener('deactivate', onDeactivate);
			IEventDispatcher(dispatcher).removeEventListener('viewActivate', onViewActivate);
			IEventDispatcher(dispatcher).removeEventListener('viewDeactivate', onViewDeactivate);
			IEventDispatcher(dispatcher).removeEventListener('removing', onRemoving);
		}
	
	}
}
